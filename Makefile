# © Copyright IBM Corporation 2017, 2021
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

###############################################################################
# Conditional variables - you can override the values of these variables from
# the command line
###############################################################################

include config.env

# RELEASE shows what release of the container code has been built
RELEASE ?=
# MQ_ARCHIVE_REPOSITORY is a remote repository from which to pull the MQ_ARCHIVE (if required)
MQ_ARCHIVE_REPOSITORY ?=
# MQ_ARCHIVE_REPOSITORY_DEV is a remote repository from which to pull the MQ_ARCHIVE_DEV (if required)
MQ_ARCHIVE_REPOSITORY_DEV ?=
# MQ_ARCHIVE_REPOSITORY_USER is the user for the remote repository (if required)
MQ_ARCHIVE_REPOSITORY_USER ?=
# MQ_ARCHIVE_REPOSITORY_CREDENTIAL is the password/API key for the remote repository (if required)
MQ_ARCHIVE_REPOSITORY_CREDENTIAL ?=
# MQ_ARCHIVE is the name of the file, under the downloads directory, from which MQ Advanced can
# be installed. Does not apply to MQ Advanced for Developers
MQ_ARCHIVE ?= IBM_MQ_$(MQ_VERSION_VRM)_$(MQ_ARCHIVE_TYPE)_$(MQ_ARCHIVE_ARCH)_NOINST.tar.gz
# MQ_ARCHIVE_DEV is the name of the file, under the downloads directory, from which MQ Advanced
# for Developers can be installed
MQ_ARCHIVE_DEV ?= $(MQ_VERSION)-IBM-MQ-Advanced-for-Developers-Non-Install-$(MQ_ARCHIVE_DEV_TYPE)$(MQ_ARCHIVE_DEV_ARCH).tar.gz
# MQ_SDK_ARCHIVE specifies the archive to use for building the golang programs.  Defaults vary on developer or advanced.
MQ_SDK_ARCHIVE ?= $(MQ_ARCHIVE_DEV_$(MQ_VERSION))
# Options to `go test` for the Docker tests
TEST_OPTS_DOCKER ?=
# Timeout for the Docker tests
TEST_TIMEOUT_DOCKER ?= 30m
# MQ_IMAGE_ADVANCEDSERVER is the name of the built MQ Advanced image
MQ_IMAGE_ADVANCEDSERVER ?=ibm-mqadvanced-server
# MQ_IMAGE_DEVSERVER is the name of the built MQ Advanced for Developers image
MQ_IMAGE_DEVSERVER ?=ibm-mqadvanced-server-dev
# MQ_MANIFEST_TAG is the tag to use for fat-manifest
MQ_MANIFEST_TAG ?= $(MQ_VERSION)$(RELEASE_TAG)$(LTS_TAG)$(MQ_MANIFEST_TAG_SUFFIX)
# MQ_TAG is the tag of the built MQ Advanced image & MQ Advanced for Developers image
MQ_TAG ?= $(MQ_MANIFEST_TAG)-$(ARCH)
# COMMAND is the container command to run.  "podman" or "docker"
COMMAND ?=$(shell type -p podman 2>&1 >/dev/null && echo podman || echo docker)
# MQ_DELIVERY_REGISTRY_HOSTNAME is a remote registry to push the MQ Image to (if required)
MQ_DELIVERY_REGISTRY_HOSTNAME ?=
# MQ_DELIVERY_REGISTRY_NAMESPACE is the namespace/path on the delivery registry (if required)
MQ_DELIVERY_REGISTRY_NAMESPACE ?=
# MQ_DELIVERY_REGISTRY_USER is the user for the remote registry (if required)
MQ_DELIVERY_REGISTRY_USER ?=
# MQ_DELIVERY_REGISTRY_CREDENTIAL is the password/API key for the remote registry (if required)
MQ_DELIVERY_REGISTRY_CREDENTIAL ?=
# REGISTRY_USER is the username used to login to the Red Hat registry
REGISTRY_USER ?=
# REGISTRY_PASS is the password used to login to the Red Hat registry
REGISTRY_PASS ?=
# ARCH is the platform architecture (e.g. amd64, ppc64le or s390x)
ARCH ?= $(if $(findstring x86_64,$(shell uname -m)),amd64,$(shell uname -m))
# LTS is a boolean value to enable/disable LTS container build
LTS ?= false

