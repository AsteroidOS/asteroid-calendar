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
import org.asteroid.controls 1.0

Application {
    Calendar {
        id: cal
        anchors.centerIn: parent
        width: DeviceInfo.hasRoundScreen ? parent.width/Math.sqrt(2) : parent.width
        height: DeviceInfo.hasRoundScreen ? parent.height/Math.sqrt(2) : parent.height
        frameVisible: false

        style: CalendarStyle {
            background: Rectangle {
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#69c0ba" }
                    GradientStop { position: 1.0; color: "#2f4d78" }
                }
            }

            gridVisible: false

            dayOfWeekDelegate: Item {}

            dayDelegate: Item {
                Rectangle {
                    id: selectedBackground
                    anchors.centerIn: parent;
                    width: Math.min(parent.width, parent.height)
                    height: Math.min(parent.width, parent.height)
                    radius: width/2; color: "#69c0ba"; opacity: 0
                }

                Text {
                    id: dayText
                    text: styleData.date.getDate()
                    anchors.centerIn: parent
                    color: styleData.visibleMonth && styleData.valid ? "#FFF" : "#BBB"
                    font.pixelSize: control.height/13
                }

                states: [
                   State {
                       name: "pressed"; when: styleData.selected == true
                       PropertyChanges { target: selectedBackground; opacity: .4 }
                       PropertyChanges { target: selectedBackground; scale: 1.3 }
                       PropertyChanges { target: dayText; scale: 1.3 }
                       PropertyChanges { target: dayText; z: 1 }
                   }
                ]

                transitions: [
                    Transition {
                        from: ""
                        to: "pressed"
                        NumberAnimation {
                            properties: "z,scale";
                            easing.type: Easing.OutExpo;
                            duration: 50
                        }
                        NumberAnimation {
                           properties: "opacity";
                           easing.type: Easing.OutExpo;
                           duration: 100
                        }
                    },
                    Transition {
                        from: "pressed"
                        to: ""
                        NumberAnimation {
                           properties: "z,scale";
                           easing.type: Easing.OutExpo;
                           duration: 200
                        }
                        NumberAnimation {
                           properties: "opacity";
                           easing.type: Easing.OutExpo;
                           duration: 300
                        }
                    }
                ]
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
                    color: "white"
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
                    color: "white"
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
