.DEFAULT_GOAL := help

org_code := mahit2024

tasks := writeTxt_
tasks := $(foreach t,$(tasks),flow/$t)


.PHONY: help install install-tess import flow export lint format pre-commit $(tasks)

help:
	$(info Please use 'make <target>', where <target> is one of)
	$(info )
	$(info   install     install packages and prepare software environment)
	$(info )
	$(info   import      import data required for processing document flow)
	$(info   flow        execute the tasks in the document flow)
	$(info   export      export the data generated by the document flow)
	$(info )
	$(info   lint        run the code linters)
	$(info   format      reformat code)
	$(info   pre-commit  run pre-commit checks, runs yaml lint, you need pre-commit)
	$(info )
	$(info Check the makefile to know exactly what each target is doing.)
	@echo # dummy command

install: pyproject.toml
	poetry install --only=dev

install-tess:
	sudo apt-get install tesseract-ocr-all -y

import/documents/all_infos.json:
	wget -O $@ 'https://raw.githubusercontent.com/orgpedia/mahgetGR/main/export/orgpedia_mahgetGR/GRs.json'

import: import/documents/all_infos.json
	$(info running import)
	poetry run python import/src/build_documents.py import/documents/all_infos.json import/documents/documents.json flow/writeTxt_/input


flow: $(tasks)
$(tasks):
	poetry run make -C $@

lint:
	poetry run ruff .

format:
	poetry run ruff format .

export: 
	poetry run python flow/src/export.py import/documents flow/writeTxt_ export/orgpedia_mahit2024


# Use pre-commit if there are lots of edits,
# https://pre-commit.com/ for instructions
# Also set git hook `pre-commit install`
pre-commit:
	pre-commit run --all-files
