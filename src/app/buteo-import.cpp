/*
 * Copyright (C) 2015 Canonical, Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "buteo-import.h"

#include <Accounts/Manager>
#include <Accounts/Account>
#include <Accounts/AccountService>

#include <QtCore/QDebug>

#include <QtDBus/QDBusReply>

#include <QtContacts/QContactManager>
#include <QtContacts/QContact>
#include <QtContacts/QContactGuid>
#include <QtContacts/QContactExtendedDetail>
#include <QtContacts/QContactDetailFilter>

#define BUTEO_DBUS_SERVICE_NAME   "com.meego.msyncd"
#define BUTEO_DBUS_OBJECT_PATH    "/synchronizer"
#define BUTEO_DBUS_INTERFACE      "com.meego.msyncd"
#define SETTINGS_BUTEO_KEY        "Buteo/migration_complete"

using namespace QtContacts;

ButeoImport::ButeoImport(QObject *parent)
    : QObject(parent),
      m_importLoop(0)
{
    connect(this, SIGNAL(updated()), SIGNAL(outDatedChanged()));
    connect(this, SIGNAL(updateError(QString)), SIGNAL(outDatedChanged()));
}

ButeoImport::~ButeoImport()
{
}

bool ButeoImport::loadAccounts(QList<quint32> &accountsToUpdate)
{
    if (!prepareButeo()) {
        qWarning() << "Fail to connect with buteo service";
        return false;
    }

    // check whitch account already has a source
    Accounts::Manager mgr;
    accountsToUpdate = mgr.accountList("contacts");

    qDebug() << "Accounts" << accountsToUpdate;

    // check which account does not have a source
    QMap<QString, quint32> srcs = sources();
    for(QMap<QString, uint>::const_iterator i = srcs.begin();
        i != srcs.end();
        i++) {
        qDebug() << "Source" << i.key() << "Account" << i.value();
        // remove ids that already has a source from the idList
        if (i.value() > 0) {
            accountsToUpdate.removeOne(i.value());
        }
    }

    // check which account does not have a sync profile
    Q_FOREACH(const quint32 &accountId, QList<quint32>(accountsToUpdate)) {
        QDBusReply<QStringList> reply = m_buteoInterface->call("syncProfilesByKey",
                                                               "accountid",
                                                               QString::number(accountId));
        if (!reply.value().isEmpty()) {
            qDebug() << "Account has sync profile" << accountId;
            accountsToUpdate.removeOne(accountId);
        }
    }

    return true;
}

bool ButeoImport::enableContactsService(quint32 accountId)
{
    Accounts::Manager mgr;
    Accounts::Account *account = mgr.account(accountId);

    if (account) {
        Q_FOREACH(Accounts::Service service, account->services()) {
            qDebug() << "Enabling service" << service.displayName();
            if (service.serviceType() == "contacts") {
                account->selectService(service);
                account->setEnabled(true);
                account->syncAndBlock();
            }
        }
        delete account;
        return true;
    } else {
        return false;
    }
}

bool ButeoImport::isOutDated()
{
    // check settings
    QSettings settings;
    if (settings.value(SETTINGS_BUTEO_KEY, false).toBool()) {
        qDebug() << "Application has already been migrated.";
        return false;
    }

    QList<quint32> accountsToUpdate;
    if (loadAccounts(accountsToUpdate)) {
        if (accountsToUpdate.isEmpty()) {
            qDebug() << "No account to update";
            settings.setValue(SETTINGS_BUTEO_KEY, true);
            settings.sync();
            return false;
        }
        qDebug() << accountsToUpdate.size() << "accounts, to update";
    } else {
        qWarning() << "Fail to load online accounts";
    }
    // alwasys retur true if loadAccounts fail
    return true;
}

bool ButeoImport::busy()
{
    if (m_importLock.tryLock(100)) {
        m_importLock.unlock();
        return false;
    }
    return true;
}

QMap<QString, quint32> ButeoImport::sources() const
{
    QMap<QString, quint32> result;
    QScopedPointer<QContactManager> manager(new QContactManager("galera"));
    QContactDetailFilter sourceFilter;
    sourceFilter.setDetailType(QContactDetail::TypeType, QContactType::FieldType);
    sourceFilter.setValue( QContactType::TypeGroup);
    Q_FOREACH(const QContact &c, manager->contacts(sourceFilter)) {
        uint accountId = 0;
        if (c.id().toString().endsWith("source@system-address-book")) {
            continue;
        }

        Q_FOREACH(const QContactExtendedDetail &xDet, c.details<QContactExtendedDetail>()) {
            if (xDet.name() == "ACCOUNT-ID") {
                if (xDet.data().isValid()) {
                    accountId = xDet.data().toString().toUInt();
                }
                break;
            }
        }

        result.insert(c.id().toString(), accountId);
    }

    return result;
}

bool ButeoImport::prepareButeo()
{
    if (!m_buteoInterface.isNull()) {
        return true;
    }

    m_buteoInterface.reset(new QDBusInterface(BUTEO_DBUS_SERVICE_NAME,
                                              BUTEO_DBUS_OBJECT_PATH,
                                              BUTEO_DBUS_INTERFACE));

    if (!m_buteoInterface->isValid()) {
        m_buteoInterface.reset();
        qWarning() << "Fail to connect with syncfw";
        return false;
    }

    connect(m_buteoInterface.data(),
            SIGNAL(signalProfileChanged(QString, int, QString)),
            SLOT(onProfileChanged(QString, int, QString)));
    connect(m_buteoInterface.data(),
            SIGNAL(syncStatus(QString,int,QString,int)),
            SLOT(onSyncStatusChanged(QString,int,QString,int)));

    return true;
}

QMap<quint32, QString> ButeoImport::createProfileForAccounts(QList<quint32> ids)
{
    QMap<quint32, QString> map;
    if (m_buteoInterface.isNull()) {
        qWarning() << "Buteo interface is not valid";
        return map;
    }

    Q_FOREACH(quint32 id, ids) {
        if (!enableContactsService(id)) {
            qWarning() << "Fail to enable contacts service for acccount:" << id;
            continue;
        }

        QDBusReply<QString> result = m_buteoInterface->call("createSyncProfileForAccount", id);
        if (result.error().isValid()) {
            qWarning() << "Fail to create profile for account" << id << result.error();
        } else if (!result.value().isEmpty()) {
            qDebug() << "Profile created" << result.value() << id;
            map.insert(id, result.value());
        } else {
            qWarning() << "Fail to create profile for account" << id;
        }
    }
    return map;
}

bool ButeoImport::removeProfile(const QString &profileId)
{
    if (m_buteoInterface.isNull()) {
        qWarning() << "Buteo interface is not valid";
        return false;
    }

    // check for account
    quint32 accountId = m_accountToProfiles.key(profileId, 0);
    if (accountId == 0) {
        qWarning() << "Fail to find account related with profile" << profileId;
        return false;
    }

    // check for source
    QMap<QString, quint32> listOfSources = sources();
    QString sourceName = listOfSources.key(accountId, "");

    // remove source
    if (!sourceName.isEmpty()) {
        QScopedPointer<QContactManager> manager(new QContactManager("galera"));
        QContactId sourceId = QContactId::fromString(QString("qtcontacts:galera::%1").arg(sourceName));
        if (!manager->removeContact(sourceId)) {
            qWarning() << "Fail to remove contact source:" << sourceName;
            return false;
        }
    } else {
        qDebug() << "No source was created for account" << accountId;
    }

    // remove profile
    QDBusReply<bool> result = m_buteoInterface->call("removeProfile", profileId);
    if (result.error().isValid()) {
        qWarning() << "Fail to remove profile" << profileId << result.error();
        return false;
    } else {
        qDebug() << "Recent created profile removed" << profileId;
    }

    return true;
}

bool ButeoImport::removeSources(const QStringList &sources)
{
    if (sources.isEmpty()) {
        return true;
    }

    bool result = true;
    QScopedPointer<QContactManager> manager(new QContactManager("galera"));
    Q_FOREACH(const QString &source, sources) {
        if (!manager->removeContact(QContactId::fromString(source))) {
            qWarning() << "Fail to remove source" << source;
            result = false;
        }
    }

    return result;
}

bool ButeoImport::commit()
{
    Q_ASSERT(m_accountToProfiles.isEmpty());

    // remove old sources
    if (m_removeOldSources) {
        QStringList oldSources;
        QMap<QString, quint32> srcs = sources();

        for(QMap<QString, uint>::const_iterator i = srcs.begin();
            i != srcs.end();
            i++) {
            if (i.value() == 0) {
                qDebug() << "Remove source" << i.key();
                oldSources << i.key();
            }
        }
        removeSources(oldSources);
    }

    // all acconts synced
    m_importLock.unlock();
    if (m_importLoop) {
        m_importLoop->quit();
    }

    // update settings key
    QSettings settings;
    settings.setValue(SETTINGS_BUTEO_KEY, true);
    settings.sync();

    // disable address-book-service safe-mode
    QDBusMessage setSafeMode = QDBusMessage::createMethodCall("com.canonical.pim",
                                                              "/com/canonical/pim/AddressBook",
                                                              "org.freedesktop.DBus.Properties",
                                                              "Set");
    QList<QVariant> args;
    args << "com.canonical.pim.AddressBook"
         << "safeMode"
         << false;
    setSafeMode.setArguments(args);
    QDBusConnection::sessionBus().call(setSafeMode);

    emit updated();
    emit busyChanged();
    return true;
}

void ButeoImport::error(ButeoImport::ImportError errorCode)
{
    m_lastError = errorCode;
    emit updateError(errorCode);
}

bool ButeoImport::update(bool removeOldSources)
{
    // check settings key
    QSettings settings;
    if (settings.value(SETTINGS_BUTEO_KEY).toBool()) {
        // already imported
        qDebug() << "Application has already been migrated.";
        error(ButeoImport::ApplicationAreadyUpdated);
        return false;
    }

    if (!m_importLock.tryLock()) {
        qWarning() << "Fail to lock import mutex";
        error(ButeoImport::InernalError);
        return false;
    }

    if (m_buteoInterface.isNull()) {
        qWarning() << "Fail to connect with contact sync service.";
        error(ButeoImport::FailToConnectWithButeo);
        return false;
    }

    emit busyChanged();

    m_removeOldSources = removeOldSources;
    m_accountToProfiles.clear();

    QList<quint32> accountsToUpdate;
    if (!loadAccounts(accountsToUpdate)) {
        // fail to load accounts information
        m_importLock.unlock();
        emit busyChanged();

        qWarning() << "Fail to load accounts information";
        error(ButeoImport::OnlineAccountNotFound);
        return false;
    }

    qDebug() << "Will create buteo profile for" << accountsToUpdate << "accounts";
    if (accountsToUpdate.isEmpty()) {
        // if there is not account to update just commit the update
        bool result = commit();
        return result;
    }

    m_accountToProfiles = createProfileForAccounts(accountsToUpdate);
    if (m_accountToProfiles.isEmpty()) {
        // fail to create profiles
        m_importLock.unlock();
        emit busyChanged();
        qWarning() << "Fail to create profiles";
        error(ButeoImport::FailToCreateButeoProfiles);
        return false;
    }

    return true;
}

ButeoImport::ImportError ButeoImport::lastError() const
{
    return m_lastError;
}

void ButeoImport::wait()
{
    m_importLoop = 0;
    while(!m_importLock.tryLock(1000)) {
        qDebug() << "Wait import to finish";
        m_importLoop = new QEventLoop;
        m_importLoop->exec();
    }
    qDebug() << "Import finished";
    delete m_importLoop;
    m_importLock.unlock();
}

void ButeoImport::onProfileChanged(const QString &profileName, int changeType, const QString &profileAsXml)
{
    Q_UNUSED(profileAsXml);
    /*
    *      0 (ADDITION): Profile was added.
    *      1 (MODIFICATION): Profile was modified.
    *      2 (DELETION): Profile was deleted.
    */
    switch(changeType) {
    case 0:
        // profile created sync should start soon
        qDebug() << "Profile created" << profileName;
        break;
    case 1:
        break;
    case 2:
        {
            quint32 accountId = m_accountToProfiles.key(profileName, 0);
            if (accountId > 0) {
                qDebug() << "Profile removed" << accountId << profileName;
                m_accountToProfiles.remove(accountId);

                if (m_accountToProfiles.isEmpty()) {
                    // all acconts removed
                    m_importLock.unlock();
                    if (m_importLoop) {
                        m_importLoop->quit();
                    }
                }
            }
            break;
        }
    }
}

