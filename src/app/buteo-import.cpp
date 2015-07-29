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

bool ButeoImport::isOutDated() const
{
    // check settings
    QSettings settings;
    if (settings.value(SETTINGS_BUTEO_KEY, false).toBool()) {
        qDebug() << "Application has already been migrated.";
        return false;
    }

    // check whitch account already has a source
    Accounts::Manager mgr;
    Accounts::AccountIdList accountIds = mgr.accountList("contacts");
    qDebug() << "Accounts" << accountIds;

    QMap<QString, quint32> srcs = sources();
    for(QMap<QString, uint>::const_iterator i = srcs.begin();
        i != srcs.end();
        i++) {
        // remove ids that already has a source from the idList
        if (i.value() > 0) {
            accountIds.removeOne(i.value());
        }
    }

    qDebug() << accountIds.size() << "accounts, without sources";
    return (!accountIds.isEmpty());
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

    QDBusReply<bool> result = m_buteoInterface->call("removeProfile", profileId);
    if (result.error().isValid()) {
        qWarning() << "Fail to remove profile" << profileId << result.error();
        return false;
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
    qDebug() << "Will remove old sources" << m_removeOldSources << m_sourceToAccount.size();

    // remove old sources
    if (m_removeOldSources) {
        QStringList sources;
        for(QMap<QString, uint>::const_iterator i = m_sourceToAccount.begin();
            i != m_sourceToAccount.end();
            i++) {
            if (i.value() == 0) {
                qDebug() << "Remove source" << i.key();
                sources << i.key();
            }
        }
        removeSources(sources);
    }

    // update settings key
    QSettings settings;
    settings.setValue(SETTINGS_BUTEO_KEY, true);
    settings.sync();

    // all acconts synced
    m_importLock.unlock();
    if (m_importLoop) {
        m_importLoop->quit();
    }

    emit updated();
    emit busyChanged();
    return true;
}

void ButeoImport::error(const QString &message)
{
    m_lastError = message;
    emit updateError(message);
}

bool ButeoImport::update(bool removeOldSources)
{
    // check settings key
    QSettings settings;
    if (settings.value(SETTINGS_BUTEO_KEY).toBool()) {
        // already imported
        qDebug() << "Application has already been migrated.";
        return false;
    }

    if (!m_importLock.tryLock()) {
        qWarning() << "Fail to lock import mutex";
        return false;
    }

    emit busyChanged();

    m_removeOldSources = removeOldSources;
    m_accountToProfiles.clear();
    m_sourceToAccount.clear();

    // check whitch account already has a source
    Accounts::Manager mgr;
    Accounts::AccountIdList accountIds = mgr.accountList("contacts");

    m_sourceToAccount = sources();
    for(QMap<QString, uint>::const_iterator i = m_sourceToAccount.begin();
        i != m_sourceToAccount.end();
        i++) {
        // remove ids that already has a source from the idList
        if (i.value() > 0) {
            accountIds.removeOne(i.value());
        }
    }

    qDebug() << "Will create buteo profile for" << accountIds << "accounts";
    // now accountIds only contains ids for accounts that does not contain sources
    // lets create buteo-config for these accounts
    if (accountIds.isEmpty()) {
        // if there is not account to update just commit the update
        bool result = commit();
        return result;
    }

    if (prepareButeo()) {
        m_accountToProfiles = createProfileForAccounts(accountIds);
        if (m_accountToProfiles.isEmpty()) {
            // fail to create profiles
            m_importLock.unlock();
            emit busyChanged();
            error("Fail to create profiles");
            return false;
        }
    } else {
        // fail to connect with buteo
        m_importLock.unlock();
        emit busyChanged();
        error("Fail to connect with sync service");
        return false;
    }

    return true;
}

QString ButeoImport::lastError() const
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
        error(QString("Fail to sync profile %1").arg(profileName));
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
