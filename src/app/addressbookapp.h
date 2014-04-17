/*
 * Copyright (C) 2012-2013 Canonical, Ltd.
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

#ifndef ADDRESSBOOK_APP_H
#define ADDRESSBOOK_APP_H

#include <QtCore/QObject>
#include <QtDBus/QDBusInterface>
#include <QtGui/QGuiApplication>
#include <QtQuick/QQuickView>

class ContentCommunicator;

class AddressBookApp : public QGuiApplication
{
    Q_OBJECT
    Q_PROPERTY(bool firstRun READ isFirstRun CONSTANT)
    Q_PROPERTY(bool syncing READ isSyncing NOTIFY syncingChanged)
    Q_PROPERTY(bool syncEnabled READ syncEnabled NOTIFY syncEnabledChanged)

public:
    AddressBookApp(int &argc, char **argv);
    virtual ~AddressBookApp();

    bool setup();
    bool isSyncing() const;
    bool syncEnabled() const;

Q_SIGNALS:
    void syncingChanged();
    void syncEnabledChanged();

public Q_SLOTS:
    void activateWindow();
    QUrl copyImage(QObject *contact, const QUrl &imageUrl);
    void parseUrl(const QString &arg);
    void onViewStatusChanged(QQuickView::Status status);
    void returnVcard(const QUrl &url);
    bool isFirstRun() const;
    void unsetFirstRun() const;
    void sendTabEvent() const;

    // sync monitor
    void startSync() const;

private:
    void callQMLMethod(const QString name, QStringList args);
    void connectWithSyncMonitor();

private:
    QQuickView *m_view;
    ContentCommunicator *m_contentComm;
    QDBusInterface *m_syncMonitor;
    QString m_initialArg;
    bool m_viewReady;
    bool m_pickingMode;
    bool m_testMode;
};

#endif
