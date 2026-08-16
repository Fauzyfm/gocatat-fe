# ============================================================
# Stage 1: Build Flutter Web
# ============================================================
FROM ghcr.io/cirruslabs/flutter:3.27.4 AS builder

WORKDIR /app

# Copy dependency files first for better layer caching
COPY pubspec.yaml pubspec.lock ./

# Get dependencies (offline cache layer)
RUN flutter pub get

# Copy the rest of the source code
COPY . .

# Accept API_BASE_URL as a build argument (configurable from EasyPanel)
ARG API_BASE_URL=https://my-project-gocatat-be.lzfki7.easypanel.host/api/v1

# Write .env file at build time so flutter_dotenv can bundle it
RUN echo "API_BASE_URL=${API_BASE_URL}" > .env

# Build Flutter for web (release mode, optimized)
RUN flutter build web --release --web-renderer canvaskit

# ============================================================
# Stage 2: Serve with Nginx
# ============================================================
FROM nginx:1.27-alpine AS production

# Remove default nginx static content
RUN rm -rf /usr/share/nginx/html/*

# Copy built Flutter web app from builder stage
COPY --from=builder /app/build/web /usr/share/nginx/html

# Custom nginx config for SPA routing
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget -qO- http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
