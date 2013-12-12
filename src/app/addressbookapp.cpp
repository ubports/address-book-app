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
#include "imagescalethread.h"
#include "contentcommunicator.h"

#include <QDir>
#include <QUrl>
#include <QUrlQuery>
#include <QDebug>
#include <QStringList>
#include <QQuickItem>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQuickView>
#include <QLibrary>
#include <QIcon>

#include <QQmlEngine>

static void printUsage(const QStringList& arguments)
{
    qDebug() << "usage:"
             << arguments.at(0).toUtf8().constData()
             << "[addressbook:///addphone?id=<contact-id>&phone=<phone-number>"
             << "[addressbook:///contact?id=<contact-id>"
             << "[addressbook:///create?phone=<phone-number>"
             << "[addressbook:///pick?single=<true/false>"
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
    : QGuiApplication(argc, argv),
      m_view(0),
      m_pickingMode(false)
{
    setApplicationName("AddressBookApp");
    m_contentComm = new ContentCommunicator(this);
}

bool AddressBookApp::setup()
{
    installIconPath();
    bool fullScreen = false;

    QString contactKey;
    QStringList arguments = this->arguments();
    QByteArray defaultManager("galera");
    QByteArray testData;

    // use galare as default QtContacts Manager
    if (qEnvironmentVariableIsSet("QTCONTACTS_MANAGER_OVERRIDE")) {
        defaultManager = qgetenv("QTCONTACTS_MANAGER_OVERRIDE");
    }

    testData = qgetenv("ADDRESS_BOOK_TEST_DATA");

    qDebug() << "Using contact manager:" << defaultManager;

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

    /* Configure "artwork:" prefix so that any access to a file whose name starts
       with that prefix resolves properly. */
    QDir::addSearchPath("artwork", fullPath("/artwork"));

    m_view = new QQuickView();
    m_viewReady = false;
    QObject::connect(m_view, SIGNAL(statusChanged(QQuickView::Status)),
                     this, SLOT(onViewStatusChanged(QQuickView::Status)));
    QObject::connect(m_view->engine(), SIGNAL(quit()), SLOT(quit()));

    m_view->setResizeMode(QQuickView::SizeRootObjectToView);
    m_view->setTitle("AddressBook");
    m_view->engine()->addImportPath(importPath("/imports/"));
    m_view->rootContext()->setContextProperty("DEFAULT_CONTACT_MANAGER", defaultManager);
    m_view->rootContext()->setContextProperty("contentHub", m_contentComm);
    m_view->rootContext()->setContextProperty("application", this);
    m_view->rootContext()->setContextProperty("contactKey", contactKey);
    m_view->rootContext()->setContextProperty("TEST_DATA", testData);

    QUrl source(fullPath("/imports/MainWindow.qml"));
    m_view->setSource(source);

    if (fullScreen) {
        m_view->showFullScreen();
    } else {
        m_view->show();
    }

    if (arguments.size() == 2) {
        if (!m_viewReady) {
            m_initialArg = arguments.at(1);
        } else {
            parseUrl(arguments.at(1));
        }
    }

    return true;
}

AddressBookApp::~AddressBookApp()
{
    if (m_view) {
        delete m_view;
    }

    if (m_contentComm) {
        delete m_contentComm;
    }
}

void AddressBookApp::onViewStatusChanged(QQuickView::Status status)
{
    if (status == QQuickView::Ready) {
        m_viewReady = true;
        if (!m_initialArg.isEmpty()) {
            parseUrl(m_initialArg);
            m_initialArg.clear();
        }
    }
}

void AddressBookApp::returnVcard(const QUrl &url)
{
    if (m_pickingMode) {
        printf("%s\n", qPrintable(url.toString()));
        this->quit();
    }
}

void AddressBookApp::parseUrl(const QString &arg)
{
    QUrl url = QUrl::fromPercentEncoding(arg.toUtf8());
    if (url.scheme() != "addressbook") {
        return;
    }

    // Remove the first "/"
    QString methodName = url.path().right(url.path().length() -1);
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

        //pick
        args << "single";
        methodsMetaData.insert("pick", args);
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
            method.invoke(mainView, Q_ARG(QVariant, QVariant(args[0].toUtf8())));
            break;
        case 2:
            method.invoke(mainView, Q_ARG(QVariant, QVariant(args[0].toUtf8())),
                                    Q_ARG(QVariant, QVariant(args[1].toUtf8())));
            break;
        default:
            qWarning() << "Invalid arguments";
            return;
        }
    }
    m_pickingMode = (name == "pick");
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
    // keep track of threads to avoid memory leeak
    ImageScaleThread *imgThread;
    QVariant oldThread = contact->property("IMAGE_SCALE_THREAD");
    if (!oldThread.isNull()) {
        imgThread = oldThread.value<ImageScaleThread *>();
        imgThread->updateImageUrl(imageUrl);
    } else {
        imgThread = new ImageScaleThread(imageUrl, contact);
        contact->setProperty("IMAGE_SCALE_THREAD", QVariant::fromValue<ImageScaleThread*>(imgThread));
    }

    imgThread->start();

    while(imgThread->isRunning()) {
        this->processEvents(QEventLoop::AllEvents, 3000);
    }

    return imgThread->outputFile();
}
