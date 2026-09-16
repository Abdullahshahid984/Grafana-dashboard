# Redirect restore cluster to stable Phase 2 workspace to preserve state link
    if ($cluster_name -match "-rst-") {
        if ($cluster_name -match "-(dev|sit|uat|perf|prd)-") {
            $environment = $matches[1]
            $tfc_workspace_phase2 = $tfc_workspace_phase1 -replace "phase1$", "phase2-aks-bfhaks-ihub-eus2-$environment-01"
            Write-Host "##[warning]RST cluster detected: Using original environment workspace"
        } else {
            Write-Host "##[error]Could not extract environment from RST cluster: $cluster_name"
            exit 1
        }
    } else {
        $tfc_workspace_phase2 = $tfc_workspace_phase1 -replace "phase1$", "phase2-$cluster_name"
    }
