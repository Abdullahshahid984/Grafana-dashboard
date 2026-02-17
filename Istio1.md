kubectl label namespace istio-upgrade-testing istio.io/rev=stable-asm-1-27 --overwrite


kubectl get ns istio-upgrade-testing --show-labels
