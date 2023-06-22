export LDFLAGS="-w -s"

local: tidy format lint

run:
	@go run -ldflags $(LDFLAGS) -race .

build:
	@go build -ldflags $(LDFLAGS) -o go-app

tidy:
	@go mod tidy

format:
	@terraform fmt ./terraform
	@find . -type f -name '*.go' -not -path './vendor/*' -exec gofmt -s -w {} +
	@find . -type f -name '*.go' -not -path './vendor/*' -exec goimports -w  -local github.com/RashadAnsari {} +

lint:
	@terraform fmt -check ./terraform
	@golangci-lint -c .golangci.yml run ./...

test:
	@go test -ldflags $(LDFLAGS) -v -race -p 1 ./...
