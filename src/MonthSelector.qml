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
import org.asteroid.utils 1.0

Item {
    id: root
    property var pop

    PageHeader {
        id: title

        //% "Month"
        text: qsTrId("id-month-page")
    }

    Row {
        id: dateSelector

        anchors {
            left: parent.left
            leftMargin: DeviceSpecs.hasRoundScreen ? Dims.w(10) : 0
            right: parent.right
            rightMargin: DeviceSpecs.hasRoundScreen ? Dims.w(10) : 0
            top: title.bottom
        }
        height: Dims.h(60)

        CircularSpinner {
            id: monthLV

            height: parent.height
            width: parent.width / 2
            model: 12
            showSeparator: true
            delegate: SpinnerDelegate { text: Qt.locale().monthName(index, Locale.ShortFormat) }
        }

        Spinner {
            id: yearLV

            height: parent.height
            width: parent.width / 2
            model: 100
            delegate: SpinnerDelegate { text: index + 2000 }
        }
   }

    Component.onCompleted: {
        monthLV.currentIndex = month;
        yearLV.currentIndex = year - 2000;
    }

    IconButton {
        iconName: "ios-checkmark-circle-outline"
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: Dims.iconButtonMargin
        }
        onClicked: {
            month = monthLV.currentIndex
            year = yearLV.currentIndex + 2000

            root.pop();
        }
    }
}
