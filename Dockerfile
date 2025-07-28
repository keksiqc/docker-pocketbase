# ╔═════════════════════════════════════════════════════╗
# ║                       SETUP                         ║
# ╚═════════════════════════════════════════════════════╝
  # GLOBAL
  ARG APP_UID=1000 \
      APP_GID=1000 \
      BUILD_SRC=https://github.com/pocketbase/pocketbase.git \
      BUILD_ROOT=/go/pocketbase
  ARG BUILD_BIN=${BUILD_ROOT}/pocketbase

  # :: FOREIGN IMAGES
  FROM 11notes/distroless AS distroless
  FROM 11notes/distroless:curl AS distroless-curl

# ╔═════════════════════════════════════════════════════╗
# ║                       BUILD                         ║
# ╚═════════════════════════════════════════════════════╝
  # :: POCKETBASE
  FROM 11notes/go:1.24 AS build
  ARG APP_VERSION \
      BUILD_SRC \
      BUILD_ROOT \
      BUILD_BIN \
      CGO_ENABLED=0

  RUN set -ex; \
    apk --update --no-cache add \
      nodejs \
      npm \
      git;

  RUN set -ex; \
    git clone ${BUILD_SRC} -b v${APP_VERSION};

  RUN set -ex; \
    cd ${BUILD_ROOT}/ui; \
    npm ci; \
    npm run build;

  RUN set -ex; \
    cd ${BUILD_ROOT}; \
    go mod tidy; \
    go build -ldflags "-s -w -X github.com/pocketbase/pocketbase.Version=${APP_VERSION}" -o ${BUILD_BIN} ./examples/base;

  RUN set -ex; \
    eleven distroless ${BUILD_BIN};

  # :: FILE SYSTEM
  FROM alpine AS file-system
  ARG APP_ROOT
  USER root
  RUN set -ex; \
    eleven mkdir /distroless${APP_ROOT}/var/{pb_data,pb_hooks,pb_migrations,pb_public};

# ╔═════════════════════════════════════════════════════╗
# ║                       IMAGE                         ║
# ╚═════════════════════════════════════════════════════╝
  # :: HEADER
  FROM scratch

  # :: default arguments
    ARG TARGETPLATFORM \
        TARGETOS \
        TARGETARCH \
        TARGETVARIANT \
        APP_IMAGE \
        APP_NAME \
        APP_VERSION \
        APP_ROOT \
        APP_UID \
        APP_GID \
        APP_NO_CACHE

  # :: default environment
    ENV APP_IMAGE=${APP_IMAGE} \
        APP_NAME=${APP_NAME} \
        APP_VERSION=${APP_VERSION} \
        APP_ROOT=${APP_ROOT}

  # :: multi-stage
    COPY --from=distroless / /
    COPY --from=distroless-curl / /
    COPY --from=build /distroless/ /
    COPY --from=file-system --chown=${APP_UID}:${APP_GID} /distroless/ /

# :: PERSISTENT DATA
  VOLUME ["${APP_ROOT}/var"]

# :: HEALTH
  HEALTHCHECK --interval=5s --timeout=2s --start-period=5s \
    CMD ["/usr/local/bin/curl", "-kILs", "--fail", "-o", "/dev/null", "http://localhost:8090/api/health"]

# :: EXECUTE
  USER ${APP_UID}:${APP_GID}
  ENTRYPOINT ["/usr/local/bin/pocketbase"]
  CMD ["serve", "--http=0.0.0.0:8090", "--dir", "${APP_ROOT}/var/pb_data", "--publicDir", "${APP_ROOT}/var/pb_public", "--hooksDir", "${APP_ROOT}/var/pb_hooks", "--migrationsDir", "${APP_ROOT}/var/pb_migrations"]