###############################################################################
# Other variables
###############################################################################
# Build doesn't work if BuildKit is enabled
DOCKER_BUILDKIT=0
GO_PKG_DIRS = ./cmd ./internal ./test
MQ_ARCHIVE_TYPE=LINUX
MQ_ARCHIVE_DEV_TYPE=Linux
# BUILD_SERVER_CONTAINER is the name of the web server container used at build time
BUILD_SERVER_CONTAINER=build-server
# NUM_CPU is the number of CPUs available to Docker.  Used to control how many
# test run in parallel
NUM_CPU ?= $(or $(shell docker info --format "{{ .NCPU }}"),2)
# BASE_IMAGE_TAG is a normalized version of BASE_IMAGE, suitable for use in a Docker tag
BASE_IMAGE_TAG=$(lastword $(subst /, ,$(subst :,-,$(BASE_IMAGE))))
#BASE_IMAGE_TAG=$(subst /,-,$(subst :,-,$(BASE_IMAGE)))
MQ_IMAGE_DEVSERVER_BASE=mqadvanced-server-dev-base
# Docker image name to use for JMS tests
DEV_JMS_IMAGE=mq-dev-jms-test
# Variables for versioning
IMAGE_REVISION=$(shell git rev-parse HEAD)
IMAGE_SOURCE=$(shell git config --get remote.origin.url)
EMPTY:=
SPACE:= $(EMPTY) $(EMPTY)
# MQ_VERSION_VRM is MQ_VERSION with only the Version, Release and Modifier fields (no Fix field).  e.g. 9.2.0 instead of 9.2.0.0
MQ_VERSION_VRM=$(subst $(SPACE),.,$(wordlist 1,3,$(subst .,$(SPACE),$(MQ_VERSION))))

ifneq (,$(findstring Microsoft,$(shell uname -r)))
	DOWNLOADS_DIR=$(patsubst /mnt/c%,C:%,$(realpath ./downloads/))
else ifneq (,$(findstring Windows,$(shell echo ${OS})))
	DOWNLOADS_DIR=$(shell pwd)/downloads/
else
	DOWNLOADS_DIR=$(realpath ./downloads/)
endif

# Try to figure out which archive to use from the architecture
ifeq "$(ARCH)" "amd64"
	MQ_ARCHIVE_ARCH=X86-64
	MQ_ARCHIVE_DEV_ARCH=X64
else ifeq "$(ARCH)" "ppc64le"
	MQ_ARCHIVE_ARCH=PPC64LE
else ifeq "$(ARCH)" "s390x"
	MQ_ARCHIVE_ARCH=S390X
endif

# LTS_TAG is the tag modifier for an LTS container build
LTS_TAG=
ifeq "$(LTS)" "true"
ifneq "$(LTS_TAG_OVERRIDE)" "$(EMPTY)"
	LTS_TAG=$(LTS_TAG_OVERRIDE)
else
	LTS_TAG=-lts
endif
	MQ_ARCHIVE:=$(MQ_VERSION)-IBM-MQ-Advanced-Non-Install-Linux$(MQ_ARCHIVE_ARCH).tar.gz
	MQ_DELIVERY_REGISTRY_NAMESPACE:=$(MQ_DELIVERY_REGISTRY_NAMESPACE)$(LTS_TAG)
endif

ifneq (,$(findstring release-candidate,$(TRAVIS_TAG)))
    MQ_DELIVERY_REGISTRY_NAMESPACE=release-candidates
endif

ifneq "$(MQ_DELIVERY_REGISTRY_NAMESPACE)" "$(EMPTY)"
	MQ_DELIVERY_REGISTRY_FULL_PATH=$(MQ_DELIVERY_REGISTRY_HOSTNAME)/$(MQ_DELIVERY_REGISTRY_NAMESPACE)
else
	MQ_DELIVERY_REGISTRY_FULL_PATH=$(MQ_DELIVERY_REGISTRY_HOSTNAME)
endif

# image tagging

ifneq "$(RELEASE)" "$(EMPTY)"
	EXTRA_LABELS=--label release=$(RELEASE)
	RELEASE_TAG="-$(RELEASE)"
endif

ifeq "$(TIMESTAMPFLAT)" "$(EMPTY)"
	TIMESTAMPFLAT=$(shell date "+%Y%m%d%H%M%S")
endif

ifeq "$(GIT_COMMIT)" "$(EMPTY)"
	GIT_COMMIT=$(shell git rev-parse --short HEAD)
endif

ifeq ($(shell [ ! -z $(TRAVIS) ] && [ "$(TRAVIS_PULL_REQUEST)" = "false" ] && [ "$(TRAVIS_BRANCH)" = "$(MAIN_BRANCH)" ] && echo true), true)
	MQ_MANIFEST_TAG_SUFFIX=.$(TIMESTAMPFLAT).$(GIT_COMMIT)
endif

PATH_TO_MQ_TAG_CACHE=$(TRAVIS_BUILD_DIR)/.tagcache
ifneq "$(TRAVIS)" "$(EMPTY)"
ifneq ("$(wildcard $(PATH_TO_MQ_TAG_CACHE))","")
include $(PATH_TO_MQ_TAG_CACHE)
endif
endif

MQ_AMD64_TAG=$(MQ_MANIFEST_TAG)-amd64
MQ_S390X_TAG?=$(MQ_MANIFEST_TAG)-s390x

# end image tagging

MQ_IMAGE_FULL_RELEASE_NAME=$(MQ_IMAGE_ADVANCEDSERVER):$(MQ_TAG)
MQ_IMAGE_DEV_FULL_RELEASE_NAME=$(MQ_IMAGE_DEVSERVER):$(MQ_TAG)

