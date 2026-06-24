package main

import (
	"obsactAnalyser/internal/codegen"
	"obsactAnalyser/internal/parser"
	"os"
)

func main() {
	data, _ := os.ReadFile(os.Args[1])
	tokensChan := parser.Tokenize(string(data))
	lex := &parser.Lexer{Tokens: tokensChan}
	parser.Parse(lex)
	final := codegen.RuntimePy + "\n\n" + lex.GeneratedCode.String()
	os.WriteFile("saida.py", []byte(final), 0644)
}
