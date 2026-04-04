DOTNET := $(or $(shell command -v dotnet 2>/dev/null),/opt/homebrew/opt/dotnet@9/libexec/dotnet)
export DOTNET_ROOT := $(dir $(DOTNET))

.PHONY: build install clean restore

build:
	$(DOTNET) build

install:
	$(DOTNET) publish

clean:
	$(DOTNET) clean
	rm -rf bin/ obj/

restore:
	$(DOTNET) restore
