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
    hub->register_import_export_handler(this);
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
        return;
    }

    m_transfer = transfer;
    m_tempFile.setFileTemplate(QDir::tempPath() + "/vcard_XXXXXX.vcf");
    m_tempFile.open();
    m_tempFile.setAutoRemove(false);
    connect(m_transfer, SIGNAL(selectionTypeChanged()), SIGNAL(multipleItemsChanged()));
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

    m_tempFile.flush();
    m_tempFile.close();

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
    return QUrl::fromLocalFile(m_tempFile.fileName());
}
