import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

ColumnLayout {
    id: root

    property var pluginApi: null
    readonly property var mainInst: pluginApi?.mainInstance ?? null

    property bool valueEnabled: pluginApi?.pluginSettings?.enabled ?? true
    property string valueApiUrl: pluginApi?.pluginSettings?.apiUrl ?? ""
    property string valueApiKey: pluginApi?.pluginSettings?.apiKey ?? ""
    property string valueConfigPath: pluginApi?.pluginSettings?.configPath ?? ""
    property bool valueVerifyTls: pluginApi?.pluginSettings?.verifyTls ?? false
    property int valuePollIntervalMs: pluginApi?.pluginSettings?.pollIntervalMs ?? 10000
    property var valueFolderIds: {
        const raw = pluginApi?.pluginSettings?.folderIds ?? [];
        try {
            return Array.from(raw);
        } catch (e) {
            return [];
        }
    }

    function tr(key, params) {
        return pluginApi?.tr(key, params);
    }

    function sourceLabel(code) {
        return mainInst?.sourceLabel(code);
    }

    function isFolderSelected(folderId) {
        return valueFolderIds.indexOf(folderId) >= 0;
    }

    function toggleFolder(folderId) {
        const updated = Array.from(valueFolderIds);
        const index = updated.indexOf(folderId);
        if (index >= 0) {
            updated.splice(index, 1);
        } else {
            updated.push(folderId);
        }
        valueFolderIds = updated;
    }

    function saveSettings(triggerRefresh) {
        if (!pluginApi) return;
        let url = valueApiUrl.trim();
        if (url && !url.startsWith("http://") && !url.startsWith("https://")) {
            url = "http://" + url;
        }
        pluginApi.pluginSettings.enabled = valueEnabled;
        pluginApi.pluginSettings.apiUrl = url;
        pluginApi.pluginSettings.apiKey = valueApiKey.trim();
        pluginApi.pluginSettings.configPath = valueConfigPath.trim();
        pluginApi.pluginSettings.verifyTls = valueVerifyTls;
        pluginApi.pluginSettings.pollIntervalMs = valuePollIntervalMs;
        pluginApi.pluginSettings.folderIds = Array.from(valueFolderIds);
        pluginApi.saveSettings();
        if (triggerRefresh) {
            mainInst?.requestPoll(true);
        }
    }

    spacing: Style.marginM

    NToggle {
        Layout.fillWidth: true
        label: tr("settings.enabled")
        description: tr("settings.enabled-desc")
        checked: root.valueEnabled
        onToggled: checked => root.valueEnabled = checked
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Style.marginS

        NLabel {
            label: tr("settings.url")
            description: tr("settings.url-desc")
        }

        Rectangle {
            Layout.fillWidth: true
            height: Math.round(36 * Style.uiScaleRatio)
            radius: Style.radiusM
            color: Color.mSurfaceVariant
            border.color: urlField.activeFocus ? Color.mPrimary : Color.mOutline
            border.width: Style.borderS

            TextInput {
                id: urlField
                anchors.fill: parent
                anchors.margins: Style.marginM
                verticalAlignment: TextInput.AlignVCenter
                color: Color.mOnSurface
                selectionColor: Color.mPrimary
                selectedTextColor: Color.mOnPrimary
                clip: true
                text: root.valueApiUrl
                onTextChanged: root.valueApiUrl = text

                NText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "http://127.0.0.1:8384"
                    visible: !urlField.text && !urlField.activeFocus
                    opacity: 0.4
                }
            }
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Style.marginS

        NLabel {
            label: tr("settings.api-key")
            description: tr("settings.api-key-desc")
        }

        Rectangle {
            Layout.fillWidth: true
            height: Math.round(36 * Style.uiScaleRatio)
            radius: Style.radiusM
            color: Color.mSurfaceVariant
            border.color: apiField.activeFocus ? Color.mPrimary : Color.mOutline
            border.width: Style.borderS

            TextInput {
                id: apiField
                anchors.fill: parent
                anchors.margins: Style.marginM
                verticalAlignment: TextInput.AlignVCenter
                color: Color.mOnSurface
                selectionColor: Color.mPrimary
                selectedTextColor: Color.mOnPrimary
                clip: true
                echoMode: TextInput.Password
                text: root.valueApiKey
                onTextChanged: root.valueApiKey = text

                NText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "X-API-Key"
                    visible: !apiField.text && !apiField.activeFocus
                    opacity: 0.4
                }
            }
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Style.marginS

        NLabel {
            label: tr("settings.config-path")
            description: tr("settings.config-path-desc")
        }

        Rectangle {
            Layout.fillWidth: true
            height: Math.round(36 * Style.uiScaleRatio)
            radius: Style.radiusM
            color: Color.mSurfaceVariant
            border.color: pathField.activeFocus ? Color.mPrimary : Color.mOutline
            border.width: Style.borderS

            TextInput {
                id: pathField
                anchors.fill: parent
                anchors.margins: Style.marginM
                verticalAlignment: TextInput.AlignVCenter
                color: Color.mOnSurface
                selectionColor: Color.mPrimary
                selectedTextColor: Color.mOnPrimary
                clip: true
                text: root.valueConfigPath
                onTextChanged: root.valueConfigPath = text

                NText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "~/.local/state/syncthing/config.xml"
                    visible: !pathField.text && !pathField.activeFocus
                    opacity: 0.4
                }
            }
        }
    }

    NToggle {
        Layout.fillWidth: true
        label: tr("settings.verify-tls")
        description: tr("settings.verify-tls-desc")
        checked: root.valueVerifyTls
        onToggled: checked => root.valueVerifyTls = checked
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Style.marginS

        NLabel {
            label: tr("settings.poll-interval-label", { "value": Math.round(root.valuePollIntervalMs / 1000) })
            description: tr("settings.poll-interval-desc")
        }

        NSlider {
            Layout.fillWidth: true
            from: 2000
            to: 60000
            value: root.valuePollIntervalMs
            stepSize: 1000
            onMoved: root.valuePollIntervalMs = Math.round(value)
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Style.marginS

        NLabel {
            label: tr("settings.folders")
            description: tr("settings.folders-desc")
        }

        Flow {
            Layout.fillWidth: true
            spacing: Style.marginS

            Repeater {
                model: mainInst?.availableFolders ?? []

                delegate: Rectangle {
                    required property var modelData
                    readonly property bool isSelected: root.isFolderSelected(modelData.id)

                    width: chipLabel.implicitWidth + Math.round(22 * Style.uiScaleRatio)
                    height: Math.round(30 * Style.uiScaleRatio)
                    radius: height / 2
                    color: isSelected ? Qt.alpha(Color.mPrimary, 0.15) : Color.mSurfaceVariant
                    border.color: isSelected ? Color.mPrimary : Color.mOutline
                    border.width: Style.borderS

                    NText {
                        id: chipLabel
                        anchors.centerIn: parent
                        text: modelData.label
                        font.bold: parent.isSelected
                        color: parent.isSelected ? Color.mPrimary : Color.mOnSurface
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.toggleFolder(parent.modelData.id)
                    }
                }
            }
        }

        NText {
            text: tr("settings.no-folders")
            visible: (mainInst?.availableFolders?.length ?? 0) === 0
            wrapMode: Text.Wrap
            color: Qt.alpha(Color.mOnSurface, 0.65)
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginS

        Rectangle {
            Layout.preferredWidth: saveLabel.width + Math.round(24 * Style.uiScaleRatio)
            Layout.preferredHeight: Math.round(32 * Style.uiScaleRatio)
            radius: Style.radiusM
            color: saveMouse.containsMouse ? Qt.darker(Color.mPrimary, 1.1) : Color.mPrimary

            NText {
                id: saveLabel
                anchors.centerIn: parent
                text: tr("settings.save")
                color: Color.mOnPrimary
            }

            MouseArea {
                id: saveMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.saveSettings(false);
                    saveStatus.text = tr("settings.saved");
                    saveStatusTimer.restart();
                }
            }
        }

        Rectangle {
            Layout.preferredWidth: refreshLabel.width + Math.round(24 * Style.uiScaleRatio)
            Layout.preferredHeight: Math.round(32 * Style.uiScaleRatio)
            radius: Style.radiusM
            color: refreshMouse.containsMouse ? Color.mOutline : Color.mSurfaceVariant
            border.color: Color.mOutline
            border.width: Style.borderS

            NText {
                id: refreshLabel
                anchors.centerIn: parent
                text: tr("settings.refresh")
            }

            MouseArea {
                id: refreshMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.saveSettings(true);
                    saveStatus.text = tr("settings.saved");
                    saveStatusTimer.restart();
                }
            }
        }

        NText {
            id: saveStatus
            text: ""
            opacity: 0.7
        }
    }

    Timer {
        id: saveStatusTimer
        interval: 2000
        onTriggered: saveStatus.text = ""
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.topMargin: Style.marginM
        spacing: Style.marginXS

        NText {
            text: tr("settings.status")
            font.bold: true
        }

        NText {
            text: mainInst?.stateLabel(mainInst.enabled ? mainInst.state : "disabled") ?? ""
            color: mainInst ? mainInst.statusColor(mainInst.enabled ? mainInst.state : "disabled") : Color.mOutline
        }

        NText {
            text: mainInst?.statusSummary() ?? ""
            wrapMode: Text.Wrap
            color: Qt.alpha(Color.mOnSurface, 0.75)
        }

        NText {
            text: tr("settings.url-info", { "value": mainInst?.resolvedUrl || "-" })
            pointSize: Style.fontSizeS
            color: Qt.alpha(Color.mOnSurface, 0.6)
            elide: Text.ElideRight
        }

        NText {
            text: tr("settings.api-source-info", { "value": root.sourceLabel(mainInst?.apiKeySource ?? "none") })
            pointSize: Style.fontSizeS
            color: Qt.alpha(Color.mOnSurface, 0.6)
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.topMargin: Style.marginM
        spacing: Style.marginXS

        NText {
            text: tr("settings.about")
            font.bold: true
        }

        NText {
            text: tr("settings.developer")
            wrapMode: Text.Wrap
            color: Qt.alpha(Color.mOnSurface, 0.75)
        }

        NText {
            text: "v" + (pluginApi?.manifest?.version ?? "1.0.0")
            color: Qt.alpha(Color.mOnSurface, 0.5)
        }
    }
}
