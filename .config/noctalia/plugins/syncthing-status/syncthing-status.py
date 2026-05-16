#!/usr/bin/env python3
"""Fetch a Syncthing status snapshot for the Noctalia plugin."""

from __future__ import annotations

import argparse
import json
import ssl
import sys
import urllib.error
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET
from datetime import datetime, timezone
from pathlib import Path

DEFAULT_CONFIG_PATHS = (
    Path.home() / ".local" / "state" / "syncthing" / "config.xml",
    Path.home() / ".config" / "syncthing" / "config.xml",
)

ACTIVE_FOLDER_STATES = {
    "cleaning",
    "scan-waiting",
    "scanning",
    "sync-preparing",
    "syncing",
}


def now_iso() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def to_int(value, default=0) -> int:
    try:
        return int(value)
    except (TypeError, ValueError):
        return default


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Read Syncthing status and output one JSON snapshot.")
    parser.add_argument("--url", default="", help="Syncthing GUI base URL")
    parser.add_argument("--api-key", default="", help="Syncthing API key")
    parser.add_argument("--config-path", default="", help="Path to config.xml")
    parser.add_argument("--folders", default="", help="Comma-separated folder IDs to monitor")
    parser.add_argument("--timeout", type=float, default=5.0, help="HTTP timeout in seconds")
    parser.add_argument("--verify-tls", action="store_true", help="Verify TLS certificates")
    return parser.parse_args()


def normalize_base_url(value: str, default_scheme: str = "http") -> str:
    url = (value or "").strip()
    if not url:
        return ""
    if not url.startswith(("http://", "https://")):
        url = f"{default_scheme}://{url}"
    url = url.rstrip("/")
    if url.endswith("/rest"):
        url = url[:-5]
    return url


def resolve_config_path(explicit_path: str) -> Path | None:
    if explicit_path:
        path = Path(explicit_path).expanduser()
        return path if path.is_file() else None
    for path in DEFAULT_CONFIG_PATHS:
        if path.is_file():
            return path
    return None


def load_xml_config(path: Path | None) -> dict:
    if path is None:
        return {
            "configPath": "",
            "guiEnabled": False,
            "guiTls": False,
            "guiAddress": "",
            "apiKey": "",
            "folders": [],
        }

    root = ET.parse(path).getroot()
    gui = root.find("./gui")
    folders = []
    for folder in root.findall("./folder"):
        folder_id = folder.attrib.get("id", "").strip()
        if not folder_id:
            continue
        folders.append(
            {
                "id": folder_id,
                "label": folder.attrib.get("label", "").strip() or folder_id,
            }
        )

    return {
        "configPath": str(path),
        "guiEnabled": (gui is not None and gui.attrib.get("enabled", "true").lower() != "false"),
        "guiTls": (gui is not None and gui.attrib.get("tls", "false").lower() == "true"),
        "guiAddress": (root.findtext("./gui/address") or "").strip(),
        "apiKey": (root.findtext("./gui/apikey") or "").strip(),
        "folders": folders,
    }


def build_runtime_config(args: argparse.Namespace) -> tuple[dict, dict]:
    config_path = resolve_config_path(args.config_path)
    xml_config = load_xml_config(config_path)

    default_scheme = "https" if xml_config["guiTls"] else "http"
    base_url = normalize_base_url(args.url, default_scheme=default_scheme)
    api_key = (args.api_key or "").strip()

    url_source = "manual"
    if not base_url:
        gui_address = xml_config["guiAddress"]
        if gui_address and xml_config["guiEnabled"]:
            base_url = normalize_base_url(gui_address, default_scheme=default_scheme)
            url_source = "config"
        else:
            url_source = "none"

    api_source = "manual"
    if not api_key:
        api_key = xml_config["apiKey"]
        api_source = "config" if api_key else "none"

    monitored_ids = [item.strip() for item in args.folders.split(",") if item.strip()]

    runtime = {
        "baseUrl": base_url,
        "apiKey": api_key,
        "verifyTls": bool(args.verify_tls),
        "timeout": float(args.timeout),
        "monitoredIds": monitored_ids,
        "sources": {
            "configPath": xml_config["configPath"],
            "urlSource": url_source,
            "apiKeySource": api_source,
        },
    }
    return runtime, xml_config


