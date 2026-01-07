This summary highlights **what actually matters** when upgrading from **Istio 1.26 to 1.27**, focusing on **impact and required actions** for AKS / production environments.

---

### High-Level Changes

| Area               | Change in 1.27                                          | Impact                                          |
| ------------------ | ------------------------------------------------------- | ----------------------------------------------- |
| Traffic Management | TrafficDistribution, retry budgets, multi-cert gateways | More control, possible routing behavior changes |
| Security           | Stable ClusterTrustBundle, CRL, PQC TLS                 | Stronger zero-trust security                    |
| Sidecars           | **Native sidecars enabled by default**                  | Potential breaking change                       |
| Telemetry          | **Lightstep & OpenCensus removed**                      | Migration required                              |
| Ambient Mesh       | Improved CNI, nftables, ServiceScope                    | More stable ambient mode                        |
| Installation       | Cleaner Helm defaults                                   | Easier operations                               |
| istioctl           | More flags & richer output                              | Better troubleshooting                          |

---

## Key Changes & Required Actions

### 1. Native Sidecars Enabled by Default (Major Change)

**What changed**

* `ENABLE_NATIVE_SIDECARS=true` by default
* `istio-proxy` now runs as an **init container**

**Impact**

* Mutating webhooks or controllers that expect `istio-proxy` as a normal container **may break**

**Mitigation (per workload if needed):**

```yaml
sidecar.istio.io/native-side: "false"
```

**Strongly recommended testing**

* OPA / Kyverno
* Security scanners
* Custom mutating webhooks

---

### 2. Gateway: Multiple Certificates Support

**What changed**

* Gateways can now serve **RSA and ECDSA certificates simultaneously**

**Impact**

* Better TLS performance and broader client compatibility

**Action**

* No breaking change
* Optional enhancement

---

### 3. Telemetry Providers Removed

**What changed**

* Lightstep and OpenCensus fully removed

**Impact**

* Existing telemetry configurations may stop working

**Action**

* Migrate to **OpenTelemetry**
* Validate tracing and access logs

---

### 4. TrafficDistribution Behavior Changes

**What changed**

* New traffic distribution modes:

  * PreferClose
  * PreferSameNode
  * PreferSameZone
* Subzones ignored when PreferClose is used

**Impact**

* Traffic routing behavior may change in multi-AZ or latency-sensitive services

**Action**

* Review services using `trafficDistribution`

---

### 5. Retry Budgets Added

**What changed**

* Retry budgets added to DestinationRule

**Impact**

* Prevents retry storms and protects upstream services

**Action**

* Recommended for high-throughput services

---

### 6. Ambient Mesh & CNI Improvements

**What changed**

* nftables support
* Improved CNI ownership model
* Stability fixes for ztunnel and pod lifecycle

**Impact**

* More stable ambient mesh
* Reduced traffic bypass risk

**Optional**

* Enable nftables only if kernel supports it

---

### 7. Security Enhancements

**New in 1.27**

* Stable ClusterTrustBundle API
* Certificate Revocation Lists (CRL)
* External SDS providers
* Post-Quantum TLS (PQC compliance policy)

**Impact**

* Stronger security posture, especially for regulated environments

---





👍
