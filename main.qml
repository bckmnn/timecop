import QtQuick 2.5
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import Qt.labs.settings 1.0
import "TimeEngine.js" as TimeEngine

Window {
    visible: true
    width: 600;
    height: 200;

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
        style: style.progBarStyle
        value: calculator.currentProgressRegular
        x: 10
        y:10
        width: (parent.width - progressRegular.x*3) * calculator.regularTimePart
        Text{
            anchors.centerIn: parent
            property string hours: (calculator.regHoursToGo*-1) < 10 ? "0"+(calculator.regHoursToGo*-1):(calculator.regHoursToGo*-1)
            property string minutes: (calculator.regMinutesToGo*-1) < 10 ? "0"+(calculator.regMinutesToGo*-1):(calculator.regMinutesToGo*-1)
            text:  hours + ":" + minutes + " ("+(calculator.currentProgressRegular*100).toFixed()+"%)"
        }
    }

    ProgressBar{
        id: progressExtra
        style: style.progBarStyle
        anchors.top: progressRegular.top
        anchors.left: progressRegular.right
        anchors.leftMargin: progressRegular.x
        value: calculator.currentProgressMax
        width: (parent.width - progressRegular.x*3) * calculator.extraTimePart
    }

    Timer{
        interval: 1000*60
        repeat: true
        running: true
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

        function update(){
            TimeEngine.update(18,0,0);
            currentProgressRegular = TimeEngine.currentProgressRegular
            currentProgressMax = TimeEngine.currentProgressMax
            regularTimePart = TimeEngine.regularTimePart
            extraTimePart = TimeEngine.extraTimePart
            arrivalTime = TimeEngine.arrivalTime
            endTime = TimeEngine.calculatedEndTime
            maxTime = TimeEngine.calculatedMaxTime
            regMinutesToGo = TimeEngine.diffNowEndTime.minutes
            regHoursToGo = TimeEngine.diffNowEndTime.hours
        }
    }

    Style{
        id: style
    }

    Component.onCompleted: {
        calculator.update();
    }


}
