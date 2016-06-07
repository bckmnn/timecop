import QtQuick 2.5
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import Qt.labs.settings 1.0
import QtQml.StateMachine 1.0 as DSM
import QtQuick.Dialogs 1.1
import "TimeEngine.js" as TimeEngine

Window {
    id: window
    visible: false
    width: 600;
    height: 200;

    function systrayActivated(reason){
        console.log("systray "+reason)
        moveWindow();
        window.show()
    }

    function moveWindow(){
        window.x = Screen.width - window.width
        window.y = Qt.platform.os === "osx" ? 0 : Screen.height - window.height
    }

    flags:  Qt.Window | Qt.WindowStaysOnTopHint //| Qt.WindowTransparentForInput

    Component.onCompleted: {
        moveWindow();
        if(settings.useFirstStartTimeAsArrivalTime){
            var now = new Date();
            if(settings.arrivalTimeDay != now.getDay()){
                settings.arrivalTimeDay = now.getDay()
                settings.arrivalTimeHours = now.getHours()
                settings.arrivalTimeMinutes = now.getMinutes()
                console.log("first start today ... setting arrival time")
            }
        }
    }

    DSM.StateMachine {
        id: stateMachine
        initialState: stateAppStarted
        running: true
        DSM.State {
            id: stateAppStarted
        }
        DSM.State {
            id: stateRegularWorkingTime
        }
        DSM.State {
            id: stateAlertEndWorkingTime
        }
        DSM.State {
            id: stateAlertEndWorkingTimeDismissed
        }
        DSM.State {
            id: stateExtraWorkingTime
        }
        DSM.State {
            id: stateAlertEndExtraTime
        }
        DSM.State {
            id: stateAlertEndExtraTimeDismissed
        }
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
        property int arrivalTimeHours: 0
        property int arrivalTimeMinutes: 0
        property int arrivalTimeDay: 0
        property bool useFirstStartTimeAsArrivalTime: true
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
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        edit.visible = !edit.visible
                    }
                }
                Rectangle{
                    id: edit
                    anchors.fill: parent
                    color: "white"
                    visible: false
                    FocusScope{
                        anchors.fill: parent
                        focus: edit.visible
                        TextInput{
                            id:inputHours
                            anchors.left: parent.left
                            anchors.right: colon.left
                            text: calculator.arrivalTime.getHours()
                            color: acceptableInput ? "green":"red"
                            inputMask: "90"
                            font.bold: true
                            horizontalAlignment: TextInput.AlignHCenter
                            focus: true
                            KeyNavigation.tab: inputMinutes
                            onFocusChanged: {
                                if(focus){
                                    cursorPosition = 0;
                                }
                            }
                        }
                        Text{
                            id: colon
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: ":"
                        }
                        TextInput{
                            id:inputMinutes
                            anchors.left: colon.right
                            anchors.right: parent.right
                            text: calculator.arrivalTime.getMinutes()
                            color: acceptableInput ? "green":"red"
                            inputMask: "90"
                            font.bold: true
                            horizontalAlignment: TextInput.AlignHCenter
                            KeyNavigation.tab: btnAccept
                            onFocusChanged: {
                                if(focus){
                                    cursorPosition = 0;
                                }
                            }
                        }
                        Button{
                            id: btnAccept
                            anchors.left: parent.right
                            text: "Ankunftszeit ändern"
                            isDefault: true
                            onClicked: {
                                if(inputMinutes.acceptableInput && inputHours.acceptableInput){
                                    var hours = parseInt(inputHours.text)
                                    var minutes = parseInt(inputMinutes.text)
                                    settings.arrivalTimeHours = hours
                                    settings.arrivalTimeMinutes = minutes
                                    calculator.update()
                                    edit.visible = false;
                                }
                            }
                        }
                    }
                }
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
        property bool firstCalcDone: false
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

        signal endRegularWorkTime
        signal endExtraWorkTime

        function update(){
            TimeEngine.update(settings.arrivalTimeHours,settings.arrivalTimeMinutes,0);
            currentProgressRegular = TimeEngine.currentProgressRegular
            currentProgressMax = TimeEngine.currentProgressMax
            regularTimePart = TimeEngine.regularTimePart
            extraTimePart = TimeEngine.extraTimePart
            arrivalTime = TimeEngine.arrivalTime
            endTime = TimeEngine.calculatedEndTime
            maxTime = TimeEngine.calculatedMaxTime
            regMinutesToGo = TimeEngine.diffNowEndTime.minutes >= 0 ?  TimeEngine.diffNowEndTime.minutes : 0
            regHoursToGo = TimeEngine.diffNowEndTime.hours >= 0 ?  TimeEngine.diffNowEndTime.hours : 0
            extraMinutesToGo = TimeEngine.diffNowMaxTime.minutes >= 0 ?  TimeEngine.diffNowMaxTime.minutes : 0
            extraHoursToGo = TimeEngine.diffNowMaxTime.hours >= 0 ?  TimeEngine.diffNowMaxTime.hours : 0
            firstCalcDone = true
        }
    }

    MessageDialog {
        property bool showIt: (calculator.regMinutesToGo <= 15 && calculator.regHoursToGo == 0 && calculator.extraHoursToGo > 0 && calculator.extraMinutesToGo > 0) ? true:false
        id: alertRegularWorkTime
        title: "Erinnerung"
        text: "In 15 Minuten endet die reguläre Arbeitszeit!"
        onShowItChanged: {
            console.log("alert reg")
            if(showIt){
                window.showNormal();
                window.raise();
                alertRegularWorkTime.open();
            }
        }
    }

    MessageDialog {
        property bool showIt: (calculator.firstCalcDone && calculator.extraMinutesToGo <= 15 && calculator.extraHoursToGo == 0) ? true:false
        id: alertExtraWorkTime
        title: "Erinnerung"
        text: "In 15 Minuten erreichen Sie die Höchstarbeitszeit!"
        onShowItChanged: {
            console.log("alert max")
            if(showIt){
                window.showNormal();
                window.raise();
                alertExtraWorkTime.open();
            }
        }
    }

    Style{
        id: style
    }

}
