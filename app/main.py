import os

from flask import Flask, jsonify

app = Flask(__name__)


@app.get("/")
def index():
    return jsonify(
        status="healthy",
        service="gcp-cloudrun-demo",
        message="Hello from Cloud Run",
        environment=os.environ.get("ENVIRONMENT", "local"),
        # Only report whether the secret was injected; never return its value.
        secret_configured=bool(os.environ.get("DEMO_SECRET")),
    )


@app.get("/health")
def health():
    return jsonify(status="ok")


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
