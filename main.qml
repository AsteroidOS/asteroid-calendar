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

import QtQuick 2.4
import org.nemomobile.calendar 1.0
import org.asteroid.controls 1.0

Application {
    centerColor: "#00ccb2"
    outerColor: "#00322c"
    property color overlayColor: "#209283"

    property date currentDate: new Date()

    property int year: currentDate.getFullYear()
    property int month: currentDate.getMonth()+1
    property int day: currentDate.getDate()

    function zeroPadding(i) {
        if (i > 9) return i
        else       return "0" + i
    }

    Component  { id: eventDialogLayer;   EventDialog   { } }
    Component  { id: monthSelectorLayer; MonthSelector { } }
    LayerStack {
        id: layerStack
        firstPage: firstPageComponent
    }

    AgendaModel {
        id: agendaModel
        startDate: new Date(year, month, day)
        endDate: startDate
    }

    Component {
        id: firstPageComponent

        Item {
            property int daySelectorHeight: height*5/7
            property int dayInfoHeight: height/7
            onDaySelectorHeightChanged: agenda.contentY = -daySelectorHeight-dayInfoHeight

            ListView {
                id: agenda
                anchors.fill: parent
                model: agendaModel
                NumberAnimation on contentY {
                    id: yAnimation
                    duration: 200
                }
                onMovementEnded: {
                    if(contentY < 0) {
                        if(contentY > -daySelectorHeight/2) {
                            yAnimation.to = -dayInfoHeight
                            yAnimation.start()
                        } else {
                            yAnimation.to = -daySelectorHeight-dayInfoHeight
                            yAnimation.start()
                        }
                    }
                }
                delegate: Item {
                    height: agenda.contentY >= -dayInfoHeight ? dayInfoHeight*1.7 : dayInfoHeight
                    width: parent.width
                    Behavior on height { NumberAnimation { duration: 100 } }

                    Text {
                        id: hour
                        text: Qt.formatTime(model.occurrence.startTime)
                        color: "white"
                        horizontalAlignment: Text.AlignRight
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        width: parent.width/3
                        font.pixelSize: parent.height/2.5
                    }
                    Text {
                        id: title
                        color: "white"
                        anchors.left: hour.right
                        anchors.right: parent.right
                        anchors.leftMargin: 20
                        text: model.event.displayLabel
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: parent.height/2.5
                    }
                }
                header: Item { height: daySelectorHeight + dayInfoHeight }
                footer: Item { height: Math.max(2*dayInfoHeight, agenda.height-(agenda.count+1)*dayInfoHeight) }
            }

            IconButton {
                id: add
                width: dayInfoHeight
                height: dayInfoHeight
                anchors.bottom: parent.bottom
                anchors.bottomMargin: dayInfoHeight/2
                anchors.horizontalCenter: parent.horizontalCenter
                enabled: opacity == 1.0
                opacity: agenda.contentY >= -dayInfoHeight ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 200 } }
                iconColor: "white"
                pressedIconColor: "lightgrey"
                iconName:  "ios-add-circle-outline"
                onClicked: layerStack.push(eventDialogLayer)
            }

            Item {
                id: daySelector
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.left: parent.left
                height: {
                    if(agenda.contentY >= -dayInfoHeight)                  return 0;
                    if(agenda.contentY < -daySelectorHeight-dayInfoHeight) return daySelectorHeight
                    else                                                   return -agenda.contentY-dayInfoHeight
                }
                visible: height > 0
                enabled: height > 0

                Rectangle {
                    id: monthInfo
                    color: overlayColor
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 2*parent.height*dayInfoHeight/daySelectorHeight

                    Text {
                        anchors.fill: parent
                        color: "white"
                        text: Qt.locale().monthName(month-1, Locale.LongFormat)
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: height/4
                        font.capitalization: Font.Capitalize
                    }
                }

                MouseArea {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 2*monthInfo.height
                    onClicked: layerStack.push(monthSelectorLayer)
                }

                ListView {
                    id: dayLV
                    anchors.top: monthInfo.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    model: new Date(year, month, 0).getDate();
                    orientation: ListView.Horizontal

                    delegate: Item {
                        width: dayLV.width/2.3
                        height: dayLV.height

                        Image {
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectFit
                            opacity: parent.ListView.isCurrentItem ? 1.0 : 0.0
                            Behavior on opacity { NumberAnimation { duration: 200 } }
                            source: "qrc:/day_background.png"
                        }

                        Text {
                            text: Qt.locale().dayName(new Date(year, month-1, index+1).getDay(), Locale.ShortFormat) +
                                  "\n" + (index+1) + "\n"
                            color: "white"
                            anchors.centerIn: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: parent.height/10
                            font.capitalization: Font.Capitalize
                            scale: parent.ListView.isCurrentItem ? 1.3 : 1
                            Behavior on scale { NumberAnimation { duration: 200 } }
                        }

                        MouseArea {
                            enabled: parent.ListView.isCurrentItem
                            anchors.fill: parent
                            onClicked: {
                                yAnimation.to = -dayInfoHeight
                                yAnimation.start()
                            }
                        }
                    }

                    preferredHighlightBegin: width/2 - dayLV.width/5
                    preferredHighlightEnd: width/2 + dayLV.width/5
                    highlightRangeMode: ListView.StrictlyEnforceRange
                    snapMode: ListView.SnapToItem

                    currentIndex: day-1
                    onCurrentIndexChanged: day = currentIndex + 1
                    spacing: 1/count
                }
            }

            Rectangle {
                id: dayInfo
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: daySelector.bottom
                height: dayInfoHeight
                color: overlayColor
                Text {
                    anchors.fill: parent
                    color: "white"
                    text: agenda.count + " Events on " + Qt.locale().dayName(new Date(year, month-1, day).getDay(), Locale.ShortFormat) + " " + zeroPadding(day) + "/" + month + "/" + zeroPadding(year-2000)
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: height/2.5
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        yAnimation.to = -dayInfoHeight
                        yAnimation.start()
                    }
                }
            }

            Rectangle {
                anchors.top: dayInfo.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: dayInfo.height/5
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#66000000" }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }
        }
    }
}
