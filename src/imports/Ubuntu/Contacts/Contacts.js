// Format contact name to be displayed
function formatToDisplay(contact, contactDetail, detailFields, detail) {
    if (!contact) {
        return ""
    }

    if (!detail) {
        detail = contact.detail(contactDetail)
    }

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

    return values
}
