Here’s a **short and clean version**:

---

## Istio 1.27 – Key Changes (Summary)

### 🔹 Major Changes

**1. Native Sidecars**

* Enabled by default (`ENABLE_NATIVE_SIDECARS=true`)
* `istio-proxy` runs as init container
* May break OPA, Kyverno, security scanners, or custom webhooks
* Disable per workload if needed:
  `sidecar.istio.io/native-side: "false"`
* **Strongly recommended: test before upgrade**

---

**2. Telemetry Removal**

* Lightstep & OpenCensus removed
* **Action:** Migrate to OpenTelemetry

---

**3. Traffic Distribution Updates**

* New modes: `PreferClose`, `PreferSameNode`, `PreferSameZone`
* May change routing in multi-AZ setups
* **Action:** Review affected services

---

**4. Retry Budgets Added**

* Available in `DestinationRule`
* Prevents retry storms
* Recommended for high-traffic services

---

### 🔹 Improvements 

**5. Multiple TLS Certificates in Gateway**

* RSA + ECDSA supported together
* Better performance & compatibility

**6. Ambient Mesh & CNI Enhancements**

* nftables support
* More stable ztunnel
* Reduced traffic bypass risk

**7. Security Enhancements**

* Stable ClusterTrustBundle
* CRL support
* External SDS providers
* Post-Quantum TLS support


