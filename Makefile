generate:
	goyacc -o internal/parser/parser.go -v internal/parser/out.output internal/parser/grammar.y
	rm -rf y.output

run:
	go run ./internal/parser/