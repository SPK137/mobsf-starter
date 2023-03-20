format:
	crystal tool format .

.PHONY: format

build:
	shards build --production --release --no-debug

.PHONY: build

test: build
	crystal spec

.PHONY: test

clean:
	rm -rf ./bin

.PHONY: clean
