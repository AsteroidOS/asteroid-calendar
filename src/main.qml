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
import org.nemomobile.calendar 1.0
import Nemo.Configuration 1.0
import org.asteroid.controls 1.0
import org.asteroid.utils 1.0

Application {
    id: app

    centerColor: "#EA9C14"
    outerColor: "#5E3F08"
    property color overlayColor: "#b07414"

    property date currentDate: new Date()

    property int year: currentDate.getFullYear()
    property int month: currentDate.getMonth()+1
    property int day: currentDate.getDate()

    function zeroPadding(i) {
        if (i > 9) return i
        else       return "0" + i
    }

    ConfigurationValue {
        id: use12H
        key: "/org/asteroidos/settings/use-12h-format"
        defaultValue: false
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
            onDaySelectorHeightChanged: agenda.contentY = -daySelectorHeight

            function animateToDayView() {
                yAnimation.to = DeviceInfo.hasRoundScreen ? -dayInfoHeight : 0
                yAnimation.start()
            }
            property bool isDayView: agenda.contentY >= -dayInfoHeight

            function animateToMonthView() {
                yAnimation.to = -daySelectorHeight
                yAnimation.start()
            }

            ListView {
                id: agenda
                anchors.fill: parent
                clip: true
                anchors.topMargin: dayInfoHeight
                model: agendaModel
                NumberAnimation on contentY {
                    id: yAnimation
                    duration: 200
                }
                onMovementEnded: {
                    if(!isDayView) {
                        if(contentY > -daySelectorHeight/2) animateToDayView()
                        else animateToMonthView()
                    }
                }
                delegate: MouseArea {
                    height: agenda.contentY > -daySelectorHeight/2 ? dayInfoHeight*1.7 : dayInfoHeight
                    width: parent.width
                    Behavior on height { NumberAnimation { duration: 100 } }

                    Label {
                        id: hour
                        text: Qt.formatTime(model.occurrence.startTime, use12H.value ? "hh:mm AP" : "hh:mm")
                        horizontalAlignment: Text.AlignRight
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        width: parent.width/3
                        font.pixelSize: use12H.value ? parent.height/3.3 : parent.height/2.5
                    }
                    Label {
                        id: title
                        anchors.left: hour.right
                        anchors.right: parent.right
                        anchors.leftMargin: 20
                        text: model.event.displayLabel
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: parent.height/2.5
                    }

                    onClicked: layerStack.push(eventDialogLayer, {"event": model.event})
                }
                header: Item { height: daySelectorHeight }
                footer: Item { height: Math.max(2*dayInfoHeight, agenda.height-agenda.count*dayInfoHeight*1.7) - (DeviceInfo.hasRoundScreen ? dayInfoHeight/2 : 0) }
            }

            IconButton {
                id: add
                enabled: opacity == 1.0
                opacity: !isDayView ? 0.0 : 1.0
                Behavior on opacity { NumberAnimation { duration: 200 } }
                iconName:  "ios-add-circle-outline"
                onClicked: layerStack.push(eventDialogLayer)
            }

            Item {
                id: daySelector
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.left: parent.left
                height: {
                    if(isDayView)    return 0;
                    if(agenda.contentY < -daySelectorHeight) return daySelectorHeight
                    else                                     return -agenda.contentY -
                        (DeviceInfo.hasRoundScreen ? 0 : (daySelectorHeight+agenda.contentY)/(daySelectorHeight)*dayInfoHeight)
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

                    Label {
                        anchors.fill: parent
                        text: Qt.locale().monthName(month-1, Locale.LongFormat)
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: height/4
                        font.capitalization: Font.Capitalize
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: layerStack.push(monthSelectorLayer)
                    }
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

                        Label {
                            text: Qt.locale().dayName(new Date(year, month-1, index+1).getDay(), Locale.ShortFormat) +
                                  "\n" + (index+1)
                            anchors.centerIn: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: parent.height/10
                            font.capitalization: Font.Capitalize
                            scale: parent.ListView.isCurrentItem ? 1.5 : 1
                            Behavior on scale { NumberAnimation { duration: 200 } }
                        }

                        MouseArea {
                            enabled: parent.ListView.isCurrentItem
                            anchors.fill: parent
                            onClicked: animateToDayView()
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
                anchors.topMargin: {
                    if(agenda.contentY >= 0)  return dayInfoHeight
                    if(!isDayView) return 0
                    else return dayInfoHeight - daySelector.height
                }
                Component.onCompleted: if(!DeviceInfo.hasRoundScreen) anchors.topMargin=0
                height: dayInfoHeight
                color: overlayColor
                Label {
                    anchors.fill: parent
                    //% "%1 Events on %2 %3/%4/%5"
                    text: qsTrId("id-events-recap").arg(agenda.count).arg(Qt.locale().dayName(new Date(year, month-1, day).getDay(), Locale.ShortFormat)).arg(zeroPadding(day)).arg(month).arg(zeroPadding(year-2000))
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: height/2.5
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: animateToDayView()
                }
            }
            Rectangle {
                id: shadow
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
