/*
 * Copyright (C) 2022 - Timo Könnecke <github.com/eLtMosen>
 *               2016 - Florent Revest <revestflo@gmail.com>
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
import QtGraphicalEffects 1.15
import org.nemomobile.calendar 1.0
import Nemo.Configuration 1.0
import org.asteroid.controls 1.0
import org.asteroid.utils 1.0

Application {
    id: app

    centerColor: "#CC7700"
    outerColor: "#0C0300"

    property color overlayColor: "#77000000"
    property color accentColor: "#aaCC5800"

    property date currentDate: new Date()

    property int year: currentDate.getFullYear()
    property int month: currentDate.getMonth()
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
        startDate: new Date(year, month, day, 0, 0, 0)
        endDate: new Date(year, month, day, 23, 59, 59)
    }

    Component {
        id: firstPageComponent

        Item {
            property bool isDayView: agenda.contentY >= -dayInfoHeight
            property int daySelectorHeight: height * 5 / 7
            property int dayInfoHeight: height / 7

            onDaySelectorHeightChanged: agenda.contentY = -daySelectorHeight

            function animateToDayView() {
                yAnimation.to = DeviceInfo.hasRoundScreen ? -dayInfoHeight : 0
                yAnimation.start()
            }

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
                        if(contentY > -daySelectorHeight / 2) animateToDayView()
                        else animateToMonthView()
                    }
                }

                delegate: MouseArea {
                    height: agenda.contentY > -daySelectorHeight / 2 ?
                                dayInfoHeight * 1.186 :
                                DeviceInfo.hasRoundScreen ?
                                    dayInfoHeight * .94 :
                                    dayInfoHeight
                    width: parent.width

                    Behavior on height { NumberAnimation { duration: 200 } }

                    DropShadow {
                        anchors.fill: hour
                        transparentBorder: true
                        horizontalOffset: 1
                        verticalOffset: 1
                        radius: 1
                        samples: 3
                        spread: .2
                        source: hour
                        color: overlayColor
                    }

                    DropShadow {
                        anchors.fill: title
                        transparentBorder: true
                        horizontalOffset: 1
                        verticalOffset: 1
                        radius: 1
                        samples: 3
                        spread: .2
                        source: title
                        color: overlayColor
                    }

                    Label {
                        id: hour

                        text: Qt.formatTime(model.occurrence.startTime, "hh:mm")
                        anchors {
                            verticalCenter: parent.verticalCenter
                            verticalCenterOffset: -parent.height * .02
                            left: parent.left
                            leftMargin: parent.width * .23
                        }
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        width: parent.width / 4
                        font.pixelSize: parent.height / 2
                        font.styleName: "SemiCondensed SemiBold"

                        Label {
                            id: ap

                            text: Qt.formatTime(model.occurrence.startTime, use12H.value ? "AP" : "")
                            anchors {
                                bottom: parent.top
                                bottomMargin: -parent.height * .34
                                left: parent.right
                                leftMargin: -parent.width * .94
                            }
                            opacity: .8
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                            width: parent.width
                            font.pixelSize: parent.height / 2.8
                            font.styleName: "SemiCondensed Medium"
                        }
                    }

                    Label {
                        id: title

                        text: model.event.displayLabel
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                        anchors {
                            left: hour.right
                            right: parent.right
                            leftMargin: parent.width * .04
                            verticalCenter: hour.verticalCenter
                        }
                        font.pixelSize: parent.height / 2
                        font.styleName: "SemiCondensed"

                    }

                    Item {
                        anchors {
                            bottom: parent.bottom
                            horizontalCenter: parent.horizontalCenter
                        }
                        height: parent.height * .04
                        width: parent.width

                        LinearGradient {
                                anchors.fill: parent
                                start: Qt.point(300, 0)
                                end: Qt.point(0, 0)
                                gradient: Gradient {
                                    GradientStop { position: .1; color: "#00000000" }
                                    GradientStop { position: .5; color: "#44000000" }
                                    GradientStop { position: .9; color: "#00000000" }
                                }
                            }
                    }

                    onClicked: layerStack.push(eventDialogLayer, {"event": model.event})
                }

                header: Item { height: daySelectorHeight }
                footer: Item { height: Math.max(2 * dayInfoHeight, agenda.height - agenda.count * dayInfoHeight * 1.186) - (DeviceInfo.hasRoundScreen ? dayInfoHeight / 2 : 0) }
            }

            Rectangle {
                id: addBubble

                anchors {
                    centerIn: parent
                    verticalCenterOffset: parent.height * .366
                }
                scale: agenda.count > 0 ? 1 : 1.4
                opacity: !isDayView ? 0 : 1
                width: parent.height * .18
                height: width
                radius: width
                color: overlayColor

                Behavior on opacity { NumberAnimation { duration: 100 } }

                IconButton {
                    id: addIcon

                    iconName:  "ios-add"
                    anchors.centerIn: addBubble
                    enabled: opacity === 1.0
                    onClicked: layerStack.push(eventDialogLayer)
                }
            }


            Item {
                id: daySelector

                anchors {
                    top: parent.top
                    right: parent.right
                    left: parent.left
                }
                height: {
                    if(isDayView)    return 0;
                    if(agenda.contentY < -daySelectorHeight) return daySelectorHeight
                    else                                     return -agenda.contentY
                }
                visible: height > 0
                enabled: height > 0

                Rectangle {
                    id: monthInfo

                    color: overlayColor
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                    }
                    height: 2 * parent.height * dayInfoHeight / daySelectorHeight

                    Label {
                        text: year
                        anchors {
                            fill: parent
                            bottomMargin: Dims.h(10)
                        }
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font {
                            pixelSize: parent.height/5
                            styleName: "Light"
                            kerning: !yAnimation.running
                            preferShaping: !yAnimation.running
                        }
                    }

                    Label {
                        id: monthDisplay

                        text: Qt.locale().monthName(month, Locale.LongFormat)
                        anchors {
                            fill: parent
                            topMargin: Dims.h(7)
                        }
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font {
                            pixelSize: parent.height/3.2
                            styleName: "Condensed"
                            capitalization: Font.Capitalize
                            kerning: !yAnimation.running
                            preferShaping: !yAnimation.running
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: layerStack.push(monthSelectorLayer)
                    }
                }

                ListView {
                    id: dayLV
                    anchors {
                        top: monthInfo.bottom
                        horizontalCenter: parent.horizontalCenter
                        bottom: parent.bottom
                    }
                    width: Dims.w(84)
                    model: new Date(year, month+1, 0).getDate();
                    orientation: ListView.Horizontal

                    delegate: Item {
                        id: listRow

                        width: dayLV.width / 2.5
                        height: dayLV.height
                        clip: false

                        Image {
                            anchors.centerIn: parent
                            width: parent.height
                            height: width
                            smooth: !yAnimation.running
                            opacity: listRow.ListView.isCurrentItem ? 1 : 0
                            source: index === 0 ? "day-background-leftstop.svg" : (index+1) ===  dayLV.count ? "day-background-rightstop.svg" : "day-background.svg"

                            Behavior on opacity { NumberAnimation { duration: 150 } }
                        }

                        DropShadow {
                            anchors.fill: countBubble
                            visible: listRow.ListView.isCurrentItem && agenda.count > 0
                            opacity: listRow.ListView.isCurrentItem && agenda.count > 0 ? 1 : 0
                            transparentBorder: true
                            horizontalOffset: 1.4
                            verticalOffset: 1.4
                            radius: 1
                            samples: 3
                            spread: .2
                            source: countBubble
                            color: overlayColor
                        }

                        Rectangle {
                            id: countBubble

                            visible: listRow.ListView.isCurrentItem && agenda.count > 0
                            opacity: listRow.ListView.isCurrentItem && agenda.count > 0 ? 1 : 0
                            anchors {
                                centerIn: parent
                                verticalCenterOffset: -parent.height * .3
                                horizontalCenterOffset: index > 8 ? parent.height * .35 : parent.height * .20
                            }
                            width: parent.height * .23
                            height: width
                            radius: width
                            color: accentColor

                            Behavior on opacity { NumberAnimation { duration: 150 } }

                            Label {
                                text: agenda.count
                                anchors {
                                    fill: countBubble
                                    bottomMargin: parent.height * .03
                                }
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font {
                                    pixelSize: parent.height/1.6
                                    styleName: "Condensed Bold"
                                    letterSpacing: -parent.width * .03
                                    kerning: !yAnimation.running
                                    preferShaping: !yAnimation.running
                                }
                            }
                        }

                        DropShadow {
                            anchors.fill: rowShadow
                            transparentBorder: true
                            horizontalOffset: 1.6
                            verticalOffset: 1.6
                            radius: 1
                            samples: 3
                            spread: .2
                            source: rowShadow
                            color: overlayColor
                        }

                        Item {
                            id: rowShadow

                            anchors.fill: parent
                            clip: false

                            Label {
                                text: index + 1
                                clip: false
                                anchors {
                                    centerIn: parent
                                    verticalCenterOffset: listRow.ListView.isCurrentItem ? -Dims.h(4.5) : -Dims.h(.6)
                                }
                                opacity: listRow.ListView.isCurrentItem ? 1 : .6
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font {
                                    pixelSize: parent.height / 2.4
                                    styleName: listRow.ListView.isCurrentItem ? "Condensed Bold" : "Condensed Medium"
                                    capitalization: Font.Capitalize
                                    letterSpacing: -parent.width * .02
                                    kerning: !yAnimation.running
                                    preferShaping: !yAnimation.running
                                }
                                scale: listRow.ListView.isCurrentItem ? 1.5 : 1

                                Behavior on scale { NumberAnimation { duration: 150 } }
                                Behavior on opacity { NumberAnimation { duration: 150 } }
                                Behavior on anchors.verticalCenterOffset { NumberAnimation { duration: 150 } }
                            }

                            Label {
                                text: Qt.locale().dayName(new Date(year, month, index + 1).getDay(), Locale.LongFormat)
                                clip: false
                                anchors {
                                    centerIn: parent
                                    verticalCenterOffset: listRow.ListView.isCurrentItem ? Dims.h(11) : Dims.h(10)
                                }
                                opacity: listRow.ListView.isCurrentItem ? 1 : .7
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font {
                                    pixelSize: parent.height / 9
                                    capitalization: Font.Capitalize
                                    styleName: "SemiCondensed"
                                    kerning: !yAnimation.running
                                    preferShaping: !yAnimation.running
                                }
                                scale: listRow.ListView.isCurrentItem ? 1.5 : 1

                                Behavior on scale { NumberAnimation { duration: 150 } }
                                Behavior on opacity { NumberAnimation { duration: 150 } }
                                Behavior on anchors.verticalCenterOffset { NumberAnimation { duration: 150 } }
                            }
                        }

                        MouseArea {
                            enabled: parent.ListView.isCurrentItem
                            anchors.fill: parent
                            onClicked: animateToDayView()
                        }
                    }

                    preferredHighlightBegin: width / 2 - dayLV.width / 5
                    preferredHighlightEnd: width / 2 + dayLV.width / 5
                    highlightRangeMode: ListView.StrictlyEnforceRange
                    snapMode: ListView.SnapToItem
                    currentIndex: day - 1
                    onCurrentIndexChanged: day = currentIndex + 1
                    spacing: 1 / count
                }
            }

            Label {
                text: year + "/" + zeroPadding(month+1) + "/" + zeroPadding(day)
                opacity: isDayView ? 1 : 0
                anchors {
                    bottom: dayInfo.top
                    bottomMargin: parent.height * .01
                    horizontalCenter: parent.horizontalCenter
                }
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font {
                    pixelSize: parent.height / 16
                    styleName: "SemiCondensed"
                }

                Behavior on opacity { NumberAnimation { duration: 100 } }

                MouseArea {
                    anchors.fill: parent
                    onClicked: !isDayView ? animateToDayView() : animateToMonthView()
                }
            }

            Rectangle {
                id: dayInfo

                anchors {
                    left: parent.left
                    right: parent.right
                    top: daySelector.bottom
                    topMargin: {
                        if(agenda.contentY >= 0)  return dayInfoHeight
                        if(!isDayView) return 0
                        else return dayInfoHeight - daySelector.height
                    }
                }
                Component.onCompleted: if(!DeviceInfo.hasRoundScreen) anchors.topMargin = 0
                height: dayInfoHeight
                color: overlayColor

                Label {
                    //% "%1 Events on %2"
                    text: qsTrId("id-events-recap").arg(agenda.count).arg(Qt.locale().dayName(new Date(year, month, day).getDay(), Locale.ShortFormat))
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: height / 2.2
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: !isDayView ? animateToDayView() : animateToMonthView()
                }
            }
        }
    }
}
