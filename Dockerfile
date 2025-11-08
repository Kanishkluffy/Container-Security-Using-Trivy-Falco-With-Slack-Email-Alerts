# Intentional use of older Node base image for vulnerabilities
FROM node:12-alpine

WORKDIR /app

# Copy package files and install (older versions are in package.json)
COPY package*.json ./
RUN npm install --no-audit

# Copy rest of the repo (includes src/ and static/)
COPY . .

EXPOSE 3000

# Run server from src/index.js
CMD ["node", "src/index.js"]
