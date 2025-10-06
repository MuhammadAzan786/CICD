# ==============================================================================
# MULTI-STAGE BUILD
# ==============================================================================
# Why multi-stage?
#   - Stage 1: Build the React app (needs Node.js, npm, dev dependencies)
#   - Stage 2: Serve static files (only needs nginx, not Node.js)
#   - Result: Final image is ~25MB (nginx+files) vs ~200MB (with Node.js)
#   - Keeps production image small, fast, and secure

# ==============================================================================
# STAGE 1: BUILD STAGE
# ==============================================================================
# This stage compiles the React app into static HTML/CSS/JS files
FROM node:18-alpine AS builder

# Add label to identify this as the build stage
LABEL stage=builder

# Set working directory for the build process
WORKDIR /app

# Copy package files first (for Docker layer caching)
# If package.json doesn't change, Docker reuses this cached layer
COPY package*.json ./

# Install ALL dependencies (including devDependencies)
# We need devDependencies like vite, eslint, etc. to build the app
# --silent flag reduces npm output noise during build
RUN npm install --silent

# Copy all source code and configuration files
# This includes src/, public/, index.html, vite.config.js, etc.
COPY . .

# Build the React app for production
# This runs "vite build" which:
#   1. Bundles and minifies JavaScript
#   2. Optimizes CSS
#   3. Processes images and assets
#   4. Outputs everything to the /app/dist folder
# The dist folder contains the final static files ready to serve
RUN npm run build

# At this point, /app/dist contains:
#   - index.html (entry point)
#   - assets/index-[hash].js (bundled JavaScript)
#   - assets/index-[hash].css (bundled CSS)
#   - Other optimized assets

# ==============================================================================
# STAGE 2: PRODUCTION STAGE (NGINX)
# ==============================================================================
# This stage creates the final lightweight image with only nginx + built files
FROM nginx:alpine

# Add metadata for documentation
LABEL maintainer="your-email@example.com"
LABEL description="React frontend served with nginx"

# Copy the custom nginx configuration
# This tells nginx how to serve the React app (especially for client-side routing)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built files from Stage 1 (builder) to nginx's serving directory
# --from=builder specifies we're copying from the first stage
# /app/dist is where Vite placed the built files in Stage 1
# /usr/share/nginx/html is nginx's default directory for serving static files
COPY --from=builder /app/dist /usr/share/nginx/html

# Expose port 80 (nginx default HTTP port)
# This is documentation - actual port mapping happens with docker run -p
# Example: docker run -p 3000:80 means:
#   - Host port 3000 (your computer) → Container port 80 (nginx)
#   - Access the app at http://localhost:3000
EXPOSE 80

# Start nginx in the foreground
# nginx -g 'daemon off;' keeps nginx running in foreground (required for Docker)
# If nginx runs as daemon (background), the container would exit immediately
CMD ["nginx", "-g", "daemon off;"]

# ==============================================================================
# WHY THIS APPROACH?
# ==============================================================================
# 1. Small image size: ~25MB (nginx:alpine + React build)
#    vs ~200MB if we kept Node.js in the final image
#
# 2. Security: Final image doesn't contain:
#    - Node.js (not needed to serve static files)
#    - npm packages (including potential vulnerabilities)
#    - Source code (only compiled/minified production code)
#
# 3. Performance: nginx is optimized for serving static files
#    - Handles thousands of concurrent connections
#    - Caching, gzip compression, HTTP/2 support
#
# 4. Clean separation: Build tools (Stage 1) separate from runtime (Stage 2)

# ==============================================================================
# FINAL IMAGE CONTENTS
# ==============================================================================
# The final image contains:
#   ✓ nginx web server
#   ✓ Built React app (HTML, CSS, JS in /usr/share/nginx/html)
#   ✓ Custom nginx.conf
#
# NOT included (discarded from Stage 1):
#   ✗ Node.js
#   ✗ npm
#   ✗ Source code (src/, public/)
#   ✗ node_modules
#   ✗ Build tools (vite, etc.)
