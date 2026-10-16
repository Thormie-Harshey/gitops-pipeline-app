const express = require("express");

const app = express();

// Home address
app.get("/", (req, res) => {
  res.json({ message: "Hello from the GitOps pipeline v2" });
});

// Health check, used by Docker and Kubernetes
app.get("/health", (req, res) => {
  res.status(200).json({ status: "ok" });
});

// Share the app with other files (server.js and the tests)
module.exports = app;
