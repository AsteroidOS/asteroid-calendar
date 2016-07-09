/*
 * Copyright (C) 2015 - Florent Revest <revestflo@gmail.com>
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

import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0
import org.asteroid.controls 1.0

Application {
    Calendar {
        id: cal
        anchors.centerIn: parent
        width: DeviceInfo.hasRoundScreen ? parent.width/Math.sqrt(2) : parent.width
        height: DeviceInfo.hasRoundScreen ? parent.height/Math.sqrt(2) : parent.height
        frameVisible: false

        style: CalendarStyle {
            background: LinearGradient {
                start: Qt.point(0, 0)
                end: Qt.point(0, parent.height)
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#79cade" }
                    GradientStop { position: 1.0; color: "#69bfd1" }
                }
            }

            gridVisible: false

            dayOfWeekDelegate: Item {}

            dayDelegate: Item {
                Rectangle {
                    anchors.centerIn: parent
                    width: Math.min(parent.width, parent.height)
                    height: Math.min(parent.width, parent.height)
                    radius: width/2
                    color: "transparent"
                    border.color: "white"
                    border.width: 1
                    visible: styleData.selected
                }

                Text {
                    text: styleData.date.getDate()
                    anchors.centerIn: parent
                    color: styleData.visibleMonth && styleData.valid ? "#FFF" : "#555"
                    font.pixelSize: control.height/13
                }
            }
            navigationBar: Item {
                height: control.height/8
                Text {
                     width: parent.height
                     height: width
                     anchors.verticalCenter: parent.verticalCenter
                     anchors.left: parent.left
                     verticalAlignment: Text.AlignVCenter
                     horizontalAlignment: Text.AlignHCenter
                     text: "<"
                     color: "white"
                     MouseArea {
                         anchors.fill: parent
                         onClicked: control.showPreviousMonth()
                     }
                }
                Text {
                    text: styleData.title
                    color: "#FFF"
                    horizontalAlignment: Text.AlignHCenter
                    anchors.fill: parent
                    font.pixelSize: control.height/11
                }
                Text {
                     width: parent.height
                     height: width
                     anchors.verticalCenter: parent.verticalCenter
                     anchors.right: parent.right
                     verticalAlignment: Text.AlignVCenter
                     horizontalAlignment: Text.AlignHCenter
                     text: ">"
                     color: "white"
                     MouseArea {
                         anchors.fill: parent
                         onClicked: control.showNextMonth()
                     }
                }
                Rectangle {
                    height: 1
                    color: "#b8d6f3"
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: 15
                    anchors.rightMargin: 15
                }
            }
        }
    }
}
