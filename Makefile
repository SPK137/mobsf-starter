format:
	crystal tool format .

.PHONY: format

build:
	shards build --production --release --no-debug 

.PHONY: build

build-windows:
	crystal build src/mobsf.cr --cross-compile --target "x86_64-windows-msvc"
.PHONY: build-windows

build-linux:
	crystal build src/mobsf.cr --cross-compile --target "x86_64-linux-gnu"
.PHONY: build-linux

build-mac:
	crystal build src/mobsf.cr --cross-compile --target "x86_64-darwin"
.PHONY: build-mac

test: build
	crystal spec

.PHONY: test

clean:
	rm -rf ./bin

.PHONY: clean
