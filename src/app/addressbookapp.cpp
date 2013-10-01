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

#include "config.h"
#include "addressbookapp.h"
#include "addressbookappdbus.h"

#include <QDir>
#include <QUrl>
#include <QUrlQuery>
#include <QDebug>
#include <QStringList>
#include <QQuickItem>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQuickView>
#include <QDBusInterface>
#include <QDBusReply>
#include <QDBusConnectionInterface>
#include <QLibrary>
#include <QIcon>
#include <QTemporaryFile>

#include <QQmlEngine>

static void printUsage(const QStringList& arguments)
{
    qDebug() << "usage:"
             << arguments.at(0).toUtf8().constData()
             << "[contact://CONTACT_ID]"
             << "[create://PHONE_NUMBER]"
             << "[addressbook://addphone?id=<contact-id>&phone=<phone-number>"
             << "[addressbook://contact?id=<contact-id>"
             << "[addressbook://create?phone=<phone-number>"
             << "[--fullscreen]"
             << "[--help]"
             << "[-testability]";
}

static QString fullPath(const QString &fileName)
{
    QString result;
    QString appPath = QCoreApplication::applicationDirPath();
    if (appPath == ADDRESS_BOOK_APP_BINDIR) {
        result = QString(ADDRESS_BOOK_APP_INSTALL_DATADIR) + fileName;
    } else {
        result = QString(ADDRESS_BOOK_APP_DEV_DATADIR) + fileName;
    }
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

//this is necessary to work on desktop
//On desktop use: export ADDRESS_BOOK_APP_ICON_THEME=ubuntu-mobile
static void installIconPath()
{
    QByteArray iconTheme = qgetenv("ADDRESS_BOOK_APP_ICON_THEME");
    if (!iconTheme.isEmpty()) {
        QIcon::setThemeName(iconTheme);
    }
}

AddressBookApp::AddressBookApp(int &argc, char **argv)
    : QGuiApplication(argc, argv), m_view(0), m_applicationIsReady(false)
{
    setApplicationName("AddressBookApp");
    m_dbus = new AddressBookAppDBus(this);
}

bool AddressBookApp::setup()
{
    installIconPath();
    static QList<QString> validSchemes;
    bool fullScreen = false;

    if (validSchemes.isEmpty()) {
        validSchemes << "contact";
        validSchemes << "create";
        validSchemes << "addressbook";
    }

    QString contactKey;
    QStringList arguments = this->arguments();

    if (arguments.contains("--help")) {
        printUsage(arguments);
        return false;
    }

    if (arguments.contains("--fullscreen")) {
        arguments.removeAll("--fullscreen");
        fullScreen = true;
    }

    // The testability driver is only loaded by QApplication but not by QGuiApplication.
    // However, QApplication depends on QWidget which would add some unneeded overhead => Let's load the testability driver on our own.
    if (arguments.contains("-testability")) {
        arguments.removeAll("-testability");
        QLibrary testLib(QLatin1String("qttestability"));
        if (testLib.load()) {
            typedef void (*TasInitialize)(void);
            TasInitialize initFunction = (TasInitialize)testLib.resolve("qt_testability_init");
            if (initFunction) {
                initFunction();
            } else {
                qCritical("Library qttestability resolve failed!");
            }
        } else {
            qCritical("Library qttestability load failed!");
        }
    }

    /* Ubuntu APP Manager gathers info on the list of running applications from the .desktop
       file specified on the command line with the desktop_file_hint switch, and will also pass a stage hint
       So app will be launched like this:

       /usr/bin/dialer-app --desktop_file_hint=/usr/share/applications/dialer-app.desktop
                          --stage_hint=main_stage

       So remove whatever --arg still there before continue parsing
    */
    for (int i = arguments.count() - 1; i >=0; --i) {
        if (arguments[i].startsWith("--")) {
            arguments.removeAt(i);
        }
    }

    if (arguments.size() == 2) {
        QUrl uri(arguments.at(1));
        if (validSchemes.contains(uri.scheme())) {
            m_arg = arguments.at(1);
        }
    }

    // check if the app is already running, if it is, send the message to the running instance
    QDBusReply<bool> reply = QDBusConnection::sessionBus().interface()->isServiceRegistered(AddressBookAppDBus::serviceName());
    if (reply.isValid() && reply.value()) {
        QDBusInterface appInterface(AddressBookAppDBus::serviceName(),
                                    AddressBookAppDBus::objectPath(),
                                    AddressBookAppDBus::interfaceName());
        appInterface.call("SendAppMessage", m_arg);
        return false;
    }

    if (!m_dbus->connectToBus()) {
        qWarning() << "Failed to expose" << AddressBookAppDBus::interfaceName() << "on DBUS.";
    }

    /* Configure "artwork:" prefix so that any access to a file whose name starts
       with that prefix resolves properly. */
    QDir::addSearchPath("artwork", fullPath("/artwork"));

    m_view = new QQuickView();
    QObject::connect(m_view, SIGNAL(statusChanged(QQuickView::Status)), this, SLOT(onViewStatusChanged(QQuickView::Status)));
    QObject::connect(m_view->engine(), SIGNAL(quit()), SLOT(quit()));

    m_view->setResizeMode(QQuickView::SizeRootObjectToView);
    m_view->setTitle("AddressBook");
    m_view->engine()->addImportPath(importPath("/imports/"));
    m_view->rootContext()->setContextProperty("application", this);
    m_view->rootContext()->setContextProperty("contactKey", contactKey);
    m_view->rootContext()->setContextProperty("dbus", m_dbus);

    QUrl source(fullPath("/imports/main.qml"));
    m_view->setSource(source);

    if (fullScreen) {
        m_view->showFullScreen();
    } else {
        m_view->show();
    }

    connect(m_dbus,
            SIGNAL(request(QString)),
            SLOT(onMessageReceived(QString)));

    return true;
}

AddressBookApp::~AddressBookApp()
{
    if (m_view) {
        delete m_view;
    }
}

void AddressBookApp::onViewStatusChanged(QQuickView::Status status)
{
    if (status == QQuickView::Ready) {
        m_applicationIsReady = true;
        parseArgument(m_arg);
        m_arg.clear();
    }
}

void AddressBookApp::parseUrl(const QString &arg)
{
    QUrl url(arg);

    QString methodName = url.host();
    QStringList args;

    QMap<QString, QStringList> methodsMetaData;

    if (methodsMetaData.isEmpty()) {
        QStringList args;
        //edit
        args << "id" << "phone";
        methodsMetaData.insert("addphone", args);
        args.clear();

        //view
        args << "id";
        methodsMetaData.insert("contact", args);
        args.clear();

        //add
        args << "phone";
        methodsMetaData.insert("create", args);
        args.clear();
    }

    QUrlQuery query(url);
    QList<QPair<QString, QString> > queryItemsPair = query.queryItems();
    QMap<QString, QString> queryItems;

    //convert items to map
    for(int i=0; i < queryItemsPair.count(); i++) {
        QPair<QString, QString> item = queryItemsPair[i];
        queryItems.insert(item.first, item.second);
    }

    if (methodsMetaData.contains(methodName)) {
        QStringList argsNames = methodsMetaData[methodName];

        if (queryItems.size() != argsNames.size()) {
            qWarning() << "invalid" << methodName << "arguments size";
            return;
        }

        Q_FOREACH(QString arg, argsNames) {
            if (queryItems.contains(arg)) {
                args << queryItems[arg];
            } else {
                qWarning() << "argument" << arg << "not found in method" << methodName << "call";
                return;
            }
        }
    } else {
        qWarning() << "method" << methodName << "not supported";
        return;
    }

    callQMLMethod(methodName, args);
}

void AddressBookApp::parseArgument(const QString &arg)
{
    if (arg.isEmpty()) {
        return;
    }

    // new scheme
    if (arg.startsWith("addressbook://")) {
        parseUrl(arg);
        return;
    }

    QStringList args = arg.split("://");
    if (args.size() != 2) {
        return;
    }

    QString scheme = args[0];
    QStringList values;
    values << args[1];

    callQMLMethod(scheme, values);
}

void AddressBookApp::callQMLMethod(const QString name, QStringList args)
{
    QQuickItem *mainView = m_view->rootObject();
    if (!mainView) {
        return;
    }
    const QMetaObject *mo = mainView->metaObject();

    // create QML signature: Ex. function(QVariant, QVariant, QVariant)
    QString argsSignature = QString("QVariant,").repeated(args.size());
    if (argsSignature.endsWith(",")) {
        argsSignature = argsSignature.left(argsSignature.size() - 1);
    }

    QString methodSignature = QString("%1(%2)").arg(name).arg(argsSignature);
    int index = mo->indexOfMethod(methodSignature.toUtf8().data());
    if (index != -1) {
        QMetaMethod method = mo->method(index);
        switch(args.count()) {
        case 0:
            method.invoke(mainView);
            break;
        case 1:
            method.invoke(mainView, Q_ARG(QVariant, QVariant(args[0])));
            break;
        case 2:
            method.invoke(mainView, Q_ARG(QVariant, QVariant(args[0])),
                                    Q_ARG(QVariant, QVariant(args[1])));
            break;
        default:
            qWarning() << "Invalid arguments";
            break;
        }
    }
}

void AddressBookApp::onMessageReceived(const QString &message)
{
    if (m_applicationIsReady) {
        parseArgument(message);
        m_arg.clear();
        activateWindow();
    } else {
        m_arg = message;
    }
}

void AddressBookApp::activateWindow()
{
    if (m_view) {
        m_view->raise();
        m_view->requestActivate();
    }
}

QUrl AddressBookApp::copyImage(QObject *contact, const QUrl &imageUrl)
{
    QFile img(imageUrl.toLocalFile());
    if (img.exists() && img.open(QFile::ReadOnly)) {
        QTemporaryFile *tmp = new QTemporaryFile(contact);
        if (tmp->open()) {
            tmp->close();
            QImage tmpAvatar = QImage(img.fileName());
            QImage scaledAvatar = tmpAvatar.scaledToHeight(720, Qt::SmoothTransformation);
            scaledAvatar.save(tmp->fileName(), "png", 9);
            return QUrl(tmp->fileName());
        }
    }
    return QUrl();
}
