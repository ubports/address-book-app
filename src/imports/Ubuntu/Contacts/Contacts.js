
var phoneTypeModel = null

// Format contact name to be displayed
function formatToDisplay(contact, contactDetail, detailFields, defaultTitle) {
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
