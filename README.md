# MLOps 2026.1 - Serviço de Classificador de Texto

## Como instalar?

```bash
conda create -n intent-clf python=3.11
conda activate intent-clf
pip install -r requirements.txt
```

## Como treinar um modelo?

```bash
# Na pasta intent_classifier:
cd intent_classifier/

python intent_classifier.py train \
    --config="confusion/confusion_config.yml" \
    --training_data="confusion/confusion_intents.yml" \
    --save_model="confusion/confusion.keras" \
    --wandb_project="mlops-2026-1"

python intent_classifier.py train \
    --config="clair_intents/clair_intents_config.yml" \
    --training_data="clair_intents/clair_intents.yml" \
    --save_model="clair_intents/clair_intents.keras" \
    --wandb_project="mlops-2026-1"
```

## Como rodar?

Certifique-se de preencher o arquivo .env com as variáveis de ambiente.

```bash
# Na pasta raiz:
python -m uvicorn app.app:app --host 0.0.0.0 --port 8000 --log-level debug --reload
```

<!-- Lab 4 trigger CI -->
