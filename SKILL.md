---
name: schematize-python
metadata:
  version: 0.1.0
description: O piso de PYTHON da casa — ferramenta com governança, não terra sem lei. Rege onde Python entra (dados/ML, automação, ferramental interno) e onde é **VETADO** (API/serviço de produto novo, exatamente como Node), com a forma da única exceção (servir modelo atrás de um serviço do rol, sem regra de negócio); `uv` com lockfile commitado (sem lock, "funciona na minha máquina" é literal); `ruff` como gate de lint E format; tipagem que TRAVA o CI, com catraca no legado e validação de fronteira em runtime por pydantic; empacotamento de ferramenta isolado (`uv tool`, nunca misturada ao app); segurança (pickle é execução de código, `shell=True`, `random` vs `secrets`, HTTP sem timeout); GIL e as três concorrências; e **notebook não é entregável** (a ordem de execução não é a ordem das células). Traz gate executável. Use SEMPRE que for escrever, revisar ou auditar `.py`/`.ipynb`.
---
<!-- cross-skill: linguagens.md, efeitos-externos.md -> schematize-engineering -->

# O piso de Python da casa (schematize-python)

Python **está na casa e continua** — dados/ML, automação, ferramental. O que faltava era decisão:
até 2026-08-21 esse uso era **implícito**, e uso implícito é **uso sem piso**. Esta skill escreve os
dois lados: **onde ele entra** e **onde é vetado**.

**Versão:** skill `schematize-python` v0.1.0. Changelog em `CHANGELOG.md`.

## Por que ela nasceu

A vistoria de 2026-08-21 achou o desenho do problema: o motor `simulated/run.py` — **que a casa
distribui em 8 skills e que tinha dois bugs reais** achados na própria vistoria — é Python **sem
governança**; e as skills `data` e `ai` pressupõem Python em toda parte **sem jamais dizê-lo**.
Ferramenta sem piso não fica neutra: ela vira o lugar por onde o piso das outras vaza.

## Comandos (Claude Code)

| Comando | O que faz |
|---|---|
| `/python-help` | lista os comandos |
| `/python-load` | carrega à força o corpo normativo (piso, escopo, notebook) |
| `/python-review` | revisa `.py`/`.ipynb` contra o piso: roda o gate + `ruff` e lê o que a máquina não lê |
| `/python-claude` | cria/mescla o `CLAUDE.md` sempre-on de Python na raiz do repo |
| `/python-cc` · `/python-handoff` | context compact / handoff arquivado |

## Como usar

1. **Antes de escrever**, saiba **se é aqui**: `references/escopo.md`. API de produto nova **não é**.
2. **Rode o gate:** `bash scripts/check-python.sh .` — `0` passa · `1` reprova · `2` **nada para
   verificar** (que não é aprovação).
3. **Piso técnico** em `references/piso.md`: `uv` + lock, `ruff` como gate, tipos que travam,
   empacotamento, segurança, concorrência, estrutura.
4. **Se há notebook**, ele é exploração: `references/dados-notebook.md`.

Mapa de references:

| Tarefa | Reference |
|---|---|
| O piso executável: `uv`/lock, `ruff`, tipagem que trava, empacotamento de ferramenta, segurança, GIL e concorrência, estrutura | `references/piso.md` |
| **Onde Python entra e onde é VETADO**; a forma da exceção (servir modelo); legado que já é backend | `references/escopo.md` |
| **Notebook não é entregável**; reprodutibilidade de pipeline; armadilhas de pandas; fronteira com `data` e `ai` | `references/dados-notebook.md` |
| Versões e ferramental (`uv`, `ruff`, `mypy`, `pytest`, `pydantic`), com data de verificação | `references/stack-versoes.md` |

## Pisos inegociáveis (vetam o atalho)

1. **Python é ferramenta, não backend de produto novo.** API/serviço novo nasce no rol
   (`schematize-engineering` → `references/linguagens.md` §2.1). A exceção — servir modelo — tem
   forma: serviço fino, sem regra de negócio, atrás de um serviço do rol.
2. **`uv` com `uv.lock` commitado**, `uv sync --frozen` no CI. Sem lock, o transitivo sobe sozinho no
   runner e "funciona na minha máquina" é literal.
3. **`ruff check` e `ruff format --check` travam o merge.** Um só formatador. `# noqa` nu é VETADO —
   sempre com o código e o motivo.
4. **Tipagem trava o CI** no código novo/tocado (`mypy --strict`); legado por catraca que só encolhe.
   E **a fronteira valida em runtime** (`pydantic`) — anotação não valida nada.
5. **Ferramenta instala isolada** (`uv tool`/`pipx`), nunca junto das dependências do app.
   `pip install` global é VETADO.
6. **`pickle` é execução de código** — nunca sobre dado externo. Junto: `eval`/`exec` sobre entrada,
   `yaml.load` sem `SafeLoader`, `subprocess(shell=True)`, `assert` como validação (o `-O` remove).
7. **`secrets`, não `random`,** para qualquer coisa de segurança.
8. **Toda chamada de rede tem `timeout` explícito** — `requests`/`httpx` **não** têm por default: a
   chamada pendura para sempre e o worker morre segurando a conexão.
9. **CPU-bound vai para processo, não thread** (GIL); chamada bloqueante dentro de `async def` trava
   o event loop inteiro.
10. **Notebook não é entregável:** vai sem saída, sem dado real, sem credencial — e quando vira
    produto, vira **módulo** em `src/`, com teste e tipo.
11. **Orquestrador não desenvolve; subagent barato executa.** O agent principal só planeja, despacha e revisa; ação onerosa vira micro-tasks para subagents em `sonnet` (falhou → o mesmo subagent corrige → re-decompõe → só então `opus`, com motivo). Detalhe: `schematize-engineering` → `references/orquestracao.md` §9.

## Relação com as outras skills

- **`schematize-engineering`** — a base e o rol; o veto de API nova mora lá (§2.1 de `linguagens.md`).
- **`schematize-data`** — contrato de dado, qualidade, lineage, backfill. Aqui é o **como escrever**;
  lá, **o que o dado precisa cumprir**.
- **`schematize-ai`** — eval, guardrail, custo. O runner de eval é Python, e obedece a este piso.
- **`schematize-qa`** — a disciplina de teste (`pytest` é o runner); o `simulated/run.py` dela é
  Python da casa e é código de produção.
- **`schematize-shell`** — a fronteira prática: passou de parsing sério, retry e dado estruturado,
  já não é shell.
