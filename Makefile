PROJECT_DIR    := $(shell pwd)
CHANNEL        := $(shell git branch --show-current)
APPLICATION    := harbor

MANIFEST_DIR := $(PROJECT_DIR)/manifests
MANIFESTS    := $(shell find $(MANIFEST_DIR) -name '*.yaml' -o -name '*.tgz')

BUMP           := release
CURRENT_VER    := $(shell semver get release)
RELEASE_NOTES  := $(shell git log --pretty="- %B" $(CURRENT_VER)..)

app:
	@replicated app create --name ${APPLICATION}

channel:
	@replicated channel create --name $(CHANNEL)

lint: $(MANIFESTS)
	@replicated release lint --yaml-dir $(MANIFEST_DIR)

.PHONY: bump
bump:
	@semver up $(BUMP) 1>/dev/null

release: $(MANIFESTS) bump
	@replicated release create \
		--app $(APPLICATION) \
		--token ${REPLICATED_API_TOKEN} \
		--auto -y \
		--yaml-dir $(MANIFEST_DIR) \
		--version $(shell semver get release) \
		--release-notes "$(RELEASE_NOTES)" \
		--promote $(CHANNEL)
	@git tag $(shell semver get release) -m "release $(shell semver get release) to channel $(CHANNEL): $(RELEASE_NOTES)"

install:
	@kubectl kots install ${REPLICATED_APP}

