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

#ifndef CONTENTCOMMUNICATOR_H
#define CONTENTCOMMUNICATOR_H

#include <com/ubuntu/content/import_export_handler.h>
#include <com/ubuntu/content/transfer.h>

#include <QStringList>

using namespace com::ubuntu;

/*!
 * Class to handle the communication with the content manager
 */
class ContentCommunicator : public content::ImportExportHandler
{
    Q_OBJECT
    Q_PROPERTY(bool active READ isActive NOTIFY activeChanged)
    Q_PROPERTY(bool multipleItems READ isMultipleItems NOTIFY multipleItemsChanged)

public:
    ContentCommunicator(QObject *parent = 0);

    virtual void handle_import(content::Transfer*);
    virtual void handle_export(content::Transfer *transfer);


    bool isActive() const;
    bool isMultipleItems() const;

public Q_SLOTS:
    void cancelTransfer();
    void returnContacts(const QUrl &contactsFile);
    QUrl createTemporaryFile() const;

Q_SIGNALS:
    void contactRequested();
    void activeChanged();
    void multipleItemsChanged();

private:
    content::Transfer *m_transfer;
};

#endif // CONTENTCOMMUNICATOR_H
