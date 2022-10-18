FROM $SOURCE_REPO:$IMAGE_TAG
ARG DRIVERS
ARG OS_TYPE
USER root
RUN --mount='type=bind,source=build,target=/build' /build/build.sh
USER $USER
