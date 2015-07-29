#include <QObject>
#include <QSignalSpy>
#include <QSettings>
#include <QTemporaryFile>
#include <QDebug>
#include <QTest>

#include <QContactManager>
#include <QContactDetailFilter>

#include "buteo-import.h"

using namespace QtContacts;

class TstButeoImport : public QObject
{
    Q_OBJECT

    QTemporaryFile *m_settingsFile;

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
};

QTEST_MAIN(TstButeoImport)

#include "tst-buteo-import.moc"
