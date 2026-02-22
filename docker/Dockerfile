# =============================================================================
# Stage 1: Build kuriborosu (offline MIDI-to-WAV renderer)
# =============================================================================
FROM ubuntu:25.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies for kuriborosu and Carla
# Note: liblo-dev is excluded to avoid typedef conflicts with Carla's internal OSC code
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        git \
        ca-certificates \
        pkg-config \
        libsndfile1-dev \
        libx11-dev \
        libmagic-dev \
        libasound2-dev \
        libpulse-dev \
        libfluidsynth-dev \
        python3 \
    && rm -rf /var/lib/apt/lists/*

# Clone kuriborosu with Carla submodule and build
# Disable OSC and JACK (not needed for offline rendering, avoids liblo conflicts)
RUN git clone --recursive --depth 1 https://github.com/falkTX/kuriborosu.git /tmp/kuriborosu && \
    cd /tmp/kuriborosu && \
    cmake -B build -DCMAKE_BUILD_TYPE=Release -DCARLA_USE_OSC=OFF -DCARLA_USE_JACK=OFF && \
    cmake --build build --parallel $(nproc)

# =============================================================================
# Stage 2: Runtime image
# =============================================================================
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
        libsndfile1 \
        libfluidsynth3 \
        liblo7 \
        libmagic1 \
    && pip install --break-system-packages git+https://github.com/andreimatveyeu/jackmesh.git@0.5.4 \
    && apt-get remove -y --purge git python3-pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy kuriborosu binary from builder stage
COPY --from=builder /tmp/kuriborosu/build/bin/kuriborosu /usr/local/bin/kuriborosu

# Configure locales
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG="en_US.UTF-8" LANGUAGE="en_US:en" LC_ALL="en_US.UTF-8"

# Application setup
RUN mkdir -p /app/scripts
ARG GIT_COMMIT=unspecified
LABEL name=ghcr.io/andreimatveyeu/mda_rhodes_piano:latest
LABEL revision=$GIT_COMMIT

COPY config /app/mda_rhodes
COPY scripts /app/scripts
RUN chmod +x /app/scripts/*.sh

# Default: run in realtime mode (two instances of mda-lv2 plugin via jalv)
CMD pw-jack jalv -b 256 -n mda_rhodes -x -i -l /app/mda_rhodes/piano & \
    pw-jack jalv -b 256 -n mda_rhodes_reverb -x -i -l /app/mda_rhodes/reverb & \
    sleep 3 && pw-jack jackmesh -l /app/mda_rhodes/connections.toml && echo "All connected" & tail -f /dev/null
