#include <QObject>
#include <QSignalSpy>
#include <QSettings>
#include <QTemporaryFile>
#include <QDebug>
#include <QTest>

#include <QContactManager>
#include <QContactDetailFilter>

#include "buteo-import.h"


#define ADDRESS_BOOK_BUS_NAME   "com.canonical.pim"
#define ADDRESS_BOOK_OBJ        "/com/canonical/pim/AddressBook"
#define ADDRESS_BOOK_IFACE      "com.canonical.pim.AddressBook"

using namespace QtContacts;

class TstButeoImport : public QObject
{
    Q_OBJECT

    QTemporaryFile *m_settingsFile;

private:
    void createSource(const QString &sourceId,
                      const QString &sourceName,
                      const QString &provider,
                      const QString &applicationId,
                      quint32 accountId,
                      bool readOnly,
                      bool primary)
    {
        QDBusMessage createSource = QDBusMessage::createMethodCall(ADDRESS_BOOK_BUS_NAME,
                                                                   ADDRESS_BOOK_OBJ,
                                                                   ADDRESS_BOOK_IFACE,
                                                                   "createSource");
        QList<QVariant> args;
        args << sourceId
             << sourceName
             << provider
             << applicationId
             << accountId
             << readOnly
             << primary;
        createSource.setArguments(args);
        QDBusConnection::sessionBus().call(createSource);
    }

    void resetAddressBook()
    {
        QDBusMessage reset = QDBusMessage::createMethodCall(ADDRESS_BOOK_BUS_NAME,
                                                            ADDRESS_BOOK_OBJ,
                                                            ADDRESS_BOOK_IFACE,
                                                           "reset");
        QDBusConnection::sessionBus().call(reset);
    }

private Q_SLOTS:
    void init()
    {
        m_settingsFile = new QTemporaryFile;
        QVERIFY(m_settingsFile->open());
        qDebug() << "Using as temporary file:" << m_settingsFile->fileName();
        //Make sure that we use a new settings every time that we run the test
        QSettings::setPath(QSettings::NativeFormat, QSettings::UserScope, m_settingsFile->fileName());
    }

    void cleanup()
    {
        resetAddressBook();
        delete m_settingsFile;
    }

    void tst_isOutDated()
    {
        ButeoImport import;
        QVERIFY(import.isOutDated());
        QVERIFY(!import.busy());
    }

    void tst_importAccount()
    {
        // populate sources
        createSource("source@1", "source-1", "google", "", 0, false, true);
        createSource("source@2", "source-2", "google", "", 0, false, false);
        createSource("source@3", "source-3", "google", "", 0, false, false);
        createSource("source@4", "source-4", "google", "", 0, false, false);

        ButeoImport bImport;

        QSignalSpy updatedSignal(&bImport, SIGNAL(updated()));
        QSignalSpy busyChangedSignal(&bImport, SIGNAL(busyChanged()));

        QVERIFY(bImport.update(true));
        QVERIFY(bImport.busy());
        QTRY_COMPARE(updatedSignal.count(), 1);
        QTRY_COMPARE(busyChangedSignal.count(), 2);
        QVERIFY(!bImport.busy());

        // Check if old sources was deleted
        QContactManager manager("galera");
        QContactDetailFilter sourceFilter;
        sourceFilter.setDetailType(QContactDetail::TypeType, QContactType::FieldType);
        sourceFilter.setValue( QContactType::TypeGroup);
        QCOMPARE(manager.contacts(sourceFilter).size(), 0);
    }

    void tst_importSomeAccounts()
    {
        // populate sources
        createSource("source@2", "source-2", "google", "", 0, false, false);
        createSource("source@3", "source-3", "google", "", 0, false, false);
        createSource("source@4", "source-4", "google", "", 0, false, false);
        // mark this source as already imported
        createSource("source@1", "source-1", "google", "", 141, false, false);

        ButeoImport bImport;

        QSignalSpy updatedSignal(&bImport, SIGNAL(updated()));
        QSignalSpy busyChangedSignal(&bImport, SIGNAL(busyChanged()));

        QVERIFY(bImport.update(true));
        QVERIFY(bImport.busy());
        QTRY_COMPARE(updatedSignal.count(), 1);
        QTRY_COMPARE(busyChangedSignal.count(), 2);
        QVERIFY(!bImport.busy());

        // Check if old sources was deleted
        QContactManager manager("galera");
        QContactDetailFilter sourceFilter;
        sourceFilter.setDetailType(QContactDetail::TypeType, QContactType::FieldType);
        sourceFilter.setValue( QContactType::TypeGroup);
        QCOMPARE(manager.contacts(sourceFilter).size(), 1);
    }
};

QTEST_MAIN(TstButeoImport)

#include "tst-buteo-import.moc"
