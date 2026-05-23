SRCS = $(wildcard *.c)
PROGS = $(patsubst %.c,%,$(SRCS))

UNAME_S := $(shell uname -s)

# ---------------------------------------------------------------------------
# macOS: 通过 Docker 进入 NixOS 环境进行构建
# ---------------------------------------------------------------------------
ifeq ($(UNAME_S),Darwin)

DOCKER_RUN = docker run \
	--rm \
	-v nix_store_volume:/nix \
	-v $(shell pwd)/../..:/cs110l-spr-2020-starter-code \
	-w /cs110l-spr-2020-starter-code \
	nixos/nix

NIX_DEVELOP = $(DOCKER_RUN) \
	nix develop \
	--extra-experimental-features nix-command \
	--extra-experimental-features flakes

all: $(PROGS)

# $$CC / $$CFLAGS 由 Nix 环境展开，$@ / $< 由 Make 展开
%: %.c
	$(NIX_DEVELOP) --command sh -c 'cd week3/inspect-fds && $$CC $$CFLAGS -o $@ $<'

clean:
	$(NIX_DEVELOP) --command sh -c 'cd week3/inspect-fds && rm -f $(PROGS)'

shell:
	@docker run \
	-it \
	--rm \
	-v nix_store_volume:/nix \
	-v $(shell pwd)/../..:/cs110l-spr-2020-starter-code \
	-w /cs110l-spr-2020-starter-code \
	nixos/nix \
	nix develop \
	--extra-experimental-features nix-command \
	--extra-experimental-features flakes

# ---------------------------------------------------------------------------
# Linux / NixOS: 直接构建
# ---------------------------------------------------------------------------
else

all: $(PROGS)

%: %.c
	$(CC) $(CFLAGS) -o $@ $<

clean:
	rm -f $(PROGS)

endif

.PHONY: all clean shell
