# Redirect restore cluster to stable Phase 2 workspace to preserve state link
    if ($cluster_name -eq "aks-bfhaks-ihub-eus2-dev-rst-01") {
        $tfc_workspace_phase2 = "ws-bfhaks-ihub_workloads-dev-eus2-phase2"
        Write-Host "##[warning]Redirecting restore cluster to stable Dev Phase 2 workspace."
    } else {
        $tfc_workspace_phase2 = $tfc_workspace_phase1 -replace "phase1$", "phase2-$cluster_name"
    }
