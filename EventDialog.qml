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
import org.nemomobile.time 1.0
import org.nemomobile.calendar 1.0
import org.asteroid.controls 1.0

Item {
    id: root
    property var pop
    property var event

    function zeroPadding(i) {
        if (i > 9) return i
        else       return "0" + i
    }

    Text {
        id: title
        color: "white"
        text: typeof event === 'undefined' ? qsTr("New Event").toUpperCase() : qsTr("Edit Event").toUpperCase()
        height: Dims.h(15)
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }

    Row {
        id: timeSelector
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: title.bottom
        anchors.topMargin: Dims.h(5)
        height: Dims.h(28)

        ListView {
            id: hourLV
            height: parent.height
            width: Dims.w(50)
            clip: true
            spacing: Dims.h(2)
            model: 24
            delegate: Item {
                width: hourLV.width
                height: Dims.h(10)
                Text {
                    text: index
                    anchors.centerIn: parent
                    color: parent.ListView.isCurrentItem ? "white" : "lightgrey"
                    scale: parent.ListView.isCurrentItem ? 1.5 : 1
                    Behavior on scale { NumberAnimation { duration: 200 } }
                    Behavior on color { ColorAnimation { } }
                }
            }
            preferredHighlightBegin: height / 2 - Dims.h(5)
            preferredHighlightEnd: height / 2 + Dims.h(5)
            highlightRangeMode: ListView.StrictlyEnforceRange
        }

        Rectangle {
            width: 1
            height: parent.height*0.8
            color: "lightgrey"
            anchors.verticalCenter: parent.verticalCenter
        }

        ListView {
            id: minuteLV
            height: parent.height
            width: Dims.w(50)
            clip: true
            spacing: Dims.h(2)
            model: 60
            delegate: Item {
                width: minuteLV.width
                height: Dims.h(10)
                Text {
                    text: zeroPadding(index)
                    anchors.centerIn: parent
                    color: parent.ListView.isCurrentItem ? "white" : "lightgrey"
                    scale: parent.ListView.isCurrentItem ? 1.5 : 1
                    Behavior on scale { NumberAnimation { duration: 200 } }
                    Behavior on color { ColorAnimation { } }
                }
            }
            preferredHighlightBegin: height / 2 - Dims.h(5)
            preferredHighlightEnd: height / 2 + Dims.h(5)
            highlightRangeMode: ListView.StrictlyEnforceRange
        }
    }

    TextField {
        id: titleField
        width: Dims.w(80)
        anchors.top: timeSelector.bottom
        anchors.topMargin: Dims.h(10)
        anchors.horizontalCenter: parent.horizontalCenter
        previewText: qsTr("Title")
    }

    HandWritingKeyboard {
        anchors.fill: parent
    }

    IconButton {
        iconName: "ios-trash-circle"
        iconColor: "white"
        pressedIconColor: "lightgrey"
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
        anchors.left: typeof event !== 'undefined' ? parent.horizontalCenter : undefined
        anchors.leftMargin: Dims.w(2)
        anchors.horizontalCenter: typeof event !== 'undefined' ? undefined : parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Dims.iconButtonMargin

        iconName: typeof event !== 'undefined' ? "ios-checkmark-circle-outline" : "ios-add-circle-outline"
        iconColor: "white"
        pressedIconColor: "lightgrey"

        onClicked: {
            if(typeof event !== 'undefined')
                Calendar.removeAll(event.uniqueId)

            event = Calendar.createNewEvent()

            if(titleField.text.length)
                event.displayLabel = titleField.text
            else
                event.displayLabel = qsTr("Untitled event")
            event.location = "Event Location"
            event.description = "Event Description"

            event.recur = CalendarEvent.RecurOnce
            event.unsetRecurEndDate()
            event.reminder = CalendarEvent.ReminderNone

            event.setStartTime(new Date(year, month, day, hourLV.currentIndex, minuteLV.currentIndex), CalendarEvent.SpecLocalZone)
            event.setEndTime(new Date(year, month, day, (hourLV.currentIndex+1)%24, minuteLV.currentIndex), CalendarEvent.SpecLocalZone)
            event.allDay = false

            event.calendarUid = Calendar.defaultNotebook
            event.save()

            root.pop();
        }
    }

    WallClock { id: wallClock }

    Component.onCompleted: {
        if (typeof event === 'undefined') {
            hourLV.currentIndex = wallClock.time.getHours();
            minuteLV.currentIndex = wallClock.time.getMinutes();
        }
        else {
            hourLV.currentIndex   = event.startTime.getHours();
            minuteLV.currentIndex = event.startTime.getMinutes();
            titleField.text = event.displayLabel
        }
    }
}
