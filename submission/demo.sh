#!/bin/bash
# Garante que o docker esteja ativo
service docker start >/dev/null 2>&1

# Sobe o stack se estiver parado
cd /mnt/c/Users/Enzo/Desktop/Arquivos/UFRN/mlops/mlops-2026-1
docker compose up -d >/dev/null 2>&1

# Espera a API responder (lifespan do FastAPI carrega tensorflow -> demora ~6s)
for i in $(seq 1 30); do
  if curl -fs -o /dev/null http://127.0.0.1:8000/ 2>/dev/null; then break; fi
  sleep 1
done

echo "[1] Containers em execucao (docker ps):"
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
echo
echo "[2] GET http://127.0.0.1:8000/  (raiz da API FastAPI):"
curl -sS http://127.0.0.1:8000/
echo
echo
echo "[3] POST http://127.0.0.1:8000/predict?text=ola+mundo  (escreve no Mongo):"
curl -sS -X POST "http://127.0.0.1:8000/predict?text=ola+mundo"
echo
echo
echo "[4] Documentos no Mongo do container local (mongosh):"
docker exec mlops-mongo mongosh --quiet dev_intent_logs --eval "db.DEV_intent_logs.find().sort({_id:-1}).limit(3).toArray()"
