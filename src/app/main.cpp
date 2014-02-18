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

#include "config.h"
#include "addressbookapp.h"

// Qt
#include <QCoreApplication>

int main(int argc, char** argv)
{
    QCoreApplication::setOrganizationName("Canonical");
    QCoreApplication::setOrganizationDomain("canonical.com");
    QCoreApplication::setApplicationName("Address Book App");

    AddressBookApp application(argc, argv);

    if (!application.setup()) {
        return 0;
    }

    return application.exec();
}

