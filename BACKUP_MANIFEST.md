# Excluded local data and artifacts

The cluster checkout contains these ignored local resources; they are not in the public repository:

- `data/` (about 2.8 GB): downloaded benchmark datasets and generated benchmark inputs.
- `corpus/` (about 19.5 GB): local document corpora.
- `outputs/` (about 10 MB): generated evaluation outputs.
- `pi-mono/` (about 648 MB): local dependency checkout.
- `.venv/` (about 22 MB): Python virtual environment.
- `scripts/bcplus_eval/run_bcplus_eval.py.bak.20260630_020947`: editor/backup copy.

The `.gitignore` excludes these paths. Copy any data or dependency checkout you need to retain to separate storage before the cluster account is removed.
