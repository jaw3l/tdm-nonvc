FROM python:3.8-slim

LABEL org.opencontainers.image.source="https://github.com/jaw3l/tdm-nonvc"
LABEL org.opencontainers.image.title="TDM-noVNC"

WORKDIR /usr/src/app

RUN apt-get update && apt-get upgrade -y

# Build dependencies needed for the TDM
RUN apt-get install -y \
    tk \
    gtk+3.0 \
    pkg-config \
    python3-dev \
    libcairo2-dev \
    libappindicator3-dev \
    libgirepository1.0-dev \
    libayatana-appindicator3-dev

# Copy the requirements.txt file and install Python dependencies
COPY ./tdm/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the project
COPY ./tdm .

COPY ./docker/entrypoint.sh /usr/bin
RUN chmod +x /usr/bin/entrypoint.sh

ENV DISPLAY=localhost:0.0 \
    LOG_LEVEL=INFO

ENTRYPOINT [ "/usr/bin/entrypoint.sh" ]
