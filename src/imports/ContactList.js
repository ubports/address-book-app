/****************************************************************************
**
** Copyright (C) 2013 Canonical Ltd
**
****************************************************************************/

var sectionData = [];
var _sections = [];

function initSectionData(list) {
    if (!list || !list.model) {
        return;
    }

    sectionData = [];
    _sections = [];

    var current = "",
        prop = list.section.property,
        item;

    for (var i = 0, count = list.model.contacts.length; i < count; i++) {
        item = list.sectionValueForContact(list.model.contacts[i])
        if (item !== current) {
            current = item;
            _sections.push(current);
            sectionData.push({ index: i, header: current });
        }
    }
}

function getIndexFor(sectionName) {
    var val = sectionData[_sections.indexOf(sectionName)].index;
    return val === 0 || val > 0 ? val : -1;
}
