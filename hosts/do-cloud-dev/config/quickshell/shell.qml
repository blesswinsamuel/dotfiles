import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

ShellRoot {
	Variants {
		model: Quickshell.screens

		PanelWindow {
			required property var modelData
			screen: modelData

			anchors {
				top: true
				left: true
				right: true
			}

			implicitHeight: 32
			color: "#1e1e2e"

			RowLayout {
				anchors.fill: parent
				anchors.leftMargin: 12
				anchors.rightMargin: 12
				spacing: 16

				Text {
					text: "do-cloud-dev"
					color: "#89b4fa"
					font.pixelSize: 13
					font.bold: true
					Layout.alignment: Qt.AlignVCenter
				}

				Text {
					text: modelData.name
					color: "#a6adc8"
					font.pixelSize: 12
					Layout.alignment: Qt.AlignVCenter
				}

				Item {
					Layout.fillWidth: true
				}

				Text {
					id: clock
					color: "#cdd6f4"
					font.pixelSize: 13
					Layout.alignment: Qt.AlignVCenter

					Process {
						id: dateProc
						command: ["date", "+%a %H:%M"]
						running: true
						stdout: StdioCollector {
							onStreamFinished: clock.text = this.text.trim()
						}
					}

					Timer {
						interval: 30000
						running: true
						repeat: true
						onTriggered: dateProc.running = true
					}
				}
			}
		}
	}
}
