//pragma Singleton
import QtQuick 2.5
import QtQuick.Controls.Styles 1.4


QtObject {
    property Component regularProgress: ProgressBarStyle{
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
            color: "#76f293"
            border.color: "#5add79"
        }
    }
    property Component extraProgress: ProgressBarStyle{
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
            color: "#fdea7f"
            border.color: "#e3d066"
        }
    }

}