def request_json(runtime: dict, path: str, *, auth: bool = True, params: dict | None = None):
    base_url = runtime["baseUrl"]
    url = f"{base_url}{path}"
    if params:
        url = f"{url}?{urllib.parse.urlencode(params)}"

    headers = {}
    if auth and runtime["apiKey"]:
        headers["X-API-Key"] = runtime["apiKey"]

    context = None
    if url.startswith("https://") and not runtime["verifyTls"]:
        context = ssl.create_default_context()
        context.check_hostname = False
        context.verify_mode = ssl.CERT_NONE

    request = urllib.request.Request(url, headers=headers)
    with urllib.request.urlopen(request, timeout=runtime["timeout"], context=context) as response:
        return json.load(response)


def error_snapshot(state: str, detail: str, runtime: dict, xml_config: dict, *, available_folders=None) -> dict:
    return {
        "state": state,
        "detail": detail,
        "checkedAt": now_iso(),
        "sources": {
            **runtime["sources"],
            "resolvedUrl": runtime["baseUrl"],
        },
        "devices": {
            "configured": 0,
            "connected": 0,
            "paused": 0,
        },
        "totals": {
            "monitoredFolders": 0,
            "pausedFolders": 0,
            "syncingFolders": 0,
            "erroredFolders": 0,
            "needItems": 0,
            "needBytes": 0,
        },
        "folders": [],
        "availableFolders": available_folders or xml_config.get("folders", []),
        "recentErrors": [],
    }


def summarize_folder(folder: dict, status: dict) -> dict:
    raw_state = (status.get("state") or "unknown").strip() or "unknown"
    need_items = to_int(status.get("needTotalItems"))
    need_bytes = to_int(status.get("needBytes"))
    pull_errors = to_int(status.get("pullErrors"))
    error_count = to_int(status.get("errors"))
    watch_error = (status.get("watchError") or "").strip()
    hard_error = (status.get("error") or "").strip()

    if folder.get("paused"):
        state = "paused"
    elif hard_error or watch_error or pull_errors > 0 or error_count > 0:
        state = "error"
    elif raw_state in ACTIVE_FOLDER_STATES or need_items > 0 or need_bytes > 0:
        state = "syncing"
    else:
        state = "idle"

    detail = watch_error or hard_error
    return {
        "id": folder.get("id", ""),
        "label": folder.get("label", "") or folder.get("id", ""),
        "paused": bool(folder.get("paused", False)),
        "state": state,
        "rawState": raw_state,
        "needItems": need_items,
        "needBytes": need_bytes,
        "pullErrors": pull_errors,
        "errorCount": error_count,
        "detail": detail,
    }


def classify_snapshot(snapshot: dict) -> dict:
    folders = snapshot["folders"]
    totals = snapshot["totals"]
    devices = snapshot["devices"]

    if not folders:
        detail = snapshot["detail"] or "No monitored folders are configured."
        return {**snapshot, "state": "unconfigured", "detail": detail}

    if totals["pausedFolders"] == totals["monitoredFolders"]:
        return {**snapshot, "state": "paused"}

    if totals["erroredFolders"] > 0:
        detail = snapshot["detail"] or "One or more monitored folders reported errors."
        return {**snapshot, "state": "error", "detail": detail}

    if totals["syncingFolders"] > 0 or totals["needItems"] > 0 or totals["needBytes"] > 0:
        return {**snapshot, "state": "syncing"}

    if devices["configured"] > 0 and devices["connected"] == 0 and devices["paused"] < devices["configured"]:
        return {**snapshot, "state": "disconnected"}

    return {**snapshot, "state": "idle"}


