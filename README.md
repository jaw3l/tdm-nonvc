# TDM-noVNC

This repository combines [Twitch Drop Miner](https://github.com/DevilXD/TwitchDropsMiner) and [noVNC](https://github.com/theasp/docker-novnc) into a single docker-compose file.

## Installation

**Example Compose File:**

```yaml
services:
  twitch_drop_miner:
    image: ghcr.io/jaw3l/tdm-nonvc:latest
    container_name: twitch_drop_miner
    restart: unless-stopped
    volumes:
      - ./data/tdm:/usr/src/app/data
    networks:
      - tdm
    depends_on:
      - novnc
    environment:
      - LOG_LEVEL=CALL
      - DISPLAY=novnc:0.0

  novnc:
    image: theasp/novnc:latest
    container_name: novnc
    restart: unless-stopped
    ports:
      - 8080:8080
    environment:
      - DISPLAY_WIDTH=1024
      - DISPLAY_HEIGHT=768
      - RUN_XTERM=no
      - RUN_FLUXBOX=yes
    networks:
      - tdm

networks:
  tdm:
    driver: bridge
    name: twitch_drop_miner_network
```

### Volumes

You can import `cookies.jar` and `settings.json` from your previous instances. All you have to do is mount `/usr/src/app/data` to a folder and move files into that folder.

### Environment Variables

#### TDM

| Variable    | Description                                     | Default         |
| ----------- | ----------------------------------------------- | --------------- |
| `LOG_LEVEL` | Log level options: `WARN`,`INFO`,`CALL`,`DEBUG` | `INFO`          |
| `DISPLAY`   | X Display name and screen                       | `localhost:0.0` |

#### noVNC

| Variable         | Description                     | Default |
| ---------------- | ------------------------------- | ------- |
| `DISPLAY_WIDTH`  | Display width                   | 1024    |
| `DISPLAY_HEIGHT` | Display height                  | 768     |
| `RUN_XTERM`      | Run xterm terminal on startup   | yes     |
| `RUN_FLUXBOX`    | Run fluxbox desktop environment | yes     | 
