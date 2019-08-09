.PHONY: build

build: builder

builder:
	docker build -t mini-oio/builder .
