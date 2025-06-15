#!/bin/bash

# Update and install Docker
yum update -y
amazon-linux-extras enable docker
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Create app directories
mkdir -p /home/ec2-user/app/backend
mkdir -p /home/ec2-user/app/frontend/src

# Backend app
cat <<'EOF' > /home/ec2-user/app/backend/app.js
const express = require('express');
const app = express();
const port = 5000;
app.get('/api', (req, res) => res.json({ message: 'Hello from Backend API' }));
app.listen(port, () => console.log(\`Backend running at http://localhost:\${port}\`));
EOF

cat <<'EOF' > /home/ec2-user/app/backend/package.json
{
  "name": "backend",
  "version": "1.0.0",
  "main": "app.js",
  "scripts": {
    "start": "node app.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
EOF

cat <<'EOF' > /home/ec2-user/app/backend/Dockerfile
FROM node:18 AS build
WORKDIR /app
COPY . .
RUN npm install

FROM node:18-slim
WORKDIR /app
COPY --from=build /app .
EXPOSE 5000
CMD ["npm", "start"]
EOF

# Frontend app
cat <<'EOF' > /home/ec2-user/app/frontend/src/App.js
import React from 'react';
function App() {
  return (
    <div>
      <h1>Hello from React Frontend</h1>
    </div>
  );
}
export default App;
EOF

cat <<'EOF' > /home/ec2-user/app/frontend/package.json
{
  "name": "frontend",
  "version": "1.0.0",
  "private": true,
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-scripts": "5.0.1"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build"
  }
}
EOF

cat <<'EOF' > /home/ec2-user/app/frontend/Dockerfile
FROM node:18 AS build
WORKDIR /app
COPY . .
RUN npm install
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 80
EOF

# Install Node.js for build (Amazon Linux doesn't come with it)
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs

# Build Docker images
cd /home/ec2-user/app/backend
docker build -t local-backend .

cd /home/ec2-user/app/frontend
docker build -t local-frontend .

# Run containers
docker run -d -p 5000:5000 --name backend local-backend
docker run -d -p 80:80 --name frontend local-frontend

# Permissions
chown -R ec2-user:ec2-user /home/ec2-user/app

