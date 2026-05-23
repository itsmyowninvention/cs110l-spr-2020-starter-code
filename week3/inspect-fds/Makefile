SRCS := $(wildcard *.c)
INSPECT_FDS := target/debug/inspect-fds
PROGS := $(patsubst %.c,%,$(SRCS)) $(INSPECT_FDS)

UNAME_S := $(shell uname -s)

all: $(PROGS)

# ---------------------------------------------------------------------------
# macOS: 通过 Docker 进入 NixOS 环境进行构建
# ---------------------------------------------------------------------------
ifeq ($(UNAME_S),Darwin)

DOCKER_FLAGS = --rm \
	-v nix_store_volume:/nix \
	-v $(shell pwd)/../..:/cs110l-spr-2020-starter-code \
	-w /cs110l-spr-2020-starter-code/week3/inspect-fds

NIX_FLAGS = --extra-experimental-features nix-command \
	--extra-experimental-features flakes

NIX_DEVELOP = docker run $(DOCKER_FLAGS) nixos/nix \
	nix develop /cs110l-spr-2020-starter-code $(NIX_FLAGS)

%: %.c
	$(NIX_DEVELOP) --command sh -c '$$CC $$CFLAGS -o $@ $<'

$(INSPECT_FDS):
	$(NIX_DEVELOP) --command sh -c 'cargo build'

shell:
	@docker run -it $(DOCKER_FLAGS) nixos/nix \
	nix develop /cs110l-spr-2020-starter-code $(NIX_FLAGS)

# ---------------------------------------------------------------------------
# Linux / NixOS: 直接构建
# ---------------------------------------------------------------------------
else

%: %.c
	$(CC) $(CFLAGS) -o $@ $<

$(INSPECT_FDS):
	cargo build

endif

clean:
	rm -f $(PROGS) inspect-fds
	cargo clean

.PHONY: all clean shell
