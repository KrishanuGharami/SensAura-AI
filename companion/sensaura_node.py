#!/usr/bin/env python3
"""SensAura Node: a local, allowlisted workstation state companion.

The server intentionally performs no shell/process execution.  It only updates
its own explicit in-memory profile state and acknowledges that state change.
Bind to loopback by default; a non-loopback bind requires SENSAURA_NODE_TOKEN.
"""

import hmac
import json
import os
import argparse
import time
from datetime import datetime, timezone
from http.server import BaseHTTPRequestHandler, HTTPServer

DEFAULT_PORT = int(os.environ.get("SENSAURA_NODE_PORT", "8765"))
AUTH_TOKEN = os.environ.get("SENSAURA_NODE_TOKEN", "")
DEFAULT_HOST = os.environ.get("SENSAURA_NODE_HOST", "127.0.0.1")
HOST = DEFAULT_HOST
PORT = DEFAULT_PORT
ALLOWLIST = frozenset({"FOCUS", "REST", "BREAK", "ARRIVING", "LEAVING", "RESET"})
START_TIME = time.monotonic()

workstation_state = {
    "node_id": "sensaura-node-workstation-01",
    "hostname": "local-workstation",
    "status": "ONLINE",
    "current_profile": "RESET",
    "media_muted": False,
    "focus_session_active": False,
    "break_timer_active": False,
    "locked": False,
    "last_command_id": None,
    "last_command_time": None,
    "command_count": 0,
}


def execute_profile(command: str) -> bool:
    """Apply only the companion's explicit state model; never execute a process."""
    workstation_state["current_profile"] = command
    workstation_state["focus_session_active"] = command == "FOCUS"
    workstation_state["break_timer_active"] = command == "BREAK"
    workstation_state["media_muted"] = command == "FOCUS"
    workstation_state["locked"] = command == "LEAVING"
    if command in {"RESET", "REST", "ARRIVING"}:
        workstation_state["media_muted"] = False
    return True


class SensAuraHandler(BaseHTTPRequestHandler):
    server_version = "SensAuraNode/1.0"

    def _authorized(self) -> bool:
        if not AUTH_TOKEN:
            return HOST in {"127.0.0.1", "localhost", "::1"}
        supplied = self.headers.get("Authorization", "")
        expected = f"Bearer {AUTH_TOKEN}"
        expected = "Bearer " + AUTH_TOKEN
        return hmac.compare_digest(supplied, expected)

    def _send_json(self, status: int, payload: dict) -> None:
        body = json.dumps(payload, separators=(",", ":")).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Headers", "Authorization, Content-Type")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Cache-Control", "no-store")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_OPTIONS(self):
        self.send_response(204)
        self.send_header("Allow", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Headers", "Authorization, Content-Type")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.end_headers()

    def do_GET(self):
        if not self._authorized():
            self._send_json(401, {"status": "UNAUTHORIZED"})
            return
        self._send_json(
            200,
            {
                "node": workstation_state["node_id"],
                "status": workstation_state["status"],
                "uptime_seconds": round(time.monotonic() - START_TIME, 3),
                "state": workstation_state,
            },
        )

    def do_POST(self):
        if not self._authorized():
            self._send_json(401, {"status": "UNAUTHORIZED"})
            return

        try:
            content_length = int(self.headers.get("Content-Length", "0"))
        except ValueError:
            content_length = 0
        if content_length <= 0 or content_length > 4096:
            self._send_json(413, {"status": "REJECTED", "error": "Invalid request size"})
            return

        try:
            payload = json.loads(self.rfile.read(content_length).decode("utf-8"))
        except (UnicodeDecodeError, json.JSONDecodeError):
            self._send_json(400, {"status": "REJECTED", "error": "Malformed JSON"})
            return
        if not isinstance(payload, dict):
            self._send_json(400, {"status": "REJECTED", "error": "JSON object required"})
            return

        command = payload.get("command")
        if not isinstance(command, str):
            self._send_json(400, {"status": "REJECTED", "error": "Command required"})
            return
        command = command.strip().upper()
        if command not in ALLOWLIST:
            self._send_json(403, {"status": "REJECTED", "error": "Command not allowlisted"})
            return

        request_id = payload.get("requestId")
        client_id = payload.get("clientId", "sensaura-client")
        if not isinstance(request_id, str) or not request_id or len(request_id) > 128:
            self._send_json(400, {"status": "REJECTED", "error": "Invalid requestId"})
            return
        if not isinstance(client_id, str) or len(client_id) > 128:
            self._send_json(400, {"status": "REJECTED", "error": "Invalid clientId"})
            return

        if not execute_profile(command):
            self._send_json(503, {"status": "NOT_EXECUTED"})
            return

        workstation_state["last_command_id"] = request_id
        workstation_state["last_command_time"] = datetime.now(timezone.utc).isoformat()
        workstation_state["command_count"] += 1
        self._send_json(
            200,
            {
                "status": "ACKNOWLEDGED",
                "requestId": request_id,
                "command": command,
                "clientId": client_id,
                "timestamp": workstation_state["last_command_time"],
                "nodeId": workstation_state["node_id"],
                "executionMode": "state-only",
                "state": workstation_state,
            },
        )

    def log_message(self, _format, *_args):
        pass


def main():
    parser = argparse.ArgumentParser(description="Run the SensAura laptop companion node.")
    parser.add_argument(
        "--host",
        default=DEFAULT_HOST,
        help="Bind address; use 0.0.0.0 for phone/LAN access",
    )
    parser.add_argument("--port", type=int, default=DEFAULT_PORT)
    args = parser.parse_args()
    if not 1 <= args.port <= 65535:
        parser.error("port must be between 1 and 65535")
    if args.host not in {"127.0.0.1", "localhost", "::1"} and not AUTH_TOKEN:
        raise RuntimeError(
            "SENSAURA_NODE_TOKEN is required for non-loopback binds. "
            "Set it and pass the same token with --dart-define."
        )

    global HOST, PORT
    HOST, PORT = args.host, args.port
    server = HTTPServer((HOST, PORT), SensAuraHandler)
    print(f"SensAura Node listening on http://{HOST}:{PORT}")
    print("Allowlisted state profiles:", ", ".join(sorted(ALLOWLIST)))
    print("No shell or process execution is enabled.")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
