JSONNET_FMT := jsonnet fmt -n 2 --max-blank-lines 2 --string-style s --comment-style s

JB_BINARY := $(GOPATH)/bin/jb
EMBEDMD_BINARY := $(GOPATH)/bin/embedmd

all: generate fmt test

hack/jsonnet-docker-image: scripts/jsonnet/Dockerfile
# Create empty target file, for the sole purpose of recording when this target
# was last executed via the last-modification timestamp on the file. See
# https://www.gnu.org/software/make/manual/make.html#Empty-Targets
	docker build -f - -t po-jsonnet . < scripts/jsonnet/Dockerfile
	touch $@

generate-in-docker: hack/jsonnet-docker-image
	@echo ">> Compiling assets and generating Kubernetes manifests"
	docker run \
	--rm \
	-u=$(shell id -u $(USER)):$(shell id -g $(USER)) \
	-v $$PWD:/go/src/github.com/coreos/kube-prometheus/ \
	-v $(shell go env GOCACHE):/.cache/go-build \
	--workdir /go/src/github.com/coreos/kube-prometheus \
	po-jsonnet make generate

generate: manifests **.md

# **.md: $(EMBEDMD_BINARY) $(shell find examples) build.sh example.jsonnet
# 	$(EMBEDMD_BINARY) -w `find . -name "*.md" | grep -v vendor`

manifests: vendor example.jsonnet build.sh
	rm -rf manifests
	./build.sh ./examples/kustomize.jsonnet

fmt:
	find . -name 'vendor' -prune -o -name '*.libsonnet' -o -name '*.jsonnet' -print | \
		xargs -n 1 -- $(JSONNET_FMT) -i

test-e2e:
	go test -timeout 55m -v ./tests/e2e -count=1

test-in-docker: hack/jsonnet-docker-image
	@echo ">> Compiling assets and generating Kubernetes manifests"
	docker run \
	--rm \
	-u=$(shell id -u $(USER)):$(shell id -g $(USER)) \
	-v $$PWD:/go/src/github.com/coreos/kube-prometheus/ \
	-v $(shell go env GOCACHE):/.cache/go-build \
	--workdir /go/src/github.com/coreos/kube-prometheus \
	po-jsonnet make test

build: remove
	$(MAKE) compile

compile: 
	jsonnet -J vendor -m manifests orangesys.jsonnet | xargs -I{} sh -c 'cat {} | gojsontoyaml > {}.yaml; rm -f {}' -- {}

remove:
	rm -rf manifests && mkdir manifests

init:
	rm -rvf vendor
	jb install

.PHONY: generate generate-in-docker test test-in-docker fmt build compile init remove
