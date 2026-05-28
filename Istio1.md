**1 — Validate manifests**
```
istioctl validate -f <manifest.yaml>
```
```
istioctl validate -f <directory/>
```

**2 — Analyze mesh**
```
istioctl analyze
```
```
istioctl analyze -n <namespace>
```
```
istioctl analyze --verbose -n <namespace>
```
```
istioctl analyze <manifest.yaml>
```

**3 — Proxy status**
```
istioctl proxy-status
```
```
istioctl proxy-status <pod-name>.<namespace>
```

**4 — Proxy config (Envoy internals)**
```
istioctl proxy-config all <pod-name> -n <namespace>
```
```
istioctl proxy-config routes <pod-name> -n <namespace>
```
```
istioctl proxy-config listeners <pod-name> -n <namespace>
```
```
istioctl proxy-config clusters <pod-name> -n <namespace>
```
```
istioctl proxy-config endpoints <pod-name> -n <namespace>
```
```
istioctl proxy-config secret <pod-name> -n <namespace>
```

**5 — Version & install check**
```
istioctl version
```
```
istioctl verify-install
```
```
istioctl ps
```

**6 — Debug / tracing**
```
istioctl proxy-config log <pod-name> -n <namespace> --level debug
```
```
istioctl proxy-config log <pod-name> -n <namespace> --level warning
```
```
istioctl authn tls-check <pod-name> -n <namespace>
```
```
istioctl authn tls-check <pod-name> <service>.<namespace>.svc.cluster.local
```

**7 — ASM / Azure specific**
```
kubectl get ns <namespace> --show-labels
```
```
kubectl get pods -n <namespace> -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.annotations.sidecar\.istio\.io/status}{"\n"}{end}'
```
```
kubectl get pods -n aks-istio-system
```
```
kubectl get pods -n aks-istio-ingress
```
