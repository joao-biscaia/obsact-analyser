# Transpilador ObsAct

Transpilador que compila programas escritos em ObsAct para Python. A análise léxica é
feita por um lexer escrito manualmente e a análise sintática por um parser LALR(1) gerado com
goyacc.

## Requisitos

- Go 1.21 ou superior
- goyacc (apenas para gerar o parser): `go install golang.org/x/tools/cmd/goyacc@latest`

## Como executar

### Com Go instalado

Gerar o parser e compilar:

```
make build
```

Rodar sobre um arquivo de entrada:

```
./build/obsact -filepath testdata/valid/valid.obsact -output testdata/output-valids/
```

O código Python gerado é escrito em `saida.py` dentro do diretório de saída.

Flags disponíveis:

- `-filepath`: caminho do arquivo `.obsact` de entrada (padrão: `testdata/valid/valid.obsact`)
- `-output`: diretório de saída do `saida.py` (padrão: `testdata/output-valids/`)

### Sem Go instalado (binário pré-compilado)

Os binários para cada plataforma ficam em `dist/` após `make release`:

```
./dist/obsact-linux-amd64 -filepath entrada.obsact -output ./
```

## Build para várias plataformas

```
make release
```

Gera os binários em `dist/` para Linux, Windows, macOS Intel e macOS ARM.

## Executar a saída

```
python3 saida.py
```
