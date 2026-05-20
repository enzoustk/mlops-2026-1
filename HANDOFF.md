# Lab 4 - Handoff para continuar no MacBook

Estado atual do trabalho e o que falta para submeter.

---

## Status

| Etapa | Status |
|---|---|
| Fork criado (`enzoustk/mlops-2026-1`) | ✅ |
| Secrets configurados (`MONGO_URI`, `MONGO_DB`, `WANDB_API_KEY`, `WANDB_MODELS`) | ✅ |
| `docker-compose.yml` com container Mongo (commit `1889fbf`) | ✅ |
| Workflow `ci.yml` disparado | ✅ (in_progress no momento do handoff) |
| Screenshot Parte 2 (API + Mongo local) | ✅ — `submission/02_api_mongo_local.png` |
| Screenshot Parte 1 (Actions verde) | ⏳ falta capturar quando CI ficar verde |
| ZIP final com as 2 screenshots | ⏳ |

> **Atenção**: o workflow `docs.yml` está falhando — **não é problema do Lab 4** (é outro workflow do repo, fora do escopo da tarefa). O que importa é o `ci.yml` (CI - Build e Testes do Classificador).

---

## Passo 1 — Clonar no MacBook

```bash
gh auth login                                        # se ainda não estiver autenticado
gh repo clone enzoustk/mlops-2026-1
cd mlops-2026-1
```

---

## Passo 2 — Recriar o `.env` local

O `.env` versionado tem placeholders (`xxxxx`). No Windows ele foi marcado com `git update-index --skip-worktree`, mas em clone novo aparece com os placeholders originais. Sobrescreva com:

```bash
cat > .env <<'EOF'
ENV="dev"
WANDB_API_KEY="placeholder-no-wb-account"
WANDB_MODELS=""
MONGO_URI="mongodb://localhost:27017"
MONGO_DB="dev_intent_logs"
EOF

# Opcional: evitar que aparece como modificado em git status
git update-index --skip-worktree .env
```

> `WANDB_MODELS=""` é o truque: o `lifespan` do FastAPI tenta carregar modelos do W&B; vazio = pula carga, app sobe limpo e `/predict` ainda grava no Mongo (com `predictions: {}`).

---

## Passo 3 — Acompanhar o CI (Parte 1)

URL do run que disparei:
**https://github.com/enzoustk/mlops-2026-1/actions/runs/26179535309**

Ou pela lista:
**https://github.com/enzoustk/mlops-2026-1/actions**

Tempo estimado: 6-10 min (tensorflow pesado no `pip install`).

Quando o job `build-and-test` ficar **verde** ✅:
1. Abra a página do run no navegador
2. Tire screenshot com `Cmd+Shift+4` (selecionar área) ou `Cmd+Shift+3` (tela toda)
3. Salve como `submission/01_ci_success.png`

Se precisar re-disparar:
```bash
git commit --allow-empty -m "ci: trigger"
git push origin main
```

---

## Passo 4 — Rodar Parte 2 no MacBook (caso queira re-validar)

A screenshot da Parte 2 já está em `submission/02_api_mongo_local.png`. Se quiser regenerar do zero no Mac:

```bash
# Pré-requisitos: Docker Desktop ativo
docker compose up -d
sleep 15                          # esperar lifespan do FastAPI

# Teste
curl -s http://localhost:8000/
curl -s -X POST "http://localhost:8000/predict?text=ola+mundo"

# Verificar doc no Mongo
docker exec mlops-mongo mongosh --quiet dev_intent_logs \
  --eval 'db.DEV_intent_logs.find().sort({_id:-1}).limit(3).toArray()'
```

No Mac, `localhost:8000` funciona direto do host (no Windows precisei rodar o curl de dentro do WSL porque o Docker estava em WSL2 sem Docker Desktop).

Versão "bonita" do demo para refazer screenshot:
```bash
bash submission/demo.sh           # bash script
# ou abre os scripts em submission/ e adapta para macOS
```

---

## Passo 5 — Gerar o ZIP de submissão

```bash
cd submission
zip lab4_submission.zip 01_ci_success.png 02_api_mongo_local.png
```

Resultado: `submission/lab4_submission.zip` com as 2 screenshots.

---

## Resumo das mudanças no repo (vs upstream `adaj/mlops-2026-1`)

| Arquivo | Mudança |
|---|---|
| `docker-compose.yml` | Adicionado serviço `mongo` (porta 27017) + override de `MONGO_URI` para `mongodb://mongo:27017` + `depends_on` |
| `README.md` | Linha extra (comentário do trigger de CI) — irrelevante |
| `HANDOFF.md` | Este arquivo |
| `submission/` | Screenshot Parte 2 + scripts auxiliares de demo |

A modificação efetiva do Lab 4 está toda no `docker-compose.yml`.
