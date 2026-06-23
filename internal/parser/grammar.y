%{
package main

import(
	"fmt"
	"os"
	"strconv"
)
%}



%union{
	str string
	num int
}
%token <str> NAMEDEVICE
%token DISPOSITIVO
%token <str> OBSERVATION
%token <num> NUM
%token <str> MSG
%token <str> BOOL
%token <str> OPLOGIC
%token SET IF ELSE THEN AND ALERT SEND
%token LIGAR DESLIGAR VERIFICAR
%type <str> ACTION
%nonassoc THEN
%nonassoc ELSE
%%

PROGRAM: DEVICES CMDS
DEVICES: DEVICE DEVICES | DEVICE
DEVICE: DISPOSITIVO ':' '{' NAMEDEVICE '}'
DEVICE: DISPOSITIVO ':' '{' NAMEDEVICE ',' OBSERVATION '}'
CMDS: CMD '.' CMDS | CMD '.'
CMD: ATTRIB | OBSACT | ACT
ATTRIB: SET OBSERVATION '=' VAR
ATTRIB: SET OBSERVATION '=' ACTEXECUTE
OBSACT:
	IF OBS THEN CMDS

OBSACT: IF OBS THEN CMDS ELSE CMDS
OBS: OBSERVATION OPLOGIC VAR
OBS: OBSERVATION OPLOGIC VAR AND OBS
VAR: NUM | BOOL
ACT: ACTEXECUTE | ACTALERT
ACTEXECUTE:
	ACTION NAMEDEVICE{
		fmt.Printf("%s('%s')\n", $1, $2)
	}
ACTALERT: SEND ALERT '(' MSG ')' NAMEDEVICE
ACTALERT: SEND ALERT '(' MSG ',' OBSERVATION ')' NAMEDEVICE
ACTION:
	LIGAR{
		$$ = "ligar"
	}
	| DESLIGAR{
		$$ = "desligar"
	}
	| VERIFICAR{
		$$ = "verificar"
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
	switch t.typ {
            case NUM:
                n, _ := strconv.Atoi(t.val)
                lval.num = n

            case NAMEDEVICE, OBSERVATION, MSG, BOOL, OPLOGIC:
                lval.str = t.val
        }
	lval.str = t.val
	return t.typ
}

func (l *Lexer) Error(s string){
	fmt.Fprintln(os.Stderr, "erro de sintaxe", s)
}

func main (){

	lex := &Lexer{
		tokens: []token{
			{typ: DISPOSITIVO, val: "dispositivo"},
                            {typ: int(':'), val: ":"},
                            {typ: int('{'), val: "{"},
                            {typ: NAMEDEVICE, val: "lampada"},
                            {typ: int('}'), val: "}"},

                            {typ: LIGAR, val: "ligar"},
                            {typ: NAMEDEVICE, val: "lampada"},
                            {typ: int('.'), val: "}"},
		},
	}
	yyParse(lex)
}





