#!/bin/bash
git lfs install
git lfs pull
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
pre-commit install
# test the installation
pre-commit run --all-files
