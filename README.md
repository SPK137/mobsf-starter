# MobSF Starter
Starter for installing dependencies and MobSF

## Prerequisites

- [Crystal v1.5.0](https://crystal-lang.org/install/)
- [make](https://formulae.brew.sh/formula/make)

## Development Commands

| cmd           | description                     |
| ------------- | ------------------------------- |
| `make format` | Format the source code          |
| `make build`  | Build a binary file from source |
| `make test`   | Run tests according to spec     |

To quickly test out command without building a binary:

```shell
# setup command
crystal run ./src/mobsf.cr setup

# update command
crystal run ./src/mobsf.cr update

# help command
crystal run ./src/mobsf.cr -h
```

## Usage

### Linux

- After giving the binary permission to execute, simply run `./mobsf-installer --help to explore the commands`

- For quick installation, run `./mobsf-installer setup --setup-type=all`

- In case the binary cannot be run, run the following command before running the binary

```
sudo apt-get install libevent-2.1
```


