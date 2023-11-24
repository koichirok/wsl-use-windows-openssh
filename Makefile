prefix ?= /usr
OPENSSH_DIR_SYSTEM ?= /mnt/c/Windows/System32/OpenSSH
OPENSSH_DIR_BETA ?= /mnt/c/Program Files/OpenSSH
OPENSSH_DIR := \
	$(shell PATH="$(OPENSSH_DIR_SYSTEM):$(OPENSSH_DIR_BETA)" c=$$(command -v ssh.exe 2>/dev/null); echo $${c%/*})
OPENSSH_CMDS ?= scp sftp ssh ssh-add ssh-agent ssh-keygen ssh-keyscan

.PHONY: build

build:
ifeq ($(OPENSSH_DIR),)
	@echo "No OpenSSH installation found."
	@false
endif
	@echo "Generating OpenSSH command symlinks..."
	@mkdir -p lib/wsl-ssh
	@for cmd in $(OPENSSH_CMDS); do \
		if [ -x "$(OPENSSH_DIR)/$$cmd.exe" ]; then \
			ln -svf "$(OPENSSH_DIR)/$$cmd.exe" "lib/wsl-ssh/$$cmd"; \
		else \
			echo "$$cmd: $$cmd.exe not found."; \
		fi; \
	done

clean:
	@echo "Removing OpenSSH command symlinks..."
	@rm -vf lib/wsl-ssh/*

install: build
	install -d $(DESTDIR)$(prefix)/bin
	install -m 755 -o root -g root -D bin/* $(DESTDIR)$(prefix)/bin

	install -d $(DESTDIR)/etc/profile.d
	install -m 644 -o root -g root -D etc/profile.d/* $(DESTDIR)/etc/profile.d

	install -d $(DESTDIR)$(prefix)/lib/wsl-ssh
	cp -P lib/wsl-ssh/* $(DESTDIR)$(prefix)/lib/wsl-ssh

	install -d $(DESTDIR)$(prefix)/share/wsl-ssh
	install -m 644 -o root -g root  -D share/wsl-ssh/* $(DESTDIR)$(prefix)/share/wsl-ssh
