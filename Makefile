DOTNET := $(or $(shell command -v dotnet 2>/dev/null),/opt/homebrew/opt/dotnet@9/libexec/dotnet)
export DOTNET_ROOT := $(dir $(DOTNET))

.PHONY: build install clean restore open-mods-dir-macos open-mods-dir-linux open-mods-dir-windows

build:
	$(DOTNET) build

install:
	$(DOTNET) publish

clean:
	$(DOTNET) clean
	rm -rf bin/ obj/

restore:
	$(DOTNET) restore

# Open the game's mods directory on different platforms
open-mods-dir-macos:
	open "$(HOME)/Library/Application Support/Steam/steamapps/common/Slay the Spire 2/SlayTheSpire2.app/Contents/mods"

open-mods-dir-linux:
	xdg-open "$(HOME)/.local/share/Steam/steamapps/common/Slay the Spire 2/mods"

open-mods-dir-windows:
	start "" "C:\\Program Files (x86)\\Steam\\steamapps\\common\\Slay the Spire 2\\mods"
