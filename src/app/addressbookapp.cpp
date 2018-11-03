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

#include "config.h"
#include "addressbookapp.h"

#include <QDir>
#include <QUrl>
#include <QUrlQuery>
#include <QDebug>
#include <QDesktopServices>
#include <QStringList>
#include <QQuickItem>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQuickView>
#include <QLibrary>
#include <QIcon>
#include <QSettings>
#include <QTimer>
#include <QElapsedTimer>
#include <QDBusReply>

#include <QQmlEngine>

#define ADDRESS_BOOK_FIRST_RUN_KEY          "first-run"

static QElapsedTimer s_elapsed;

static void printUsage(const QStringList& arguments)
{
    qDebug() << "usage:"
             << arguments.at(0).toUtf8().constData()
             << "[addressbook:///contact?id=<contact-id>]"
             << "[addressbook:///create?phone=<phone-number>]"
             << "[addressbook:///pick?single=<true/false>]"
             << "[addressbook:///importvcard?url=<vcard-file>]"
             << "[addressbook:///createAccount?providerId=<provider-id>]"
             << "[--fullscreen]"
             << "[--help]"
             << "[-testability]";
}

static bool clickModeEnabled()
{
    return ((QString(ADDRESS_BOOK_APP_CLICK_PACKAGE).toLower() == "on") ||
             (QString(ADDRESS_BOOK_APP_CLICK_PACKAGE) == "1"));
}

static QString fullPath(const QString &fileName)
{
    QString result;
    QString appPath = QCoreApplication::applicationDirPath();
    if (qEnvironmentVariableIsSet(SNAP_PATH)) {
        result = qgetenv(SNAP_PATH) + QStringLiteral("/usr/share/address-book-app/") + fileName;
    } else if (appPath.startsWith(ADDRESS_BOOK_DEV_BINDIR)) {
        result = QString(ADDRESS_BOOK_APP_DEV_DATADIR) + fileName;
    } else if (clickModeEnabled()) {
        result = appPath + QStringLiteral("/share/address-book-app/") + fileName;
    } else {
        result = QString(ADDRESS_BOOK_APP_INSTALL_DATADIR) + fileName;
    }
    return result;
}

static QString importPath(const QString &suffix)
{
    QString appPath = QCoreApplication::applicationDirPath();
    if (qEnvironmentVariableIsSet(SNAP_PATH)) {
        return qgetenv(SNAP_PATH) + suffix;
    } else if (ADDRESS_BOOK_APP_CLICK_MODE) {
        return QString(QT_EXTRA_IMPORTS_DIR) + suffix;
    } else if (appPath.startsWith(ADDRESS_BOOK_DEV_BINDIR)) {
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
        qDebug() << "Register extra icon theme:" << iconTheme;
        QIcon::setThemeName(iconTheme);
    }
}

AddressBookApp::AddressBookApp(int &argc, char **argv)
    : QGuiApplication(argc, argv),
      m_view(0),
      m_netManager(new QNetworkConfigurationManager),
      m_pickingMode(false),
      m_testMode(false),
      m_withArgs(false)
{
    s_elapsed.start();
    setOrganizationName(SETTINGS_ORGANIZATION_NAME);
    setApplicationName(SETTINGS_APP_NAME);
    setOrganizationDomain(SETTINGS_ORGANIZATION_DOMAIN);
    connect(m_netManager.data(),
            SIGNAL(onlineStateChanged(bool)),
            SIGNAL(isOnlineChanged()),
            Qt::QueuedConnection);
}

