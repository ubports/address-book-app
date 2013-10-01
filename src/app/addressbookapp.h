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

#include <QObject>
#include <QQuickView>
#include <QGuiApplication>

class AddressBookAppDBus;

class AddressBookApp : public QGuiApplication
{
    Q_OBJECT

public:
    AddressBookApp(int &argc, char **argv);
    virtual ~AddressBookApp();

    bool setup();

public Q_SLOTS:
    void activateWindow();
    QUrl copyImage(QObject *contact, const QUrl &imageUrl);

private:
    void parseArgument(const QString &arg);
    void parseUrl(const QString &arg);
    void callQMLMethod(const QString name, QStringList args);

private Q_SLOTS:
    void onMessageReceived(const QString &message);
    void onViewStatusChanged(QQuickView::Status status);

private:
    QQuickView *m_view;
    AddressBookAppDBus *m_dbus;
    QString m_arg;
    bool m_applicationIsReady;
};

#endif
