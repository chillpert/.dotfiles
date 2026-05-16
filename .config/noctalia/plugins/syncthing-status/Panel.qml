import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import qs.Commons
import qs.Widgets

Item {
    id: root

    property var pluginApi: null
    readonly property var geometryPlaceholder: panelContainer
    property real contentPreferredWidth: 340 * Style.uiScaleRatio
    property real contentPreferredHeight: 420 * Style.uiScaleRatio
    readonly property bool allowAttach: true

    anchors.fill: parent

    readonly property var mainInst: pluginApi?.mainInstance ?? null
    readonly property string currentState: mainInst?.enabled ? (mainInst?.state ?? "unconfigured") : "disabled"

    function tr(key, params) {
        return pluginApi?.tr(key, params);
    }

    function folderStateText(folder) {
        if (!mainInst) return "";
        if (folder.state === "syncing" && folder.needItems > 0) {
            return tr("panel.folder-state", { "state": mainInst.stateLabel(folder.state), "count": folder.needItems });
        }
        return mainInst.stateLabel(folder.state);
    }

    Rectangle {
        id: panelContainer
        anchors.fill: parent
        color: "transparent"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Style.marginM
            spacing: Style.marginM

            NBox {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Style.marginM
                    spacing: Style.marginM
                    clip: true

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Style.marginS

                        Image {
                            width: Math.round(22 * Style.uiScaleRatio)
                            height: Math.round(22 * Style.uiScaleRatio)
                            source: Qt.resolvedUrl("icon.svg")
                            sourceSize: Qt.size(width, height)
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            mipmap: true
                            layer.enabled: true
                            layer.effect: MultiEffect {
                                colorization: 1.0
                                colorizationColor: Color.mPrimary
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: Style.marginXXS

                            NText {
                                text: tr("panel.title")
                                pointSize: Style.fontSizeL
                                font.bold: true
                                color: Color.mOnSurface
                            }

                            NText {
                                text: mainInst?.stateLabel(mainInst.enabled ? mainInst.state : "disabled")
                                pointSize: Style.fontSizeS
                                color: Qt.alpha(Color.mOnSurface, 0.7)
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: refreshLabel.width + Math.round(22 * Style.uiScaleRatio)
                            Layout.preferredHeight: Math.round(30 * Style.uiScaleRatio)
                            radius: Style.radiusM
                            color: refreshMouse.containsMouse ? Qt.darker(Color.mPrimary, 1.1) : Color.mPrimary

                            NText {
                                id: refreshLabel
                                anchors.centerIn: parent
                                text: tr("panel.refresh")
                                color: Color.mOnPrimary
                            }

                            MouseArea {
                                id: refreshMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: mainInst?.requestPoll(true)
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Style.marginS

                        Rectangle {
                            width: Math.round(((mainInst?.statusBadgeIcon(root.currentState) ?? "") !== "" ? 18 : 10) * Style.uiScaleRatio)
                            height: Math.round(((mainInst?.statusBadgeIcon(root.currentState) ?? "") !== "" ? 18 : 10) * Style.uiScaleRatio)
                            radius: width / 2
                            color: mainInst ? mainInst.statusBadgeBackground(root.currentState) : Color.mOutline

                            NIcon {
                                anchors.centerIn: parent
                                visible: (mainInst?.statusBadgeIcon(root.currentState) ?? "") !== ""
                                icon: mainInst?.statusBadgeIcon(root.currentState) ?? ""
                                pointSize: Style.fontSizeXXS
                                color: mainInst ? mainInst.statusBadgeForeground(root.currentState) : Color.mOnSurface
                            }
                        }

                        NText {
                            text: mainInst?.statusSummary() ?? ""
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                        }
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        columns: 3
                        columnSpacing: Style.marginS
                        rowSpacing: Style.marginS

                        Repeater {
                            model: [
                                {
                                    "label": tr("panel.devices"),
                                    "value": (mainInst?.connectedDevices ?? 0) + "/" + (mainInst?.configuredDevices ?? 0)
                                },
                                {
                                    "label": tr("panel.folders"),
                                    "value": String(mainInst?.monitoredFolders ?? 0)
                                },
                                {
                                    "label": tr("panel.pending"),
                                    "value": (mainInst?.needItems ?? 0) > 0
                                        ? String(mainInst?.needItems ?? 0)
                                        : (mainInst ? mainInst.formatBytes(mainInst.needBytes) : "0 B")
                                }
                            ]

                            delegate: Rectangle {
                                required property var modelData
                                Layout.fillWidth: true
                                implicitHeight: Math.round(68 * Style.uiScaleRatio)
                                radius: Style.iRadiusM
                                color: Color.mSurfaceVariant

                                Column {
                                    anchors.centerIn: parent
                                    spacing: Style.marginXS

                                    NText {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: modelData.value
                                        font.bold: true
                                        pointSize: Style.fontSizeM
                                        color: Color.mOnSurface
                                    }

                                    NText {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: modelData.label
                                        pointSize: Style.fontSizeS
                                        color: Qt.alpha(Color.mOnSurface, 0.6)
                                    }
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Style.marginS

                        NText {
                            text: tr("panel.folders")
                            font.bold: true
                            color: Color.mOnSurface
                        }

                        Repeater {
                            model: mainInst?.folders ?? []

                            delegate: Rectangle {
                                required property var modelData
                                Layout.fillWidth: true
                                implicitHeight: Math.round(46 * Style.uiScaleRatio)
                                radius: Style.iRadiusM
                                color: Color.mSurfaceVariant
                                border.color: Qt.alpha(mainInst?.statusColor(modelData.state) ?? Color.mOutline, 0.5)
                                border.width: Style.borderS

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: Style.marginS
                                    spacing: Style.marginS

                                    Rectangle {
                                        width: Math.round(8 * Style.uiScaleRatio)
                                        height: Math.round(8 * Style.uiScaleRatio)
                                        radius: width / 2
                                        color: mainInst?.statusColor(modelData.state) ?? Color.mOutline
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: Style.marginXXS

                                        NText {
                                            text: modelData.label
                                            font.bold: true
                                            color: Color.mOnSurface
                                            elide: Text.ElideRight
                                        }

                                        NText {
                                            text: root.folderStateText(modelData)
                                            pointSize: Style.fontSizeS
                                            color: Qt.alpha(Color.mOnSurface, 0.65)
                                            elide: Text.ElideRight
                                        }
                                    }
                                }
                            }
                        }

                        NText {
                            text: tr("panel.no-folders")
                            visible: (mainInst?.folders?.length ?? 0) === 0
                            color: Qt.alpha(Color.mOnSurface, 0.6)
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Style.marginXS
                        visible: !!(mainInst?.detail ?? "")

                        NText {
                            text: tr("panel.details")
                            font.bold: true
                        }

                        NText {
                            Layout.fillWidth: true
                            text: mainInst?.detail ?? ""
                            wrapMode: Text.WrapAnywhere
                            color: mainInst?.hasProblem ? Color.mError : Qt.alpha(Color.mOnSurface, 0.75)
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Style.marginXS

                        NText {
                            Layout.fillWidth: true
                            text: tr("panel.last-check-info", { "value": mainInst?.formatCheckedAt(mainInst?.checkedAt ?? "") ?? "-" })
                            pointSize: Style.fontSizeS
                            color: Qt.alpha(Color.mOnSurface, 0.65)
                            wrapMode: Text.WordWrap
                        }

                        NText {
                            Layout.fillWidth: true
                            text: tr("panel.url-info", { "value": mainInst?.resolvedUrl || "-" })
                            pointSize: Style.fontSizeS
                            color: Qt.alpha(Color.mOnSurface, 0.65)
                            wrapMode: Text.WrapAnywhere
                        }

                        NText {
                            Layout.fillWidth: true
                            text: tr("panel.config-path-info", { "value": mainInst?.resolvedConfigPath || "-" })
                            pointSize: Style.fontSizeS
                            color: Qt.alpha(Color.mOnSurface, 0.65)
                            wrapMode: Text.WrapAnywhere
                        }

                        NText {
                            Layout.fillWidth: true
                            text: tr("panel.api-source-info", { "value": mainInst ? mainInst.sourceLabel(mainInst.apiKeySource) : "-" })
                            pointSize: Style.fontSizeS
                            color: Qt.alpha(Color.mOnSurface, 0.65)
                            wrapMode: Text.WordWrap
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Style.marginXS
                        visible: (mainInst?.recentErrors?.length ?? 0) > 0

                        NText {
                            text: tr("panel.recent-errors")
                            font.bold: true
                            color: Color.mOnSurface
                        }

                        Repeater {
                            model: mainInst?.recentErrors ?? []

                            delegate: NText {
                                required property var modelData
                                Layout.fillWidth: true
                                text: modelData.message
                                wrapMode: Text.WrapAnywhere
                                pointSize: Style.fontSizeS
                                color: Qt.alpha(Color.mOnSurface, 0.75)
                            }
                        }
                    }
                }
            }
        }
    }
}
