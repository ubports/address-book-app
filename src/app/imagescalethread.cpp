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
    qDebug() << "Start thread" << __LINE__;
    if (!m_tmpFile) {
        m_tmpFile = new QTemporaryFile(this);
        // Create a temporary file
        m_tmpFile->open();
        m_tmpFile->close();

    }
    qDebug() << "Start thread" << __LINE__;
    QFile img(m_imageUrl.toLocalFile());
    if (img.exists() && img.open(QFile::ReadOnly)) {
        QImage tmpAvatar = QImage(img.fileName());
        QImage scaledAvatar = tmpAvatar.scaledToHeight(720, Qt::SmoothTransformation);
        scaledAvatar.save(m_tmpFile->fileName(), "png", 9);
    }
    qDebug() << "Start thread" << __LINE__;
}
