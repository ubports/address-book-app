/*
 * Copyright (C) 2012-2015 Canonical, Ltd.
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
#include <QtDBus/QDBusPendingCallWatcher>
#include <QtGui/QGuiApplication>
#include <QtQuick/QQuickView>
#include <QtNetwork/QNetworkConfigurationManager>

class AddressBookApp : public QGuiApplication
{
    Q_OBJECT
    Q_PROPERTY(bool firstRun READ isFirstRun CONSTANT)
    Q_PROPERTY(QString callbackApplication READ callbackApplication WRITE setCallbackApplication NOTIFY callbackApplicationChanged)
    Q_PROPERTY(bool isOnline READ isOnline NOTIFY isOnlineChanged)
    Q_PROPERTY(bool serverSafeMode READ serverSafeMode NOTIFY serverSafeModeChanged)
    Q_PROPERTY(bool updating READ updating NOTIFY updatingChanged)

public:
    AddressBookApp(int &argc, char **argv);
    virtual ~AddressBookApp();

    bool setup();

    QString callbackApplication() const;
    void setCallbackApplication(const QString &application);

    bool isOnline() const;
    bool serverSafeMode() const;
    bool updating() const;

Q_SIGNALS:
    void callbackApplicationChanged();
    void isOnlineChanged();
    void serverSafeModeChanged();
    void updatingChanged();
    void sourcesChanged();

public Q_SLOTS:
    void activateWindow();
    void parseUrl(const QString &arg);
    void onViewStatusChanged(QQuickView::Status status);
    void returnVcard(const QUrl &url);
    bool isFirstRun() const;
    void unsetFirstRun() const;
    void goBackToSourceApp();
    void startUpdate();

    // debug
    void elapsed() const;


private Q_SLOTS:
    void onUpdateCallFinished(QDBusPendingCallWatcher *watcher);

private:
    void callQMLMethod(const QString name, QStringList args);
    void connectWithServer();

private:
    QQuickView *m_view;
    QScopedPointer<QNetworkConfigurationManager> m_netManager;
    QScopedPointer<QDBusInterface> m_server;
    QScopedPointer<QDBusPendingCallWatcher> m_updateWatcher;
    QString m_initialArg;
    QString m_callbackApplication;
    bool m_viewReady;
    bool m_pickingMode;
    bool m_testMode;
    bool m_withArgs;
};

#endif
