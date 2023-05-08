# yarn install
# yarn build:dev

FROM node:16-bullseye-slim

WORKDIR /app

# Copy repo skeleton first, to avoid unnecessary docker cache invalidation.
# The skeleton contains the package.json of each package in the monorepo,
# and along with yarn.lock and the root package.json, that's enough to run yarn install.
COPY yarn.lock package.json ./
COPY dist ./dist

# install sqlite3 dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends python3 && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/apt/* && \
    mkdir -p /app/configs/creds && mkdir -p /app/configs/github && \
    yarn config set python /usr/bin/python3

RUN yarn install --frozen-lockfile --production --network-timeout 300000 && rm -rf "$(yarn cache dir)"

# Then copy the rest of the backend bundle, along with any other files we might want.

CMD ["node", "dist/index.js"]
