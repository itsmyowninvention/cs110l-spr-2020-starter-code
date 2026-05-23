SRCS = $(wildcard *.c)
PROGS = $(patsubst %.c,%,$(SRCS))

all: $(PROGS)

%: %.c
	$(CC) $(CFLAGS) -o $@ $<

clean:
	rm -f $(PROGS)

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
