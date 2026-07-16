.PHONY: up down status reset

up:
	$(MAKE) -C cluster up

down:
	$(MAKE) -C cluster down

status:
	$(MAKE) -C cluster status

reset:
	$(MAKE) -C cluster reset
