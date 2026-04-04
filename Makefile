DOTNET := $(or $(shell command -v dotnet 2>/dev/null),/opt/homebrew/opt/dotnet@9/libexec/dotnet)
export DOTNET_ROOT := $(dir $(DOTNET))

.PHONY: build install clean restore open-mods-dir-macos open-mods-dir-linux open-mods-dir-windows open-mods-dir open-game

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

# Auto-detect OS to open the mods directory
open-mods-dir:
	@if [ "$(OS)" = "Windows_NT" ]; then \
		cmd /c start "" "C:\\Program Files (x86)\\Steam\\steamapps\\common\\Slay the Spire 2\\mods" ; \
	elif [ "`uname`" = "Darwin" ]; then \
		open "$(HOME)/Library/Application Support/Steam/steamapps/common/Slay the Spire 2/SlayTheSpire2.app/Contents/mods" ; \
	else \
		xdg-open "$(HOME)/.local/share/Steam/steamapps/common/Slay the Spire 2/mods" ; \
	fi

# Kill the game if running, then launch it (default install paths)
open-game:
	@if [ "$(OS)" = "Windows_NT" ]; then \
		cmd /c taskkill /IM SlayTheSpire2.exe /F 2> NUL || exit 0 &> NUL ; \
		cmd /c start "" "C:\\Program Files (x86)\\Steam\\steamapps\\common\\Slay the Spire 2\\SlayTheSpire2.exe" ; \
	elif [ "`uname`" = "Darwin" ]; then \
		pkill -f "Slay.*Spire.*2" || true ; \
		open "$(HOME)/Library/Application Support/Steam/steamapps/common/Slay the Spire 2/SlayTheSpire2.app" ; \
	else \
		pkill -f "Slay.*Spire.*2" || true ; \
		nohup "$(HOME)/.local/share/Steam/steamapps/common/Slay the Spire 2/SlayTheSpire2.x86_64" >/dev/null 2>&1 & ; \
	fi
