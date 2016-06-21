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

#include "imagescalethread.h"

#include <QImage>
#include <QImageReader>
#include <QFile>
#include <QDir>
#include <QUuid>
#include <QDebug>

ImageScaleThread::ImageScaleThread(const QUrl &imageUrl, QObject *listener)
     : m_imageUrl(imageUrl),
       m_id(QUuid::createUuid().toString()),
       m_listener(listener),
       m_tmpFile(0)
{
}

ImageScaleThread::~ImageScaleThread()
{
    if (m_tmpFile) {
        m_tmpFile->setAutoRemove(false);
        m_tmpFile->deleteLater();
        m_tmpFile = 0;
    }
}

QString ImageScaleThread::id()
{
    return m_id;
}

QString ImageScaleThread::outputFile() const
{
    if (m_tmpFile) {
        return m_tmpFile->fileName();
    } else {
        return QString();
    }
}

void ImageScaleThread::run()
{
    // make sure that the old image get deleted
    if (m_tmpFile) {
        qDebug() << "Delete previous avatar" << m_tmpFile->fileName();
        m_tmpFile->setAutoRemove(true);
        m_tmpFile->close();
        delete m_tmpFile;
    }

    // Create the temporary file
    m_tmpFile = new QTemporaryFile(QString("%1/avatar_XXXXXX.png").arg(QDir::tempPath()));
    if (!m_tmpFile->open()) {
        qWarning() << "Fail to create avatar temporary file";
        return;
    }

    // try using the Qt's image reader to speedup the scaling
    QImage scaledAvatar;
    QImageReader reader(m_imageUrl.toLocalFile());
    if (reader.canRead()) {
        QSize size = reader.size();
        if ((size.height() > 720) && (size.width() > 720)) {
            size.scale(720, 720,  Qt::KeepAspectRatioByExpanding);
        }
        reader.setScaledSize(size);
        scaledAvatar = reader.read();
    }

    // fallback to use a QImage to load the avatar if the image reader failed
    if (scaledAvatar.isNull()) {
        QImage img(m_imageUrl.toLocalFile());
        if (!img.isNull()) {
            if ((img.height() > 720) && (img.width() > 720)) {
                scaledAvatar = img.scaled(720, 720, Qt::KeepAspectRatioByExpanding, Qt::FastTransformation);
            } else {
                scaledAvatar = img;
            }
        }
    }

    // and finally, save the image
    if (!scaledAvatar.isNull()) {
        scaledAvatar.save(m_tmpFile, "png");
    }

    m_tmpFile->setAutoRemove(false);
    m_tmpFile->close();

    if (m_listener) {
        QMetaObject::invokeMethod(m_listener, "imageCopyDone",
                                  Q_ARG(QString, m_id), Q_ARG(QString, m_tmpFile->fileName()));
    }
}
