
var phoneTypeModel = null
var contactColors = ["#DC3023", "#FF8936", "#FFB95A", "#8DB255", "#749F8D", "#48929B", "#A87CA0"]

// Format contact name to be displayed
function formatToDisplayWithDetails(contact, contactDetail, detailFields, defaultTitle)
{
    if (!contact) {
        return defaultTitle
    }

    var detail = contact.detail(contactDetail)
    var values = ""
    for (var i=0; i < detailFields.length; i++) {
        if (detail) {
            var value = detail.value(detailFields[i]);
            if (value) {
                if (i > 0 && detail) {
                    values += " "
                }
                values += value;
            }
        }
    }

    if (values.length === 0) {
        return defaultTitle
    }

    return values
}

function formatToDisplay(contact, defaultTitle)
{
    if (!contact) {
        return defaultTitle
    }

    var detail = contact.detail(ContactDetail.DisplayLabel)
    if (detail && (detail.label.length > 0)) {
        return detail.label
    }

    detail = contact.detail(ContactDetail.Name)
    if (detail) {
        var fullName = detail.firstName

        if (detail.middleName != "")
            fullName += " " + detail.middleName

        if (detail.lastName != "")
            fullName += " " + detail.lastName

        if (fullName.length > 0) {
            return fullName
        }
    }

    detail = contact.detail(ContactDetail.Organization)
    if (detail) {
        if (detail.name && (detail.name.length > 0)) {
            return detail.name
        }
    }

    var details = contact.details(ContactDetail.PhoneNumber)
    if (details.length > 0) {
        detail = details[0]
        if (detail.number && detail.number.length > 0) {
            return detail.number
        }
    }

    details = contact.details(ContactDetail.Email)
    if (details.length > 0) {
        detail = details[0]
        if (detail.emailAddress && detail.emailAddress.length > 0) {
            return detail.emailAddress
        }
    }

    details = contact.details(ContactDetail.OnlineAccount)
    if (details.length > 0) {
        detail = details[0]
        if (detail.accountUri && detail.accountUri.length > 0) {
            return detail.accountUri
        }
    }

    return defaultTitle
}

function getAvatar(contact, defaultValue)
{
    // use this verbose mode to avoid problems with binding loops
    var avatarUrl = defaultValue

    if (!contact) {
        return avatarUrl
    }

    var avatarDetail = contact.detail(ContactDetail.Avatar)
    if (avatarDetail) {
        var avatarValue = avatarDetail.value(Avatar.ImageUrl)
        if (avatarValue && (avatarValue !== "")) {
            avatarUrl = avatarValue
        }
    }
    return avatarUrl
}

function getFavoritePhoneLabel(contact, defaultValue)
{
    var phoneLabel = defaultValue
    if (!contact) {
        return phoneLabel
    }

    if (!phoneTypeModel) {
        phoneTypeModel = Qt.createQmlObject("import Ubuntu.Contacts 0.1; ContactDetailPhoneNumberTypeModel {}",
                                            parent,
                                            "getFavoritePhoneLabel")

    }

    var prefDetail = contact.preferredDetail("TEL")
    if (prefDetail) {
        phoneLabel = phoneTypeModel.get(phoneTypeModel.getTypeIndex(prefDetail)).label
    }
    return phoneLabel
}

function createEmptyContact(phoneNumber, parent)
{
    var details = [ {detail: "PhoneNumber", field: "number", value: phoneNumber},
                    {detail: "EmailAddress", field: "emailAddress", value: ""},
                    {detail: "Name", field: "firstName", value: ""}
                  ]

    var newContact =  Qt.createQmlObject("import QtContacts 5.0; Contact{ }", parent)
    var detailSourceTemplate = "import QtContacts 5.0; %1{ %2: \"%3\" }"
    for (var i=0; i < details.length; i++) {
        var detailMetaData = details[i]
        var newDetail = Qt.createQmlObject(detailSourceTemplate.arg(detailMetaData.detail)
                                        .arg(detailMetaData.field)
                                        .arg(detailMetaData.value), parent)
        newContact.addDetail(newDetail)
    }
    return newContact
}

function isNewContact(contact)
{
    return (contact && (contact.contactId === "qtcontacts:::"))
}

function contactColor(name)
{
    var hash = Contacts.qHash(name)
    return contactColors[(hash % contactColors.length)]
}
