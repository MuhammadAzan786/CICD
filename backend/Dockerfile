# ==============================================================================
# BASE IMAGE
# ==============================================================================
# Use the official Node.js 18 image based on Alpine Linux
# Alpine is a lightweight Linux distribution (~5MB) that keeps the image small
# node:18-alpine includes Node.js 18.x and npm pre-installed
FROM node:18-alpine

# ==============================================================================
# METADATA
# ==============================================================================
# Add labels for better documentation and organization
LABEL maintainer="your-email@example.com"
LABEL description="Simple Express.js backend API"

# ==============================================================================
# WORKING DIRECTORY
# ==============================================================================
# Set the working directory inside the container to /app
# All subsequent commands (COPY, RUN, CMD) will be executed relative to this directory
# If /app doesn't exist, Docker will create it automatically
WORKDIR /app

# ==============================================================================
# INSTALL DEPENDENCIES
# ==============================================================================
# Copy package.json and package-lock.json first (before copying source code)
# This allows Docker to cache the npm install layer
# If package files don't change, Docker reuses the cached layer (faster builds)
COPY package*.json ./

# Install production dependencies only
# --production flag skips devDependencies (like jest, supertest)
# --silent reduces npm output noise
# This step creates the node_modules folder inside /app
RUN npm install --production --silent

# ==============================================================================
# COPY APPLICATION SOURCE CODE
# ==============================================================================
# Copy all application files from the backend folder to /app in the container
# The . refers to the current directory on the host (backend folder)
# The ./ refers to the WORKDIR inside the container (/app)
# Files listed in .dockerignore will be excluded
COPY . .

# ==============================================================================
# EXPOSE PORT
# ==============================================================================
# Expose port 5000 to allow external access to the application
# This is a documentation step - it tells users which port the app uses
# The actual port binding happens when running the container with -p flag
# Example: docker run -p 5000:5000 means:
#   - Host port 5000 (left side) maps to Container port 5000 (right side)
#   - Requests to localhost:5000 on your machine → forwarded to port 5000 in container
EXPOSE 5000

# ==============================================================================
# ENVIRONMENT VARIABLES (OPTIONAL)
# ==============================================================================
# Set default environment variables
# These can be overridden when running the container with -e flag
# Example: docker run -e PORT=3000 my-backend
ENV NODE_ENV=production
ENV PORT=5000

# ==============================================================================
# START THE APPLICATION
# ==============================================================================
# CMD defines the default command to run when the container starts
# This runs "npm start" which executes "node server.js" (from package.json)
# Unlike RUN (which executes during build), CMD executes when container starts
# Only the last CMD in a Dockerfile takes effect
CMD ["npm", "start"]

# ==============================================================================
# ALTERNATIVE START COMMANDS (choose one):
# ==============================================================================
# Option 1 (current): CMD ["npm", "start"]
#   - Runs the "start" script from package.json
#   - Slightly slower startup due to npm overhead
#
# Option 2: CMD ["node", "server.js"]
#   - Directly runs Node.js (faster startup)
#   - More explicit and avoids npm wrapper
