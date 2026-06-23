package lexer

import "strings"

type item struct {
	typ itemType
	val string
}

type itemType int

const (
	itemError itemType = iota
	itemDot
	itemEOF
	itemDispositivo
	itemSet
	itemThen
	itemIf
	itemElse
	itemEndIf
	itemAlert
	itemEnviar
	itemLigar
	itemDesligar
	itemVerificar
	itemNameDevice
	itemOpLogic
	itemAnd
	itemBool
	itemNum
	itemMsg
	itemObservation
)
var itemMap = map[string]itemType{
	"dispositivo": itemDispositivo,
	"set": itemSet,
	"se": itemIf,
	"entao": itemThen,
	"senao": itemElse,
	"enviar": itemEnviar,
	"alerta": itemAlert,
	"ligar": itemLigar,
	"desligar": itemDesligar,
	"verificar": itemVerificar,
	"&&": itemAnd,
	".": itemDot,
	"==": itemOpLogic,
	">=": itemOpLogic,
	">": itemOpLogic,
	"<": itemOpLogic,
	"<=": itemOpLogic,
	"!=": itemOpLogic,
	"True": itemBool,
	"False": itemBool,
}

type token struct {
	typ int
	val string
}

type lexer struct {
	input  string
	pos    int
	start  int
	width  int
	tokens chan token
}
type stateFn func(*lexer) stateFn

func (l *lexer) run() {
	for state := lexInit; state != nil; {
		state = state(l)
	}
	close(l.tokens)
}
func lex(input string) (*lexer, chan token) {
	l := &lexer{
		input:  input,
		tokens: make(chan token),
	}
	go l.run()
	return l, l.tokens
}

func (l *lexer) emit(t token) {
	l.tokens <- token{t.typ, l.input[l.start:l.pos]}
	l.start = l.pos
}

func lexInit(l *lexer) stateFn {
	for {
		if strings.HasPrefix(l.input[l.pos:], )
	}

}
