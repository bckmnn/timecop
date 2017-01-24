import QtQuick 2.0
import QtQuick.Window 2.0
import QtQuick.Controls 1.5
import QtQuick.Controls.Styles 1.4

Window {
    width: 500
    height: 600
    property alias offsetUseStartTime: offsetUseStartTime
    property alias quitButton: quitButton
    property alias checkBoxAddBreakTime: checkBoxAddBreakTime
    property alias checkBoxUseStartTime: checkBoxUseStartTime
    property alias message: message
    property alias regWorkingTime: regWorkingTime
    property alias maxWorkingTime: maxWorkingTime
    property alias pauseTime: pauseTime
    property alias openSettingsBtn: openSettings

    Label {
        id: label1
        x: 31
        y: 64
        text: qsTr("Reguläre Arbeitszeit ohne Pause")
    }

    TextField {
        id: regWorkingTime
        x: 270
        y: 64
        placeholderText: qsTr("7:00")
        inputMask: "09:99"
        style: style.textInputStyle

        onFocusChanged: {
            if(focus){
                cursorPosition = 0
            }
        }
    }

    Label {
        id: label2
        x: 31
        y: 92
        text: qsTr("Pause")
    }

    TextField {
        id: pauseTime
        x: 270
        y: 92
        placeholderText: qsTr("00:50")
        inputMask: "09:99"
        style: style.textInputStyle

        onFocusChanged: {
            if(focus){
                cursorPosition = 0
            }
        }
    }

    Label {
        id: label3
        x: 31
        y: 120
        text: qsTr("Maximale Arbeitszeit")
    }

    TextField {
        id: maxWorkingTime
        x: 270
        y: 120
        placeholderText: qsTr("10:00")
        inputMask: "09:99"
        style: style.textInputStyle

        onFocusChanged: {
            if(focus){
                cursorPosition = 0
            }
        }
    }

    CheckBox {
        id: checkBoxAddBreakTime
        x: 31
        y: 209
        text: qsTr("Berechne Pause in reguläre Arbeitszeit ein.")
    }

    CheckBox {
        id: checkBoxUseStartTime
        x: 31
        y: 241
        text: offsetUseStartTime.text !== "0" ? qsTr("Nutze die Zeit des Programmstarts minus "+offsetUseStartTime.text+" Minuten als Ankunftszeit.") : qsTr("Nutze die Zeit des Programmstarts als Ankunftszeit.")
    }


    Item{
        id: offsetGroup
        x: 0
        y: 261
        width: 500
        height: 42
        opacity: checkBoxUseStartTime.checked ? 1 : 0.5
        TextField {
            id: offsetUseStartTime
            x: 200
            y: 5
            width: 36
            height: 22
            text: "0"
            enabled: checkBoxUseStartTime.checked
            style: style.textInputStyle
            inputMask: "00"
            placeholderText: qsTr("0")
            onFocusChanged: {
                if(focus){
                    cursorPosition = 0
                }
            }
        }

        Label {
            id: labelOffset2
            x: 243
            y: 8
            text: qsTr("Minuten vor Programmstart.")
        }

        Label {
            id: labelOffset1
            x: 53
            y: 8
            text: qsTr("Setze Ankunfstzeit auf ")
        }
    }



    ToolButton {
        id: openSettings
        x: 31
        y: 324
        width: 438
        height: 42
        text: qsTr("öffne Ordner der Einstellungsdatei")
    }

    modality: Qt.ApplicationModal

    Style{
        id: style
    }

    Text {
        id: message
        x: 31
        y: 154
        width: 438
        height: 15
        color: "#4d4d4d"
        text: qsTr("")
        font.pixelSize: 12
    }

    Button {
        id: quitButton
        x: 31
        y: 17
        width: 438
        height: 27
        text: qsTr("Timecop beenden")
        tooltip: qsTr("Timecop beenden")
    }

    TableView {
        id: tableView1
        x: 31
        y: 466
        width: 438
        height: 104
        verticalScrollBarPolicy: 1
        frameVisible: true
        horizontalScrollBarPolicy: 0
    }

    Label {
        id: label4
        x: 31
        y: 435
        text: qsTr("Erinnerungen:")
    }





}
