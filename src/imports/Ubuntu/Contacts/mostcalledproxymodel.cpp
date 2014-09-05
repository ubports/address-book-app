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

#include "mostcalledproxymodel.h"

#include <QtContacts/QContactManager>
#include <QtContacts/QContactFilter>
#include <QtContacts/QContactPhoneNumber>
#include <QtContacts/QContactFetchRequest>

#include <QDebug>

using namespace QtContacts;

bool mostCalledContactsModelDataLessThan(const MostCalledContactsModelData &d1, const MostCalledContactsModelData &d2)
{
    return d1.callCount < d2.callCount;
}

MostCalledContactsModel::MostCalledContactsModel(QObject *parent)
    : QAbstractListModel(parent),
      m_sourceModel(0),
      m_currentFetch(0),
      m_manager(new QContactManager("galera")),
      m_maxCount(20),
      m_average(0),
      m_outdated(true),
      m_reloadingModel(false),
      m_aboutToQuit(false)
{
    connect(this, SIGNAL(sourceModelChanged(QAbstractItemModel*)), SLOT(markAsOutdated()));
    connect(this, SIGNAL(maxCountChanged(uint)), SLOT(markAsOutdated()));
    connect(this, SIGNAL(startIntervalChanged(QDateTime)), SLOT(markAsOutdated()));
}

MostCalledContactsModel::~MostCalledContactsModel()
{
    m_aboutToQuit = true;
    m_phones.clear();

    if (m_currentFetch) {
        m_currentFetch->cancel();
    }
}

QVariant MostCalledContactsModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }

    int row = index.row();
    if ((row >= 0) && (row < m_data.size())) {
        switch (role)
        {
        case MostCalledContactsModel::ContactIdRole:
            return m_data[row].contactId;
        case MostCalledContactsModel::PhoneNumberRole:
            return m_data[row].phoneNumber;
        case MostCalledContactsModel::CallCountRole:
            return m_data[row].callCount;
        default:
            return QVariant();
        }
    }
    return QVariant();
}

QHash<int, QByteArray> MostCalledContactsModel::roleNames() const
{
    static QHash<int, QByteArray> roles;
    if (roles.isEmpty()) {
        roles.insert(MostCalledContactsModel::ContactIdRole, "contactId");
        roles.insert(MostCalledContactsModel::PhoneNumberRole, "phoneNumber");
        roles.insert(MostCalledContactsModel::CallCountRole, "callCount");
    }
    return roles;
}

int MostCalledContactsModel::rowCount(const QModelIndex &) const
{
    return m_data.size();
}

QAbstractItemModel *MostCalledContactsModel::sourceModel() const
{
    return m_sourceModel;
}

void MostCalledContactsModel::setSourceModel(QAbstractItemModel *model)
{
    if (m_sourceModel != model) {
        if (m_sourceModel) {
            disconnect(m_sourceModel);
        }

        m_sourceModel = model;
        connect(m_sourceModel, SIGNAL(dataChanged(QModelIndex,QModelIndex)), SLOT(markAsOutdated()));
        connect(m_sourceModel, SIGNAL(rowsInserted(QModelIndex,int,int)), SLOT(markAsOutdated()));
        connect(m_sourceModel, SIGNAL(rowsRemoved(QModelIndex,int,int)), SLOT(markAsOutdated()));
        connect(m_sourceModel, SIGNAL(modelReset()), SLOT(markAsOutdated()));

        Q_EMIT sourceModelChanged(m_sourceModel);
    }
}


uint MostCalledContactsModel::maxCount() const
{
    return m_maxCount;
}

void MostCalledContactsModel::setMaxCount(uint value)
{
    if (m_maxCount != value) {
        m_maxCount = value;
        Q_EMIT maxCountChanged(m_maxCount);
    }
}

int MostCalledContactsModel::callAverage() const
{
    return m_average;
}

QDateTime MostCalledContactsModel::startInterval() const
{
    return m_startInterval;
}

void MostCalledContactsModel::setStartInterval(const QDateTime &value)
{
    if (m_startInterval != value) {
        m_startInterval = value;
        Q_EMIT startIntervalChanged(m_startInterval);
    }
}

QVariant MostCalledContactsModel::getSourceData(int row, int role)
{
    QAbstractItemModel *source = sourceModel();
    if (!source) {
        return QVariant();
    }

    while ((source->rowCount() <= row)  && (source->canFetchMore(QModelIndex()))) {
        source->fetchMore(QModelIndex());
    }

    if (source->rowCount() < row) {
        return QVariant();
    }

    QModelIndex sourceIndex = source->index(row, 0);
    return source->data(sourceIndex, role);
}

