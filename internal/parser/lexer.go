package parser

import (
	"fmt"
	"strings"
	"unicode"
	"unicode/utf8"
)

var itemMap = map[string]int{
	"dispositivo": DISPOSITIVO,
	"set":         SET,
	"se":          IF,
	"entao":       THEN,
	"senao":       ELSE,
	"enviar":      SEND,
	"alerta":      ALERT,
	"ligar":       LIGAR,
	"desligar":    DESLIGAR,
	"verificar":   VERIFICAR,
	"&&":          AND,
	"True":        BOOL,
	"False":       BOOL,
	"fim":         ENDIF,
}

const eof = -1

const itemError = -2

type tokenizer struct {
	input  string
	pos    int
	start  int
	width  int
	tokens chan token
}
type stateFn func(*tokenizer) stateFn

func (l *tokenizer) run() {
	for state := lexInit; state != nil; {
		state = state(l)
	}
	close(l.tokens)
}
func Tokenize(input string) chan token {
	l := &tokenizer{
		input:  input,
		tokens: make(chan token),
	}
	go l.run()
	return l.tokens
}

func (l *tokenizer) emit(t token) {
	l.tokens <- token{t.typ, l.input[l.start:l.pos]}
	l.start = l.pos
}

func lexInit(l *tokenizer) stateFn {
	for {
		switch r := l.next(); {
		case r == eof:
			return nil
		case unicode.IsSpace(r):
			l.ignore()
		case unicode.IsLetter(r):
			l.backup()
			return lexWord
		case unicode.IsDigit(r):
			l.backup()
			return lexNumber
		case r == '"':
			return lexString
		case strings.ContainsRune(":{}(),.", r):
			l.emit(token{typ: int(r)})
		case r == '<' || r == '>' || r == '=' || r == '!':
			l.backup()
			return lexOperator
		case r == '&':
			return lexAnd
		default:
			return l.errorf("caractere inesperado: %q", r)
		}
	}
}
func lexAnd(l *tokenizer) stateFn {
	if l.accept("&") {
		l.emit(token{typ: AND})
		return lexInit
	}
	return l.errorf("sintaxe inválida: %q", l.input[l.start:l.pos])
}

func lexString(l *tokenizer) stateFn {
	l.ignore()
	l.acceptRunFunc(func(r rune) bool {
		return r != '"'
	})
	l.emit(token{typ: MSG})
	l.next()
	l.ignore()
	return lexInit
}
func lexOperator(l *tokenizer) stateFn {
	r := l.next()
	switch r {
	case '>', '<':
		l.accept("=")
		l.emit(token{typ: OPLOGIC})
		break
	case '=':
		if l.accept("=") {
			l.emit(token{typ: OPLOGIC})
			break
		} else {
			l.emit(token{typ: int('=')})
			break
		}
	case '!':
		if !l.accept("=") {
			l.errorf("operador inválido!")
			break
		} else {
			l.emit(token{typ: OPLOGIC})
			break
		}
	}
	return lexInit
}

func (l *tokenizer) next() rune {
	if l.pos >= len(l.input) {
		l.width = 0
		return eof
	}
	r, w := utf8.DecodeRuneInString(l.input[l.pos:])
	l.width = w
	l.pos += l.width
	return r
}

func (l *tokenizer) backup() {
	l.pos -= l.width
}
func (l *tokenizer) ignore() {
	l.start = l.pos
}

func (l *tokenizer) peek() rune {
	r := l.next()
	l.backup()
	return r
}

// consome se é valido
func (l *tokenizer) accept(valid string) bool {
	if strings.IndexRune(valid, l.next()) >= 0 {
		return true
	}
	l.backup()
	return false
}

func (l *tokenizer) acceptRun(valid string) {
	for strings.IndexRune(valid, l.next()) >= 0 {
	}
	l.backup()
}

func (l *tokenizer) acceptRunFunc(valid func(rune) bool) {
	for valid(l.next()) {
	}
	l.backup()
}

func lexWord(l *tokenizer) stateFn {
	l.acceptRunFunc(func(r rune) bool {
		return unicode.IsLetter(r) || unicode.IsDigit(r)
	})
	word := l.input[l.start:l.pos]

	if typ, ok := itemMap[word]; ok {
		l.emit(token{typ: typ})
	} else {
		l.emit(token{typ: IDENT})
	}
	return lexInit
}

func lexNumber(l *tokenizer) stateFn {
	digits := "0123456789"
	l.acceptRun(digits)
	if r := l.peek(); unicode.IsLetter(r) || unicode.IsNumber(r) {
		l.next()
		return l.errorf("número mal formulado: %q", l.input[l.start:l.pos])
	}
	l.emit(token{typ: NUM})
	return lexInit
}

func (l *tokenizer) errorf(format string, args ...interface{}) stateFn {
	l.tokens <- token{typ: itemError, val: fmt.Sprintf(format, args...)}
	return nil
}
