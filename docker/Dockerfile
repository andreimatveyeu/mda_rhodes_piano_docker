FROM ubuntu:25.04

ENV DEBIAN_FRONTEND=noninteractive

# Install locales, core audio, mda-lv2, jalv,
# GTK runtime, jack-tools, jackmesh (for connecting the audio modules)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        locales \
        pipewire \
        pipewire-jack \
        libgtk-3-0 \
        libsm6 \
        jack-tools \
	jack-example-tools \
        mda-lv2 \
        jalv \
        dragonfly-reverb \
        libgtk2.0-dev \
        python3 \
        python3-pip \
        git \
    && pip install --break-system-packages git+https://github.com/andreimatveyeu/jackmesh.git@0.5.4 \
    && apt-get remove -y --purge git python3-pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure locales
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG="en_US.UTF-8" LANGUAGE="en_US:en" LC_ALL="en_US.UTF-8"

# Application setup
RUN mkdir /app
ARG GIT_COMMIT=unspecified
LABEL name=ghcr.io/andreimatveyeu/mda_rhodes:latest
LABEL revision=$GIT_COMMIT

COPY config /app/mda_rhodes

# Command to run two instances of mda-lv2 plugin via jalv
CMD pw-jack jalv -b 256 -n mda_rhodes -x -i -l /app/mda_rhodes/piano & \
    pw-jack jalv -b 256 -n mda_rhodes_reverb -x -i -l /app/mda_rhodes/reverb & \
    sleep 3 && pw-jack jackmesh -l /app/mda_rhodes/connections.toml && echo "All connected" & tail -f /dev/null
