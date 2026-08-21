# schematize-python

> **Python é ferramenta, não backend de produto novo.** Ele já estava na casa — dados/ML, automação,
> o motor de teste que o catálogo distribui — e nunca tinha sido **decidido**. Esta skill escreve os
> dois lados: onde ele entra, onde é **VETADO**, e o piso que ele cumpre nos dois casos.

Pacote de **skill normativa para [Claude Code](https://claude.com/claude-code)**.
Parte do catálogo **schematize skills**.

## Por que ela existe

A vistoria de 2026-08-21: o motor `simulated/run.py` — **distribuído em 8 skills, com dois bugs
reais** achados na própria vistoria — era Python sem governança; `data` e `ai` pressupõem Python em
toda parte **sem jamais dizê-lo**. *Uso implícito é uso sem piso.*

## Instalar

### Pelo app schematize (recomendado)

```bash
schematize install python
```

### Manual

```bash
git clone https://github.com/schematizeme/skill-python.git /tmp/skill-python
bash /tmp/skill-python/install.sh .
```

## O que tem dentro

- **SKILL.md** — o contrato: 10 pisos inegociáveis + o mapa de references.
- **references/** — `escopo` (onde entra e onde é vetado; a forma da exceção), `piso` (`uv`/lock,
  `ruff`, tipos que travam, empacotamento, segurança, GIL), `dados-notebook` (notebook não é
  entregável; reprodutibilidade), `stack-versoes` (anexo volátil, com data).
- **scripts/** — `check-python.sh` (o gate) e `check-python.test.sh` (11 casos, 9 vermelhos).
- **assets/lint/ruff.toml** — o piso de lint para o projeto **estender**.
- **assets/commands/** — `/python-help`, `/python-load`, `/python-review`, `/python-claude`,
  `/python-cc`, `/python-handoff`.
- **assets/CLAUDE.md** — regra sempre-on para a raiz do repo.

## Comandos

| Comando | O que faz |
|---|---|
| `/python-help` | lista os comandos |
| `/python-load` | carrega o corpo normativo e passa a aplicá-lo |
| `/python-review` | roda o gate + `ruff` e revisa o que a máquina não lê |
| `/python-claude` | cria/mescla o `CLAUDE.md` sempre-on |
| `/python-cc` · `/python-handoff` | context compact / handoff no archive |

## Versão

**v0.1.0** — changelog em `CHANGELOG.md`.

## Regra de ouro

**"É só um script" é a frase que antecede o incidente.** O script roda em produção, com credencial
de produção, no cron das 3h — e por isso cumpre o mesmo piso do resto.

MIT.
