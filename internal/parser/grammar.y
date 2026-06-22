%{
package main

import(
	"fmt"
	"os"
)
%}



%union{
	str string
}
%token LIGAR
%token <str> NAMEDEVICE
%%

programa:
	LIGAR NAMEDEVICE
	{
		nome := $2
		fmt.Printf("ligar(\"%s\")\n", nome)
	}

%%

type Lexer struct{
	tokens []token
	pos int
}

type token struct{
	typ int
	val string
}

func (l * Lexer) Lex(lval *yySymType) int{
	if l.pos >= len(l.tokens){
		return 0
	}
	t := l.tokens[l.pos]
	l.pos++
	lval.str = t.val
	return t.typ
}

func (l *Lexer) Error(s string){
	fmt.Fprintln(os.Stderr, "erro de sintaxe", s)
}

func main (){

	lex := &Lexer{
		tokens: []token{
			{typ: LIGAR},
			{typ: NAMEDEVICE, val: "lampada"},
		},
	}
	yyParse(lex)
}





