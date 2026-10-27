```
$p = (az rest --method get --url "https://management.azure.com/subscriptions/cf7e12f8-ce8c-43c8-a1c0-1287d71499ca/resourceGroups/rg-ads-cus-entbusops-prd-ext-apim-001/providers/Microsoft.ApiManagement/service/apim-ads-cus-entbusops-prd-ext-apim-001/diagnostics/applicationinsights?api-version=2022-08-01" | ConvertFrom-Json).properties
"frontend request : $($p.frontend.request.headers.Count)  (uid: $($p.frontend.request.headers -contains 'uid'), x-b2c-jwt: $($p.frontend.request.headers -contains 'x-b2c-jwt'))"
"frontend response: $($p.frontend.response.headers.Count)"
"backend request  : $($p.backend.request.headers.Count)"
"backend response : $($p.backend.response.headers.Count)"
"sampling: $($p.sampling.percentage)  verbosity: $($p.verbosity)"
```