void ButeoImport::onSyncStatusChanged(const QString &profileName,
                                      int status,
                                      const QString &message,
                                      int moreDetails)
{
    Q_UNUSED(message);
    Q_UNUSED(moreDetails);

    qDebug() << "SyncStatus" << profileName << status << message << moreDetails;
    if (!m_accountToProfiles.values().contains(profileName)) {
        qDebug() << "Profile not found" << profileName;
        return;
    }

    /*
    *      0 (QUEUED): Sync request has been queued or was already in the
    *          queue when sync start was requested.
    *      1 (STARTED): Sync session has been started.
    *      2 (PROGRESS): Sync session is progressing.
    *      3 (ERROR): Sync session has encountered an error and has been stopped,
    *          or the session could not be started at all.
    *      4 (DONE): Sync session was successfully completed.
    *      5 (ABORTED): Sync session was aborted.
    */
    switch(status) {
    case 5:
        qWarning() << "Sync aborted for profile" << profileName;
    case 3:
        qWarning() << "Fail to sync profile" << profileName;
        error(ButeoImport::SyncError);
        removeProfile(profileName);
        break;
    case 4:
        {
            quint32 accountId = m_accountToProfiles.key(profileName, 0);
            if (accountId > 0) {
                qDebug() << "Sync finished for profile:" << accountId << profileName;
                m_accountToProfiles.remove(accountId);
                if (m_accountToProfiles.isEmpty()) {
                    commit();
                }
            }
            break;
        }
    }
}
