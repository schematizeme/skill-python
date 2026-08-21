# Piso de Python (schematize-python) — sempre-on

1. **Python é ferramenta, não backend de produto novo.** Dados/ML, automação e ferramental: sim.
   **API/serviço de produto novo: VETADO** — nasce no rol (Go/Rust/Elixir/C#/Zig/Ruby) com ADR.
   Servir modelo é a exceção: serviço **fino, sem regra de negócio, atrás** de um serviço do rol.
2. **`uv` + `uv.lock` commitado**; `uv sync --frozen` no CI; `requires-python` declarado.
3. **`ruff check` e `ruff format --check` travam o merge.** `# noqa` sempre com código e motivo.
4. **Tipagem trava o CI** no novo/tocado (`mypy --strict`); legado por catraca. **Fronteira validada
   em runtime** com `pydantic` — anotação não valida nada.
5. **Ferramenta isolada** (`uv tool`/`pipx`), nunca nas dependências do app. `pip install` global é
   VETADO.
6. **Segurança:** `pickle` é **execução de código** (nunca sobre dado externo); sem `eval`/`exec`
   sobre entrada; `yaml.safe_load`; `subprocess([...])` com lista, nunca `shell=True`; `assert` não
   é validação (o `-O` remove).
7. **`secrets`, não `random`,** para token/OTP/salt/nonce.
8. **`timeout` explícito em toda chamada de rede** — `requests`/`httpx` não têm por default.
9. **CPU-bound → processo** (GIL); nada de chamada bloqueante dentro de `async def`.
10. **Notebook não é entregável:** sem saída, sem dado real, sem credencial; virou produto, virou
    módulo em `src/` com teste e tipo.

Gate: `bash .claude/skills/schematize-python/scripts/check-python.sh .`
