FROM node:20.11.0-alpine@sha256:9b61ed13fef9ca689326f40c0c0b4da70e37a18712f200b4c66d3b44fd59d98e
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}
LABEL "repository"="https://github.com/rwaight/actions"
#LABEL "homepage"="https://github.com/rwaight/actions/tree/main/releases/release-drafter"
LABEL "homepage" = "https://github.com/rwaight/actions"
LABEL "maintainer"="rwaight"
LABEL "org.opencontainers.image.source"="https://github.com/rwaight/actions"
LABEL "org.opencontainers.image.url" = "https://github.com/rwaight/actions/tree/main/releases/release-drafter"
LABEL "com.github.actions.name"="Release Drafter"
LABEL "com.github.actions.description"="Drafts your next release notes as pull requests are merged into master."
LABEL "com.github.actions.icon"="edit-2"
LABEL "com.github.actions.color"="orange"

WORKDIR /app
COPY . .
RUN yarn --frozen-lockfile
ENTRYPOINT [ "/app/node_modules/.bin/probot" ]
CMD [ "receive", "/app/index.js" ]
