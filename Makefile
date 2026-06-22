generate:
	goyacc -o internal/parser/parser.go internal/parser/grammar.y
	rm -rf y.output

run:
	go run ./internal/parser/