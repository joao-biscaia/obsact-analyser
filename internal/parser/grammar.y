%{
package parser

import(
	"fmt"
	"os"
	"strings"
	"strconv"
)
%}



%union{
	str string
	num int
}
%token DISPOSITIVO
%token <num> NUM
%token <str> MSG
%token PARA
%token TODOS
%token <str> IDENT
%token <str> BOOL
%token <str> OPLOGIC
%token SET IF ELSE ENDIF THEN AND ALERT SEND
%token LIGAR DESLIGAR VERIFICAR
%type <str> ACTION
%type <str> CMD CMDS ACT ATTRIB OBSACT ACTEXECUTE ACTALERT OBS VAR EXPR DEVICE DEVICES LISTA
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
| SEND ALERT '(' MSG ')' PARA TODOS ':' LISTA{
	lista := strings.Split($9, ",")
	var sb strings.Builder
	for _, val := range lista{
		sb.WriteString(fmt.Sprintf("alert('%s', '%s')\n", val, $4))
	}
	$$ = sb.String()
}
|SEND ALERT '(' MSG ',' IDENT ')' PARA TODOS ':' LISTA {
         lista := strings.Split($11, ",")
         var sb strings.Builder
         for _, dev := range lista {
             sb.WriteString(fmt.Sprintf("alert('%s', '%s', '%s')\n", dev, $4, $6))
         }
         $$ = sb.String()
     }
LISTA:
	IDENT ',' LISTA {$$ = $1 + "," + $3}
	| IDENT {$$ = $1}
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
	Tokens chan token
	pos int
	GeneratedCode strings.Builder
}

type token struct{
	typ int
	val string
}



func (l * Lexer) Lex(lval *yySymType) int{
	t, ok := <-l.Tokens
	if !ok{
		return 0
	}
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
}
func Parse(lex yyLexer) int{
	return yyParse(lex)
}
