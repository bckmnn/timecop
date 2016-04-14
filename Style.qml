//pragma Singleton
import QtQuick 2.5
import QtQuick.Controls.Styles 1.4


QtObject {
    property Component progBarStyle: ProgressBarStyle{
        id: progressStyle
        background: Rectangle {
                    radius: 3
                    color: "lightgray"
                    border.color: "gray"
                    border.width: 1
                    implicitWidth: 200
                    implicitHeight: 24
                }
        progress: Rectangle {
            radius: 3
            color: "lightsteelblue"
            border.color: "steelblue"
        }
    }

}
