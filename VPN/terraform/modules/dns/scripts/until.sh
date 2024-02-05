#! /bin/sh
set -e


# Before installing verify that the namespace exists 
istioNamespace="${ISTIO_NAMESPACE:-istio-system}"
if ! kubectl get namespace $istioNamespace; then
    printf "\"%s\" is configured as the namespace to install Istio, it does not exist, cannot install\n" "$istioNamespace"
    exit 1
fi


# Determine if a custom cert is required. If so wait on it to exist
istioWaitForCustomSecret="${ISTIO_CUSTOM_CERT_REQUIRED:-false}"
if [ "$istioWaitForCustomSecret" = true ]; then
    printf "The build script is configured to wait for a custom CA Cert, in the Istio namespace. It will wait until the secret exists for the script is cancelled\n"
    istioCertLink="https://istio.io/v2.8/docs/tasks/security/cert-management/plugin-ca-cert/#plug-in-certificates-and-key-into-the-cluster"
    printf "Additional information regarding the secret format can be found at the following link %s\n" "$istioCertLink"
    until kubectl -n $istioNamespace get secret cacerts; do sleep 2; done
fi
