/*
 * Copyright (C) 2012-2014 Canonical, Ltd.
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

#ifndef _UBUNTU_CONTACTS_H_
#define _UBUNTU_CONTACTS_H_

#include <QtCore/QObject>
#include <QtCore/QString>
#include <QtCore/QUrl>
#include <QtCore/QScopedPointer>
#include <QtCore/QFileSystemWatcher>

class UbuntuContacts : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString tempPath READ tempPath)
    Q_PROPERTY(bool updateIsRunning READ updateIsRunning NOTIFY updateIsRunningChanged)

public:
    UbuntuContacts(QObject *parent = 0);

    QString tempPath() const;

    Q_INVOKABLE QString contactInitialsFromString(const QString &value);
    Q_INVOKABLE QString normalized(const QString &value);
    Q_INVOKABLE QString copyImage(const QUrl &imageUrl);
    Q_INVOKABLE bool containsLetters(const QString &value);
    Q_INVOKABLE bool removeFile(const QUrl &file);
    Q_INVOKABLE bool updateIsRunning() const;
    Q_INVOKABLE uint qHash(const QString &str);

Q_SIGNALS:
    void imageCopyDone(const QString &id, const QString &fileName);
    void updateIsRunningChanged();

private:
    QScopedPointer<QFileSystemWatcher> m_fileWatcher;

    static QString updaterLockFile();

};

#endif //_UBUNTU_CONTACTS_H_
