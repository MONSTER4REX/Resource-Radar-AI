FROM node:20-slim
WORKDIR /app
COPY . .
RUN npm ci
CMD ["node", "src/index.js"]
