const request = require("supertest");
const app = require("../app");

describe("GET /", () => {
  test("returns the welcome message", async () => {
    const res = await request(app).get("/");
    expect(res.status).toBe(200);
    expect(res.body.message).toBe("Hello from a hardened container");
  });
});

describe("GET /health", () => {
  test("reports the app is healthy", async () => {
    const res = await request(app).get("/health");
    expect(res.status).toBe(200);
    expect(res.body).toEqual({ status: "ok" });
  });
});

describe("Unknown paths", () => {
  test("return 404 Not Found", async () => {
    const res = await request(app).get("/does-not-exist");
    expect(res.status).toBe(404);
  });
});
