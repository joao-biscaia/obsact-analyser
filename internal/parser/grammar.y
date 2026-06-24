%{
package main

import(
	"fmt"
	"os"
	"strings"
	"strconv"
	"obsactAnalyser/internal/codegen"
)
%}



%union{
	str string
	num int
}
%token DISPOSITIVO
%token <num> NUM
%token <str> MSG
%token <str> IDENT
%token <str> BOOL
%token <str> OPLOGIC
%token SET IF ELSE ENDIF THEN AND ALERT SEND
%token LIGAR DESLIGAR VERIFICAR
%type <str> ACTION
%type <str> CMD CMDS ACT ATTRIB OBSACT ACTEXECUTE ACTALERT OBS VAR EXPR DEVICE DEVICES
%nonassoc THEN
%nonassoc ELSE
%%

PROGRAM:
	DEVICES CMDS{
		yylex.(*Lexer).GeneratedCode.WriteString($1 + $2 + "\n")
	}
DEVICE:
	DISPOSITIVO ':' '{' IDENT '}' {
		$$ = ""
	}
  | DISPOSITIVO ':' '{' IDENT ',' IDENT '}' {
		$$ = fmt.Sprintf("%s = 0\n", $6)
	}


DEVICES:
	DEVICE DEVICES { $$ = $1 + $2 }
  | DEVICE        { $$ = $1 }

CMDS:
	CMD '.' CMDS{ $$ = $1 + $3}
| CMD '.' {$$ = $1}
CMD:
	ATTRIB{
		$$ = $1 + "\n"
	}
 | OBSACT{
 	$$ = $1 + "\n"
 }
  | ACT{
  	$$ = $1+ "\n"
  }
ATTRIB:
	SET IDENT '=' VAR{
		$$ = fmt.Sprintf("%s = %s", $2, $4)
	}
ATTRIB:
	SET IDENT '=' ACTEXECUTE{
		$$ = fmt.Sprintf("%s = %s", $2, $4)
	}
OBSACT:
	IF OBS THEN CMDS ENDIF{
		$$ = fmt.Sprintf("if %s:\n%s", $2, indent($4))
	}

OBSACT:
	IF OBS THEN CMDS ELSE CMDS ENDIF{
		$$ = fmt.Sprintf("if %s:\n%s\nelse:\n%s", $2, indent($4), indent($6))
	}
OBS:
	EXPR OPLOGIC EXPR{
		$$ = fmt.Sprintf("%s %s %s", $1, $2, $3)
	}
OBS:
	EXPR OPLOGIC EXPR AND OBS{
		$$ = fmt.Sprintf("%s %s %s and %s", $1, $2, $3, $5)
	}
EXPR: VAR
| ACTEXECUTE
| IDENT
VAR:
	NUM {
		$$ = strconv.Itoa($1)
	}
	| BOOL{
		$$ = $1
	}
ACT:
	ACTEXECUTE
 	| ACTALERT
ACTEXECUTE:
	ACTION '(' IDENT ')'{
		$$ = fmt.Sprintf("%s('%s')", $1, $3)
	}
ACTALERT: SEND ALERT '(' MSG ')' IDENT{
	$$ = fmt.Sprintf("alert('%s', '%s')", $6, $4)
}
ACTALERT:
	SEND ALERT '(' MSG ',' IDENT ')' IDENT{
		$$ = fmt.Sprintf("alert('%s', '%s', '%s')", $6, $4, $8)
	}
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
func indent(s string) string{
	linhas := strings.Split(strings.TrimRight(s, "\n"), "\n")
	for i, l := range linhas{
		if l != ""{
			linhas[i] = "\t" + l
		}
	}
	return strings.Join(linhas, "\n")
}

type Lexer struct{
	tokens []token
	pos int
	GeneratedCode strings.Builder
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
            case IDENT, MSG, BOOL, OPLOGIC:
                lval.str = t.val
        }
	return t.typ
}

func (l *Lexer) Error(s string){
	fmt.Fprintln(os.Stderr, "erro de sintaxe", s)
	if l.pos < len(l.tokens) {
        		fmt.Printf("token atual: %+v, posição = %d\n", l.tokens[l.pos], l.pos)
        	}
}

