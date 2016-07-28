import QtQuick 2.0
import QtQuick.Window 2.0
import QtQuick.Controls 1.5
import QtQuick.Controls.Styles 1.4

Window {
    width: 400
    height: 300
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
        y: 46
        text: qsTr("Reguläre Arbeitszeit ohne Pause")
    }

    TextField {
        id: regWorkingTime
        x: 270
        y: 46
        placeholderText: qsTr("7:00")
        inputMask: "09:99"
        style: style.textInputStyle
    }

    Label {
        id: label2
        x: 31
        y: 74
        text: qsTr("Pause")
    }

    TextField {
        id: pauseTime
        x: 270
        y: 74
        placeholderText: qsTr("00:50")
        inputMask: "09:99"
        style: style.textInputStyle
    }

    Label {
        id: label3
        x: 31
        y: 102
        text: qsTr("Maximale Arbeitszeit")
    }

    TextField {
        id: maxWorkingTime
        x: 270
        y: 102
        placeholderText: qsTr("10:00")
        inputMask: "09:99"
        style: style.textInputStyle
    }

    CheckBox {
        id: checkBoxAddBreakTime
        x: 31
        y: 140
        text: qsTr("berechne Pause in reguläre Arbeitszeit ein")
    }

    CheckBox {
        id: checkBoxUseStartTime
        x: 31
        y: 172
        text: qsTr("nutze Zeit des Programmstarts als Ankunftszeit")
    }

    ToolButton {
        id: openSettings
        x: 31
        y: 214
        width: 339
        height: 42
        text: "öffne Ordner der Einstellungsdatei"
    }

    modality: Qt.ApplicationModal

    Style{
        id: style
    }

    Text {
        id: message
        x: 31
        y: 272
        width: 339
        height: 15
        color: "#4d4d4d"
        text: qsTr("")
        font.pixelSize: 12
    }

}
