FROM python:3.8-slim

LABEL org.opencontainers.image.source="https://github.com/jaw3l/tdm-nonvc"
LABEL org.opencontainers.image.title="TDM-noVNC"

WORKDIR /usr/src/app

RUN apt-get update && apt-get upgrade -y

# Build dependencies needed for the TDM
RUN apt-get install -y \
    tk \
    xvfb \
    wget \
    unzip \
    x11vnc \
    fluxbox \
    gtk+3.0 \
    pkg-config \
    python3-dev \
    libcairo2-dev \
    libappindicator3-dev \
    libgirepository1.0-dev \
    libayatana-appindicator3-dev

ENV NOVNC_VERSION="${NOVNC_VERSION:-latest}"
RUN mkdir -p /usr/share/novnc && \
    if [ "$NOVNC_VERSION" = "latest" ]; then \
    wget -qO- https://github.com/novnc/noVNC/archive/refs/heads/master.tar.gz | tar xz --strip 1 -C /usr/share/novnc; \
    else \
    wget -qO- https://github.com/novnc/noVNC/archive/v$NOVNC_VERSION.tar.gz | tar xz --strip 1 -C /usr/share/novnc; \
    fi

# Copy the requirements.txt file and install Python dependencies
COPY ./tdm/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the project
COPY ./tdm .

COPY ./docker/entrypoint.sh /usr/bin
RUN chmod +x /usr/bin/entrypoint.sh

ENV DISPLAY=:0 \
    VNC_PORT=5900 \
    NOVNC_PORT=8080 \
    LOG_LEVEL=INFO

EXPOSE $VNC_PORT $NOVNC_PORT

ENTRYPOINT [ "/usr/bin/entrypoint.sh" ]
