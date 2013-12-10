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

class ContentCommunicator;

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
    void parseUrl(const QString &arg);
    void onViewStatusChanged(QQuickView::Status status);

private:
    void callQMLMethod(const QString name, QStringList args);

private:
    QQuickView *m_view;
    ContentCommunicator *m_contentComm;
    QString m_initialArg;
    bool m_viewReady;
    bool m_pickingMode;
};

#endif