void MostCalledContactsModel::update()
{
    // skip update if not necessary
    if (!m_outdated || m_reloadingModel) {
        return;
    }

    if (m_maxCount <= 0) {
        qWarning() << "update model requested with invalid maxCount";
        m_outdated = false;
        return;
    }

    if (!m_startInterval.isValid()) {
        qWarning() << "Update model requested with invalid startInterval";
        m_outdated = false;
        return;
    }

    QAbstractItemModel *source = sourceModel();
    if (!source) {
        qWarning() << "Update model requested with null source model";
        m_outdated = false;
        return;
    }

    m_totalCalls = 0;
    m_phones.clear();
    m_phoneToContactCache.clear();
    m_contactsData.clear();
    queryContacts();
}

void MostCalledContactsModel::queryContacts()
{
    // get all phone in the date inteval
    QHash<int, QByteArray> roles = sourceModel()->roleNames();
    int participantsRole = roles.key("participants", -1);
    int timestampRole = roles.key("timestamp", -1);
    int row = 0;

    Q_ASSERT(participantsRole != -1);
    Q_ASSERT(timestampRole != -1);

    while(true) {
        QVariant date = getSourceData(row, timestampRole);

        // end of source model
        if (date.isNull()) {
            break;
        }

        // exit if date is out of interval
        if (date.toDateTime() < m_startInterval) {
            break;
        }

        QVariant participants = getSourceData(row, participantsRole);
        if (participants.isValid()) {
            Q_FOREACH(const QString phone, participants.toStringList()) {
                m_phones << phone;
            }
        }

        // next row
        row++;
    }

    // query for all phones
    nextContact();
}

void MostCalledContactsModel::nextContact()
{
    if (m_phones.isEmpty()) {
        parseResult();
        return;
    }

    QString nextPhone = m_phones.takeFirst();

    if (m_phoneToContactCache.contains(nextPhone)) {
        registerCall(nextPhone, m_phoneToContactCache.value(nextPhone));
        nextContact();
        return;
    } else {
        QContactFilter filter(QContactPhoneNumber::match(nextPhone));
        QContactFetchHint hint;
        hint.setDetailTypesHint(QList<QContactDetail::DetailType>() << QContactDetail::TypeGuid);

        m_currentFetch = new QContactFetchRequest;
        m_currentFetch->setProperty("PHONE", nextPhone);
        m_currentFetch->setFilter(filter);
        m_currentFetch->setFetchHint(hint);
        m_currentFetch->setManager(m_manager.data());

        connect(m_currentFetch,
                SIGNAL(stateChanged(QContactAbstractRequest::State)),
                SLOT(fetchContactIdDone()));

        m_currentFetch->start();
    }
}

void MostCalledContactsModel::fetchContactIdDone()
{
    Q_ASSERT(m_currentFetch);

    if (m_aboutToQuit) {
        m_currentFetch->deleteLater();
        m_currentFetch = 0;
        return;
    }

    if (m_currentFetch->state() == QContactAbstractRequest::ActiveState) {
        return;
    }

    if (!m_currentFetch->contacts().isEmpty()) {
        QString id = m_currentFetch->contacts().at(0).id().toString();
        registerCall(m_currentFetch->property("PHONE").toString(), id);
    }
    m_currentFetch->deleteLater();
    m_currentFetch = 0;
    nextContact();
}

void MostCalledContactsModel::registerCall(const QString &phone, const QString &contactId)
{
    if (m_contactsData.contains(contactId)) {
        MostCalledContactsModelData &data = m_contactsData[contactId];
        data.callCount++;
    } else {
        MostCalledContactsModelData data;
        data.contactId = contactId;
        data.phoneNumber = phone;
        data.callCount = 1;
        m_contactsData.insert(contactId, data);
    }
    m_totalCalls++;
}

void MostCalledContactsModel::parseResult()
{
    if (m_aboutToQuit) {
        return;
    }

    Q_EMIT beginResetModel();

    m_reloadingModel = true;
    m_outdated = false;
    m_data.clear();
    m_average = 0;

    if (!m_contactsData.isEmpty()) {
        // sort by callCount
        QList<MostCalledContactsModelData> data = m_contactsData.values();
        qSort(data.begin(), data.end(), mostCalledContactsModelDataLessThan);

        // average
        m_average = qRound(((qreal) (m_totalCalls)) / m_contactsData.size());
        Q_FOREACH(const MostCalledContactsModelData &d, data) {
            if (d.callCount >= m_average) {
                m_data << d;
            }
            if ((uint) m_data.size() > m_maxCount) {
                break;
            }
        }
    }

    m_totalCalls = 0;
    m_phones.clear();
    m_phoneToContactCache.clear();
    m_contactsData.clear();

    Q_EMIT endResetModel();
    m_reloadingModel = false;
    Q_EMIT callAverageChanged(m_average);
    Q_EMIT loaded();
}


void MostCalledContactsModel::markAsOutdated()
{
    // skip if model is being reloaded
    if (m_reloadingModel) {
        return;
    }

    if (!m_outdated) {
        m_outdated = true;
        Q_EMIT outdatedChange(m_outdated);
    }
}


