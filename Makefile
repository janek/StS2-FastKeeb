SHELL := /bin/sh
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

.PHONY: build install clean restore open-mods-dir open-game restart-game tail-logs wipe-mods wipe-all-mods

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
		open "$(STS2_DIR)/SlayTheSpire2.app/Contents/MacOS/mods" ; \
	else \
		xdg-open "$(STS2_DIR)/mods" ; \
	fi

# Kill the game if running, then launch it (default install paths)
open-game:
	@APPID="$(STEAM_APPID)"; \
	if [ -z "$$APPID" ] && [ -f "$(STS2_DIR)/steam_appid.txt" ]; then APPID="`cat \"$(STS2_DIR)/steam_appid.txt\"`"; fi; \
	if [ "$(OS)" = "Windows_NT" ]; then \
		cmd /c taskkill /IM SlayTheSpire2.exe /F || true ; \
		if [ -n "$$APPID" ]; then \
			cmd /c start "" "steam://run/$$APPID" ; \
		else \
			cmd /c start "" "$(STS2_DIR)\\SlayTheSpire2.exe" ; \
		fi ; \
	elif [ "`uname`" = "Darwin" ]; then \
		pkill -f "Slay.*Spire.*2" || true ; \
		if [ -z "$$APPID" ]; then APPID="2868840" ; fi ; \
		if [ -n "$$APPID" ]; then \
			open -a "Steam" --args -applaunch "$$APPID" ; \
		else \
			open "$(STS2_DIR)/SlayTheSpire2.app" ; \
		fi ; \
	else \
		pkill -f "Slay.*Spire.*2" || true ; \
		if [ -z "$$APPID" ]; then APPID="2868840" ; fi ; \
		if [ -n "$$APPID" ]; then \
			xdg-open "steam://run/$$APPID" 2>/dev/null || steam -applaunch "$$APPID" ; \
		else \
			nohup "$(STS2_DIR)/SlayTheSpire2.x86_64" >/dev/null 2>&1 & \
		fi ; \
	fi

# Alias
restart-game: open-game

# Wipe only this mod's folder from the game's mods directory, then recreate it
wipe-mods:
	@if [ "$(OS)" = "Windows_NT" ]; then \
		cmd /c rmdir /S /Q "$(STS2_DIR)\\mods\\FastKeeb" 2>NUL || true & \
		cmd /c mkdir "$(STS2_DIR)\\mods\\FastKeeb" ; \
	elif [ "`uname`" = "Darwin" ]; then \
		MODDIR="$(STS2_DIR)/SlayTheSpire2.app/Contents/MacOS/mods/FastKeeb" ; \
		rm -rf "$$MODDIR" && mkdir -p "$$MODDIR" ; \
	else \
		MODDIR="$(STS2_DIR)/mods/FastKeeb" ; \
		rm -rf "$$MODDIR" && mkdir -p "$$MODDIR" ; \
	fi

# Danger: wipes entire mods directory. Use make CONFIRM=1 wipe-all-mods
wipe-all-mods:
	@if [ "$(CONFIRM)" != "1" ]; then \
		echo "Refusing to wipe all mods without CONFIRM=1" ; exit 2 ; \
	fi
	@if [ "$(OS)" = "Windows_NT" ]; then \
		cmd /c rmdir /S /Q "$(STS2_DIR)\\mods" 2>NUL || true & \
		cmd /c mkdir "$(STS2_DIR)\\mods" ; \
	elif [ "`uname`" = "Darwin" ]; then \
		DIR="$(STS2_DIR)/SlayTheSpire2.app/Contents/MacOS/mods" ; \
		rm -rf "$$DIR" && mkdir -p "$$DIR" ; \
	else \
		DIR="$(STS2_DIR)/mods" ; \
		rm -rf "$$DIR" && mkdir -p "$$DIR" ; \
	fi

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
