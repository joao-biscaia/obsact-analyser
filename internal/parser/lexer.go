package main

import (
	"fmt"
	"strings"
	"unicode"
	"unicode/utf8"
)

type item struct {
	typ itemType
	val string
}

type itemType int

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
}

const eof = -1

const itemError = -2

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
		case strings.ContainsRune(":{}(),.=", r):
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
func lexAnd(l *lexer) stateFn {
	if l.accept("&") {
		l.emit(token{typ: AND})
		return lexInit
	}
	return l.errorf("sintaxe inválida: %q", l.input[l.start:l.pos])
}

func lexString(l *lexer) stateFn {
	l.ignore()
	l.acceptRunFunc(func(r rune) bool {
		return r != '"'
	})
	l.emit(token{typ: MSG})
	l.next()
	l.ignore()
	return lexInit
}
func lexOperator(l *lexer) stateFn {
	r := l.next()
	switch r {
	case '>', '<':
		l.accept("=")
		l.emit(token{typ: OPLOGIC})
	case '=':
		if l.accept("=") {
			l.emit(token{typ: OPLOGIC})
		} else {
			l.emit(token{typ: int('=')})
		}
	case '!':
		if !l.accept("=") {
			l.errorf("operador inválido!")
		} else {
			l.emit(token{typ: OPLOGIC})
		}
	}
	return lexInit
}

func (l *lexer) next() rune {
	if l.pos >= len(l.input) {
		l.width = 0
		return eof
	}
	r, w := utf8.DecodeRuneInString(l.input[l.pos:])
	l.width = w
	l.pos += l.width
	return r
}

func (l *lexer) backup() {
	l.pos -= l.width
}
func (l *lexer) ignore() {
	l.start = l.pos
}

func (l *lexer) peek() rune {
	r := l.next()
	l.backup()
	return r
}

// consome se é valido
func (l *lexer) accept(valid string) bool {
	if strings.IndexRune(valid, l.next()) >= 0 {
		return true
	}
	l.backup()
	return false
}

func (l *lexer) acceptRun(valid string) {
	for strings.IndexRune(valid, l.next()) >= 0 {
	}
	l.backup()
}

func (l *lexer) acceptRunFunc(valid func(rune) bool) {
	for valid(l.next()) {
	}
	l.backup()
}

func lexWord(l *lexer) stateFn {
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

func lexNumber(l *lexer) stateFn {
	digits := "0123456789"
	l.acceptRun(digits)
	if r := l.peek(); unicode.IsLetter(r) || unicode.IsNumber(r) {
		l.next()
		return l.errorf("número mal formulado: %q", l.input[l.start:l.pos])
	}
	l.emit(token{typ: NUM})
	return lexInit
}

func (l *lexer) errorf(format string, args ...interface{}) stateFn {
	l.tokens <- token{typ: itemError, val: fmt.Sprintf(format, args...)}
	return nil
}
