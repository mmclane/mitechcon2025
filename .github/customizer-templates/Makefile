SHELL:=/bin/bash
MAKE_PATH:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
ECR=example.repo.com
HARBOR_PROJECT={{ harbor-project }}
CONTAINER_NAME={{ container-name }}
ARTIFACT_REPO:=$(ECR)/$(HARBOR_PROJECT)/$(CONTAINER_NAME)
PR=LOCAL
SHA:=$(shell git rev-parse --short HEAD)
CURRENT_VERSION:=$(shell crane manifest $(ARTIFACT_REPO) | jq '.annotations.version')
STEP=minor
SEMVER:=$(shell semver -i $(STEP) $(CURRENT_VERSION) || [[ ! -z "" ]] || echo "0.0.1" )
MAJOR:=$(shell echo $(SEMVER) | cut -d. -f1)
MINOR:=$(shell echo $(SEMVER) | cut -d. -f2)
PATCH:=$(shell echo $(SEMVER) | cut -d. -f3)
BUILDER:={{ builder-default }}
SEVERITY='HIGH,CRITICAL'
AUTH:=$(shell test -e /home/runner/buildah_auth.json && echo --authfile /home/runner/buildah_auth.json || echo "")
NPM_TOKEN:=$(shell aws codeartifact get-authorization-token --domain dn --domain-owner 878788551012 --query authorizationToken --output text)

get-ver:
	@echo "current_version=$(CURRENT_VERSION)"
	@echo "new_version=$(SEMVER)"
	@echo "major=$(MAJOR)"
	@echo "minor=$(MINOR)"
	@echo "patch=$(PATCH)"

login:
	$(BUILDER) login $(ECR)

lint:
	npx lint-staged
	$(BUILDER) run --rm -i -v hadolint.yaml:/.config/hadolint.yaml example.repo.com/cache/hadolint:current < ./src/Dockerfile

unittest:
	@npm config set registry=https://dn-878788551012.d.codeartifact.us-east-1.amazonaws.com/npm/dn-npm-public/
	@npm config set //dn-878788551012.d.codeartifact.us-east-1.amazonaws.com/npm/dn-npm-public/:_authToken="$(NPM_TOKEN)"
	npm ci
	npm test

pre-push:
	npm test

build-container:
	@$(BUILDER) build \
	--build-arg ver=$(SEMVER) \
	--build-arg codeArtifactToken=$(NPM_TOKEN) \
	--target=BUILD \
	-t $(ARTIFACT_REPO):$(SEMVER) ./src/.

build: build-container

builder: unittest build push

yeet: build push

push:
	$(BUILDER) push $(AUTH) $(ARTIFACT_REPO):$(SEMVER)
	crane mutate --annotation version=$(SEMVER) $(ARTIFACT_REPO):$(SEMVER)
	crane tag $(ARTIFACT_REPO):$(SEMVER) $(MAJOR)
	crane tag $(ARTIFACT_REPO):$(SEMVER) $(MAJOR).$(MINOR)
	crane tag $(ARTIFACT_REPO):$(SEMVER) PR$(PR).$(SHA)
	crane tag $(ARTIFACT_REPO):$(SEMVER) latest

run:
	$(BUILDER) run --rm -it --entrypoint /bin/sh $(AUTH) $(ARTIFACT_REPO):latest

scan: scan-vuln scan-secret

scan-vuln:
	trivy fs --exit-code 1 --ignore-unfixed --severity $(SEVERITY) --scanners misconfig,vuln  .

scan-secret:
	trivy fs --exit-code 1 --ignore-unfixed --severity $(SEVERITY) --scanners secret --exit-code 1 .

hooks:
	@pre-commit install --hook-type pre-commit --hook-type pre-push

customize:
	python3 .github/customizer.py

init: customize hooks
