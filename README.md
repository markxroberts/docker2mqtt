# docker2mqtt - Deliver docker status information and basic control over MQTT

![Maintenance](https://img.shields.io/maintenance/yes/2023.svg)
[![Docker Pulls](https://img.shields.io/docker/pulls/markxroberts/docker2mqtt)](https://hub.docker.com/r/markxroberts/docker2mqtt)
[![buy me a coffee](https://img.shields.io/badge/If%20you%20like%20it-Buy%20me%20a%20coffee-orange.svg)](https://www.buymeacoffee.com/markxr)

This program uses `docker events` to watch for changes in your docker containers, and delivers current status to MQTT. It will also publish Home Assistant MQTT Discovery messages so that sensors and switches automatically show up in Home Assistant.  Switch events are published via `docker start`, `docker stop` and `docker restart`.

It is based entirely on skullydazed/docker2mqtt who wrote the original code.  I have adapted for my purposes.

# Running

Use docker to launch this. Please note that you must give it access to your docker socket, which is typically located at `/var/run/docker.sock`. A typical invocation is:

    docker run --network mqtt -e MQTT_HOST=mosquitto -v /var/run/docker.sock:/var/run/docker.sock ghcr.io/markxroberts/docker2mqtt:latest

You can also use docker compose:
```yaml
version: '3'
services:
  docker2mqtt:
    container_name: docker2mqtt
    image: ghcr.io/markxroberts/docker2mqtt
    environment:
    - DESTROYED_CONTAINER_TTL=86400
    - DOCKER2MQTT_HOSTNAME=my_docker_host
    - HOMEASSISTANT_PREFIX=homeassistant
    - HOMEASSISTANT_NAME_PREFIX=docker
    - MQTT_CLIENT_ID=docker2mqtt
    - MQTT_HOST=mosquitto
    - MQTT_PORT=1883
    - MQTT_USER=username
    - MQTT_PASSWD=password
    - MQTT_TIMEOUT=30
    - MQTT_TOPIC_PREFIX=docker
    - MQTT_QOS=1
    restart: always
    volumes:
    - /var/run/docker.sock:/var/run/docker.sock
```

# Configuration

You can use environment variables to control the behaviour.

| Variable | Default | Description |
|----------|---------|-------------|
| `LOGGING` | INFO | Options DEBUG, WARNING |
| `DESTROYED_CONTAINER_TTL` | 86400 | How long, in seconds, before destroyed containers are removed from Home Assistant. Containers won't be removed if the service is restarted before the TTL expires. |
| `DOCKER2MQTT_HOSTNAME` | Container Hostname | The hostname of your docker host. This will be the container's hostname by default, you probably want to override it. |
| `HOMEASSISTANT_PREFIX` | `homeassistant` | The prefix for Home Assistant discovery. Must be the same as `discovery_prefix` in your Home Assistant configuration. |
| `HOMEASSISTANT_NAME_PREFIX` | `docker` | The friendly name and entity_id prefix for Home Assistant |
| `MQTT_CLIENT_ID` | `docker2mqtt` | The client id to send to the MQTT broker. |
| `MQTT_HOST` | `localhost` | The MQTT broker to connect to. |
| `MQTT_PORT` | `1883` | The port on the broker to connect to. |
| `MQTT_USER` | `` | The user to send to the MQTT broker. Leave unset to disable authentication. |
| `MQTT_PASSWD` | `` | The password to send to the MQTT broker. Leave unset to disable authentication. |
| `MQTT_TIMEOUT` | `30` | The timeout for the MQTT connection. |
| `MQTT_TOPIC_PREFIX` | `docker` | The MQTT topic prefix. With the default data will be published to `docker/<Container_Name>`. |
| `MQTT_QOS` | `1` | The MQTT QOS level |

# Consuming The Data

4 sensors, 1 switch and 1 button are currently created in Home Assistant for each container, with each container defined as a device:

```
  binary_sensor.HOMEASSISTANT_NAME_PREFIX_<container>_state
  sensor.HOMEASSISTANT_NAME_PREFIX_<container>_event
  sensor.HOMEASSISTANT_NAME_PREFIX_<container>_event_type
  sensor.HOMEASSISTANT_NAME_PREFIX_<container>_created
  switch.HOMEASSISTANT_NAME_PREFIX_<container>_switch
  button.HOMEASSISTANT_NAME_PREFIX_<container>_restart
```

Data is published to the topics `<MQTT_TOPIC_PREFIX>/<container>_[status,event,event_type,created]` using JSON serialization. Updates will be published whenever a change happens and take the following form:

```yaml
{
    'name': <Container Name>,
    'image': <Container Image>,
    'status': <'paused', 'running', or 'stopped'>,
    'state': <'on' or 'off'>,
    'event': <Container event date>,
    'created': <Container created date>,
    'ip': <Container IP address>
}
```
The switch and button topics monitored by the application are:
```
  <MQTT_TOPIC_PREFIX>/<container>/switch
  <MQTT_TOPIC_PREFIX>/<container>/restart
```

# Home Assistant

After you start the service, sensors, switches and buttons should show up in Home Assistant within a couple of minutes depending on the number of containers that you have.  Switches will not be published for Home Assistant or docker2mqtt provided that the container names contain `Home` and `Assistant` or `docker2mqtt`.  These are case insensitive.

Beware that 'devices' may remain present within Home Assistant if the delete or rename process doesn't complete.

