import QtQuick 2.5
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import Qt.labs.settings 1.0
import "TimeEngine.js" as TimeEngine

Window {
    id: window
    visible: true
    width: 600;
    height: 200;

    function systrayActivated(reason){
        console.log("systray "+reason)
        window.show()
    }

    flags:  Qt.Window | Qt.WindowStaysOnTopHint //| Qt.WindowTransparentForInput

    Component.onCompleted: {
        x = Screen.desktopAvailableWidth - width
        y = Qt.platform.os === "osx" ? 0 : Screen.desktopAvailableHeight - height
    }

    Settings{
        id: settings
        property int regularWorkingTimeHours: 7
        property int regularWorkingTimeMinutes: 0
        property int regularBreakTimeHours: 0
        property int regularBreakTimeMinutes: 50
        property int maximumWorkingTimeHours: 10
        property int maximumWorkingTimeMinutes: 0
        property bool addBreakTimeToRegularDailyWorkingTime: true
    }

    Row{
        x: 10
        y: 50
        spacing: 20
        Column{
            spacing: 10
            Text {
                text: qsTr("Kommt-Zeit:")
            }
            Text {
                text: qsTr("Ende Arbeitszeit:")
            }
            Text {
                text: qsTr("Erreichen Höchstarbeitszeit:")
            }
        }
        Column{
            spacing: 10
            Text {
                text: calculator.arrivalTime.toLocaleTimeString("hh:mm")+ " Uhr"
            }
            Text {
                text: calculator.endTime.toLocaleTimeString("hh:mm")+ " Uhr"
            }
            Text {
                text: calculator.maxTime.toLocaleTimeString("hh:mm")+ " Uhr"
            }
        }
    }

    ProgressBar{
        id: progressRegular
        style: style.regularProgress
        value: calculator.currentProgressRegular
        x: 10
        y:10
        width: (parent.width - progressRegular.x*3) * calculator.regularTimePart
        Text{
            anchors.centerIn: parent
            property string hours: calculator.regHoursToGo < 10 ? "0"+calculator.regHoursToGo:calculator.regHoursToGo
            property string minutes: calculator.regMinutesToGo < 10 ? "0"+calculator.regMinutesToGo:calculator.regMinutesToGo
            text:  hours + ":" + minutes + " ("+(calculator.currentProgressRegular*100).toFixed()+"%)"
            visible: progressExtra.value == 0
        }
    }

    ProgressBar{
        id: progressExtra
        style: style.extraProgress
        anchors.top: progressRegular.top
        anchors.left: progressRegular.right
        anchors.leftMargin: progressRegular.x
        value: calculator.currentProgressMax
        width: (parent.width - progressRegular.x*3) * calculator.extraTimePart
        Text{
            anchors.centerIn: parent
            property string hours: calculator.extraHoursToGo < 10 ? "0"+calculator.extraHoursToGo:calculator.extraHoursToGo
            property string minutes: calculator.extraMinutesToGo < 10 ? "0"+calculator.extraMinutesToGo:calculator.extraMinutesToGo
            text:  hours + ":" + minutes + " ("+(calculator.currentProgressMax*100).toFixed()+"%)"
            visible: progressRegular.value == 1
        }
    }

    Timer{
        interval: 1000*30
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            calculator.update()
        }
    }

    QtObject{
        id: calculator
        property real currentProgressRegular: 0
        property real currentProgressMax: 0
        property real regularTimePart: 0
        property real extraTimePart: 0
        property date arrivalTime: new Date()
        property date endTime: new Date()
        property date maxTime: new Date()
        property int regMinutesToGo: 0
        property int regHoursToGo: 0
        property int extraMinutesToGo: 0
        property int extraHoursToGo: 0

        function update(){
            TimeEngine.update(12,0,0);
            currentProgressRegular = TimeEngine.currentProgressRegular
            currentProgressMax = TimeEngine.currentProgressMax
            regularTimePart = TimeEngine.regularTimePart
            extraTimePart = TimeEngine.extraTimePart
            arrivalTime = TimeEngine.arrivalTime
            endTime = TimeEngine.calculatedEndTime
            maxTime = TimeEngine.calculatedMaxTime
            regMinutesToGo = TimeEngine.diffNowEndTime.minutes <= 0 ?  TimeEngine.diffNowEndTime.minutes*-1 : 0
            regHoursToGo = TimeEngine.diffNowEndTime.hours <= 0 ?  TimeEngine.diffNowEndTime.hours*-1 : 0
            extraMinutesToGo = TimeEngine.diffNowMaxTime.minutes <= 0 ?  TimeEngine.diffNowMaxTime.minutes*-1 : 0
            extraHoursToGo = TimeEngine.diffNowMaxTime.hours <= 0 ?  TimeEngine.diffNowMaxTime.hours*-1 : 0
        }
    }

    Style{
        id: style
    }

}
