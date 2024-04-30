ROOT_DIR = $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
REPORTS ?= $(ROOT_DIR)/reports
TEST_FORMAT ?= standard-verbose
GOTEST_FLAGS = --format=$(TEST_FORMAT) -- -count=1 -cover -coverprofile=$(REPORTS)/$(TEST_SCENARIO)_coverage.out
GINKGO_FLAGS = -ginkgo.focus="$(FOCUS)" -ginkgo.v -ginkgo.skip="$(SKIP)" -ginkgo.reportFile=./junit_$(TEST_SCENARIO)_test.xml


all: lint format-check unit-test

lint:
	golangci-lint run -v

format:
	@goimports -w -l src/ || /bin/true

format-check:
	@test -z $(shell $(MAKE) format)

generate:
	go generate $(shell go list ./...)

unit-test:
	$(MAKE) _test TEST_SCENARIO=unit TIMEOUT=30m TEST="$(or $(TEST),$(shell go list ./...))"

_test: $(REPORTS)
	gotestsum $(GOTEST_FLAGS) $(TEST) $(GINKGO_FLAGS) -timeout $(TIMEOUT) || ($(MAKE) _post_test && /bin/false)
	$(MAKE) _post_test

_post_test: $(REPORTS)
	@for name in `find '$(ROOT_DIR)' -name 'junit*.xml' -type f -not -path '$(REPORTS)/*'`; do \
		mv -f $$name $(REPORTS)/junit_$(TEST_SCENARIO)_$$(basename $$(dirname $$name)).xml; \
	done
	$(MAKE) _coverage

$(REPORTS):
	-mkdir -p $(REPORTS)

_coverage: $(REPORTS)
ifeq ($(CI), true)
	gocov convert $(REPORTS)/$(TEST_SCENARIO)_coverage.out | gocov-xml > $(REPORTS)/$(TEST_SCENARIO)_coverage.xml
ifeq ($(TEST_SCENARIO), unit)
	COVER_PROFILE=$(REPORTS)/$(TEST_SCENARIO)_coverage.out ./hack/publish-codecov.sh
endif
endif
