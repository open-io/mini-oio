.PHONY: build test

build: builder

builder:
	docker build -t openioci/builder .

test:
	./test.sh
