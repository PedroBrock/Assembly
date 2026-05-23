# 🔐 Cifra de César em Assembly (MASM32)

Projeto desenvolvido para a disciplina de **Arquitetura de Computadores I**, implementando uma variação da **Cifra de César** em linguagem Assembly (MASM32) para Windows.

---

## 📖 Descrição

O programa realiza a **criptografia e descriptografia de arquivos de texto** utilizando uma variação da Cifra de César, onde todos os bytes do arquivo são deslocados para frente (criptografar) ou para trás (descriptografar) com base em uma chave numérica definida pelo usuário.

### Como funciona

- **Criptografar:** cada byte do arquivo é somado ao valor da chave (`byte + chave`)
- **Descriptografar:** cada byte do arquivo é subtraído pelo valor da chave (`byte - chave`)
- A chave deve ser um número inteiro entre **1 e 20**
- O arquivo é lido em blocos de **512 bytes** por vez

---

## 🖥️ Requisitos

- Windows (32 bits ou modo de compatibilidade)
- [MASM32 SDK](http://www.masm32.com/) instalado em `C:\masm32`

---

## 🚀 Como compilar e executar

1. Certifique-se de que o MASM32 está instalado corretamente.
2. Abra o prompt de comando e navegue até o diretório do projeto.
3. Compile com os seguintes comandos:

```bat
ml /c /coff cifra.asm
link /subsystem:console cifra.obj
```

4. Execute o programa gerado:

```bat
cifra.exe
```

---

## 📋 Como usar

Ao executar o programa, um menu interativo será exibido no console:

```
MENU
1.Criptografar
2.Descriptografar
3.Sair
Escolha um numero (de 1 a 3)
```

**Passo a passo:**

1. Escolha a opção desejada (`1` para criptografar, `2` para descriptografar, `3` para sair)
2. Informe o nome do **arquivo de entrada** (ex: `texto.txt`)
3. Informe o nome do **arquivo de saída** (ex: `texto_cifrado.txt`)
4. Informe a **chave** (número de 1 a 20)

O arquivo de saída será criado (ou sobrescrito) com o conteúdo processado.

### Exemplo de uso

```
Escolha: 1
Arquivo de entrada: mensagem.txt
Arquivo de saída:   mensagem_cifrada.txt
Chave:              7
```

Para descriptografar, utilize o mesmo arquivo cifrado como entrada e a **mesma chave**:

```
Escolha: 2
Arquivo de entrada: mensagem_cifrada.txt
Arquivo de saída:   mensagem_original.txt
Chave:              7
```

---

## 🏗️ Estrutura do código

| Seção / Rótulo       | Descrição                                                  |
|----------------------|------------------------------------------------------------|
| `.data`              | Declaração de variáveis, buffers e strings do console      |
| `start`              | Ponto de entrada; obtém handles de entrada/saída           |
| `menu`               | Exibe o menu e lê a opção do usuário                       |
| `criptografar`       | Loop de leitura do arquivo e chamada de `criptografarProc` |
| `descriptografar`    | Loop de leitura do arquivo e chamada de `descriptografarProc` |
| `fechar_arquivos`    | Fecha os handles e retorna ao menu                         |
| `criptografarProc`   | Subrotina: desloca cada byte do buffer para frente (`+chave`) |
| `descriptografarProc`| Subrotina: desloca cada byte do buffer para trás (`-chave`)  |

---

## ⚙️ Detalhes de implementação

- **Leitura em blocos:** o arquivo é lido em blocos de 512 bytes usando `ReadFile`, permitindo processar arquivos de qualquer tamanho.
- **Convenção de chamada:** as subrotinas `criptografarProc` e `descriptografarProc` utilizam a pilha para receber os parâmetros (chave, bytes lidos e endereço do buffer), limpando 12 bytes ao retornar (`ret 12`).
- **Conversão de string para inteiro:** a função `atodw` do MASM32 é utilizada para converter a entrada do console (chave e opção) em valores numéricos.
- **Terminação de string:** o caractere `CR` (ASCII 13) inserido pelo `ReadConsole` é substituído por `NULL` (ASCII 0) antes de processar as entradas.

---

## ⚠️ Limitações

- O programa **não valida** se a chave está entre 1 e 20 — valores fora do intervalo são aceitos mas podem gerar resultados inesperados.
- Funciona apenas com arquivos de **texto simples** (bytes individuais); arquivos binários podem ser processados, mas o resultado depende dos valores dos bytes.
- Desenvolvido e testado em ambiente **Windows 32 bits**.

---

## 📚 Referências

- [MASM32 SDK Documentation](http://www.masm32.com/)
- [Cifra de César — Wikipédia](https://pt.wikipedia.org/wiki/Cifra_de_C%C3%A9sar)
- Win32 API: `ReadFile`, `WriteFile`, `CreateFile`, `ReadConsole`, `WriteConsole`

---

## 👨‍💻 Disciplina

> Arquitetura de Computadores I
