.PHONY: check ci hypr-check zsh-check nvim-check fmt build-iso build-noctalia-slow switch build push status host-age sops-check backup-configs

check:
	ALLOW_DIRTY=1 ./scripts/ci.sh

ci:
	./scripts/ci.sh --full

hypr-check:
	./scripts/hypr-check.sh

zsh-check:
	./scripts/zsh-check.sh

nvim-check:
	./scripts/nvim-check.sh

fmt:
	nix fmt

build-iso:
	./scripts/guard-gaming.sh
	nix build .#iso-custom -o result-iso-custom --max-jobs 1 --cores 1

build-noctalia-slow:
	./scripts/guard-gaming.sh
	./scripts/build-slow.sh nix build --no-link .#nixosConfigurations.MagicBook.config.home-manager.users.Michael.programs.noctalia.package --max-jobs 1 --cores 1

switch:
	./scripts/deploy.sh switch

build:
	./scripts/deploy.sh build

push:
	./scripts/push.sh

status:
	./scripts/status.sh

host-age:
	./scripts/host-age.sh

sops-check:
	./scripts/sops-check.sh

backup-configs:
	./scripts/backup-manual-configs.sh
