# Radarr select-count fork

A fork of [Radarr](https://github.com/Radarr/Radarr) that adds a chunked
bulk-add workflow to the movie index.

## Purpose

Radarr's select mode can only select all or click rows one at a time. This fork
adds a **Select Count** control beside *Select All*:

- type a number (for example `174`) and commit with Enter, tab-out, or the Go
  button to select exactly the first N movies in the current filter and sort
  order;
- use the `250` / `500` / `1000` / `All` presets for the same operation;
- an oversized count is rejected, the input reverts, and a local hint names the
  maximum committable count;
- the select footer gains a **Mark Selected** button that reapplies the last tag
  used through the Tags modal in one click, so a chunk can be tagged as handled.

Selection is pure frontend state. No backend or API behaviour changes.

## Base and history

- Forked from Radarr `develop` at commit `14afe5286`.
- Feature commit: `feat(movies): add select-count selection and chunk tagging`.
- The feature branch is merged into `develop` in this repository.
- The upstream project, its documentation and its contribution rules live at
  <https://github.com/Radarr/Radarr>. This fork is not affiliated with upstream.

## Build

The repository builds Radarr from source and serves the production frontend
bundle:

```bash
docker build -t legends/radarr-select-count:7.0.0.10772 .
```

The image is a framework-dependent .NET 10 build. It runs as the user supplied by
the container runtime; mount a writable `/config` and expose port `7878`.

```bash
docker run -d \
  --name radarr-select-count \
  -p 7878:7878 \
  -v /path/to/appdata:/config \
  -v /path/to/media:/media:rslave \
  legends/radarr-select-count:7.0.0.10772
```

Radarr-specific environment variables (`RADARR__POSTGRES__*`,
`RADARR__AUTH__APIKEY`) are read exactly as upstream.

## License

Radarr is licensed under GPL-3.0. This fork carries the same license; see
[`LICENSE`](LICENSE).