#setup variables for fat-manifests
MQ_IMAGE_DEVSERVER_MANIFEST=$(MQ_IMAGE_DEVSERVER):$(MQ_MANIFEST_TAG)
MQ_IMAGE_ADVANCEDSERVER_MANIFEST=$(MQ_IMAGE_ADVANCEDSERVER):$(MQ_MANIFEST_TAG)
MQ_IMAGE_DEVSERVER_AMD64=$(MQ_DELIVERY_REGISTRY_FULL_PATH)/$(MQ_IMAGE_DEVSERVER):$(MQ_AMD64_TAG)
MQ_IMAGE_DEVSERVER_S390X=$(MQ_DELIVERY_REGISTRY_FULL_PATH)/$(MQ_IMAGE_DEVSERVER):$(MQ_S390X_TAG)
MQ_IMAGE_ADVANCEDSERVER_AMD64=$(MQ_DELIVERY_REGISTRY_FULL_PATH)/$(MQ_IMAGE_ADVANCEDSERVER):$(MQ_AMD64_TAG)
MQ_IMAGE_ADVANCEDSERVER_S390X=$(MQ_DELIVERY_REGISTRY_FULL_PATH)/$(MQ_IMAGE_ADVANCEDSERVER):$(MQ_S390X_TAG)

###############################################################################
# Build targets
###############################################################################
.PHONY: default
default: build-devserver

# Build all components (except incubating ones)
.PHONY: all
all: build-devserver build-advancedserver

.PHONY: test-all
test-all: build-devjmstest test-devserver test-advancedserver

.PHONY: devserver
devserver: build-devserver build-devjmstest test-devserver

.PHONY: advancedserver
advancedserver: build-advancedserver test-advancedserver

# Build incubating components
.PHONY: incubating
incubating: build-explorer

downloads/$(MQ_ARCHIVE_DEV):
	$(info $(SPACER)$(shell printf $(TITLE)"Downloading IBM MQ Advanced for Developers "$(MQ_VERSION)$(END)))
	mkdir -p downloads
ifneq "$(BUILD_RSYNC_SERVER)" "$(EMPTY)"
# Use key which is not stored in the repository to fetch the files from the fileserver
	curl -L $(BUILD_RSYNC_ENCRYPTED_KEY_URL) -o ./host.key.gpg
	@echo $(BUILD_RSYNC_ENCRYPTION_PASSWORD)|gpg --batch --passphrase-fd 0 ./host.key.gpg
	chmod 600 ./host.key
	rsync -rv -e "ssh -o BatchMode=yes -q -o StrictHostKeyChecking=no -i ./host.key" --include="*/" --include="*.tar.gz" --exclude="*" $(BUILD_RSYNC_USER)@$(BUILD_RSYNC_SERVER):"$(BUILD_RSYNC_PATH)" downloads/$(MQ_ARCHIVE_DEV)
	-@rm host.key.gpg host.key
else
ifneq "$(MQ_ARCHIVE_REPOSITORY_DEV)" "$(EMPTY)"
	curl -u $(MQ_ARCHIVE_REPOSITORY_USER):$(MQ_ARCHIVE_REPOSITORY_CREDENTIAL) -X GET "$(MQ_ARCHIVE_REPOSITORY_DEV)" -o downloads/$(MQ_ARCHIVE_DEV)
else
	curl -L https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/messaging/mqadv/$(MQ_ARCHIVE_DEV) -o downloads/$(MQ_ARCHIVE_DEV)
endif
endif

downloads/$(MQ_ARCHIVE):
	$(info $(SPACER)$(shell printf $(TITLE)"Downloading IBM MQ Advanced "$(MQ_VERSION)$(END)))
	mkdir -p downloads
ifneq "$(BUILD_RSYNC_SERVER)" "$(EMPTY)"
# Use key which is not stored in the repository to fetch the files from the fileserver
	-@rm host.key.gpg host.key
	curl -L $(BUILD_RSYNC_ENCRYPTED_KEY_URL) -o ./host.key.gpg
	@echo $(BUILD_RSYNC_ENCRYPTION_PASSWORD)|gpg --batch --passphrase-fd 0 ./host.key.gpg
	chmod 600 ./host.key
	rsync -rv -e "ssh -o BatchMode=yes -q -o StrictHostKeyChecking=no -i ./host.key" --include="*/" --include="*.tar.gz" --exclude="*" $(BUILD_RSYNC_USER)@$(BUILD_RSYNC_SERVER):"$(BUILD_RSYNC_PATH)" downloads/$(MQ_ARCHIVE)
	-@rm host.key.gpg host.key
else
ifneq "$(MQ_ARCHIVE_REPOSITORY)" "$(EMPTY)"
	curl -u $(MQ_ARCHIVE_REPOSITORY_USER):$(MQ_ARCHIVE_REPOSITORY_CREDENTIAL) -X GET "$(MQ_ARCHIVE_REPOSITORY)" -o downloads/$(MQ_ARCHIVE)
