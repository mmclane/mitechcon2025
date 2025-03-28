SHELL:=/bin/bash
MAKE_PATH:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
ECR=example.repo.com
HARBOR_PROJECT=m3test
CONTAINER_NAME=mitechcondemo
ARTIFACT_REPO:=$(ECR)/$(HARBOR_PROJECT)/$(CONTAINER_NAME)
PR=LOCAL
SHA:=$(shell git rev-parse --short HEAD)
CURRENT_VERSION:=$(shell crane manifest $(ARTIFACT_REPO) | jq '.annotations.version')
STEP=minor
SEMVER:=$(shell semver -i $(STEP) $(CURRENT_VERSION) || [[ ! -z "" ]] || echo "0.0.1" )
MAJOR:=$(shell echo $(SEMVER) | cut -d. -f1)
MINOR:=$(shell echo $(SEMVER) | cut -d. -f2)
PATCH:=$(shell echo $(SEMVER) | cut -d. -f3)
BUILDER:=docker
SEVERITY='HIGH,CRITICAL'
AUTH:=$(shell test -e /home/runner/buildah_auth.json && echo --authfile /home/runner/buildah_auth.json || echo "")

get-ver:
	@echo "current_version=$(CURRENT_VERSION)"
	@echo "new_version=$(SEMVER)"
	@echo "major=$(MAJOR)"
	@echo "minor=$(MINOR)"
	@echo "patch=$(PATCH)"

login:
	$(BUILDER) login $(ECR)

lint:
	@echo "Python Linter"
	-pylint --rcfile .pylintrc -rn -sn ./src

	@echo ""
	@echo "Docker Linter"
	hadolint  -c hadolint.yaml ./src/Dockerfile

unittest:
	@echo "Running unit tests"
	@cd src && python3 -m unittest


build-container:
	echo "This is version $(SEMVER)" > ./src/version.txt
	@$(BUILDER) build \
	-t $(ARTIFACT_REPO):PR$(PR).$(SHA) ./src/.


build: build-container
builder: build push
yeet: build push

push:
	$(BUILDER) push $(AUTH) $(ARTIFACT_REPO):PR$(PR).$(SHA)
	crane mutate --annotation version=$(SEMVER) $(ARTIFACT_REPO):PR$(PR).$(SHA)
	crane tag $(ARTIFACT_REPO):PR$(PR).$(SHA) $(MAJOR)
	crane tag $(ARTIFACT_REPO):PR$(PR).$(SHA) $(MAJOR).$(MINOR)
	crane tag $(ARTIFACT_REPO):PR$(PR).$(SHA) latest
	crane tag $(ARTIFACT_REPO):PR$(PR).$(SHA) $(SEMVER)

run:
	$(BUILDER) run $(AUTH) -p 8001:8501 -e local=true -e TXT_COLOR=Orange -e RUN_ENV=container $(ARTIFACT_REPO):$(SEMVER)

run-py:
	streamlit run ./application/application.py --server.address=0.0.0.0 --server.headless=true

run-container:
	$(BUILDER) run --rm -it --entrypoint /bin/sh $(AUTH) $(ARTIFACT_REPO):$(SEMVER)

scan: scan-vuln scan-secret

scan-vuln:
	trivy fs -c ./trivy.yaml --exit-code 1 --ignore-unfixed --severity $(SEVERITY) --scanners misconfig,vuln  .

scan-secret:
	trivy fs --scanners secret --exit-code 1 .

pre-push:
	@echo "Running unit tests"
	@cd src && python3 -m unittest


hooks:
	@pre-commit install --hook-type pre-commit --hook-type pre-push

customize:
	python3 .github/customizer.py

init: customize hooks
