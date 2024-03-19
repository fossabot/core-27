# Automatically generated by hassfest.
#
# To update, run python3 -m script.hassfest -p docker
ARG BUILD_FROM
FROM ${BUILD_FROM}

# Synchronize with homeassistant/core.py:async_stop
ENV \
    S6_SERVICES_GRACETIME=240000 \
    UV_SYSTEM_PYTHON=true

ARG QEMU_CPU

# Install uv
RUN pip3 install uv==0.1.22

WORKDIR /usr/src

## Setup Home Assistant Core dependencies
COPY requirements.txt homeassistant/
COPY homeassistant/package_constraints.txt homeassistant/homeassistant/
RUN \
    uv pip install \
        --no-build \
        -r homeassistant/requirements.txt

COPY requirements_all.txt home_assistant_frontend-* home_assistant_intents-* homeassistant/
RUN \
    if ls homeassistant/home_assistant_frontend*.whl 1> /dev/null 2>&1; then \
        uv pip install homeassistant/home_assistant_frontend-*.whl; \
    fi \
    && if ls homeassistant/home_assistant_intents*.whl 1> /dev/null 2>&1; then \
        uv pip install homeassistant/home_assistant_intents-*.whl; \
    fi \
    && if [ "${BUILD_ARCH}" = "i386" ]; then \
        LD_PRELOAD="/usr/local/lib/libjemalloc.so.2" \
        MALLOC_CONF="background_thread:true,metadata_thp:auto,dirty_decay_ms:20000,muzzy_decay_ms:20000" \
        linux32 uv pip install \
            --no-build \
            -r homeassistant/requirements_all.txt; \
    else \
        LD_PRELOAD="/usr/local/lib/libjemalloc.so.2" \
        MALLOC_CONF="background_thread:true,metadata_thp:auto,dirty_decay_ms:20000,muzzy_decay_ms:20000" \
        uv pip install \
            --no-build \
            -r homeassistant/requirements_all.txt; \
    fi

## Setup Home Assistant Core
COPY . homeassistant/
RUN \
    uv pip install \
        -e ./homeassistant \
    && python3 -m compileall \
        homeassistant/homeassistant

# Home Assistant S6-Overlay
COPY rootfs /

WORKDIR /config
