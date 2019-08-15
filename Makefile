.PHONY: build test

build: builder

builder:
	docker build -t mini-oio/builder .

test:
	./test.sh