def _check_connectivity(runtime: dict, xml_config: dict) -> dict | None:
    """Verify Syncthing is reachable and API key is available."""
    if not runtime["baseUrl"]:
        return error_snapshot(
            "unconfigured",
            "Syncthing GUI URL could not be resolved from settings or config.xml.",
            runtime,
            xml_config,
        )

    try:
        request_json(runtime, "/rest/noauth/health", auth=False)
    except urllib.error.HTTPError as exc:
        if exc.code != 404:
            return error_snapshot("offline", f"Syncthing health check failed with HTTP {exc.code}.", runtime, xml_config)
    except ssl.SSLError:
        return error_snapshot(
            "offline",
            "TLS handshake failed. Disable TLS verification or use a trusted certificate.",
            runtime,
            xml_config,
        )
    except urllib.error.URLError as exc:
        return error_snapshot("offline", f"Cannot reach Syncthing GUI: {exc.reason}.", runtime, xml_config)
    except TimeoutError:
        return error_snapshot("offline", "Syncthing GUI health check timed out.", runtime, xml_config)

    if not runtime["apiKey"]:
        return error_snapshot(
            "unconfigured",
            "Syncthing API key is missing. Set it manually or expose it via config.xml.",
            runtime,
            xml_config,
        )

    return None


def _fetch_core_data(runtime: dict, xml_config: dict) -> tuple | dict:
    """Fetch core API endpoints. Returns data tuple or error_snapshot dict."""
    try:
        return (
            request_json(runtime, "/rest/system/status"),
            request_json(runtime, "/rest/config"),
            request_json(runtime, "/rest/system/connections"),
            request_json(runtime, "/rest/system/error"),
        )
    except urllib.error.HTTPError as exc:
        if exc.code in (401, 403):
            return error_snapshot("unauthorized", "Syncthing rejected the API key.", runtime, xml_config)
        return error_snapshot("error", f"Syncthing API returned HTTP {exc.code}.", runtime, xml_config)
    except ssl.SSLError:
        return error_snapshot(
            "offline",
            "TLS handshake failed. Disable TLS verification or use a trusted certificate.",
            runtime,
            xml_config,
        )
    except urllib.error.URLError as exc:
        return error_snapshot("offline", f"Cannot reach Syncthing API: {exc.reason}.", runtime, xml_config)
    except TimeoutError:
        return error_snapshot("offline", "Syncthing API request timed out.", runtime, xml_config)


def _parse_config_folders(config: dict) -> list:
    """Parse and sort folder list from Syncthing config."""
    folders = []
    for folder in config.get("folders", []):
        folder_id = (folder.get("id") or "").strip()
        if not folder_id:
            continue
        folders.append(
            {
                "id": folder_id,
                "label": (folder.get("label") or "").strip() or folder_id,
                "paused": bool(folder.get("paused", False)),
            }
        )
    folders.sort(key=lambda item: item["label"].lower())
    return folders


def _count_devices(config: dict, system_status: dict, connections: dict) -> dict:
    """Count configured, connected, and paused remote devices."""
    my_id = (system_status.get("myID") or "").strip()
    connection_map = connections.get("connections", {}) if isinstance(connections, dict) else {}
    remote_devices = [
        device
        for device in config.get("devices", [])
        if isinstance(device, dict) and (device.get("deviceID") or "") != my_id
    ]

    configured = 0
    connected = 0
    paused = 0
    for device in remote_devices:
        device_id = (device.get("deviceID") or "").strip()
        if not device_id:
            continue
        configured += 1
        info = connection_map.get(device_id, {})
        if info.get("paused"):
            paused += 1
        elif info.get("connected"):
            connected += 1

    return {"configured": configured, "connected": connected, "paused": paused}


def _collect_folder_summaries(runtime: dict, monitored_folders: list) -> list:
    """Fetch per-folder status and build summaries."""
    summaries = []
    for folder in monitored_folders:
        if folder.get("paused"):
            summaries.append(
                {
                    "id": folder["id"],
                    "label": folder["label"],
                    "paused": True,
                    "state": "paused",
                    "rawState": "paused",
                    "needItems": 0,
                    "needBytes": 0,
                    "pullErrors": 0,
                    "errorCount": 0,
                    "detail": "",
                }
            )
            continue
        try:
            status = request_json(runtime, "/rest/db/status", params={"folder": folder["id"]})
        except urllib.error.HTTPError as exc:
            status = {"state": "error", "error": f"HTTP {exc.code} while reading folder status."}
        except (urllib.error.URLError, TimeoutError, ssl.SSLError) as exc:
            status = {"state": "error", "error": f"Folder status request failed: {exc}"}
        summaries.append(summarize_folder(folder, status))
    return summaries


