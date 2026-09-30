#!/usr/bin/env bash
# Vermelho primeiro do gate de Python. Cada fixture é um arquivo com UM defeito.
#
# strict-ok: harness de teste — continua depois de um caso vermelho para reportar todos
# (`schematize-shell` -> `references/piso.md` secao 1)
set -u
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
G="$AQUI/check-python.sh"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT INT TERM
ok=0; fail=0

# caso <nome> <exit-esperado> <agulha> — o FIXTURE vem pelo stdin (heredoc = dado, não código).
caso() {
  local nome="$1" esp="$2" agulha="$3" arq="${4:-alvo.py}"
  local d="$TMP/$nome"; mkdir -p "$d"
  cat > "$d/$arq"
  local saida; saida="$(bash "$G" "$d" 2>&1)"; local rc=$?
  if [ "$rc" != "$esp" ]; then echo "  ✖ $nome: exit $rc, esperado $esp"; sed 's/^/      /' <<<"$saida"; fail=$((fail+1)); return; fi
  if [ -n "$agulha" ] && ! grep -qF -- "$agulha" <<<"$saida"; then echo "  ✖ $nome: exit certo, saída sem \"$agulha\""; sed 's/^/      /' <<<"$saida"; fail=$((fail+1)); return; fi
  echo "  ✔ $nome"; ok=$((ok+1))
}

echo "== verde de partida =="
caso verde 0 "no piso" <<'FIX'
"""Módulo de exemplo no piso."""

from __future__ import annotations

import secrets
import subprocess
import tempfile
from pathlib import Path


def gerar_token(n: int = 32) -> str:
    """Token de sessão: CSPRNG, nunca `random`."""
    return secrets.token_urlsafe(n)


def rodar(args: list[str]) -> int:
    """Lista de argumentos, nunca string com shell=True."""
    return subprocess.run(args, check=False, timeout=30).returncode


def escrever(conteudo: str) -> Path:
    with tempfile.NamedTemporaryFile("w", delete=False) as fh:
        fh.write(conteudo)
        return Path(fh.name)
FIX

echo "== segurança =="
caso shell-true 1 "shell=True" <<'FIX'
import subprocess


def rodar(cmd: str) -> None:
    subprocess.run(cmd, shell=True, check=False)
FIX
caso yaml-load 1 "SafeLoader" <<'FIX'
import yaml


def ler(texto: str) -> dict:
    return yaml.load(texto)
FIX
caso random-em-token 1 "use \`secrets\`" <<'FIX'
import random


def gerar_token() -> str:
    """Gera o token de sessão."""
    return str(random.randint(1000, 9999))
FIX
caso eval-vetado 1 "VETADO" <<'FIX'
def calcular(expr: str) -> float:
    return eval(expr)
FIX

echo "== armadilhas de Python =="
caso default-mutavel 1 "default MUTÁVEL" <<'FIX'
def acumular(item: str, itens: list = []) -> list:
    itens.append(item)
    return itens
FIX
caso http-sem-timeout 1 "sem \`timeout\`" <<'FIX'
import requests


def buscar(url: str) -> str:
    return requests.get(url).text
FIX

echo "== dependência e lock =="
d="$TMP/sem-lock"; mkdir -p "$d"
printf 'def f() -> int:\n    return 1\n' > "$d/a.py"
printf '[project]\nname = "x"\nversion = "0.1.0"\nrequires-python = ">=3.12"\n' > "$d/pyproject.toml"
saida="$(bash "$G" "$d" 2>&1)"; rc=$?
if [ "$rc" = 1 ] && grep -qF "sem lockfile commitado" <<<"$saida"; then echo "  ✔ pyproject sem lock reprova"; ok=$((ok+1))
else echo "  ✖ pyproject sem lock: exit $rc"; sed 's/^/      /' <<<"$saida"; fail=$((fail+1)); fi

d="$TMP/sem-requires"; mkdir -p "$d"
printf 'def f() -> int:\n    return 1\n' > "$d/a.py"
printf '[project]\nname = "x"\nversion = "0.1.0"\n' > "$d/pyproject.toml"; : > "$d/uv.lock"
saida="$(bash "$G" "$d" 2>&1)"; rc=$?
if [ "$rc" = 1 ] && grep -qF "requires-python" <<<"$saida"; then echo "  ✔ pyproject sem requires-python reprova"; ok=$((ok+1))
else echo "  ✖ sem requires-python: exit $rc"; fail=$((fail+1)); fi

echo "== notebook =="
caso notebook-com-saida 1 "COM saída" "exploracao.ipynb" <<'FIX'
{"cells":[{"cell_type":"code","outputs":[{"output_type":"stream","text":["cpf,nome\n","529.982.247-25,Fulano\n"]}],"source":["df.head()"]}],"metadata":{},"nbformat":4}
FIX

echo "== nada para verificar =="
d="$TMP/vazio"; mkdir -p "$d"; echo "# prosa" > "$d/LEIA.md"
saida="$(bash "$G" "$d" 2>&1)"; rc=$?
if [ "$rc" = 2 ] && grep -q "não é aprovação" <<<"$saida"; then echo "  ✔ repo sem .py sai 2 (não 0)"; ok=$((ok+1))
else echo "  ✖ repo sem .py: exit $rc"; fail=$((fail+1)); fi

echo; echo "check-python: $ok ok, $fail falha(s)"; [ "$fail" = 0 ]