endif
endif

.PHONY: downloads
downloads: downloads/$(MQ_ARCHIVE_DEV) downloads/$(MQ_SDK_ARCHIVE)

.PHONY: cache-mq-tag
cache-mq-tag:
	@printf "MQ_MANIFEST_TAG=$(MQ_MANIFEST_TAG)\n" | tee $(PATH_TO_MQ_TAG_CACHE)

# Vendor Go dependencies for the Docker tests
test/docker/vendor:
	cd test/docker && go mod vendor

# Shortcut to just run the unit tests
.PHONY: test-unit
test-unit:
	docker build --target builder --file Dockerfile-server .

.PHONY: test-advancedserver
test-advancedserver: test/docker/vendor
	$(info $(SPACER)$(shell printf $(TITLE)"Test $(MQ_IMAGE_ADVANCEDSERVER):$(MQ_TAG) on $(shell docker --version)"$(END)))
	docker inspect $(MQ_IMAGE_ADVANCEDSERVER):$(MQ_TAG)
	cd test/docker && TEST_IMAGE=$(MQ_IMAGE_ADVANCEDSERVER):$(MQ_TAG) EXPECTED_LICENSE=Production go test -parallel $(NUM_CPU) -timeout $(TEST_TIMEOUT_DOCKER) $(TEST_OPTS_DOCKER)

.PHONY: build-devjmstest
build-devjmstest: registry-login
	$(info $(SPACER)$(shell printf $(TITLE)"Build JMS tests for developer config"$(END)))
	cd test/messaging && docker build --tag $(DEV_JMS_IMAGE) .

.PHONY: test-devserver
test-devserver: test/docker/vendor
	$(info $(SPACER)$(shell printf $(TITLE)"Test $(MQ_IMAGE_DEVSERVER):$(MQ_TAG) on $(shell docker --version)"$(END)))
	docker inspect $(MQ_IMAGE_DEVSERVER):$(MQ_TAG)
	cd test/docker && TEST_IMAGE=$(MQ_IMAGE_DEVSERVER):$(MQ_TAG) EXPECTED_LICENSE=Developer DEV_JMS_IMAGE=$(DEV_JMS_IMAGE) IBMJRE=true go test -parallel $(NUM_CPU) -timeout $(TEST_TIMEOUT_DOCKER) -tags mqdev $(TEST_OPTS_DOCKER)

.PHONY: coverage
coverage:
	mkdir coverage

.PHONY: test-advancedserver-cover
test-advancedserver-cover: test/docker/vendor coverage
	$(info $(SPACER)$(shell printf $(TITLE)"Test $(MQ_IMAGE_ADVANCEDSERVER):$(MQ_TAG) with code coverage on $(shell docker --version)"$(END)))
	rm -f ./coverage/unit*.cov
	# Run unit tests with coverage, for each package under 'internal'
	go list -f '{{.Name}}' ./internal/... | xargs -I {} go test -cover -covermode count -coverprofile ./coverage/unit-{}.cov ./internal/{}
