
.PHONY: generate build run test clean release build-linux build-windows build-mac-intel build-mac-arm

generate:
	goyacc -o internal/parser/parser.go internal/parser/grammar.y
	rm -f y.output

build: generate
	mkdir -p build
	go build -o build/obsact ./cmd/obsact

run: build
	./build/obsact $(FILE)

test:
	go test ./...

release: build-linux build-windows build-mac-intel build-mac-arm

build-linux: generate
	mkdir -p dist
	GOOS=linux GOARCH=amd64 go build -o dist/obsact-linux-amd64 ./cmd/obsact

build-windows: generate
	mkdir -p dist
	GOOS=windows GOARCH=amd64 go build -o dist/obsact-windows64.exe ./cmd/obsact

build-mac-intel: generate
	mkdir -p dist
	GOOS=darwin GOARCH=amd64 go build -o dist/obsact-amd64 ./cmd/obsact

build-mac-arm: generate
	mkdir -p dist
	GOOS=darwin GOARCH=arm64 go build -o dist/obsact-arm64 ./cmd/obsact

clean:
	rm -rf build dist internal/parser/parser.go y.output
