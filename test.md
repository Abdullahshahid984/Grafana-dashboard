kubectl get pods -n api-profile-v1 -l app=apiprofile -o custom-columns=NAME:.metadata.name,AGE:.metadata.creationTimestamp,NODE:.spec.nodeName | Sort-Object