#	ls -1 ./cmd | xargs -I {} go test -cover -covermode count -coverprofile ./coverage/unit-{}.cov ./cmd/{}/...
	echo 'mode: count' > ./coverage/unit.cov
	tail -q -n +2 ./coverage/unit-*.cov >> ./coverage/unit.cov
	go tool cover -html=./coverage/unit.cov -o ./coverage/unit.html

	rm -f ./test/docker/coverage/*.cov
	rm -f ./coverage/docker.*
	mkdir -p ./test/docker/coverage/
	cd test/docker && TEST_IMAGE=$(MQ_IMAGE_ADVANCEDSERVER):$(MQ_TAG)-cover TEST_COVER=true go test $(TEST_OPTS_DOCKER)
	echo 'mode: count' > ./coverage/docker.cov
	tail -q -n +2 ./test/docker/coverage/*.cov >> ./coverage/docker.cov
	go tool cover -html=./coverage/docker.cov -o ./coverage/docker.html

	echo 'mode: count' > ./coverage/combined.cov
	tail -q -n +2 ./coverage/unit.cov ./coverage/docker.cov  >> ./coverage/combined.cov
	go tool cover -html=./coverage/combined.cov -o ./coverage/combined.html

# Build an MQ image.  The commands used are slightly different between Docker and Podman
define build-mq
	$(if $(findstring docker,$(COMMAND)), @docker network create build,)
	$(if $(findstring docker,$(COMMAND)), @docker run --rm --name $(BUILD_SERVER_CONTAINER) --network build --network-alias build --volume $(DOWNLOADS_DIR):/opt/app-root/src:ro --detach registry.redhat.io/ubi8/nginx-118 nginx -g "daemon off;",)
	$(eval EXTRA_ARGS=$(if $(findstring docker,$(COMMAND)), --network build --build-arg MQ_URL=http://build:8080/$4, --volume $(DOWNLOADS_DIR):/var/downloads --build-arg MQ_URL=file:///var/downloads/$4))
	# Build the new image
	$(COMMAND) build \
	  --tag $1:$2 \
	  --file $3 \
	  $(EXTRA_ARGS) \
	  --build-arg IMAGE_REVISION="$(IMAGE_REVISION)" \
	  --build-arg IMAGE_SOURCE="$(IMAGE_SOURCE)" \
	  --build-arg IMAGE_TAG="$1:$2" \
	  --label version=$(MQ_VERSION) \
	  --label name=$1 \
	  --label build-date=$(shell date +%Y-%m-%dT%H:%M:%S%z) \
	  --label architecture="$(ARCH)" \
	  --label run="docker run -d -e LICENSE=accept $1:$2" \
	  --label vcs-ref=$(IMAGE_REVISION) \
	  --label vcs-type=git \
	  --label vcs-url=$(IMAGE_SOURCE) \
	  $(EXTRA_LABELS) \
	  --target $5 \
	  .
	$(if $(findstring docker,$(COMMAND)), @docker kill $(BUILD_SERVER_CONTAINER))
	$(if $(findstring docker,$(COMMAND)), @docker network rm build)
endef

DOCKER_SERVER_VERSION=$(shell docker version --format "{{ .Server.Version }}")
DOCKER_CLIENT_VERSION=$(shell docker version --format "{{ .Client.Version }}")
PODMAN_VERSION=$(shell podman version --format "{{ .Version }}")
.PHONY: command-version
command-version:
# If we're using Docker, then check it's recent enough to support multi-stage builds
ifneq (,$(findstring docker,$(COMMAND)))
	@test "$(word 1,$(subst ., ,$(DOCKER_CLIENT_VERSION)))" -ge "17" || ("$(word 1,$(subst ., ,$(DOCKER_CLIENT_VERSION)))" -eq "17" && "$(word 2,$(subst ., ,$(DOCKER_CLIENT_VERSION)))" -ge "05") || (echo "Error: Docker client 17.05 or greater is required" && exit 1)
	@test "$(word 1,$(subst ., ,$(DOCKER_SERVER_VERSION)))" -ge "17" || ("$(word 1,$(subst ., ,$(DOCKER_SERVER_VERSION)))" -eq "17" && "$(word 2,$(subst ., ,$(DOCKER_CLIENT_VERSION)))" -ge "05") || (echo "Error: Docker server 17.05 or greater is required" && exit 1)
endif
ifneq (,$(findstring podman,$(COMMAND)))
	@test "$(word 1,$(subst ., ,$(PODMAN_VERSION)))" -ge "1" || (echo "Error: Podman version 1.0 or greater is required" && exit 1)
endif

.PHONY: build-advancedserver-host
build-advancedserver-host: build-advancedserver

.PHONY: build-advancedserver
build-advancedserver: registry-login log-build-env downloads/$(MQ_ARCHIVE) command-version
	$(info $(SPACER)$(shell printf $(TITLE)"Build $(MQ_IMAGE_ADVANCEDSERVER):$(MQ_TAG)"$(END)))
	$(call build-mq,$(MQ_IMAGE_ADVANCEDSERVER),$(MQ_TAG),Dockerfile-server,$(MQ_ARCHIVE),mq-server)

.PHONY: build-devserver-host
build-devserver-host: build-devserver

.PHONY: build-devserver
build-devserver: registry-login log-build-env downloads/$(MQ_ARCHIVE_DEV) command-version
	$(info $(shell printf $(TITLE)"Build $(MQ_IMAGE_DEVSERVER):$(MQ_TAG)"$(END)))
	$(call build-mq,$(MQ_IMAGE_DEVSERVER),$(MQ_TAG),Dockerfile-server,$(MQ_ARCHIVE_DEV),mq-dev-server)

.PHONY: build-advancedserver-cover
build-advancedserver-cover: registry-login command-version
	$(COMMAND) build --build-arg BASE_IMAGE=$(MQ_IMAGE_ADVANCEDSERVER):$(MQ_TAG) -t $(MQ_IMAGE_ADVANCEDSERVER):$(MQ_TAG)-cover -f Dockerfile-server.cover .

.PHONY: build-explorer
build-explorer: registry-login downloads/$(MQ_ARCHIVE_DEV)
	$(call build-mq,mq-explorer,latest-$(ARCH),incubating/mq-explorer/Dockerfile,$(MQ_ARCHIVE_DEV),mq-explorer)

.PHONY: build-sdk
build-sdk: registry-login downloads/$(MQ_ARCHIVE_DEV)
	$(info $(shell printf $(TITLE)"Build $(MQ_IMAGE_SDK)"$(END)))
	$(call build-mq,mq-sdk,$(MQ_TAG),incubating/mq-sdk/Dockerfile,$(MQ_SDK_ARCHIVE),mq-sdk)

.PHONY: registry-login
registry-login:
ifneq ($(REGISTRY_USER),)
	$(COMMAND) login -u $(REGISTRY_USER) -p $(REGISTRY_PASS) registry.redhat.io
endif

.PHONY: log-build-env
log-build-vars:
	$(info $(SPACER)$(shell printf $(TITLE)"Build environment"$(END)))
	@echo ARCH=$(ARCH)
	@echo MQ_VERSION=$(MQ_VERSION)
	@echo MQ_ARCHIVE=$(MQ_ARCHIVE)
	@echo MQ_ARCHIVE_DEV=$(MQ_ARCHIVE_DEV)
	@echo MQ_IMAGE_DEVSERVER=$(MQ_IMAGE_DEVSERVER)
	@echo MQ_IMAGE_ADVANCEDSERVER=$(MQ_IMAGE_ADVANCEDSERVER)
	@echo COMMAND=$(COMMAND)
	@echo REGISTRY_USER=$(REGISTRY_USER)

.PHONY: log-build-env
log-build-env: log-build-vars
	$(info $(SPACER)$(shell printf $(TITLE)"Build environment - $(COMMAND) info"$(END)))
	@echo Command version: $(shell $(COMMAND) --version)
	$(COMMAND) info

include formatting.mk

.PHONY: pull-mq-archive
pull-mq-archive:
	curl -u $(MQ_ARCHIVE_REPOSITORY_USER):$(MQ_ARCHIVE_REPOSITORY_CREDENTIAL) -X GET "$(MQ_ARCHIVE_REPOSITORY)" -o downloads/$(MQ_ARCHIVE)

.PHONY: pull-mq-archive-dev
pull-mq-archive-dev:
	curl -u $(MQ_ARCHIVE_REPOSITORY_USER):$(MQ_ARCHIVE_REPOSITORY_CREDENTIAL) -X GET "$(MQ_ARCHIVE_REPOSITORY_DEV)" -o downloads/$(MQ_ARCHIVE_DEV)

.PHONY: push-advancedserver
push-advancedserver:
	$(info $(SPACER)$(shell printf $(TITLE)"Push production image to $(MQ_DELIVERY_REGISTRY_FULL_PATH)"$(END)))
	$(COMMAND) login $(MQ_DELIVERY_REGISTRY_HOSTNAME) -u $(MQ_DELIVERY_REGISTRY_USER) -p $(MQ_DELIVERY_REGISTRY_CREDENTIAL)
	$(COMMAND) tag $(MQ_IMAGE_ADVANCEDSERVER)\:$(MQ_TAG) $(MQ_DELIVERY_REGISTRY_FULL_PATH)/$(MQ_IMAGE_FULL_RELEASE_NAME)
	$(COMMAND) push $(MQ_DELIVERY_REGISTRY_FULL_PATH)/$(MQ_IMAGE_FULL_RELEASE_NAME)

.PHONY: push-devserver
push-devserver:
	$(info $(SPACER)$(shell printf $(TITLE)"Push developer image to $(MQ_DELIVERY_REGISTRY_FULL_PATH)"$(END)))
	$(COMMAND) login $(MQ_DELIVERY_REGISTRY_HOSTNAME) -u $(MQ_DELIVERY_REGISTRY_USER) -p $(MQ_DELIVERY_REGISTRY_CREDENTIAL)
	$(COMMAND) tag $(MQ_IMAGE_DEVSERVER)\:$(MQ_TAG) $(MQ_DELIVERY_REGISTRY_FULL_PATH)/$(MQ_IMAGE_DEV_FULL_RELEASE_NAME)
	$(COMMAND) push $(MQ_DELIVERY_REGISTRY_FULL_PATH)/$(MQ_IMAGE_DEV_FULL_RELEASE_NAME)

.PHONY: pull-advancedserver
pull-advancedserver:
	$(info $(SPACER)$(shell printf $(TITLE)"Pull production image from $(MQ_DELIVERY_REGISTRY_FULL_PATH)"$(END)))
	$(COMMAND) login $(MQ_DELIVERY_REGISTRY_HOSTNAME) -u $(MQ_DELIVERY_REGISTRY_USER) -p $(MQ_DELIVERY_REGISTRY_CREDENTIAL)
	$(COMMAND) pull $(MQ_DELIVERY_REGISTRY_FULL_PATH)/$(MQ_IMAGE_FULL_RELEASE_NAME)
	$(COMMAND) tag $(MQ_DELIVERY_REGISTRY_FULL_PATH)/$(MQ_IMAGE_FULL_RELEASE_NAME) $(MQ_IMAGE_ADVANCEDSERVER)\:$(MQ_TAG)

.PHONY: pull-devserver
pull-devserver:
	$(info $(SPACER)$(shell printf $(TITLE)"Pull developer image from $(MQ_DELIVERY_REGISTRY_FULL_PATH)"$(END)))
	$(COMMAND) login $(MQ_DELIVERY_REGISTRY_HOSTNAME) -u $(MQ_DELIVERY_REGISTRY_USER) -p $(MQ_DELIVERY_REGISTRY_CREDENTIAL)
	$(COMMAND) pull $(MQ_DELIVERY_REGISTRY_FULL_PATH)/$(MQ_IMAGE_DEV_FULL_RELEASE_NAME)
	$(COMMAND) tag $(MQ_DELIVERY_REGISTRY_FULL_PATH)/$(MQ_IMAGE_DEV_FULL_RELEASE_NAME) $(MQ_IMAGE_DEVSERVER)\:$(MQ_TAG)

.PHONY: push-manifest
push-manifest: build-skopeo-container
	$(info $(SPACER)$(shell printf $(TITLE)"** Determining the image digests **"$(END)))
ifneq "$(LTS)" "true"
	$(eval MQ_IMAGE_DEVSERVER_AMD64_DIGEST=$(shell $(COMMAND) run skopeo:latest --override-os linux --override-arch s390x  inspect --creds $(MQ_ARCHIVE_REPOSITORY_USER):$(MQ_ARCHIVE_REPOSITORY_CREDENTIAL) docker://$(MQ_IMAGE_DEVSERVER_AMD64) | jq -r .Digest))
	$(eval MQ_IMAGE_DEVSERVER_S390X_DIGEST=$(shell $(COMMAND) run skopeo:latest --override-os linux inspect --creds $(MQ_ARCHIVE_REPOSITORY_USER):$(MQ_ARCHIVE_REPOSITORY_CREDENTIAL) docker://$(MQ_IMAGE_DEVSERVER_S390X) | jq -r .Digest))
	$(info $(shell printf "** Determined the built $(MQ_IMAGE_DEVSERVER_AMD64) has a digest of $(MQ_IMAGE_DEVSERVER_AMD64_DIGEST)**"$(END)))
	$(info $(shell printf "** Determined the built $(MQ_IMAGE_DEVSERVER_S390X) has a digest of $(MQ_IMAGE_DEVSERVER_S390X_DIGEST)**"$(END)))
endif
	$(eval MQ_IMAGE_ADVANCEDSERVER_AMD64_DIGEST=$(shell $(COMMAND) run skopeo:latest --override-os linux inspect --creds $(MQ_ARCHIVE_REPOSITORY_USER):$(MQ_ARCHIVE_REPOSITORY_CREDENTIAL) docker://$(MQ_IMAGE_ADVANCEDSERVER_AMD64) | jq -r .Digest))
	$(eval MQ_IMAGE_ADVANCEDSERVER_S390X_DIGEST=$(shell $(COMMAND) run skopeo:latest --override-os linux inspect --creds $(MQ_ARCHIVE_REPOSITORY_USER):$(MQ_ARCHIVE_REPOSITORY_CREDENTIAL) docker://$(MQ_IMAGE_ADVANCEDSERVER_S390X) | jq -r .Digest))
	$(info $(shell printf "** Determined the built $(MQ_IMAGE_ADVANCEDSERVER_AMD64) has a digest of $(MQ_IMAGE_ADVANCEDSERVER_AMD64_DIGEST)**"$(END)))
	$(info $(shell printf "** Determined the built $(MQ_IMAGE_ADVANCEDSERVER_S390X) has a digest of $(MQ_IMAGE_ADVANCEDSERVER_S390X_DIGEST)**"$(END)))
ifneq "$(LTS)" "true"
	$(info $(shell printf "** Calling script to create fat-manifest for $(MQ_IMAGE_DEVSERVER_MANIFEST)**"$(END)))
	echo $(shell ./travis-build-scripts/create-manifest-list.sh -r $(MQ_DELIVERY_REGISTRY_HOSTNAME) -n $(MQ_DELIVERY_REGISTRY_NAMESPACE) -i $(MQ_IMAGE_DEVSERVER) -t $(MQ_MANIFEST_TAG) -u $(MQ_ARCHIVE_REPOSITORY_USER) -p $(MQ_ARCHIVE_REPOSITORY_CREDENTIAL)  -d "$(MQ_IMAGE_DEVSERVER_AMD64_DIGEST) $(MQ_IMAGE_DEVSERVER_S390X_DIGEST)" $(END))
endif
	$(info $(shell printf "** Calling script to create fat-manifest for $(MQ_IMAGE_ADVANCEDSERVER_MANIFEST)**"$(END)))
	echo $(shell ./travis-build-scripts/create-manifest-list.sh -r $(MQ_DELIVERY_REGISTRY_HOSTNAME) -n $(MQ_DELIVERY_REGISTRY_NAMESPACE) -i $(MQ_IMAGE_ADVANCEDSERVER) -t $(MQ_MANIFEST_TAG) -u $(MQ_ARCHIVE_REPOSITORY_USER) -p $(MQ_ARCHIVE_REPOSITORY_CREDENTIAL) -d "$(MQ_IMAGE_ADVANCEDSERVER_AMD64_DIGEST) $(MQ_IMAGE_ADVANCEDSERVER_S390X_DIGEST)" $(END))

.PHONY: build-skopeo-container
build-skopeo-container:
	$(COMMAND) images | grep -q "skopeo"; if [ $$? != 0 ]; then docker build -t skopeo:latest ./docker-builds/skopeo/; fi

.PHONY: clean
clean:
	rm -rf ./coverage
	rm -rf ./build
	rm -rf ./deps

.PHONY: install-build-deps
install-build-deps:
	ARCH=$(ARCH) ./install-build-deps.sh

.PHONY: install-credential-helper
install-credential-helper:
ifeq ($(ARCH),amd64)
	ARCH=$(ARCH) ./travis-build-scripts/install-credential-helper.sh
endif

.PHONY: build-cov
build-cov:
	mkdir -p build
	cd build; go test -c -covermode=count ../cmd/runmqserver

.PHONY: precommit
precommit: fmt lint

.PHONY: fmt
fmt: $(addsuffix /$(wildcard *.go), $(GO_PKG_DIRS))
	go fmt $(addsuffix /..., $(GO_PKG_DIRS))

.PHONY: lint
lint: $(addsuffix /$(wildcard *.go), $(GO_PKG_DIRS))
	@# This expression is necessary because /... includes the vendor directory in golint
	@# As of 11/04/2018 there is an open issue to fix it: https://github.com/golang/lint/issues/320
	golint -set_exit_status $(sort $(dir $(wildcard $(addsuffix /*/*.go, $(GO_PKG_DIRS)))))