func main (){

	lex := &Lexer{
		tokens: []token{
			{typ: DISPOSITIVO, val: "dispositivo"},
			{typ: int(':'), val: ":"}, {typ: int('{'), val: "{"},
			{typ: IDENT, val: "celular"}, {typ: int(','), val: ","},
			{typ: IDENT, val: "movimento"}, {typ: int('}'), val: "}"},

			// dispositivo:{higrometro,umidade}
			{typ: DISPOSITIVO, val: "dispositivo"},
			{typ: int(':'), val: ":"}, {typ: int('{'), val: "{"},
			{typ: IDENT, val: "higrometro"}, {typ: int(','), val: ","},
			{typ: IDENT, val: "umidade"}, {typ: int('}'), val: "}"},

			// dispositivo:{lampada,potenciaLampada}
			{typ: DISPOSITIVO, val: "dispositivo"},
			{typ: int(':'), val: ":"}, {typ: int('{'), val: "{"},
			{typ: IDENT, val: "lampada"}, {typ: int(','), val: ","},
			{typ: IDENT, val: "potenciaLampada"}, {typ: int('}'), val: "}"},

			// dispositivo:{umidificador,potenciaUmidificador}
			{typ: DISPOSITIVO, val: "dispositivo"},
			{typ: int(':'), val: ":"}, {typ: int('{'), val: "{"},
			{typ: IDENT, val: "umidificador"}, {typ: int(','), val: ","},
			{typ: IDENT, val: "potenciaUmidificador"}, {typ: int('}'), val: "}"},

			// dispositivo:{Monitor}
			{typ: DISPOSITIVO, val: "dispositivo"},
			{typ: int(':'), val: ":"}, {typ: int('{'), val: "{"},
			{typ: IDENT, val: "Monitor"}, {typ: int('}'), val: "}"},

			// set potenciaLampada = 100.   (traduzido da linha "set {lampada,potenciaLampada}=100")
			{typ: SET, val: "set"},
			{typ: IDENT, val: "potenciaLampada"},
			{typ: int('='), val: "="},
			{typ: NUM, val: "100"},
			{typ: int('.'), val: "."},

			// se umidade < 40 entao
			{typ: IF, val: "if"},
			{typ: IDENT, val: "umidade"},
			{typ: OPLOGIC, val: "<"},
			{typ: NUM, val: "40"},
			{typ: THEN, val: "then"},

			// enviar alerta ("Ar seco detectado") Monitor.   (parênteses adicionados p/ casar a regra)
			{typ: SEND, val: "send"},
			{typ: ALERT, val: "alert"},
			{typ: int('('), val: "("},
			{typ: MSG, val: "Ar seco detectado"},
			{typ: int(')'), val: ")"},
			{typ: IDENT, val: "Monitor"},
			{typ: int('.'), val: "."},

			// se verificar(umidificador) == 0 entao   (IF aninhado dentro do umidade)
			{typ: IF, val: "if"},
			{typ: VERIFICAR, val: "verificar"},
			{typ: int('('), val: "("},
			{typ: IDENT, val: "umidificador"},
			{typ: int(')'), val: ")"},
			{typ: OPLOGIC, val: "=="},
			{typ: NUM, val: "0"},
			{typ: THEN, val: "then"},

			// ligar(umidificador).
			{typ: LIGAR, val: "ligar"},
			{typ: int('('), val: "("},
			{typ: IDENT, val: "umidificador"},
			{typ: int(')'), val: ")"},
			{typ: int('.'), val: "."},

			{typ: ENDIF, val: "ENDIF"},   // fecha o IF interno (verificar)

			{typ: int('.'), val: "."},
			// set potenciaUmidificador = 100.
			{typ: SET, val: "set"},
			{typ: IDENT, val: "potenciaUmidificador"},
			{typ: int('='), val: "="},
			{typ: NUM, val: "100"},
			{typ: int('.'), val: "."},

			{typ: ENDIF, val: "ENDIF"},   // fecha o IF externo (umidade)
			{typ: int('.'), val: "."},    // ponto que fecha o CMD do IF externo na sequência

			// se movimento == True entao ligar(lampada) senao desligar(lampada).
			{typ: IF, val: "if"},
			{typ: IDENT, val: "movimento"},
			{typ: OPLOGIC, val: "=="},
			{typ: BOOL, val: "True"},
			{typ: THEN, val: "then"},

			{typ: LIGAR, val: "ligar"},
			{typ: int('('), val: "("},
			{typ: IDENT, val: "lampada"},
			{typ: int(')'), val: ")"},
			{typ: int('.'), val: "."},   // ponto fecha o CMDS do then

			{typ: ELSE, val: "else"},

			{typ: DESLIGAR, val: "desligar"},
			{typ: int('('), val: "("},
			{typ: IDENT, val: "lampada"},
			{typ: int(')'), val: ")"},
			{typ: int('.'), val: "."},   // ponto fecha o CMDS do else

			{typ: ENDIF, val: "ENDIF"},
			{typ: int('.'), val: "."},
		},
	}
	yyParse(lex)
	final := codegen.RuntimePy + "\n\n" + lex.GeneratedCode.String()
	os.WriteFile("saida.py", []byte(final), 0644)
}





