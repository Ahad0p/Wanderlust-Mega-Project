# ---------------- Build Stage ----------------
FROM node:22-slim AS builder

# Working directory
WORKDIR /app

# Install dependencies
COPY package*.json ./

RUN npm ci

# Copy source
COPY . .

# Build frontend
RUN npm run build


# ---------------- Production Stage ----------------
FROM nginx:alpine

# Copy built frontend
COPY --from=builder /app/dist /usr/share/nginx/html

# Frontend port
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
