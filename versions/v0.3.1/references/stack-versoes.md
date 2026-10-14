# Anexo volátil — versões e ferramental (Python)

> Parte da skill **schematize-python**. **Fonte volátil:** tudo aqui tem prazo de validade e é
> atualizado à parte do corpo normativo, que não crava número (regra `anexo-volatil` do lint).
>
> **Verificado em: 2026-10-14.** Cadência: trimestral e antes de cada release da skill.

## Python — a linha suportada

- **Piso normativo:** rodar numa versão **em suporte**. O CPython mantém cada minor por ~5 anos
  (2 de correção de bug + 3 só de segurança) e libera uma minor por ano, em outubro.
- **Alvo da casa:** **3.13 ou 3.14** (as linhas estáveis em suporte); a **3.15** está planejada
  para outubro de 2026 (PEP 790) — adote após o primeiro ponto-release e a prontidão das
  dependências. **3.10 chega ao EOL em outubro de 2026**: nada de versão EOL. Não fixe "a versão
  da máquina": a versão é declarada pelo projeto. <!-- reverificar: data exata do lançamento da 3.15 -->
- **`requires-python`** no `pyproject.toml` e **`.python-version`** no repo — a versão é declarada,
  não herdada do que estiver no PATH.
- **Build free-threaded (sem GIL)**: experimental na 3.13; oficialmente **suportado desde a 3.14**
  (PEP 779), ainda como build separado e com ecossistema de extensões em maturação — a decisão
  continua sendo por **ADR**, não default.

## Ferramental

| Ferramenta | Papel | Nota |
|---|---|---|
| **`uv`** | ambiente, dependência, lock, execução, instalação de ferramenta | o gerenciador da casa; `uv sync --frozen` no CI |
| **`ruff`** | lint **e** format (substitui flake8 + isort + black) | **o gate**. versão fixada no `pyproject.toml`/lock <!-- reverificar --> |
| **`mypy`** ou **`pyright`** | tipagem estática que trava o CI | strict no código novo; catraca no legado |
| `pytest` | runner de teste | disciplina na `schematize-qa` |
| `pydantic` | validação na fronteira (runtime, não só tipo) | o tipo é **derivado** do modelo |
| `nbstripout` | tira a saída do notebook no pre-commit | `dados-notebook.md` §1 |
| `pip-audit` / `uv` + OSV | vulnerabilidade em dependência | roda no CI |

**Instalação das ferramentas:** `uv tool install ruff` (ou `pipx install`) — **isolada**, nunca
misturada às dependências do app (`piso.md` §4). `pip install` global no sistema é VETADO e, em
Linux moderno, o próprio Python recusa (*externally-managed-environment*).

## Regra que NÃO é volátil

O piso (`piso.md`) e o veto do `escopo.md` valem independentemente da versão. Número muda; *"Python é
ferramenta, não backend de produto novo"* não.