.PHONY: gosec
gosec:
	$(info $(SPACER)$(shell printf "Running gosec test"$(END)))
	@gosec -fmt=json -out=gosec_results.json cmd/... internal/... 2> /dev/null ;\
	cat "gosec_results.json" ;\
	cat gosec_results.json | grep HIGH | grep severity > /dev/null ;\
	if [ $$? -eq 0 ]; then \
		printf "\nFAILURE: gosec found files containing HIGH severity issues - see results.json\n" ;\
		exit 1 ;\
	else \
		printf "\ngosec found no HIGH severity issues\n" ;\
	fi ;\
	cat gosec_results.json | grep MEDIUM | grep severity > /dev/null ;\
	if [ $$? -eq 0 ]; then \
		printf "\nFAILURE: gosec found files containing MEDIUM severity issues - see results.json\n" ;\
		exit 1 ;\
	else \
		printf "\ngosec found no MEDIUM severity issues\n" ;\
	fi ;\
	cat gosec_results.json | grep LOW | grep severity > /dev/null;\
	if [ $$? -eq 0 ]; then \
		printf "\nFAILURE: gosec found files containing LOW severity issues - see results.json\n" ;\
		exit 1;\
	else \
		printf "\ngosec found no LOW severity issues\n" ;\
fi ;\

