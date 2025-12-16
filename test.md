I investigated the FailedScheduling warning for pod apiprofile-6bc6978d85-9jm4t.
At the time of pod creation, no node had sufficient available CPU/memory, even though all nodes were in Ready state. As a result, the scheduler temporarily marked the pod as unschedulable and retried.
Once capacity became available (or the autoscaler completed its action), the pod was successfully scheduled and is currently running.
The ~2 minute delay aligns with expected behavior under temporary resource pressure in AKS and does not indicate a failure.
