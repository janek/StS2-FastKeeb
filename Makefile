DOTNET := $(or $(shell command -v dotnet 2>/dev/null),/opt/homebrew/opt/dotnet@9/libexec/dotnet)
export DOTNET_ROOT := $(dir $(DOTNET))

# Default Slay the Spire 2 install directory per OS (override with STS2_DIR=...)
UNAME_S := $(shell uname 2>/dev/null)
ifeq ($(OS),Windows_NT)
  STS2_DIR ?= C:\\Program Files (x86)\\Steam\\steamapps\\common\\Slay the Spire 2
else ifeq ($(UNAME_S),Darwin)
  STS2_DIR ?= $(HOME)/Library/Application Support/Steam/steamapps/common/Slay the Spire 2
else
  STS2_DIR ?= $(HOME)/.local/share/Steam/steamapps/common/Slay the Spire 2
endif

.PHONY: build install clean restore open-mods-dir open-game restart-game tail-logs

build:
	$(DOTNET) build

install:
	$(DOTNET) publish

clean:
	$(DOTNET) clean
	rm -rf bin/ obj/

restore:
	$(DOTNET) restore

# Auto-detect OS to open the mods directory
open-mods-dir:
	@if [ "$(OS)" = "Windows_NT" ]; then \
		cmd /c start "" "$(STS2_DIR)\\mods" ; \
	elif [ "`uname`" = "Darwin" ]; then \
		open "$(STS2_DIR)/SlayTheSpire2.app/Contents/mods" ; \
	else \
		xdg-open "$(STS2_DIR)/mods" ; \
	fi

# Kill the game if running, then launch it (default install paths)
open-game:
	@APPID="$(STEAM_APPID)" ; \
	if [ -z "$$APPID" ] && [ -f "$(STS2_DIR)/steam_appid.txt" ]; then APPID="$$(cat "$(STS2_DIR)/steam_appid.txt")" ; fi ; \
	if [ "$(OS)" = "Windows_NT" ]; then \
		cmd /c taskkill /IM SlayTheSpire2.exe /F || true ; \
		if [ -n "$$APPID" ]; then \
			cmd /c start "" "steam://run/$$APPID" ; \
		else \
			cmd /c start "" "$(STS2_DIR)\\SlayTheSpire2.exe" ; \
		fi ; \
	elif [ "`uname`" = "Darwin" ]; then \
		pkill -f "Slay.*Spire.*2" || true ; \
		# Try to autodetect AppID from default Steam library if still empty
		if [ -z "$$APPID" ]; then \
			mf="$$HOME/Library/Application Support/Steam/steamapps" ; \
			mf=$$(grep -l '"installdir"[[:space:]]*"Slay the Spire 2"' "$$mf"/appmanifest_*.acf 2>/dev/null | head -n1) ; \
			if [ -n "$$mf" ]; then APPID="$$(basename "$$mf" | sed -E 's/[^0-9]*([0-9]+).*/\1/')" ; fi ; \
		fi ; \
		if [ -n "$$APPID" ]; then \
			open -a "Steam" --args -applaunch "$$APPID" ; \
		else \
			open "$(STS2_DIR)/SlayTheSpire2.app" ; \
		fi ; \
	else \
		pkill -f "Slay.*Spire.*2" || true ; \
		# Try to autodetect AppID from default Steam library if still empty
		if [ -z "$$APPID" ]; then \
			mf="$$HOME/.local/share/Steam/steamapps" ; \
			mf=$$(grep -l '"installdir"[[:space:]]*"Slay the Spire 2"' "$$mf"/appmanifest_*.acf 2>/dev/null | head -n1) ; \
			if [ -n "$$mf" ]; then APPID="$$(basename "$$mf" | sed -E 's/[^0-9]*([0-9]+).*/\1/')" ; fi ; \
		fi ; \
		if [ -n "$$APPID" ]; then \
			xdg-open "steam://run/$$APPID" 2>/dev/null || steam -applaunch "$$APPID" ; \
		else \
			nohup "$(STS2_DIR)/SlayTheSpire2.x86_64" >/dev/null 2>&1 & ; \
		fi ; \
	fi

# Alias
restart-game: open-game

# Tail the game's Godot log (live)
tail-logs:
	@if [ "$(OS)" = "Windows_NT" ]; then \
		echo "Windows not wired yet. Open %APPDATA%\\Godot\\app_userdata\\SlayTheSpire2\\logs\\godot.log" ; \
		echo "Use: powershell Get-Content -Path \"%APPDATA%\\Godot\\app_userdata\\SlayTheSpire2\\logs\\godot.log\" -Wait" ; \
	elif [ "`uname`" = "Darwin" ]; then \
		LOGFILE="$(HOME)/Library/Application Support/SlayTheSpire2/logs/godot.log" ; \
		if [ -f "$$LOGFILE" ]; then \
			echo "Tailing $$LOGFILE" ; \
			tail -f "$$LOGFILE" ; \
		else \
			echo "Log not found at $$LOGFILE. Launch the game once, then retry." ; \
			exit 2 ; \
		fi ; \
	else \
		LOGFILE="$(HOME)/.local/share/SlayTheSpire2/logs/godot.log" ; \
		if [ -f "$$LOGFILE" ]; then \
			echo "Tailing $$LOGFILE" ; \
			tail -f "$$LOGFILE" ; \
		else \
			echo "Log not found at $$LOGFILE. Launch the game once, then retry." ; \
			exit 2 ; \
		fi ; \
	fi