include formatting.mk

.PHONY: update-release-information
update-release-information:
	sed -i.bak 's/ARG MQ_URL=.*-LinuxX64.tar.gz"/ARG MQ_URL="https:\/\/public.dhe.ibm.com\/ibmdl\/export\/pub\/software\/websphere\/messaging\/mqadv\/$(MQ_VERSION)-IBM-MQ-Advanced-for-Developers-Non-Install-LinuxX64.tar.gz"/g' Dockerfile-server && rm Dockerfile-server.bak
	$(eval MQ_VERSION_1=$(shell echo '${MQ_VERSION}' | rev | cut -c 3- | rev))
	sed -i.bak 's/IBM_MQ_.*_LINUX_X86-64_NOINST.tar.gz/IBM_MQ_${MQ_VERSION_1}_LINUX_X86-64_NOINST.tar.gz/g' docs/building.md && rm docs/building.md.bak
	sed -i.bak 's/ibm-mqadvanced-server:.*-amd64/ibm-mqadvanced-server:$(MQ_VERSION)-amd64/g' docs/security.md
	sed -i.bak 's/ibm-mqadvanced-server-dev.*-amd64/ibm-mqadvanced-server-dev:$(MQ_VERSION)-amd64/g' docs/security.md && rm docs/security.md.bak
	sed -i.bak 's/MQ_IMAGE_ADVANCEDSERVER=ibm-mqadvanced-server:.*-amd64/MQ_IMAGE_ADVANCEDSERVER=ibm-mqadvanced-server:$(MQ_VERSION)-amd64/g' docs/testing.md && rm docs/testing.md.bak
	$(eval MQ_VERSION_2=$(shell echo '${MQ_VERSION_1}' | rev | cut -c 3- | rev))
	sed -i.bak 's/knowledgecenter\/SSFKSJ_.*\/com/knowledgecenter\/SSFKSJ_${MQ_VERSION_2}.0\/com/g' docs/usage.md && rm docs/usage.md.bak
	$(eval MQ_VERSION_3=$(shell echo '${MQ_VERSION_1}' | sed "s/\.//g"))
	sed -i.bak 's/MQ_..._ARCHIVE_REPOSITORY/MQ_${MQ_VERSION_3}_ARCHIVE_REPOSITORY/g' .travis.yml && rm .travis.yml.bak
