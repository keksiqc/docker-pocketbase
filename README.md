<p align="center">
  <a href="https://pocketbase.io/">
    <img alt="PocketBase logo" height="128" src="https://pocketbase.io/images/logo.svg">
    <h1 align="center">Docker Image for PocketBase</h1>
  </a>
</p>

<p align="center">
   <a aria-label="Latest PocketBase Version" href="https://github.com/pocketbase/pocketbase/releases" target="_blank">
    <img alt="Latest PocketBase Version" src="https://img.shields.io/github/v/release/pocketbase/pocketbase?color=success&display_name=tag&label=latest&logo=docker&logoColor=%23fff&sort=semver&style=flat-square">
  </a>
  <a aria-label="Supported architectures" href="https://github.com/pocketbase/pocketbase/releases" target="_blank">
    <img alt="Supported Docker architectures" src="https://img.shields.io/badge/platform-amd64%20%7C%20arm64%20%7C%20armv7-brightgreen?style=flat-square&logo=linux&logoColor=%23fff">
  </a>
</p>

---

> [!NOTE]
>
> This project is based on the work found in
> [muchobien/pocketbase-docker](https://github.com/muchobien/pocketbase-docker).
> And uses images from [11notes](https://github.com/11notes).

## Comparison

| **image** | keksiqc/pocketbase:0.29.0 | muchobien/pocketbase:latest |
| ---: | :---: | :---: |
| **image size on disk** | 25.6MB | 59.6MB |
| **process UID/GID** | 1000/1000 | 0/0 |
| **distroless?** | ✅ | ❌ |
| **rootless?** | ✅ | ❌ |


## Supported Architectures

Pulling `ghcr.io/keksiqc/pocketbase:latest` will automatically retrieve the
appropriate image for your system architecture.

| Architecture | Supported |
| ------------ | --------- |
| amd64        | ✅        |
| arm64        | ✅        |
| armv7        | ✅        |

## Version Tags

This image offers multiple tags for different versions. Choose the appropriate
tag for your use case and exercise caution when using unstable or development
tags.

| Tag    | Available | Description                         |
| ------ | --------- | ----------------------------------- |
| latest | ✅        | Latest stable release of PocketBase |
| x.x.x  | ✅        | Specific patch release              |
| x.x    | ✅        | Minor release                       |
| x      | ✅        | Major release                       |

## Application Setup

Access the web UI at `<your-ip>:8090`. For more details, refer to the
[PocketBase Documentation](https://pocketbase.io/docs/).

## Compose

```yaml
name: "pb"
services:
  pocketbase:
    read_only: true
    image: "ghcr.io/keksiqc/pocketbase:0.29.0"
    environment:
      TZ: "Europe/Berlin"
      PB_ENCRYPTION_KEY: "6bcf9990dd6d401c113b621bf2edeebd" # Change this in production (openssl rand -hex 16)
    volumes:
      - "pocketbase.var:/pocketbase/var"
    ports:
      - "8090:8090/tcp"
    networks:
      frontend:
    restart: "always"

volumes:
  pocketbase.var:

networks:
  frontend:
    external: true

```


## Related Repositories

- [PocketBase GitHub Repository](https://github.com/pocketbase/pocketbase)
