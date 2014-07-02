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

#ifndef __MOSTCALLEDCONTACTSMODEL_H__
#define __MOSTCALLEDCONTACTSMODEL_H__

#include <QtCore/QAbstractListModel>
#include <QtCore/QScopedPointer>
#include <QtCore/QDateTime>

#include <QtContacts/QContactManager>

struct MostCalledContactsModelData
{
    QString contactId;
    QString phoneNumber;
    int callCount;
};

class MostCalledContactsModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QAbstractItemModel* sourceModel READ sourceModel WRITE setSourceModel NOTIFY sourceModelChanged)
    Q_PROPERTY(uint maxCount READ maxCount WRITE setMaxCount NOTIFY maxCountChanged)
    Q_PROPERTY(int callAverage READ callAverage NOTIFY callAverageChanged)
    Q_PROPERTY(QDateTime startInterval READ startInterval WRITE setStartInterval NOTIFY startIntervalChanged)
    Q_PROPERTY(bool outdated READ outdated NOTIFY outdatedChange)

public:
    enum Role {
        ContactIdRole = 0,
        PhoneNumberRole,
        CallCountRole
    };

    MostCalledContactsModel(QObject *parent=0);
    ~MostCalledContactsModel();

    QVariant data(const QModelIndex &index, int role) const;
    QHash<int, QByteArray> roleNames() const;
    int rowCount(const QModelIndex&) const;

    QAbstractItemModel *sourceModel() const;
    void setSourceModel(QAbstractItemModel *model);

    uint maxCount() const;
    void setMaxCount(uint value);

    int callAverage() const;
    bool outdated() const;

    QDateTime startInterval() const;
    void setStartInterval(const QDateTime &value);

    Q_INVOKABLE void update();

Q_SIGNALS:
    void maxCountChanged(uint value);
    void callAverageChanged(int value);
    void startIntervalChanged(const QDateTime &value);
    void sourceModelChanged(QAbstractItemModel *value);
    void outdatedChange(bool value);

private Q_SLOTS:
    void markAsOutdated();

private:
    QAbstractItemModel *m_sourceModel;
    QScopedPointer<QtContacts::QContactManager> m_manager;
    QList<MostCalledContactsModelData> m_data;
    uint m_maxCount;
    int m_average;
    QDateTime m_startInterval;
    bool m_outdated;
    bool m_reloadingModel;

    QString fetchContactId(const QString &phoneNumber);
    QVariant getSourceData(int row, int role);
};


#endif