bool AddressBookApp::setup()
{
    installIconPath();
    connectWithServer();

    bool fullScreen = false;

    QString contactKey;
    QStringList arguments = this->arguments();
    QByteArray defaultManager("org.nemomobile.contacts.sqlite");
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
    if (arguments.contains(QLatin1String("-testability")) ||
        qgetenv("QT_LOAD_TESTABILITY") == "1") {
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
        m_testMode = true;
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

    m_withArgs = arguments.size() > 1;

    /* Configure "artwork:" prefix so that any access to a file whose name starts
       with that prefix resolves properly. */
    QDir::addSearchPath("artwork", fullPath("/artwork"));

    m_view = new QQuickView();
    m_viewReady = false;
    QObject::connect(m_view, SIGNAL(statusChanged(QQuickView::Status)),
                     this, SLOT(onViewStatusChanged(QQuickView::Status)));
    QObject::connect(m_view->engine(), SIGNAL(quit()), SLOT(quit()));

    m_view->setMinimumWidth(300);
    m_view->setMinimumHeight(500);
    m_view->setResizeMode(QQuickView::SizeRootObjectToView);
    m_view->setTitle("Contacts");
    qDebug() << "New import path:" << QCoreApplication::applicationDirPath() + "/" + importPath("");
    m_view->engine()->addImportPath(QCoreApplication::applicationDirPath() + "/" + importPath(""));
    m_view->rootContext()->setContextProperty("QTCONTACTS_MANAGER_OVERRIDE", defaultManager);
    m_view->rootContext()->setContextProperty("application", this);
    m_view->rootContext()->setContextProperty("contactKey", contactKey);
    m_view->rootContext()->setContextProperty("TEST_DATA", testData);
    m_view->rootContext()->setContextProperty("i18nDirectory", I18N_DIRECTORY);

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
    unsetFirstRun();

    if (m_view) {
        delete m_view;
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

bool AddressBookApp::isFirstRun() const
{
    // if the app is running on test mode or with arguments we will not show the welcome screen
    if (m_testMode || m_withArgs) {
        return false;
    } else {
        QSettings settings;
        return settings.value(ADDRESS_BOOK_FIRST_RUN_KEY, true).toBool();
    }
}

void AddressBookApp::unsetFirstRun() const
{
    // mark first run as false
    QSettings settings;
    settings.setValue(ADDRESS_BOOK_FIRST_RUN_KEY, false);
    settings.sync();
}

void AddressBookApp::goBackToSourceApp()
{
    if (!m_callbackApplication.isEmpty()) {
        QDesktopServices::openUrl(QUrl(QString("application:///%1").arg(m_callbackApplication)));
        m_callbackApplication.clear();
        Q_EMIT callbackApplicationChanged();
    }
}

void AddressBookApp::startUpdate()
{
    if (m_updateWatcher) {
        return;
    }

    QDBusMessage startUpdateCall = QDBusMessage::createMethodCall("com.canonical.pim.updater",
                                                                  "/com/canonical/pim/Updater",
                                                                  "com.canonical.pim.Updater",
                                                                  "startUpdate");
    QDBusPendingCall pcall = QDBusConnection::sessionBus().asyncCall(startUpdateCall);
    m_updateWatcher.reset(new QDBusPendingCallWatcher(pcall, this));
    QObject::connect(m_updateWatcher.data(), SIGNAL(finished(QDBusPendingCallWatcher*)),
                     this, SLOT(onUpdateCallFinished(QDBusPendingCallWatcher*)));
    Q_EMIT updatingChanged();
}

void AddressBookApp::onUpdateCallFinished(QDBusPendingCallWatcher *watcher)
{
    m_updateWatcher.reset(0);
    Q_EMIT updatingChanged();
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

        //view
        args << "id";
        methodsMetaData.insert("contact", args);
        args.clear();

        //create
        args << "phone";
        methodsMetaData.insert("create", args);
        args.clear();

        //pick
        args << "single";
        methodsMetaData.insert("pick", args);
        args.clear();

        //vcard
        args << "url";
        methodsMetaData.insert("importvcard", args);
        args.clear();

        //providerId
        args << "providerId";
        methodsMetaData.insert("createAccount", args);
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
    // keep callback arg
    setCallbackApplication(queryItems.take("callback"));

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
            method.invoke(mainView, Q_ARG(QVariant, QVariant(args[0])));
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

void AddressBookApp::connectWithServer()
{
    m_server.reset(new QDBusInterface("com.canonical.pim",
                                      "/com/canonical/pim/AddressBook",
                                      "com.canonical.pim.AddressBook"));
    if (!m_server->isValid()) {
        qWarning() << "Fail to connect with pim service.";
    }
    connect(m_server.data(), SIGNAL(safeModeChanged()), SIGNAL(serverSafeModeChanged()));
    connect(m_server.data(), SIGNAL(sourcesChanged()), SIGNAL(sourcesChanged()));
    Q_EMIT serverSafeModeChanged();
}

void AddressBookApp::activateWindow()
{
    if (m_view) {
        m_view->raise();
        m_view->requestActivate();
    }
}

void AddressBookApp::elapsed() const
{
    qDebug() << "ELAPSED:" << s_elapsed.elapsed() / 1000.0;
}

QString AddressBookApp::callbackApplication() const
{
    return m_callbackApplication;
}

void AddressBookApp::setCallbackApplication(const QString &application)
{
    if (m_callbackApplication != application) {
        m_callbackApplication = application;
        Q_EMIT callbackApplicationChanged();
    }
}

bool AddressBookApp::isOnline() const
{
    return m_netManager->isOnline();
}

bool AddressBookApp::serverSafeMode() const
{
    QDBusReply<bool> reply = m_server->call("safeMode");
    return reply.value();
}

bool AddressBookApp::updating() const
{
    return !m_updateWatcher.isNull();
}

