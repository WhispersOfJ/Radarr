FROM node:24-bookworm AS frontend

WORKDIR /src

COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --network-timeout 120000

COPY . .
RUN yarn run build --env production


FROM mcr.microsoft.com/dotnet/sdk:10.0 AS backend

WORKDIR /src

COPY . .

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

WORKDIR /app

COPY --from=backend /app ./
COPY --from=frontend /src/_output/UI ./UI

VOLUME ["/config"]
EXPOSE 7878

ENTRYPOINT ["/app/Radarr", "-data=/config", "-nobrowser"]
