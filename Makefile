VERSION ?= v1.8.6
# DOCKER is the docker image repo we need to push to.
DOCKER ?= ghcr.io/aws/aws-cloud-map-mcs-controller-for-k8s/coredns-multicluster
NAME:=coredns
LDFLAGS := "-s -w -X github.com/coredns/coredns/coremain.GitCommit=$(COMMIT)"
LINUX_ARCH:=amd64 arm arm64
SOURCE_DIRS = .
DOCKER_IMAGE_NAME:=$(DOCKER)/$(NAME)
DOCKER_IMAGE_LIST_VERSIONED:=$(shell echo $(LINUX_ARCH) | sed -e "s~[^ ]*~$(DOCKER_IMAGE_NAME)\-&:$(VERSION)~g")
DOCKER_IMAGE_LIST_LATEST:=$(shell echo $(LINUX_ARCH) | sed -e "s~[^ ]*~$(DOCKER_IMAGE_NAME)\-&:latest~g")

.PHONY: test pretty mod tidy build
test:
	CGO_ENABLED=0 go test $(shell go list ./... | grep -v /vendor/|xargs echo) -cover -coverprofile=cover.out

mod:
	go mod download

tidy:
	go mod tidy

pretty:
	gofmt -l -s -w $(SOURCE_DIRS)

build:
	for arch in $(LINUX_ARCH); do \
		mkdir -p bin/$${arch}; \
		CGO_ENABLED=0 GOOS=linux GOARCH=$${arch} go build -v -o bin/$${arch}/coredns -ldflags=$(LDFLAGS) main.go; \
	done

run:
	go run main.go -conf corefile.example -dns.port=10053

package: build docker-build docker-push

docker-build:
	for arch in $(LINUX_ARCH); do \
  		cp Dockerfile bin/$${arch} ; \
	    docker build --platform linux/$${arch} --no-cache -t $(DOCKER_IMAGE_NAME)-$${arch}:$(VERSION) bin/$${arch}  && \
	    docker tag $(DOCKER_IMAGE_NAME)-$${arch}:$(VERSION) $(DOCKER_IMAGE_NAME)-$${arch}:latest ;\
	done

docker-push:
	@echo Pushing: $(VERSION) to $(DOCKER_IMAGE_NAME)
	for arch in $(LINUX_ARCH); do \
		docker push $(DOCKER_IMAGE_NAME)-$${arch}:$(VERSION) ;\
		docker push $(DOCKER_IMAGE_NAME)-$${arch}:latest ;\
	done
	docker manifest create --amend $(DOCKER_IMAGE_NAME):$(VERSION) $(DOCKER_IMAGE_LIST_VERSIONED)
	docker manifest create --amend $(DOCKER_IMAGE_NAME):latest $(DOCKER_IMAGE_LIST_LATEST)
	for arch in $(LINUX_ARCH); do \
		docker manifest annotate --arch $${arch} $(DOCKER_IMAGE_NAME):$(VERSION) $(DOCKER_IMAGE_NAME)-$${arch}:$(VERSION) ;\
		docker manifest annotate --arch $${arch} $(DOCKER_IMAGE_NAME):latest $(DOCKER_IMAGE_NAME)-$${arch}:latest ;\
	done
	docker manifest push --purge $(DOCKER_IMAGE_NAME):$(VERSION)
	docker manifest push --purge $(DOCKER_IMAGE_NAME):latest


.PHONY: clean
clean:
	go clean
	rm -f coredns bin/
