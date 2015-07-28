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
    Q_PROPERTY(QString lastError READ lastError NOTIFY updateError)

public:
    ButeoImport(QObject *parent = 0);
    ~ButeoImport();

    Q_INVOKABLE bool update(bool removeOldSources = true);
    QString lastError() const;
    bool isOutDated() const;
    bool busy();

    void wait();

Q_SIGNALS:
    void updated();
    void updateError(const QString &message);
    void busyChanged();
    void outDatedChanged();

private Q_SLOTS:
    void onProfileChanged(const QString &profileName, int changeType, const QString &profileAsXml);
    void onSyncStatusChanged(const QString &aProfileName, int aStatus, const QString &aMessage, int aMoreDetails);

private:
    QScopedPointer<QDBusInterface> m_buteoInterface;
    QMap<quint32, QString> m_accountToProfiles;
    QMap<QString, quint32> m_sourceToAccount;
    QMutex m_importLock;
    bool m_removeOldSources;
    QString m_lastError;
    QEventLoop *m_importLoop;

    QMap<QString, quint32> sources() const;
    QMap<quint32, QString> createProfileForAccounts(QList<quint32> ids);
    bool prepareButeo();
    bool createAccounts(QList<quint32> ids);
    bool removeProfile(const QString &profileId);
    bool removeSources(const QStringList &sources);
    bool commit();
    void error(const QString &message);
};
