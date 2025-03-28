REPOSERVER:=example.repo.com
REPO:=$(REPOSERVER)/helm-charts/
CHART:=mitechcondemo
CURRENT_VERSION:=$(shell crane manifest $(REPO)$(CHART) | jq '.annotations.version')
STEP=minor
VERSION:=$(shell semver -i $(STEP) $(CURRENT_VERSION) || [[ ! -z "" ]] || echo "0.0.1" )
MAJOR:=$(shell echo $(VERSION) | cut -d. -f1)
MINOR:=$(shell echo $(VERSION) | cut -d. -f2)
PATCH:=$(shell echo $(VERSION) | cut -d. -f3)
REPOUSER:="${REGISTRY_USERNAME}"
REPOPASS:="${REGISTRY_PASSWORD}"

login:
	@echo  $(REPOPASS) | helm registry login $(REPOSERVER) --username $(REPOUSER) --password-stdin
	@crane auth login $(REPOSERVER) -u $(REPOUSER) -p $(REPOPASS)

build-chart:
	@helm package . --dependency-update --app-version $(VERSION) --version $(VERSION)

push:
	helm push $(CHART)-$(VERSION).tgz oci://$(REPO)
	crane mutate --annotation version=$(VERSION) $(REPO)$(CHART):$(VERSION)
	crane tag $(REPO)$(CHART):$(VERSION) latest
	crane tag $(REPO)$(CHART):$(VERSION) $(MAJOR)
	crane tag $(REPO)$(CHART):$(VERSION) $(MAJOR).$(MINOR)
	crane tag $(REPO)$(CHART):$(VERSION) PR$(PR).$(SHA)

cleanup:
	@rm -rf ./$(CHART)-*.tgz

build: build-chart push cleanup
