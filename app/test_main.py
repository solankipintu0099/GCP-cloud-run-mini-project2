from main import app


def test_index():
    client = app.test_client()
    response = client.get("/")

    assert response.status_code == 200
    assert response.get_json()["status"] == "healthy"


def test_index_reports_config_without_leaking_secret(monkeypatch):
    monkeypatch.setenv("ENVIRONMENT", "gcp-demo")
    monkeypatch.setenv("DEMO_SECRET", "super-secret-value")
    client = app.test_client()
    response = client.get("/")

    body = response.get_json()
    assert body["environment"] == "gcp-demo"
    assert body["secret_configured"] is True
    assert "super-secret-value" not in response.get_data(as_text=True)


def test_health():
    client = app.test_client()
    response = client.get("/health")

    assert response.status_code == 200
    assert response.get_json() == {"status": "ok"}
