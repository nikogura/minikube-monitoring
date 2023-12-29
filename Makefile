.PHONY: pave
pave:
	@cd resources/kube-prometheus && ./build.sh && cd ../..
	@kubectl apply -f resources/kube-prometheus/generated/setup --server-side=true
	@kubectl apply -f resources/kube-prometheus/generated
	@kubectl apply -k resources/loki
	@kubectl apply -k resources/promtail
	@kubectl apply -f resources/grafana

.PHONY: nuke
nuke:
	@kubectl delete -f resources/grafana
	@kubectl delete -k resources/promtail
	@kubectl delete -k resources/loki
	@kubectl delete -f resources/kube-prometheus/generated
	@kubectl delete -f resources/kube-prometheus/generated/setup

