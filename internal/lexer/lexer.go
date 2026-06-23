package lexer

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
	itemSE
	itemEntao
	itemSenao
	itemEnviar
	itemAlerta
	itemPara
	itemTodos
	itemLigar
	itemDesligar
	itemVerificar
)
