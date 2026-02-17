kubectl label namespace istio-upgrade-testing istio.io/rev=prod-stable



kubectl get ns istio-upgrade-testing --show-labels


kubectl label namespace istio-upgrade-testing istio.io/rev-


kubectl label namespace istio-upgrade-testing istio.io/rev=prod-stable



kubectl rollout restart deployment -n istio-upgrade-testing

