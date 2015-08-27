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

#include <QtCore/QObject>
#include <QtCore/QMap>
#include <QtCore/QMutex>
#include <QtCore/QEventLoop>
#include <QtDBus/QDBusInterface>

class ButeoImport : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool outDated READ isOutDated NOTIFY outDatedChanged)
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
    Q_PROPERTY(ButeoImport::ImportError lastError READ lastError NOTIFY updateError)
    Q_ENUMS(ImportError)

public:
    enum ImportError {
        ApplicationAreadyUpdated = 0,
        FailToConnectWithButeo,
        FailToCreateButeoProfiles,
        InernalError,
        OnlineAccountNotFound,
        SyncAlreadyRunning,
        SyncError
    };
    ButeoImport(QObject *parent = 0);
    ~ButeoImport();

    Q_INVOKABLE bool update(bool removeOldSources = true);
    ImportError lastError() const;
    bool isOutDated();
    bool busy();

    void wait();

Q_SIGNALS:
    void updated();
    void updateError(const QString &accountName, ButeoImport::ImportError errorCode);
    void busyChanged();
    void outDatedChanged();

private Q_SLOTS:
    void onBusyChanged();
    void onProfileChanged(const QString &profileName, int changeType, const QString &profileAsXml);
    void onSyncStatusChanged(const QString &aProfileName, int aStatus, const QString &aMessage, int aMoreDetails);

private:
    QScopedPointer<QDBusInterface> m_buteoInterface;
    QMap<quint32, QString> m_accountToProfiles;
    QMutex m_importLock;
    bool m_removeOldSources;
    ImportError m_lastError;
    QEventLoop *m_importLoop;

    QMap<QString, quint32> sources() const;
    QMap<quint32, QString> createProfileForAccounts(QList<quint32> ids);
    bool prepareButeo();
    bool createAccounts(QList<quint32> ids);
    bool removeProfile(const QString &profileId);
    bool removeSources(const QStringList &sources);
    bool commit();
    bool restoreSession(const QStringList &activeSyncs);
    void error(const QString &accountName, ImportError errorCode);
    bool loadAccounts(QList<quint32> &accountsToUpdate, QList<quint32> &newAccounts);
    bool enableContactsService(quint32 accountId);
    QString accountName(quint32 accountId);
    QStringList runningSyncs() const;
    QString profileName(const QString &xml) const;
    QString profileName(quint32 accountId) const;
    bool startSync(const QString &profile) const;
    bool matchFavorites();
};
