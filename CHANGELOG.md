# Changelog — schematize-python

Todas as mudanças relevantes deste pacote, no formato [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/),
com versionamento [SemVer](https://semver.org/lang/pt-BR/).

## [0.2.0] — 2026-09-30

Pedido do dono, por **custo**: o orquestrador não desenvolve; ação onerosa vira micro-tasks baratas; `sonnet` é o default dos subagents e `opus` só entra após falha.

### Adicionado
- **Piso "Orquestrador não desenvolve; subagent barato executa"** no `assets/CLAUDE.md` e no `SKILL.md`: o agent principal só planeja, despacha e revisa; ação onerosa vira micro-tasks para subagents em `sonnet` (falhou → o mesmo subagent corrige → re-decompõe → só então `opus`, com motivo). Detalhe na base: `schematize-engineering` → `references/orquestracao.md` §9.

### Mantido (piso inalterado)
- Todos os pisos anteriores e o gate de `scripts/` seguem exatamente como estavam; a mudança é só de orquestração, não de código.

## [0.1.0] — 2026-08-21

Primeira versão. Python **já estava na casa** — dados/ML, automação, o motor `simulated/run.py` que a `schematize-qa` distribui em 8 skills — e nunca tinha sido **decidido**. A vistoria de 2026-08-21 nomeou o desenho do problema: esse motor, *que a casa distribui e que tinha dois bugs reais achados na própria vistoria*, é Python sem governança; e `data` e `ai` pressupõem Python em toda parte **sem jamais dizê-lo**. Uso implícito é uso sem piso.

### Adicionado
- **`references/escopo.md`** — os dois lados da fronteira: **onde Python entra** (dados/ML, automação, ferramental interno, notebook de exploração) e **onde é VETADO** (API/serviço de produto novo, exatamente como Node), com o motivo que não é desempenho nem gosto: *a casa não quer manter piso de produção em mais um ecossistema, e um serviço de produto vive dez anos*. Mais a **forma da exceção** (serviço de inferência **fino, sem regra de negócio, atrás** de um serviço do rol que faz authz e validação) e a regra do legado que já é backend — migra por funcionalidade, e **enquanto vive, cumpre o piso**.
- **`references/piso.md`** — `uv` com **lock commitado** (sem ele "funciona na minha máquina" é literal); **`ruff`** como gate de lint **e** format (um só formatador — ter dois é ter dois resultados); tipagem que **trava** com catraca no legado, e **validação de fronteira em runtime** com pydantic (*anotação não valida nada, e é na borda que o dado mente*); **empacotamento de ferramenta isolado**; segurança (pickle é **execução de código**; `random` vs `secrets`; **HTTP sem timeout**, que `requests`/`httpx` não têm por default); **GIL** e as três concorrências; layout `src/`.
- **`references/dados-notebook.md`** — **notebook não é entregável**, com os três porquês: diff ilegível (JSON com saída embutida), **não reprodutível por construção** (a ordem de execução não é a ordem das células; célula apagada deixa a variável viva) e **inseguro** (a saída fica salva — amostra de dado real, token colado). Mais reprodutibilidade de pipeline (semente logada, dado identificado, ambiente travado) e as três armadilhas de pandas que mais mordem.
- **`scripts/check-python.sh`** + **`scripts/check-python.test.sh`** (**11 casos**, 9 vermelhos) — o gate: `ruff`, lock e `requires-python`, `shell=True`, `yaml.load` inseguro, `eval`/`exec`, **argumento default mutável**, HTTP sem timeout, `random` em contexto de segurança, `/tmp` previsível, e **notebook commitado com saída**.
- **`assets/lint/ruff.toml`** — o piso de lint da casa (`E`,`F`,`I`,`B`,`S`,`UP`,`SIM`,`RET`,`PTH`,`ASYNC`,`DTZ`,`T20`), para o projeto **estender**.

### Medido nesta versão
- `ruff` **instalado** (0.16.4) e rodado sobre o Python do catálogo: o `simulated/run.py` tinha **import block desordenado** e formatação fora do padrão — corrigido e **propagado para as 8 cópias** (md5 idêntico), com a suíte do `run.test.sh` verde depois.

### Corrigido durante a própria escrita (vale registro)
- A regra de `shell=True` acusava a **docstring do exemplo bom** ("nunca string com shell=True"). O gate ganhou `tirar_docstring`. *Gate que confunde documentação com código produz achado inventado — e achado inventado é o começo do gate ignorado.*
