This repository provides a setup to spin up multiple Docker instances using Docker Compose based on a user-defined configuration file. The solution includes scripts and configurations to dynamically generate and start the necessary Docker containers for each instance defined in the configuration file.

## Features

_Dynamic configuration_ - Easily specify multiple Docker instances in a YAML configuration file.\
_Automated setup_ - Scripts to automatically generate Docker Compose files and start the defined services.\
_Isolated environment_ - Each instance runs in its own Docker container, ensuring isolation and manageability.\
_Simple deployment_ - Utilize Docker Compose for streamlined setup and management of services.

## Usage

1.‎‎‏‏‎ ‎Clone the repository

```sh
 git clone https://github.com/qasah/local-infrastructure.git
```

2.‎‎‏‏‎ Define your `config.yaml` file

3.‎‎‏‏‎ Set executable permission (if not already set)

```sh
 chmod +x .sh
```

4.‎‎‏‏‎ Run

```sh
 docker compose -f components.yaml up
```

\
Example of `config.yaml`

```yaml
project: valhalla
components:
  postgres:
    image: postgres
    tag: 16-bullseye
    restart: always
    port: 5432
    instances:
      - name: authentication-service
        port: 5432
        values:
          - POSTGRES_USER=***
          - POSTGRES_PASSWORD=***
          - POSTGRES_DB=***
      - name: notification-service
        port: 5433
        values:
          - POSTGRES_USER=***
          - POSTGRES_PASSWORD=***
          - POSTGRES_DB=***
  redis:
    image: redis
    tag: 7.2-alpine
    restart: always
    port: 6379
    instances:
      - name: queue
        port: 6379
        values:
          - REDIS_PASSWORD=***
      - name: cache
        port: 6380
        values:
          - REDIS_PASSWORD=***
      - name: rate-limit
        port: 6381
        values:
          - REDIS_PASSWORD=***
```

## Issues

- [ ] Volumes are currently not supported.
- [ ] If there's no `config,yml` file. After the process exits, a `config.yml` folder is automatically created - this is caused by the volume in the `components.yaml` file.
- [ ] Existing `configurator` container needs to be deleted before a new one can be launched.

## LICENSE

This project is licensed under the MIT License. See the `LICENSE` file for details.
