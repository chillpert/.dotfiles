import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

Item {
    id: root

    property var pluginApi: null
    property bool busy: false
    property bool pendingPoll: false
    property bool parsedCurrentRun: false
    property string lastStdout: ""
    property string lastStderr: ""

    readonly property var settings: pluginApi?.pluginSettings ?? ({})
    readonly property var defaults: pluginApi?.manifest?.metadata?.defaultSettings ?? ({})

    readonly property bool enabled: settings.enabled ?? defaults.enabled ?? true
    readonly property string apiUrl: (settings.apiUrl ?? defaults.apiUrl ?? "").trim()
    readonly property string apiKey: (settings.apiKey ?? defaults.apiKey ?? "").trim()
    readonly property string configPath: (settings.configPath ?? defaults.configPath ?? "").trim()
    readonly property bool verifyTls: settings.verifyTls ?? defaults.verifyTls ?? false
    readonly property int pollIntervalMs: settings.pollIntervalMs ?? defaults.pollIntervalMs ?? 10000
    readonly property var folderIds: {
        const raw = settings.folderIds ?? defaults.folderIds ?? [];
        try {
            return Array.from(raw);
        } catch (e) {
            return [];
        }
    }

    readonly property string scriptPath: (pluginApi?.pluginDir ?? "") + "/syncthing-status.py"

    function makeEmptySnapshot() {
        return {
            state: "unconfigured",
            detail: "",
            checkedAt: "",
            sources: {
                configPath: "",
                urlSource: "none",
                apiKeySource: "none",
                resolvedUrl: ""
            },
            devices: {
                configured: 0,
                connected: 0,
                paused: 0
            },
            totals: {
                monitoredFolders: 0,
                pausedFolders: 0,
                syncingFolders: 0,
                erroredFolders: 0,
                needItems: 0,
                needBytes: 0
            },
            folders: [],
            availableFolders: [],
            recentErrors: []
        };
    }

    property var snapshot: makeEmptySnapshot()

    readonly property string state: snapshot?.state ?? "unconfigured"
    readonly property string detail: snapshot?.detail ?? ""
    readonly property int configuredDevices: snapshot?.devices?.configured ?? 0
    readonly property int connectedDevices: snapshot?.devices?.connected ?? 0
    readonly property int pausedDevices: snapshot?.devices?.paused ?? 0
    readonly property int monitoredFolders: snapshot?.totals?.monitoredFolders ?? 0
    readonly property int pausedFolders: snapshot?.totals?.pausedFolders ?? 0
    readonly property int syncingFolders: snapshot?.totals?.syncingFolders ?? 0
    readonly property int erroredFolders: snapshot?.totals?.erroredFolders ?? 0
    readonly property int needItems: snapshot?.totals?.needItems ?? 0
    readonly property double needBytes: snapshot?.totals?.needBytes ?? 0
    readonly property var folders: snapshot?.folders ?? []
    readonly property var availableFolders: snapshot?.availableFolders ?? []
    readonly property var recentErrors: snapshot?.recentErrors ?? []
    readonly property string resolvedUrl: snapshot?.sources?.resolvedUrl ?? ""
    readonly property string resolvedConfigPath: snapshot?.sources?.configPath ?? ""
    readonly property string urlSource: snapshot?.sources?.urlSource ?? "none"
    readonly property string apiKeySource: snapshot?.sources?.apiKeySource ?? "none"
    readonly property string checkedAt: snapshot?.checkedAt ?? ""

    readonly property bool hasProblem: state === "offline"
                                      || state === "unauthorized"
                                      || state === "error"
                                      || state === "disconnected"

    function tr(key, params) {
        return pluginApi?.tr(key, params);
    }

    function stateLabel(code) {
        return tr("state." + code);
    }

    function sourceLabel(code) {
        return tr("source." + code);
    }

    function statusSummary() {
        if (!enabled) return tr("summary.disabled");
        if (state === "idle") {
            if (configuredDevices > 0) {
                return tr("summary.idle-devices", { "connected": connectedDevices, "configured": configuredDevices });
            }
            return tr("summary.idle-no-devices");
        }
        if (state === "syncing") {
            if (needItems > 0) return tr("summary.syncing-items", { "count": needItems });
            return tr("summary.syncing-folders", { "count": Math.max(syncingFolders, 1) });
        }
        return tr("summary." + state);
    }

    function statusColor(code) {
        if (!enabled) return Color.mOutline;
        if (code === "idle") return Color.mPrimary;
        if (code === "syncing") return Color.mSecondary;
        if (code === "paused") return Color.mOutline;
        if (code === "disconnected") return Color.mSecondary;
        if (code === "offline" || code === "unauthorized" || code === "error") return Color.mError;
        return Color.mOutline;
    }

    function statusBadgeBackground(code) {
        if (!enabled || code === "disabled") return Color.mOutline;
        if (code === "idle") return Color.mPrimary;
        if (code === "syncing") return Color.mSecondary;
        if (code === "paused") return Color.mSurfaceVariant;
        if (code === "disconnected") return Color.mSecondary;
        if (code === "offline" || code === "unauthorized" || code === "error") return Color.mError;
        return Color.mOutline;
    }

    function statusBadgeForeground(code) {
        if (!enabled || code === "disabled") return Color.mOnSurface;
        if (code === "idle") return Color.mOnPrimary;
        if (code === "syncing") return Color.mOnSecondary;
        if (code === "paused") return Color.mOnSurfaceVariant;
        if (code === "disconnected") return Color.mOnSecondary;
        if (code === "offline" || code === "unauthorized" || code === "error") return Color.mOnError;
        return Color.mOnSurface;
    }

    function statusBadgeIcon(code) {
        if (!enabled || code === "disabled") return "";
        if (code === "paused") return "player-pause";
        if (code === "disconnected" || code === "offline" || code === "unauthorized" || code === "error") return "x";
        return "";
    }

    function badgeText() {
        if (!enabled) return "";
        if (state === "syncing") {
            if (needItems > 99) return "99+";
            if (needItems > 0) return String(needItems);
            return String(Math.max(syncingFolders, 1));
        }
        return "";
    }

    function formatBytes(bytes) {
        const units = ["B", "KB", "MB", "GB", "TB"];
        let value = Number(bytes);
        let index = 0;
        while (value >= 1024 && index < units.length - 1) {
            value /= 1024;
            index++;
        }
        const rounded = (value >= 10 || index === 0) ? Math.round(value) : value.toFixed(1);
        return rounded + " " + units[index];
    }

    function formatCheckedAt(isoValue) {
        if (!isoValue) return "-";
        const parsed = new Date(isoValue);
        if (isNaN(parsed.getTime())) return isoValue;
        return parsed.toLocaleString(Qt.locale().name);
    }

    function toggleFolder(folderId) {
        if (!pluginApi?.pluginSettings) return;
        const current = Array.from(folderIds);
        const index = current.indexOf(folderId);
        if (index >= 0) {
            current.splice(index, 1);
        } else {
            current.push(folderId);
        }
        pluginApi.pluginSettings.folderIds = current;
        pluginApi.saveSettings();
    }

    function setFolderSelection(ids) {
        if (!pluginApi?.pluginSettings) return;
        pluginApi.pluginSettings.folderIds = Array.from(ids);
        pluginApi.saveSettings();
    }

    function requestPoll(force) {
        if (!enabled && !force) return;
        if (!pluginApi) return;
        if (pollProcess.running) {
            pendingPoll = true;
            return;
        }
        parsedCurrentRun = false;
        lastStdout = "";
        lastStderr = "";
        pollProcess.running = true;
    }

    function applySnapshot(rawText) {
        const text = (rawText || "").trim();
        if (!text) return;
        try {
            const parsed = JSON.parse(text);
            snapshot = parsed;
            parsedCurrentRun = true;
        } catch (error) {
            Logger.w("[syncthing-status] helper output is not valid JSON (", text.length, "bytes):", error);
        }
    }

    onEnabledChanged: {
        if (enabled) {
            pollTimer.restart();
            requestPoll(false);
        } else {
            pollTimer.stop();
        }
    }
    onApiUrlChanged: requestPoll(false)
    onApiKeyChanged: requestPoll(false)
    onConfigPathChanged: requestPoll(false)
    onVerifyTlsChanged: requestPoll(false)
    onFolderIdsChanged: requestPoll(false)
    onPollIntervalMsChanged: requestPoll(false)

    Component.onCompleted: {
        if (enabled) requestPoll(false);
    }

    readonly property Timer pollTimer: Timer {
        interval: root.pollIntervalMs
        repeat: true
        running: root.enabled
        onTriggered: root.requestPoll(false)
    }

    readonly property Process pollProcess: Process {
        command: {
            const args = [
                "python3", root.scriptPath,
                "--timeout", "5"
            ];
            if (root.apiUrl) {
                args.push("--url");
                args.push(root.apiUrl);
            }
            if (root.apiKey) {
                args.push("--api-key");
                args.push(root.apiKey);
            }
            if (root.configPath) {
                args.push("--config-path");
                args.push(root.configPath);
            }
            if (root.folderIds.length > 0) {
                args.push("--folders");
                args.push(root.folderIds.join(","));
            }
            if (root.verifyTls) {
                args.push("--verify-tls");
            }
            return args;
        }

        running: false

        onStarted: {
            root.busy = true;
        }

        onExited: (exitCode, exitStatus) => {
            root.busy = false;
            if (!root.parsedCurrentRun) {
                const fallback = root.makeEmptySnapshot();
                fallback.state = "error";
                fallback.detail = root.lastStderr || ("Helper exited with code " + exitCode);
                root.snapshot = fallback;
            }
            if (root.pendingPoll) {
                root.pendingPoll = false;
                root.requestPoll(false);
            }
        }

        stdout: StdioCollector {
            onStreamFinished: {
                root.lastStdout = text;
                root.applySnapshot(text);
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                root.lastStderr = text.trim();
                if (root.lastStderr) {
                    Logger.w("[syncthing-status]", root.lastStderr);
                }
            }
        }
    }

    IpcHandler {
        target: "plugin:syncthing-status"

        function refresh() {
            root.requestPoll(true);
        }

        function toggle() {
            const newState = !root.enabled;
            if (pluginApi?.pluginSettings) {
                pluginApi.pluginSettings.enabled = newState;
                pluginApi.saveSettings();
            }
        }

        function status() {
            return {
                enabled: root.enabled,
                busy: root.busy,
                state: root.state,
                summary: root.statusSummary(),
                devices: root.snapshot.devices,
                totals: root.snapshot.totals
            };
        }
    }
}
