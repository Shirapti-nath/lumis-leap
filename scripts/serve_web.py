"""
Local web server for the exported Godot 4 web build.

WHY this exists: Godot 4 HTML5 builds use SharedArrayBuffer, which browsers only
allow on "cross-origin isolated" pages. A plain `python3 -m http.server` does NOT
send the required headers, so the game shows a black screen / errors. This server
adds the two required headers:
    Cross-Origin-Opener-Policy: same-origin
    Cross-Origin-Embedder-Policy: require-corp

USAGE (after you export the game from Godot into  build/web/ ):
    python3 scripts/serve_web.py
Then open the printed http://localhost:8000 link in your browser.
"""
import http.server
import socketserver
import os
import sys

PORT = 8000
ROOT = os.path.join(os.path.dirname(__file__), "..", "build", "web")


class GodotHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=ROOT, **kwargs)

    def end_headers(self):
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        self.send_header("Cache-Control", "no-store")
        super().end_headers()


def main():
    if not os.path.isdir(ROOT):
        print("ERROR: No web build found at:", os.path.abspath(ROOT))
        print("You must export the game from Godot first:")
        print("  Project > Export > add a 'Web' preset > Export Project")
        print("  Save it as:  build/web/index.html")
        sys.exit(1)

    if not os.path.exists(os.path.join(ROOT, "index.html")):
        print("WARNING: build/web exists but has no index.html.")
        print("Re-export from Godot and make sure the file is named index.html")

    socketserver.TCPServer.allow_reuse_address = True
    with socketserver.TCPServer(("", PORT), GodotHandler) as httpd:
        print("Serving the game at:  http://localhost:%d" % PORT)
        print("Press Ctrl+C to stop.")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nServer stopped.")


if __name__ == "__main__":
    main()
