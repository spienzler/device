# bin

Helper scripts for the Spienzler device.

## rl-snap.rb

Grabs a still image (snapshot) from a [Reolink](https://reolink.com/) camera and
saves it to a file. `rl` stands for *Reolink*.

The script talks to the camera's local HTTP API in two steps:

1. **Login** — posts the configured username and password and reads back a
   session token.
2. **Snapshot** — calls the `Snap` command with that token and writes the
   returned JPEG to the output path you provide.

It uses only the Ruby standard library (`net/http`, `json`, `uri`) — no
external `curl`/`wget`/`jq` needed.

### Configuration

Credentials and the camera address are read from `rl.env`, which sits next to
the script (`bin/rl.env`). Create it by copying the example and filling in your
values:

```bash
cp bin/rl.env.example bin/rl.env
```

`rl.env` defines three variables:

| Variable | Description           | Example                 |
| -------- | --------------------- | ----------------------- |
| `HOST`   | Camera host and port  | `127.0.0.1:8081`        |
| `USER`   | Camera login user     | `admin`                 |
| `PW`     | Camera login password | `my-very-secret-password` |

> `rl.env` holds a plaintext password and is git-ignored — keep it that way.

### Usage

Pass the destination file as the first argument:

```bash
./bin/rl-snap.rb /path/to/snapshot.jpg
```

The image is written to the given path. If the file already exists it is
overwritten. The commander (`commander/spienzler`) calls this script on a
schedule to collect webcam shots.

### Tests

The snapshot logic (the `ReolinkCamera` class) is covered by RSpec specs in the
commander project:

```bash
cd commander
bundle exec rspec
```

### Requirements

- Ruby (uses only the standard library)
- Network access to the camera at `$HOST`
