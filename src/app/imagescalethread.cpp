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

#include "imagescalethread.h"

#include <QImage>
#include <QImageReader>
#include <QFile>
#include <QDebug>

ImageScaleThread::ImageScaleThread(const QUrl &imageUrl, QObject *parent)
    : QThread(parent),
      m_imageUrl(imageUrl),
      m_tmpFile(0)
{
}

ImageScaleThread::~ImageScaleThread()
{
    if (m_tmpFile) {
        delete m_tmpFile;
    }
}

QString ImageScaleThread::outputFile() const
{
    return m_tmpFile->fileName();
}

void ImageScaleThread::run()
{
    if (!m_tmpFile) {
        // Create the temporary file
        m_tmpFile = new QTemporaryFile();
    }

    if (!m_tmpFile->open()) {
        return;
    }

    // try using the Qt's image reader to speedup the scaling
    QImage scaledAvatar;
    QImageReader reader(m_imageUrl.toLocalFile());
    if (reader.canRead()) {
        QSize size = reader.size();
        // scale only if image bigger than 720p (1280x720)
        if ((size.height() > 1280) || (size.width() > 1280)) {
            size.scale(720, 720,  Qt::KeepAspectRatioByExpanding);
        }
        reader.setScaledSize(size);
        scaledAvatar = reader.read();
    }

    // fallback to use a QImage to load the avatar if the image reader failed
    if (scaledAvatar.isNull()) {
        QImage img(m_imageUrl.toLocalFile());
        if (!img.isNull()) {
            // scale only if image bigger than 720p (1280x720)
            if ((img.height() > 1280) || (img.width() > 1280)) {
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
    m_tmpFile->close();
}
