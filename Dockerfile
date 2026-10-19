FROM node:24-bookworm AS frontend

WORKDIR /src

COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --network-timeout 120000

COPY . .
RUN yarn run build --env production


FROM mcr.microsoft.com/dotnet/sdk:10.0 AS backend

WORKDIR /src

COPY . .

RUN sed -i 's|<AssemblyVersion>10.0.0.\*</AssemblyVersion>|<AssemblyVersion>7.0.0.10772</AssemblyVersion>|' \
    src/Directory.Build.props

RUN dotnet publish src/NzbDrone.Console/Radarr.Console.csproj \
    --configuration Release \
    --framework net10.0 \
    --runtime linux-x64 \
    --self-contained false \
    -p:AssemblyVersion=7.0.0.10772 \
    -p:EnableAnalyzers=false \
    --output /app

RUN dotnet publish src/NzbDrone.Mono/Radarr.Mono.csproj \
    --configuration Release \
    --framework net10.0 \
    --runtime linux-x64 \
    --self-contained false \
    -p:EnableAnalyzers=false \
    --output /app


FROM mcr.microsoft.com/dotnet/aspnet:10.0

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl tzdata \
    && rm -rf /var/lib/apt/lists/*

ARG VERSION=7.0.0.10772
ARG REVISION=unknown

LABEL org.opencontainers.image.title="Radarr select-count fork" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.revision="${REVISION}" \
      org.opencontainers.image.source="https://github.com/Radarr/Radarr"

WORKDIR /app

COPY --from=backend /app ./bin
COPY --from=frontend /src/_output/UI ./bin/UI

RUN printf 'PackageVersion=7.0.0.10772\nPackageAuthor=Legends fork\nUpdateMethod=Docker\nBranch=nightly\n' \
    > /app/package_info

VOLUME ["/config"]
EXPOSE 7878

ENTRYPOINT ["/app/bin/Radarr", "-data=/config", "-nobrowser"]
