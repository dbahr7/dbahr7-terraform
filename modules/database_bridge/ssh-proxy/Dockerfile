FROM segment/chamber:3 AS chamber
# Upgrading to newer versions of 9.x caused the container to fail. Follow up work is required to determine what breaks in newer versions of the base image.
FROM linuxserver/openssh-server:9.7_p1-r4-ls170
COPY --from=chamber /chamber /usr/bin/chamber

# Completely replace the logging service with our own
RUN rm -rf /etc/s6-overlay/s6-rc.d/log-openssh-server
# Copy our s6 services
COPY ./s6-rc.d /etc/s6-overlay/s6-rc.d

# Run service scripts with chamber
COPY ./build-support /build-support
RUN <<EOF
#!/bin/bash
set -euo pipefail
source /build-support/make-wrapper.sh
run_scripts=(
    /etc/s6-overlay/s6-rc.d/init-mod-openssh-server/run
    /etc/s6-overlay/s6-rc.d/init-openssh-server-config/run
    /etc/s6-overlay/s6-rc.d/svc-openssh-server/run
)
for run_script in "${run_scripts[@]}"; do
    wrapProgram \
        "$run_script" \
        --set S6_KEEP_ENV 1 \
        --run '
            if [ -n "${CHAMBER_SERVICES:-}" ]; then
              exec chamber exec $CHAMBER_SERVICES -- "$_WRAPPED_PROGRAM" "$@"
            fi'
    sed -i'' -e 's,@shell@.*$,/usr/bin/with-contenv bash,g' "$run_script"
done
rm -rf /build-support
EOF

# Set up required env vars
# https://github.com/linuxserver/docker-openssh-server#usage
ENV PUID=1000
ENV PGID=1000
ENV TZ=US/Pacific

# Optional env vars
ENV USER_NAME=ssh-user
