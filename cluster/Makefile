CLUSTER_NAME := cka-lab

.PHONY: up down status reset

up:
	kind create cluster --name $(CLUSTER_NAME) --config kind-config.yaml

down:
	kind delete cluster --name $(CLUSTER_NAME)

status:
	kubectl cluster-info --context kind-$(CLUSTER_NAME)
	kubectl get nodes -o wide

reset: down up
