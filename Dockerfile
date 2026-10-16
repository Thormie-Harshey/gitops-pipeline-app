# ---------- Stage 1: build (the kitchen) ----------
FROM node:24.21.0-alpine3.24 AS build
WORKDIR /app

# Quieter, lighter npm installs (no update or funding messages)
ENV NPM_CONFIG_UPDATE_NOTIFIER=false \
    NPM_CONFIG_FUND=false

# Copy the ingredient list and receipt first (layer caching)
COPY package.json package-lock.json ./

# Install production dependencies only, exactly as the lock file says
RUN npm ci --omit=dev

# ---------- Stage 2: runtime (the plate) ----------
FROM node:24.21.0-alpine3.24 AS runtime
WORKDIR /app

# Production settings and a memory cap for Node.js
ENV NODE_ENV=production \
    PORT=3000 \
    NODE_OPTIONS="--max-old-space-size=256"

# Create a non-root user (UID 1001), then remove package managers
# the app never uses at runtime (Trivy found all 12 CVEs inside npm)
RUN addgroup -S -g 1001 appgroup && \
    adduser -S -u 1001 -G appgroup -H -s /sbin/nologin appuser && \
    rm -rf /usr/local/lib/node_modules/npm \
           /usr/local/lib/node_modules/corepack \
           /usr/local/bin/npm /usr/local/bin/npx /usr/local/bin/corepack \
           /opt/yarn-* /usr/local/bin/yarn /usr/local/bin/yarnpkg

# Files stay owned by root, so appuser can read them but not change them
COPY --from=build /app/node_modules ./node_modules
COPY app.js server.js ./

# Switch to the non-root user (numeric IDs, so Kubernetes can verify it)
USER 1001:1001

# Document the port the app listens on
EXPOSE 3000

# Knock on /health every 30 seconds; 3 failures in a row marks it unhealthy
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD wget -qO- http://127.0.0.1:${PORT}/health || exit 1

CMD ["node", "server.js"]
