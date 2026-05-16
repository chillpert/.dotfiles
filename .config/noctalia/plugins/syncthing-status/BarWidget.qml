import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import qs.Commons
import qs.Widgets
import qs.Services.UI

Item {
    id: root

    property var pluginApi: null
    property ShellScreen screen
    property string widgetId: ""
    property string section: ""
    property int sectionWidgetIndex: -1
    property int sectionWidgetsCount: 0

    readonly property var mainInst: pluginApi?.mainInstance ?? null
    readonly property bool isPanelOpen: pluginApi?.isPanelOpen ?? false
    readonly property bool isSelected: isPanelOpen

    readonly property string screenName: screen ? screen.name : ""
    readonly property string barPosition: Settings.getBarPositionForScreen(screenName)
    readonly property bool isVertical: barPosition === "left" || barPosition === "right"
    readonly property real capsuleHeight: Style.getCapsuleHeightForScreen(screenName)

    readonly property string badge: mainInst?.badgeText() ?? ""
    readonly property real textWidth: badgeText.implicitWidth
    readonly property string currentState: mainInst?.enabled ? (mainInst?.state ?? "unconfigured") : "disabled"
    readonly property color capsuleBgColor: {
        if (isSelected) {
            return mouseArea.containsMouse ? Qt.darker(Color.mPrimary, 1.08) : Color.mPrimary;
        }
        return mouseArea.containsMouse ? Color.mHover : Style.capsuleColor;
    }
    readonly property color iconColor: {
        if (isSelected) return Color.mOnPrimary;
        return mouseArea.containsMouse ? Color.mOnHover : Color.mOnSurface;
    }
    readonly property color badgeColor: isSelected
        ? Color.mOnPrimary
        : (mouseArea.containsMouse ? Color.mOnHover : Color.mOnSurface)
    readonly property color statusBadgeBg: mainInst ? mainInst.statusBadgeBackground(root.currentState) : Color.mOutline
    readonly property color statusBadgeFg: mainInst ? mainInst.statusBadgeForeground(root.currentState) : Color.mOnSurface
    readonly property string statusBadgeIcon: mainInst ? mainInst.statusBadgeIcon(root.currentState) : ""

    implicitWidth: visualCapsule.width
    implicitHeight: visualCapsule.height

    function tooltipText() {
        if (!mainInst) return "Syncthing";
        const stateCode = mainInst.enabled ? mainInst.state : "disabled";
        return pluginApi?.tr("bar.tooltip", {
            "state": mainInst.stateLabel(stateCode),
            "summary": mainInst.statusSummary()
        });
    }

    NPopupContextMenu {
        id: contextMenu

        model: [
            {
                "label": mainInst?.enabled ? pluginApi?.tr("bar.disable") : pluginApi?.tr("bar.enable"),
                "action": "toggle",
                "icon": mainInst?.enabled ? "player-pause" : "player-play"
            },
            {
                "label": pluginApi?.tr("bar.refresh"),
                "action": "refresh",
                "icon": "refresh"
            },
            {
                "label": pluginApi?.tr("bar.settings"),
                "action": "settings",
                "icon": "settings"
            }
        ]

        onTriggered: action => {
            contextMenu.close();
            PanelService.closeContextMenu(root.screen);

            if (action === "toggle" && pluginApi?.pluginSettings) {
                pluginApi.pluginSettings.enabled = !(mainInst?.enabled ?? true);
                pluginApi.saveSettings();
            } else if (action === "refresh" && mainInst) {
                mainInst.requestPoll(true);
            } else if (action === "settings") {
                BarService.openPluginSettings(root.screen, pluginApi.manifest);
            }
        }
    }

    Rectangle {
        id: visualCapsule
        anchors.centerIn: parent
        width: Math.max(root.capsuleHeight, iconRow.implicitWidth + Style.marginM * 2)
        height: root.capsuleHeight
        color: root.capsuleBgColor
        radius: Style.radiusL
        border.color: isSelected ? Color.mPrimary : Style.capsuleBorderColor
        border.width: Style.capsuleBorderWidth

        Row {
            id: iconRow
            anchors.centerIn: parent
            spacing: badge ? Style.marginXS : 0

            Image {
                width: root.capsuleHeight * 0.55
                height: root.capsuleHeight * 0.55
                source: Qt.resolvedUrl("icon.svg")
                sourceSize: Qt.size(width, height)
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                opacity: mainInst?.enabled ? 0.9 : 0.35
                layer.enabled: true
                layer.effect: MultiEffect {
                    colorization: 1.0
                    colorizationColor: root.iconColor
                }
            }

            NText {
                id: badgeText
                text: root.badge
                visible: text !== ""
                font.bold: true
                pointSize: Style.fontSizeS
                color: root.badgeColor
            }
        }

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.bottomMargin: Style.marginXXS
            anchors.rightMargin: Style.marginXXS
            width: Math.round((root.statusBadgeIcon ? 14 : 8) * Style.uiScaleRatio)
            height: Math.round((root.statusBadgeIcon ? 14 : 8) * Style.uiScaleRatio)
            radius: width / 2
            color: root.statusBadgeBg

            NIcon {
                anchors.centerIn: parent
                visible: root.statusBadgeIcon !== ""
                icon: root.statusBadgeIcon
                pointSize: Style.fontSizeXXS
                color: root.statusBadgeFg
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor

        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) {
                PanelService.showContextMenu(contextMenu, root, root.screen);
            } else if (pluginApi) {
                pluginApi.openPanel(root.screen, root);
            }
        }

        onEntered: {
            TooltipService.show(
                root,
                root.tooltipText(),
                BarService.getTooltipDirection(root)
            );
        }

        onExited: {
            TooltipService.hide();
        }
    }
}
