# TDM-noVNC

This repository combines [Twitch Drop Miner](https://github.com/DevilXD/TwitchDropsMiner) and [noVNC](https://github.com/novnc/noVNC) into a single container.

## Installation

**Example Compose File:**

```yaml
services:
  twitch_drop_miner:
    image: ghcr.io/jaw3l/tdm-nonvc:latest
    container_name: twitch_drop_miner
    restart: unless-stopped
    ports:
      - 8080:8080
    volumes:
      - ./data/tdm:/usr/src/app/data
    environment:
      - DISPLAY_WIDTH=1024
      - DISPLAY_HEIGHT=768
      - DISPLAY_DEPTH=16
      - NOVNC_PORT=8080
      - LOG_LEVEL=INFO
```

After initiating the Docker container, you may access the VNC interface by navigating to `https://localhost:8080/vnc.html`.

If you want simpler VNC interface you may use `https://localhost:8080/vnc_lite.html`.

### Volumes

It is possible to import `cookies.jar` and `settings.json` from your earlier instances.
Simply mount `/usr/src/app/data` to a designated folder and transfer the files into that folder.

### Environment Variables

#### TDM

| Variable         | Description                                | Default |
| ---------------- | ------------------------------------------ | ------- |
| `DISPLAY_WIDTH`  | Display width                              | 1024    |
| `DISPLAY_HEIGHT` | Display height                             | 768     |
| `DISPLAY_DEPTH`  | Display bit depth                          | 16      |
| `NOVNC_PORT`     | Run fluxbox desktop environment            | 8080    |
| `LOG_LEVEL`      | Log level options: WARN, INFO, CALL, DEBUG | INFO    |

## Troubleshoot

If TDM gives an error, the application can be restarted by pressing `Right CTRL` (CTRL_R), then `.` (period).

> [!NOTE]
> Pressing the buttons at the same time does not trigger the restart.
