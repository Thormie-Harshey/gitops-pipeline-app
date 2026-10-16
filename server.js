// Borrow the agent and script from app.js (importing)
const app = require("./app");

const PORT = process.env.PORT || 3000;

// Switch the phone line on: start answering on this port
const server = app.listen(PORT, "0.0.0.0", () => {
  console.log(`Server listening on port ${PORT}`);
});

// Close cleanly when Docker or Kubernetes asks the container to stop
process.on("SIGTERM", () => {
  server.close(() => process.exit(0));
});
