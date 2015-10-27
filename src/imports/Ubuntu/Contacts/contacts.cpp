/*
 * Copyright (C) 2012-2014 Canonical, Ltd.
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

#include "contacts.h"
#include "imagescalethread.h"

#include <QtCore/QCoreApplication>
#include <QtCore/QStringList>
#include <QtCore/QDebug>
#include <QtCore/QDir>
#include <QtCore/QUrl>
#include <QtCore/QLockFile>

#include "config.h"

UbuntuContacts::UbuntuContacts(QObject *parent)
    : QObject(parent),
      m_fileWatcher(new QFileSystemWatcher)
{
    // We need to monitor the tmp dir since the file could not exists at this point
    m_fileWatcher->addPath(QDir::tempPath());
    connect(m_fileWatcher.data(),
            SIGNAL(directoryChanged(QString)),
            SIGNAL(updateIsRunningChanged()));
    connect(m_fileWatcher.data(),
            SIGNAL(fileChanged(QString)),
            SIGNAL(updateIsRunningChanged()));
}

QString UbuntuContacts::tempPath() const
{
    return QDir::tempPath();
}

QString UbuntuContacts::contactInitialsFromString(const QString &value)
{
    if (value.isEmpty() || !value.at(0).isLetter()) {
        return QString();
    }

    QString initials;
    QStringList parts = value.split(" ");
    initials = parts.first().at(0).toUpper();
    if (parts.size() > 1) {
        initials += parts.last().at(0).toUpper();
    }

    return initials;
}

QString UbuntuContacts::normalized(const QString &value)
{
    QString s2 = value.normalized(QString::NormalizationForm_D);
    QString out;

    for (int i=0, j=s2.length(); i<j; i++)
    {
        // strip diacritic marks
        if (s2.at(i).category() != QChar::Mark_NonSpacing &&
            s2.at(i).category() != QChar::Mark_SpacingCombining) {
            out.append(s2.at(i));
        }
    }
    return out;
}

QUrl UbuntuContacts::copyImage(QObject *contact, const QUrl &imageUrl)
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

    // FIXME: implement this as async function
    while(imgThread->isRunning()) {
        QCoreApplication::processEvents(QEventLoop::AllEvents, 3000);
    }

    return imgThread->outputFile();
}

bool UbuntuContacts::containsLetters(const QString &value)
{
    foreach (const QChar &c, value) {
        if (c.isLetter()) {
            return true;
        }
    }
    return false;
}

bool UbuntuContacts::removeFile(const QUrl &file)
{
    return QFile::remove(file.toLocalFile());
}

bool UbuntuContacts::updateIsRunning() const
{
    return QFile::exists(updaterLockFile());
}

QString UbuntuContacts::updaterLockFile()
{
    return QString("%1/%2").arg(QDir::tempPath()).arg("/address-book-updater.lock");
}
