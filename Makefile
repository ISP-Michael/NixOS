.PHONY: check ci fmt build-iso switch build push status

check:
	ALLOW_DIRTY=1 ./scripts/ci.sh

ci:
	./scripts/ci.sh

fmt:
	nix fmt

build-iso:
	nix build .#iso-custom -o result-iso-custom --max-jobs 1 --cores 1

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
