/*
 * Copyright (C) 2016 - Florent Revest <revestflo@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.9
import Nemo.Time 1.0
import Nemo.Configuration 1.0
import org.nemomobile.calendar 1.0
import org.asteroid.controls 1.0
import org.asteroid.utils 1.0

Item {
    id: root
    property var pop
    property var event

    function zeroPadding(i) {
        if (i > 9) return i
        else       return "0" + i
    }

    ConfigurationValue {
        id: use12H

        key: "/org/asteroidos/settings/use-12h-format"
        defaultValue: false
    }

    PageHeader {
        id: title

        //% "New Event"
        property string newEventText: qsTrId("id-new-event")
        //% "Edit Event"
        property string editEventText: qsTrId("id-edit-event")
        text: typeof event === 'undefined' ? newEventText : editEventText
    }

    Row {
        id: timeSelector

        anchors {
            left: parent.left
            leftMargin: DeviceSpecs.hasRoundScreen ? Dims.w(10) : 0
            right: parent.right
            rightMargin: DeviceSpecs.hasRoundScreen ? Dims.w(10) : 0
            top: title.bottom
        }
        height: Dims.h(38)
        width: DeviceSpecs.hasRoundScreen ? Dims.w(80) : Dims.w(100)

        property int spinnerWidth: use12H.value ? timeSelector.width / 3 : timeSelector.width / 2

        CircularSpinner {
            id: hourLV

            height: parent.height
            width: parent.spinnerWidth
            model: use12H.value ? 12 : 24
            showSeparator: true
            delegate: SpinnerDelegate { text: (index === 0 && use12H.value) ? "12" : ("0" + index).slice(-2) }
        }

        CircularSpinner {
            id: minuteLV

            height: parent.height
            width: parent.spinnerWidth
            model: 60
            showSeparator: use12H.value
        }

        Spinner {
            id: amPmLV

            height: parent.height
            width: parent.spinnerWidth
            model: 2
            delegate: SpinnerDelegate { text: index === 0 ? "AM" : "PM" }
        }
    }

    TextField {
        id: titleField

        width: Dims.w(80)
        anchors.top: timeSelector.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        //% "Title"
        previewText: qsTrId("id-title-field")
    }

    HandWritingKeyboard {
        anchors.fill: parent
    }

    IconButton {
        iconName: "ios-trash-circle"
        visible: typeof event !== 'undefined'
        anchors.right: parent.horizontalCenter
        anchors.rightMargin: Dims.w(2)
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Dims.iconButtonMargin
        onClicked: {
            Calendar.removeAll(event.uniqueId)
            root.pop()
        }
    }

    IconButton {
        iconName: typeof event !== 'undefined' ? "ios-checkmark-circle-outline" : "ios-add-circle-outline"
        anchors.left: typeof event !== 'undefined' ? parent.horizontalCenter : undefined
        anchors.leftMargin: Dims.w(2)
        anchors.horizontalCenter: typeof event !== 'undefined' ? undefined : parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Dims.iconButtonMargin
        onClicked: {
            if(typeof event !== 'undefined')
                Calendar.removeAll(event.uniqueId)

            event = Calendar.createNewEvent()

            if(titleField.text.length)
                event.displayLabel = titleField.text
            else //% "Untitled event"
                event.displayLabel = qsTrId("id-untitled-event")
            event.location = "Event Location"
            event.description = "Event Description"

            event.recur = CalendarEvent.RecurOnce
            event.unsetRecurEndDate()
            event.reminder = -1  // any negative number means "no reminder"

            var hour = hourLV.currentIndex;
            if(use12H.value)
                hour += amPmLV.currentIndex * 12;

            event.setStartTime(new Date(year, month, day, hour, minuteLV.currentIndex), CalendarEvent.SpecLocalZone)
            event.setEndTime(new Date(year, month, day, (hour+1)%24, minuteLV.currentIndex), CalendarEvent.SpecLocalZone)
            event.allDay = false

            event.calendarUid = Calendar.defaultNotebook
            event.save()

            root.pop();
        }
    }

    WallClock { id: wallClock }

    Component.onCompleted: {
        if (typeof event === 'undefined') {
            var hour = wallClock.time.getHours();
            if(use12H.value) {
                amPmLV.currentIndex = hour / 12;
                hour = hour % 12;
            }

            hourLV.currentIndex = hour;
            minuteLV.currentIndex = wallClock.time.getMinutes();
        }
        else {
            var hour = event.startTime.getHours();
            if(use12H.value) {
                amPmLV.currentIndex = hour / 12;
                hour = hour % 12;
            }

            hourLV.currentIndex   = hour;
            minuteLV.currentIndex = event.startTime.getMinutes();
            titleField.text = event.displayLabel
        }
    }
}
