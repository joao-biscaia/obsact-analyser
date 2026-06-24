package main

import (
	"flag"
	"fmt"
	"obsactAnalyser/internal/codegen"
	"obsactAnalyser/internal/parser"
	"os"
)

func main() {
	fp := flag.String("filepath", "testdata/valid/valid.obsact", "Arquivo de entrada para leitura")
	outPath := flag.String("output", "testdata/output-valids/", "Caminho para arquivo de saída")
	flag.Parse()
	data, err := os.ReadFile(*fp)
	if err != nil {
		fmt.Fprintf(os.Stderr, "erro ao ler o arquivo %s: %q\n", *fp, err)
		os.Exit(1)
	}
	tokensChan := parser.Tokenize(string(data))
	lex := &parser.Lexer{Tokens: tokensChan}
	parser.Parse(lex)
	final := codegen.RuntimePy + "\n\n" + lex.GeneratedCode.String()
	os.WriteFile(*outPath+"saida.py", []byte(final), 0644)
}
