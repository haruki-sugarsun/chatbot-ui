# ---- Base Node ----
FROM node:19-alpine AS base
WORKDIR /app
RUN mkdir /.npm; chown -R nobody:nogroup /app /.npm
USER nobody
COPY --chown=nobody:nogroup package*.json ./

# ---- Dependencies ----
FROM base AS dependencies
USER nobody
RUN npm ci

# ---- Build ----
FROM dependencies AS build
USER nobody
COPY --chown=nobody:nogroup . .
RUN ls -lha /app
RUN npm run build

# ---- Production ----
FROM base AS production
WORKDIR /app
USER nobody
COPY --chown=nobody:nogroup --from=dependencies /app/node_modules ./node_modules
COPY --chown=nobody:nogroup --from=build /app/.next ./.next
COPY --chown=nobody:nogroup --from=build /app/public ./public
COPY --chown=nobody:nogroup --from=build /app/package*.json ./
COPY --chown=nobody:nogroup --from=build /app/next.config.js ./next.config.js
COPY --chown=nobody:nogroup --from=build /app/next-i18next.config.js ./next-i18next.config.js

# Expose the port the app will run on
EXPOSE 3000

# Start the application
CMD ["npm", "start"]
