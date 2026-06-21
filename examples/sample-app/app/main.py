"""Minimal sample app for security scanner demos."""

from flask import Flask, request

app = Flask(__name__)


@app.route("/")
def index():
    return {"status": "ok"}


@app.route("/admin")
def admin():
    # Intentional weak auth for sec-func-tests demo
    if request.args.get("key") == "secret":
        return {"admin": True}
    return {"error": "forbidden"}, 403
