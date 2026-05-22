  echo -e "\ninstall cert-manager certificate:\n---"
  EXTRA_SANS_JSON=$(echo "$INSTALL_TARGET" | yq -o json -I=0 '.extra_sans // []')

  BASE=$(yq '
    .spec.commonName = strenv(INGRESS_SUBDOMAIN)
    | .spec.dnsNames = [strenv(INGRESS_SUBDOMAIN), "*."+strenv(INGRESS_SUBDOMAIN)]
  ' < "$ROOTDIR/resources/certificate.yaml.tmpl")

  echo "$BASE" | yq ".spec.dnsNames += $EXTRA_SANS_JSON" \
    > "$STAGEDIR/resources/certificate.yaml"
  cat "$STAGEDIR/resources/certificate.yaml"
