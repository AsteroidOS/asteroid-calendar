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
import org.asteroid.controls 1.0

Item {
    id: root
    property var pop

    Label {
        id: title
        //% "Select a date:"
        text: qsTrId("id-date-selection")
        height: Dims.h(20)
        font.pixelSize: Dims.l(6)
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }

    Row {
        id: dateSelector
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: title.bottom
        height: Dims.h(60)

        CircularSpinner {
            id: monthLV
            height: parent.height
            width: parent.width/2
            model: 12
            showSeparator: true
            delegate: SpinnerDelegate { text: Qt.locale().monthName(index, Locale.ShortFormat) }
        }

        Spinner {
            id: yearLV
            height: parent.height
            width: parent.width/2
            model: 100
            delegate: SpinnerDelegate { text: index+2000 }
        }
   }

    Component.onCompleted: {
        monthLV.currentIndex = month-1;
        yearLV.currentIndex = year-2000;
    }

    IconButton {
        iconName: "ios-checkmark-circle-outline"
        onClicked: {
            month = monthLV.currentIndex+1
            year = yearLV.currentIndex+2000

            root.pop();
        }
    }
}
