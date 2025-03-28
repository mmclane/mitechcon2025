FROM example.repo.com/cache/node:20-bookworm-slim AS build
ARG ver=latest
ARG codeArtifactToken
LABEL version=$ver

WORKDIR /{{ service-name }}
COPY . /{{ service-name }}/

RUN npm config set registry=https://dn-878788551012.d.codeartifact.us-east-1.amazonaws.com/npm/dn-npm-public/ && \
    npm config set //dn-878788551012.d.codeartifact.us-east-1.amazonaws.com/npm/dn-npm-public/:_authToken="${codeArtifactToken}" && \
    npm ci --omit=dev --ignore-scripts

RUN useradd nonroot --create-home
USER nonroot

ENTRYPOINT ["npm", "run", "start"]
