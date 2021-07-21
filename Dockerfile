FROM plexinc/pms-docker:latest

RUN dpkg-divert --add --rename --divert "/usr/lib/plexmediaserver/Plex Transcoder2" "/usr/lib/plexmediaserver/Plex Transcoder"

COPY [ "docker-plex-nvdec/Plex Transcoder", "/usr/lib/plexmediaserver/Plex Transcoder" ]

RUN chmod 755 "/usr/lib/plexmediaserver/Plex Transcoder"

COPY nvidia-patch/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY nvidia-patch/patch.sh /usr/local/bin/patch.sh

RUN chmod 755 /usr/local/bin/docker-entrypoint.sh /usr/local/bin/patch.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh", "/init"]

ARG NVIDIA_DRIVER_VERSION=460.91.03

WORKDIR /tmp

RUN curl -fSsl -O http://us.download.nvidia.com/XFree86/Linux-x86_64/${NVIDIA_DRIVER_VERSION}/NVIDIA-Linux-x86_64-${NVIDIA_DRIVER_VERSION}.run && \
    sh NVIDIA-Linux-x86_64-${NVIDIA_DRIVER_VERSION}.run -x && \
    ln -s /usr/bin/true /usr/local/bin/modprobe && \
    ln -s /usr/bin/true /usr/local/bin/depmod && \
    ln -s /usr/bin/true /usr/local/bin/insmod && \
    ln -s /usr/bin/true /usr/local/bin/lsmod && \
    ln -s /usr/bin/true /usr/local/bin/rmmod && \
    cd NVIDIA-Linux-x86_64-${NVIDIA_DRIVER_VERSION} && \
    ./nvidia-installer --silent --no-kernel-module --install-compat32-libs \
        --no-nouveau-check --no-nvidia-modprobe --no-rpms --no-backup \
        --no-check-for-alternate-installs --no-libglx-indirect \
        --no-install-libglvnd --x-prefix=/tmp/null --x-module-path=/tmp/null \
        --x-library-path=/tmp/null --x-sysconfig-path=/tmp/null && \
    cd /tmp && \
    rm -rf NVIDIA-Linux-x86_64-${NVIDIA_DRIVER_VERSION}*

WORKDIR /
