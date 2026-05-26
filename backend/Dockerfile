# ---------------- Build Stage ----------------
FROM node:22-slim AS builder

WORKDIR /app

COPY package*.json ./

RUN npm ci

COPY . .

# Optional tests
RUN npm test

# Remove dev dependencies
RUN npm prune --omit=dev


# ---------------- Production ----------------
FROM node:22-slim

WORKDIR /app

ENV NODE_ENV=production

COPY --from=builder /app .

EXPOSE 8080

CMD ["npm","start"]
