FROM node:24-bookworm-slim AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:24-bookworm-slim AS app
ENV NODE_ENV=production HOST=0.0.0.0 PORT=4310 DATABASE_PATH=/data/opendots.sqlite
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev && mkdir -p /data && chown node:node /data
COPY --from=build /app/dist ./dist
USER root
EXPOSE 4310
CMD ["sh", "-c", "mkdir -p /data && chown -R node:node /data && exec setpriv --reuid=node --regid=node --init-groups node dist/server/server/index.js"]