def _parse_recent_errors(system_errors: dict) -> list:
    """Extract and clean recent error messages."""
    raw = system_errors.get("errors") if isinstance(system_errors, dict) else []
    if raw is None or not isinstance(raw, list):
        return []
    return [
        {
            "when": (item.get("when") or "").strip(),
            "message": (item.get("message") or "").strip(),
        }
        for item in raw
        if isinstance(item, dict) and (item.get("message") or "").strip()
    ][:5]


def fetch_snapshot(runtime: dict, xml_config: dict) -> dict:
    error = _check_connectivity(runtime, xml_config)
    if error:
        return error

    result = _fetch_core_data(runtime, xml_config)
    if not isinstance(result, tuple):
        return result
    system_status, config, connections, system_errors = result

    config_folders = _parse_config_folders(config)
    monitored_ids = set(runtime["monitoredIds"])
    monitored_folders = [
        folder for folder in config_folders if not monitored_ids or folder["id"] in monitored_ids
    ]
    if monitored_ids and not monitored_folders:
        return error_snapshot(
            "unconfigured",
            "Selected folder IDs were not found in Syncthing.",
            runtime,
            xml_config,
            available_folders=config_folders,
        )

    devices = _count_devices(config, system_status, connections)
    folder_summaries = _collect_folder_summaries(runtime, monitored_folders)
    recent_errors = _parse_recent_errors(system_errors)

    snapshot = {
        "state": "unknown",
        "detail": "",
        "checkedAt": now_iso(),
        "sources": {
            **runtime["sources"],
            "resolvedUrl": runtime["baseUrl"],
        },
        "devices": devices,
        "totals": {
            "monitoredFolders": len(folder_summaries),
            "pausedFolders": sum(1 for f in folder_summaries if f["state"] == "paused"),
            "syncingFolders": sum(1 for f in folder_summaries if f["state"] == "syncing"),
            "erroredFolders": sum(1 for f in folder_summaries if f["state"] == "error"),
            "needItems": sum(f["needItems"] for f in folder_summaries),
            "needBytes": sum(f["needBytes"] for f in folder_summaries),
        },
        "folders": folder_summaries,
        "availableFolders": config_folders,
        "recentErrors": recent_errors,
    }

    if recent_errors and snapshot["totals"]["erroredFolders"] == 0 and not snapshot["detail"]:
        snapshot = {**snapshot, "detail": recent_errors[0]["message"]}

    return classify_snapshot(snapshot)


def main() -> int:
    args = parse_args()
    try:
        runtime, xml_config = build_runtime_config(args)
        snapshot = fetch_snapshot(runtime, xml_config)
        json.dump(snapshot, sys.stdout, ensure_ascii=True)
        sys.stdout.write("\n")
        return 0
    except ET.ParseError:
        runtime = {
            "baseUrl": normalize_base_url(args.url),
            "sources": {
                "configPath": args.config_path,
                "urlSource": "manual" if args.url else "none",
                "apiKeySource": "manual" if args.api_key else "none",
            },
        }
        snapshot = error_snapshot(
            "unconfigured",
            "Failed to parse Syncthing config.xml.",
            runtime,
            {"folders": []},
        )
        json.dump(snapshot, sys.stdout, ensure_ascii=True)
        sys.stdout.write("\n")
        return 0
    except Exception as exc:  # pragma: no cover - final fallback for plugin stability
        snapshot = {
            "state": "error",
            "detail": f"Unexpected helper error: {exc}",
            "checkedAt": now_iso(),
            "sources": {
                "configPath": args.config_path,
                "urlSource": "manual" if args.url else "none",
                "apiKeySource": "manual" if args.api_key else "none",
                "resolvedUrl": normalize_base_url(args.url),
            },
            "devices": {"configured": 0, "connected": 0, "paused": 0},
            "totals": {
                "monitoredFolders": 0,
                "pausedFolders": 0,
                "syncingFolders": 0,
                "erroredFolders": 0,
                "needItems": 0,
                "needBytes": 0,
            },
            "folders": [],
            "availableFolders": [],
            "recentErrors": [],
        }
        json.dump(snapshot, sys.stdout, ensure_ascii=True)
        sys.stdout.write("\n")
        return 0


if __name__ == "__main__":
    raise SystemExit(main())
