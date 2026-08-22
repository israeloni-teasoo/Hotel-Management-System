# Running the Hotel Management System with Docker

This repo ships a `Dockerfile` and `docker-compose.yml` that stand up the full
QloApps application (Apache + PHP 8.1, all required extensions) alongside a
MySQL 8 database — no local PHP/MySQL setup required.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) and Docker Compose v2
  (`docker compose`, bundled with recent Docker Desktop / Docker Engine).

## 1. Start the stack

From the repo root:

```bash
docker compose up -d --build
```

The first build takes a few minutes (it compiles the PHP extensions). When it
finishes, the app is served at:

**http://localhost:8080**

## 2. Run the installer

Open http://localhost:8080 in your browser — the QloApps setup wizard runs on
first visit. Accept the license and step through until it asks for the
**database configuration**, then enter:

| Field             | Value      |
| ----------------- | ---------- |
| Database server   | `db`       |
| Database name     | `qloapps`  |
| Database login    | `qloapps`  |
| Database password | `qloapps`  |
| Tables prefix     | `ps_` (default) |

Finish the wizard, set your admin account, and you're in.

## 3. Post-install (security)

QloApps requires the installer to be removed after setup. Remove it inside the
running container (or delete `install/` from the repo and rebuild):

```bash
docker compose exec app rm -rf /var/www/html/install
```

The admin back office lives at `http://localhost:8080/admin` — the wizard
renames this folder; use the name it shows you on the final screen.

## Everyday commands

```bash
docker compose logs -f app     # tail application logs
docker compose down            # stop (keeps data in named volumes)
docker compose down -v         # stop AND wipe all data (fresh install next time)
docker compose up -d --build   # rebuild after changing code
```

## Data & persistence

Persistent data lives in named Docker volumes, so `docker compose down` keeps
your install:

- `qloapps_db` — the MySQL database
- `qloapps_config`, `qloapps_img`, `qloapps_upload`, `qloapps_download` —
  installer output and user-generated content

## Developing against your own code

By default the app code is **baked into the image**, so after editing files run
`docker compose up -d --build` to see changes. To edit code live without
rebuilding, open `docker-compose.yml`, comment out the four `qloapps_*`
app volumes and uncomment the `./:/var/www/html` bind mount (Linux/macOS).

## Notes

- Ports: change the host port by editing `"8080:80"` in `docker-compose.yml`.
- The default database credentials are for **local development only** — change
  them before exposing this anywhere.
