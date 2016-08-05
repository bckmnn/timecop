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

    Style{
        id: style
    }

    ToolButton {
        id: tlbSet
        text: qsTr("🔧")
        tooltip: "Zeige Einstellungs Fenster"
        onClicked: {
            settingsWindow.show();
        }
        anchors.margins: 5
        anchors.right: parent.right
        anchors.bottom: parent.bottom
    }
    ToolButton {
        id: tlbQuit
        text: qsTr("❌")
        tooltip: "Beende Timecop"
        onClicked: {
            Qt.quit()
        }
        anchors.margins: 5
        anchors.right: tlbSet.left
        anchors.bottom: parent.bottom
    }


    SettingsWindow{
        id: settingsWindow
        openSettingsBtn.onClicked: {
            Qt.openUrlExternally("file://"+settingsPath+"/Daimler AG RD-DDA");
        }
        onVisibleChanged: {
            maxWorkingTime.text = createTimeString(settings.maximumWorkingTimeHours, settings.maximumWorkingTimeMinutes)
            regWorkingTime.text = createTimeString(settings.regularWorkingTimeHours, settings.regularWorkingTimeMinutes)
            pauseTime.text = createTimeString(settings.regularBreakTimeHours, settings.regularBreakTimeMinutes)
            checkBoxAddBreakTime.checked = settings.addBreakTimeToRegularDailyWorkingTime
            checkBoxUseStartTime.checked = settings.useFirstStartTimeAsArrivalTime
        }

        checkBoxAddBreakTime.onCheckedStateChanged: {
            if(checkBoxAddBreakTime.checkedState === Qt.Checked){
                settings.addBreakTimeToRegularDailyWorkingTime = true
            }else{
                settings.addBreakTimeToRegularDailyWorkingTime = false
            }
            calculator.update()
        }
        checkBoxUseStartTime.onCheckedStateChanged: {
            if(checkBoxUseStartTime.checkedState === Qt.Checked){
                settings.useFirstStartTimeAsArrivalTime = true
            }else{
                settings.useFirstStartTimeAsArrivalTime = false
            }
            calculator.update()
        }

        pauseTime.onEditingFinished: {
            var input = pauseTime.text.split(":")
            if(input.length == 2){
                var hours = parseInt(input[0]);
                var minutes = parseInt(input[1])
                settings.regularBreakTimeHours = hours
                settings.regularBreakTimeMinutes = minutes
                calculator.update()
                message.text = "Pause wurde auf " + hours + "h und "+minutes +"m gesetzt."
            }else{
                message.text = pauseTime.text +" lässt sich nicht teilen " + input.length
            }
        }

        regWorkingTime.onEditingFinished: {
            var input = regWorkingTime.text.split(":")
            if(input.length == 2){
                var hours = parseInt(input[0]);
                var minutes = parseInt(input[1])
                if(hours > 0 || minutes > 0){
                    settings.regularWorkingTimeHours = hours
                    settings.regularWorkingTimeMinutes = minutes
                    calculator.update()
                    message.text = "Reguläre Arbeitszeit wurde auf " + hours + "h und "+minutes +"m gesetzt."
                }else{
                    message.text = "Reguläre Arbeitszeit muss größer 0 sein. (hh:mm)"
                }
            }else{
                message.text = regWorkingTime.text +" lässt sich nicht teilen " + input.length
            }
        }

        maxWorkingTime.onEditingFinished: {
            var input = maxWorkingTime.text.split(":")
            if(input.length == 2){
                var hours = parseInt(input[0]);
                var minutes = parseInt(input[1])
                if(hours > 0 || minutes > 0){
                    settings.maximumWorkingTimeHours = hours
                    settings.maximumWorkingTimeMinutes = minutes
                    calculator.update()
                    message.text = "Maximale Arbeitszeit wurde auf " + hours + "h und "+minutes +"m gesetzt."
                }else{
                    message.text = "Maximale Arbeitszeit muss größer 0 sein. (hh:mm)"
                }
            }else{
                message.text = maxWorkingTime.text +" lässt sich nicht teilen " + input.length
            }
        }
    }

    function createTimeString(hours, minutes){
        return addLeadingZero(hours)+":"+addLeadingZero(minutes);
    }

    function addLeadingZero(value){
        if(value < 10){
            return "0"+value;
        }else{
            return ""+value;
        }
    }

    Settings{
        id: settings
        property int regularWorkingTimeHours: 7
        property int regularWorkingTimeMinutes: 0
        property int regularBreakTimeHours: 0
        property int regularBreakTimeMinutes: 50
        property int maximumWorkingTimeHours: 9
        property int maximumWorkingTimeMinutes: 59
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
            regMinutesToGo = TimeEngine.diffNowEndTime.sign === -1 ?  TimeEngine.diffNowEndTime.minutes : 0
            regHoursToGo = TimeEngine.diffNowEndTime.sign === -1 ?  TimeEngine.diffNowEndTime.hours : 0
            extraMinutesToGo = TimeEngine.diffNowMaxTime.sign === -1 ?  TimeEngine.diffNowMaxTime.minutes : 0
            extraHoursToGo = TimeEngine.diffNowMaxTime.sign === -1 ?  TimeEngine.diffNowMaxTime.hours : 0
            firstCalcDone = true
            var ttip  = "Klicke das Icon um TimeCop zu öffnen.\n"
            if(regMinutesToGo > 0 || regHoursToGo > 0){
                ttip += "Reguläre Arbeitszeit noch "+regHoursToGo+"h "+regMinutesToGo +"min\n"
                ttip += "Du kannst um "+endTime.toLocaleTimeString("hh:mm")+" nach Hause gehen."
            }else{
                ttip += "Du machst Überstunden!\n"
                ttip += "Maximale Arbeitszeit erreicht in "+extraHoursToGo+"h "+extraMinutesToGo +"min\n"
                ttip += "Du musst spätestens um "+maxTime.toLocaleTimeString("hh:mm")+" nach Hause gehen."
            }
            systrayHelper.setToolTip(ttip);
            systrayHelper.setIconColor(currentProgressRegular, currentProgressMax);
        }
    }

    MessageDialog {
        property bool showIt: (calculator.regMinutesToGo <= 15 && calculator.regHoursToGo == 0 && calculator.extraHoursToGo > 0 && calculator.extraMinutesToGo > 0) ? true:false
        id: alertRegularWorkTime
        title: "Erinnerung"
        text: "In "+calculator.regMinutesToGo+" Minuten endet die reguläre Arbeitszeit!"
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
        text: "In "+calculator.extraMinutesToGo+" Minuten erreichen Sie die Höchstarbeitszeit!"
        onShowItChanged: {
            console.log("alert max")
            if(alertRegularWorkTime.showIt === true){
                alertRegularWorkTime.close()
            }
            if(showIt){
                window.showNormal();
                window.raise();
                alertExtraWorkTime.open();
            }else{
                alertExtraWorkTime.close()
            }
        }
    }



}
