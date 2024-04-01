# Makefile for g11gkeys

# Define installation directories
PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin
SHAREDIR = $(PREFIX)/share
SYSTEMDDIR = $(SHAREDIR)/systemd/user

# Define files to install
BIN_FILE = g11gkeys
SERVICE_FILE = g11gkeys.service

# Targets
.PHONY: build install test clean

build:
	@echo "Building g11gkeys…"
	@cargo build --release

install:
	@echo "Installing files…"
	install -D -m 755 target/release/$(BIN_FILE) $(DESTDIR)$(BINDIR)/$(BIN_FILE)
	install -D -m 644 dist/$(SERVICE_FILE) $(DESTDIR)$(SYSTEMDDIR)/$(SERVICE_FILE)

test:
	@echo "Testing…"
	@cargo test

clean:
	@echo "Cleaning up…"
	@cargo clean
