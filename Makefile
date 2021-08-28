APP := fiddle
VERSION := $(shell git describe --tags --always)
MAINTAINER := $(shell git log -1 --pretty=format:'%ae')
# can use to set registry, e.g. make build IMAGE=your/fq/image
IMAGE ?= $(APP)


.PHONY: run test lint clean docker-build docker-run
.DEFAULT_GOAL := run

run: lint test
	@poetry run fiddle

test: lint
	@poetry run pytest

lint:
	@echo "Running Flake8 against source and test files..."
	@poetry run flake8
	@echo "Running Bandit against source files..."
	@poetry run bandit -r --ini setup.cfg

clean:
	rm -rf .pytest_cache .coverage fiddle/__pycache__ tests/__pycache__

docker-build:
	@echo "Building Docker image with labels:"
	@echo "Name        : $(APP)"
	@echo "Version     : $(VERSION)"
	@echo "Maintainer  : $(MAINTAINER)"
	@echo "Image       : $(IMAGE):$(VERSION)"
	@sed -e 's|{NAME}|$(APP)|g' \
	     -e 's|{MAINTAINER}|$(MAINTAINER)|g' \
		 -e 's|{VERSION}|$(VERSION)|g' Dockerfile | \
 		 docker build -t $(IMAGE):$(VERSION) -f- .
	@docker tag $(IMAGE):$(VERSION) $(IMAGE):latest

docker-run: docker-build
	@echo "Launching shell in $(IMAGE):$(VERSION) container ..."
	@docker run -it --rm                                            \
		--entrypoint /bin/bash                                      \
		--name $(APP)                                               \
		$(IMAGE):$(VERSION)

scan: docker-build
	@echo "Running trivy scan of $(IMAGE):$(VERSION) container ..."
	@trivy image --severity=HIGH,CRITICAL $(IMAGE):$(VERSION)
