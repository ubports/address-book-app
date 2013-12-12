/*
 * Copyright (C) 2013 Canonical, Ltd.
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
 *
 */

#include <contentcommunicator.h>

#include <QDebug>
#include <QTemporaryFile>
#include <QDir>

#include <com/ubuntu/content/hub.h>
#include <com/ubuntu/content/item.h>
#include <com/ubuntu/content/transfer.h>

using namespace com::ubuntu::content;

/*!
 * \brief ContentCommunicator::ContentCommunicator
 * \param parent
 */
ContentCommunicator::ContentCommunicator(QObject *parent)
    : ImportExportHandler(parent),
      m_transfer(0)
{
    Hub *hub = Hub::Client::instance();
    if (hub) {
        hub->register_import_export_handler(this);
    } else {
        qWarning() << "Fail to get Hub client instance";
    }
}

/*!
 * \brief \reimp
 */
void ContentCommunicator::handle_import(content::Transfer *)
{
    qDebug() << Q_FUNC_INFO << "address book app does not import content";
}

/*!
 * \brief \reimp
 */
void ContentCommunicator::handle_export(content::Transfer *transfer)
{
    if (m_transfer != 0) {
        qWarning() << "address book app does only one content export at a time";
        transfer->abort();
        m_transfer = 0;
        return;
    }

    if (transfer) {
        m_transfer = transfer;
        connect(m_transfer, SIGNAL(selectionTypeChanged()), SIGNAL(multipleItemsChanged()));
    } else {
        qWarning() << "Transfer pointer is null in handle_export";
    }
    Q_EMIT contactRequested();
    Q_EMIT activeChanged();
    Q_EMIT multipleItemsChanged();
}

/*!
 * \brief ContentCommunicator::cancelTransfer aborts the current transfer
 */
void ContentCommunicator::cancelTransfer()
{
    if (!m_transfer) {
        qWarning() << "No ongoing transfer to cancel";
        return;
    }

    m_transfer->abort();
    m_transfer = 0;
    Q_EMIT activeChanged();
}

/*!
 * \brief ContentCommunicator::returnContacts returns the given contacts
 * via content hub to the requester
 * \param urls
 */
void ContentCommunicator::returnContacts(const QUrl &contactsFile)
{
    if (!m_transfer) {
        qWarning() << "No ongoing transfer to return a contact";
        return;
    }

    QVector<Item> items;
    items << contactsFile;
    m_transfer->charge(items);
    m_transfer = 0;
    Q_EMIT activeChanged();
}

bool ContentCommunicator::isActive() const
{
    return (m_transfer != 0);
}

bool ContentCommunicator::isMultipleItems() const
{
    return (m_transfer && m_transfer->selectionType() == Transfer::multiple);
}

QUrl ContentCommunicator::createTemporaryFile() const
{
    QTemporaryFile tmp(QDir::tempPath() + "/vcard_XXXXXX.vcf");
    tmp.setAutoRemove(false);
    if (!tmp.open()) {
        qWarning() << "Fail to create temporary file for vcard.";
        return QUrl();
    }
    QString tmpFileName = tmp.fileName();
    tmp.close();
    return QUrl::fromLocalFile(tmpFileName);
}
