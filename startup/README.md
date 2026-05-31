# Startup Laboratorio

Scripts para baixar, executar e remover uma rotina de startup para maquinas de
laboratorio de informatica.

O fluxo principal e:

1. `get.bat` baixa os arquivos publicados.
2. `run.bat` decide entre modo automatico e modo manual.
3. `auto.bat` executa a rotina automatica.
4. `manual.bat` abre uma GUI com botoes definidos em `manual-botoes.txt`.
5. `get.bat` remove a pasta temporaria quando a execucao termina.

## Arquivos

| Arquivo | Funcao |
| --- | --- |
| `get.bat` | Baixa os arquivos publicados para uma subpasta temporaria em `C:\Temp`, executa `run.bat` e limpa a pasta ao final. |
| `run.bat` | Starter principal. Define tempo de espera, tecla de gatilho e decide entre modo automatico/manual. |
| `auto.bat` | Rotina automatica. Cria/atualiza `C:\temp\auto.txt` com data/hora. No estado atual, tambem chama `manual.bat` ao final. |
| `manual.bat` | Abre a GUI do modo manual e monta os botoes a partir de `manual-botoes.txt`. |
| `manual-botoes.txt` | Configuracao dinamica dos botoes do modo manual. |

## Uso Com Download

Use `get.bat` quando os arquivos estiverem hospedados em:

```txt
https://suporteeq.github.io/startup
```

Ele baixa:

```txt
run.bat
auto.bat
manual.bat
manual-botoes.txt
```

Os arquivos sao salvos em uma pasta temporaria unica no formato:

```txt
C:\Temp\startup-<random>
```

Depois de executar `run.bat`, o `get.bat` remove essa pasta temporaria.

Downloads usam:

```bat
curl --fail --location --show-error --output
```

Assim, erro HTTP como 404/500 faz o download falhar, o erro aparece no console,
e a execucao e interrompida antes de chamar `run.bat`.

## Instalacao Em Startup

Para executar automaticamente no login, coloque `get.bat` em:

```txt
shell:common startup
```

Normalmente isso aponta para:

```txt
C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp
```

Essa pasta pode exigir permissao de administrador para copiar arquivos.

Se preferir nao usar download, copie estes arquivos para a mesma pasta e execute
`run.bat` diretamente:

```txt
run.bat
auto.bat
manual.bat
manual-botoes.txt
```

## Configuracao Do Starter

No topo do bloco PowerShell dentro de `run.bat`:

```powershell
$WaitSeconds = 3
$TriggerKey = [ConsoleKey]::Backspace
```

Altere esses valores para mudar o tempo de espera e a tecla de gatilho.

Comportamento:

- se o usuario pressionar `Backspace` durante a contagem, executa `manual.bat`;
- se nenhuma tecla de gatilho for pressionada, executa `auto.bat`.

## Configuracao Dos Botoes

Cada bloco `[botao]` em `manual-botoes.txt` cria um botao na GUI.

Ao abrir a GUI, o `manual.bat` oculta a janela de terminal usada para iniciar o
modo manual. Essa janela nao e encerrada; ela apenas fica invisivel enquanto a
GUI permanece em uso e volta a aparecer quando a GUI e fechada.

Linhas vazias e linhas que comecam com `#` sao ignoradas. Comentarios no fim da
linha nao sao removidos.

Campos aceitos:

| Campo | Obrigatorio | Descricao |
| --- | --- | --- |
| `titulo=` | Sim | Texto exibido no botao. |
| `comando=` | Sim | Comando executado ao clicar. Pode repetir no mesmo botao ou abrir um bloco com `comando={`. |
| `verificar=` | Nao | Caminho que deve existir antes de executar o botao. Pode repetir. |
| `admin=` | Nao | `true` para executar elevado via UAC; `false` por padrao. |
| `mensagem=` | Nao | Mensagem exibida apos iniciar os comandos. Em `admin=true`, aparece depois que a janela elevada termina. |

Valores aceitos em `admin=true`: `true`, `sim`, `s`, `1`, `yes`, `y`.

Valores aceitos em `admin=false`: `false`, `nao`, `n`, `0`, `no`.

Variaveis disponiveis:

| Variavel | Valor |
| --- | --- |
| `%SCRIPT_DIR%` | Pasta onde estao os scripts baixados/executados. |
| `%AUTO_BAT%` | Caminho completo de `auto.bat`. |

## Execucao De Comandos

Todos os comandos de um mesmo botao rodam em sequencia no mesmo arquivo
temporario `.cmd`, mantendo contexto entre comandos. Voce pode declarar varios
comandos repetindo `comando=` ou usando um bloco iniciado por `comando={` e
fechado por uma linha com `}`.

O campo `verificar=` e avaliado antes de qualquer comando do botao. Nao use
`verificar=` para um arquivo que sera baixado ou criado pelo proprio bloco de
comandos; nesse caso, deixe o erro aparecer no comando seguinte ou trate dentro
do proprio bloco.

Exemplo:

```txt
[botao]
titulo=Mostrar mensagem
admin=false
comando={
echo Aperte uma tecla
pause
}
```

Arquivos `.bat` e `.cmd` recebem `call` automaticamente para o fluxo continuar.
Arquivos `.ps1` rodam via:

```txt
powershell.exe -NoProfile -ExecutionPolicy Bypass -File
```

Quando `admin=true`, o botao inteiro e executado em uma janela elevada com UAC e
o `manual.bat` aguarda a janela elevada terminar. Se o UAC for cancelado ou
falhar, a execucao daquele botao e cancelada.

Quando `admin=false`, o comando e iniciado sem elevacao. O `manual.bat` registra
os processos iniciados pelos botoes e, se o usuario fechar a GUI enquanto ainda
houver processo em execucao, espera esses processos terminarem antes de encerrar.
Isso evita que o `get.bat` apague a pasta temporaria enquanto a GUI ou uma acao
rastreada ainda esta em uso.

## Exemplo De Botao

```txt
[botao]
titulo=Registrar data/hora
admin=false
verificar=%AUTO_BAT%
comando="%AUTO_BAT%"
mensagem=Data/hora registrada em C:\temp\auto.txt.
```

## Comportamento Se Arquivos Faltarem

Se `get.bat` nao conseguir baixar algum arquivo, ele mostra o erro do `curl`,
limpa a pasta temporaria e encerra com codigo `1`.

Se `run.bat` escolher o modo automatico e `auto.bat` nao existir, ele mostra no
console:

```txt
Arquivo nao encontrado: <caminho>\auto.bat
```

Se `run.bat` escolher o modo manual e `manual.bat` nao existir, ele mostra:

```txt
Arquivo nao encontrado: <caminho>\manual.bat
```

Nesses casos, o starter encerra com codigo `1`.

## Teste Manual

Para testar o fluxo local sem download:

```bat
run.bat
```

Para testar o fluxo com download:

```bat
get.bat
```

Durante a contagem do `run.bat`, pressione `Backspace` para abrir o menu manual.
Se nao pressionar nada, o modo automatico sera executado.
