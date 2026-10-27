```
Hi Gabriel, good afternoon.

1. The failure. Yes, you’re right: the PERF apply in Release-1132 stops on “already exists”. Terraform tries to create 10 ARM deployments in rg-ads-cus-entbusops-perf-ext-apim-001 that already exist there in Failed state from earlier runs (2026-09-22 and 2026-10-09), so it can’t create them. They aren’t in the Terraform state. The original deployments failed for two reasons:

Path conflicts with existing APIs: madeOffer5xAks, madeOffer6xAks, prescreen5xAks, prescreen6xAks and wcclientaccessAks use paths that existing PERF APIs already use.
Missing named values: RATELIMIT-OLPS (prescreen6r2Aks), RATELIMIT-PRESCREENACCEPTANCE (prescreenAcceptance6xAks, 7xAks, 7xr2Aks) and RATELIMIT-CREDITBUREAU (creditbureau) are used in policies but weren’t found in PERF APIM.

These need fixing on your side (paths or version set, and the named values), then the failed deployments cleared or imported, and the release re-run. The run used build 185668.

2. Transactions API. There’s no API named or pathed Transactions in PERF APIM, and none in what Release-1132 deploys. If you mean a transactions operation inside an existing API, such as the Digital API Account or Digital API Rewards API, let us know which one and we’ll check it. The PERF gateway base is https://apim-ads-cus-entbusops-perf-ext-apim-001.azure-api.net, and the endpoint path would be added to that.
```
