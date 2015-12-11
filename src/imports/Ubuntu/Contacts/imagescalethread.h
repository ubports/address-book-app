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

#ifndef IMAGESCALETHREAD_H
#define IMAGESCALETHREAD_H

#include <QObject>
#include <QRunnable>
#include <QUrl>
#include <QPointer>
#include <QTemporaryFile>

class ImageScaleThread : public QRunnable
{
public:
    ImageScaleThread(const QUrl &imageUrl, QObject *listener);
    ~ImageScaleThread();

    QString id();
    QString outputFile() const;

protected:
    virtual void run();

private:
    QUrl m_imageUrl;
    QString m_id;
    QPointer<QObject> m_listener;
    QTemporaryFile *m_tmpFile;
};

#endif
