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

// Qt
#include <QGuiApplication>
#include <QQuickView>
#include <QQmlEngine>
#include <QQmlContext>
#include <QUrl>
#include <QDir>
#include <QDebug>
#include <QLibrary>

#include "config.h"

static QString fullPath(const QString &fileName)
{
    QString result;
    QString appPath = QCoreApplication::applicationDirPath();
    if (appPath == ADDRESS_BOOK_APP_BINDIR) {
        result = QString(ADDRESS_BOOK_APP_INSTALL_DATADIR) + fileName;
    } else {
        result = QString(ADDRESS_BOOK_APP_DEV_DATADIR) + fileName;
    }
    qDebug() << "Load:" << result << "PATH" << appPath;
    return result;
}

static QString importPath(const QString &suffix)
{
    QString appPath = QCoreApplication::applicationDirPath();
    if (appPath != ADDRESS_BOOK_APP_BINDIR) {
        return QString(ADDRESS_BOOK_APP_DEV_DATADIR) + suffix;
    } else {
        return "";
    }
}

int main(int argc, char** argv)
{
    QGuiApplication::setApplicationName(ADDRESS_BOOK_APP_NAME);
    QGuiApplication app(argc, argv);
    QStringList args = app.arguments();
    bool testability = args.removeAll("-testability") > 0;

    // The testability driver is only loaded by QApplication but not by
    // QGuiApplication.
    // However, QApplication depends on QWidget which would add some
    // unneeded overhead => Let's load the testability driver on our own.
    if (testability) {
        QLibrary testLib(QLatin1String("qttestability"));
        if (testLib.load()) {
            typedef void (*TasInitialize)(void);
            TasInitialize initFunction =
                (TasInitialize)testLib.resolve("qt_testability_init");
            if (initFunction) {
                initFunction();
            } else {
                qCritical("Library qttestability resolve failed!");
            }
        } else {
            qCritical("Library qttestability load failed!");
        }
    }

    /* Configure "artwork:" prefix so that any access to a file whose name starts
       with that prefix resolves properly. */
    QDir::addSearchPath("artwork", fullPath("/artwork"));

    QQuickView *view = new QQuickView();
    view->setResizeMode(QQuickView::SizeRootObjectToView);
    view->setTitle(ADDRESS_BOOK_APP_NAME);
    view->engine()->addImportPath(importPath("/imports/"));
    view->engine()->rootContext()->setProperty("CONTACT_DEFAULT_AVATAR", QStringLiteral("artwork:/avatar-default.svg"));

    QUrl source(fullPath("/imports/main.qml"));
    view->setSource(source);
    view->showNormal();

    return app.exec();
}

