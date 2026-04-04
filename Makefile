.PHONY: build install clean restore

build:
	dotnet build

install:
	dotnet publish

clean:
	dotnet clean
	rm -rf bin/ obj/

restore:
	dotnet restore
