import QtQuick 2.5
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import Qt.labs.settings 1.0
import QtQuick.Dialogs 1.1
import "TimeEngine.js" as TimeEngine
import "AlertEngine.js" as AlertEngine

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
                console.log("first start today ... setting arrival time")
                if(settings.startTimeOffset !== 0){
                    console.log("offset is minus "+ settings.startTimeOffset + " minutes")
                    now.setMinutes(now.getMinutes()-settings.startTimeOffset)
                    settings.arrivalTimeDay = now.getDay()
                    settings.arrivalTimeHours = now.getHours()
                    settings.arrivalTimeMinutes = now.getMinutes()
                }else{
                    settings.arrivalTimeDay = now.getDay()
                    settings.arrivalTimeHours = now.getHours()
                    settings.arrivalTimeMinutes = now.getMinutes()
                }
            }
            console.log(AlertEngine.start());
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

    SettingsWindow{
        id: settingsWindow

        quitButton.onClicked: {
            Qt.quit()
        }
        openSettingsBtn.onClicked: {
            Qt.openUrlExternally("file://"+app_settings_dir+"/Daimler AG RD-DDA");
        }

        onVisibleChanged: {
            maxWorkingTime.text = createTimeString(settings.maximumWorkingTimeHours, settings.maximumWorkingTimeMinutes)
            regWorkingTime.text = createTimeString(settings.regularWorkingTimeHours, settings.regularWorkingTimeMinutes)
            pauseTime.text = createTimeString(settings.regularBreakTimeHours, settings.regularBreakTimeMinutes)
            checkBoxAddBreakTime.checked = settings.addBreakTimeToRegularDailyWorkingTime
            checkBoxUseStartTime.checked = settings.useFirstStartTimeAsArrivalTime
            offsetUseStartTime.text = settings.startTimeOffset
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

        pauseTime.onTextChanged: {
            if(pauseTime.acceptableInput){
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
            }else{
                message.text = "Bitte gebe eine gültige Pausenzeit im Format hh:mm ein."
            }
        }

        regWorkingTime.onTextChanged: {
            if(regWorkingTime.acceptableInput){
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
            }else{
                message.text = "Bitte gebe eine gültige Reguläre Arbeitszeit im Format hh:mm ein."
            }
        }

        maxWorkingTime.onTextChanged: {
            if(maxWorkingTime.acceptableInput){
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
            }else{
                message.text = "Bitte gebe eine gültige Maximale Arbeitszeit im Format hh:mm ein."
            }
        }

        offsetUseStartTime.onTextChanged: {
            if(offsetUseStartTime.acceptableInput){
                var input = offsetUseStartTime.text
                var minutes = parseInt(input)
                    if(minutes !== NaN ){
                        settings.startTimeOffset = minutes
                        calculator.update()
                        message.text = "Startzeit Offset wurde "+minutes +" Minuten gesetzt. Erst aktiv beim nächsten Start."
                    }else{
                        message.text = "Bitte gebe ein gültiges Startzeit Offset in Minuten an."
                    }
            }else{
                message.text = "Bitte gebe ein gültiges Startzeit Offset in Minuten an."
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
        property int startTimeOffset: 0

        property bool showExtraTimeToGo: false
        property bool showRegularTimeToGo: false
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
            property string timeToGo: createTimeString(calculator.regHoursToGo, calculator.regMinutesToGo)
            property string timeDone: createTimeString(calculator.regHoursDone, calculator.regMinutesDone)
            property string progress: settings.showRegularTimeToGo ? "("+((1-calculator.currentProgressRegular)*100).toFixed()+"%)" : "("+(calculator.currentProgressRegular*100).toFixed()+"%)"
            property string labelText: settings.showRegularTimeToGo ? timeToGo+" "+progress+" to go" : "already gone "+timeDone+" "+progress
            text: labelText
            visible: progressExtra.value == 0
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                settings.showRegularTimeToGo  = !settings.showRegularTimeToGo
            }
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
            property string timeToGo: createTimeString(calculator.extraHoursToGo, calculator.extraMinutesToGo)
            property string timeDone: createTimeString(calculator.extraHoursDone, calculator.extraMinutesDone)
            property string progress: settings.showExtraTimeToGo ? "("+100-(calculator.currentProgressMax*100).toFixed()+"%)" : "("+(calculator.currentProgressMax*100).toFixed()+"%)"
            property string labelText: settings.showExtraTimeToGo ? timeToGo+" to go" : "gone "+timeDone
            text:  labelText
            visible: progressRegular.value == 1
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                settings.showExtraTimeToGo  = !settings.showExtraTimeToGo
            }
            visible: progressRegular.value == 1
        }
    }

    Timer{
        interval: 1000*20
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
        property int regMinutesDone: 0
        property int regHoursDone: 0
        property int extraMinutesDone: 0
        property int extraHoursDone: 0

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
            regMinutesDone = TimeEngine.diffNowStartTime.minutes
            regHoursDone = TimeEngine.diffNowStartTime.hours
            extraMinutesDone = TimeEngine.diffNowEndTime.sign === 1 ? TimeEngine.diffNowEndTime.minutes:0
            extraHoursDone = TimeEngine.diffNowEndTime.sign === 1 ? TimeEngine.diffNowEndTime.hours:0
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
