---
title: Authentik
parent: Installation
has_children: false
nav_order: 4
---

# Authentik (optional)

Only for internal SSO.

## ArgoCD

argo-cd/templates/sealed-oidc-authentik-client-secret.yaml

```yaml
---
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  creationTimestamp: null
  name: oidc-authentik-client-secret
  namespace: argo-cd
spec:
  encryptedData:
    oidc.authentik.clientSecret: <REGEN>
  template:
    metadata:
      creationTimestamp: null
      labels:
        app.kubernetes.io/part-of: argocd
      name: oidc-authentik-client-secret
      namespace: argo-cd
    type: Opaque
```

Configuration to change in `applications/argo-cd/values.yaml`:

```yaml
global:
  configs:
    cm:
      oidc.config: |
        name: OS2ai SSO
        issuer: https://auth.<FQDN>/application/o/argocd-kom1/
        clientID: <REGEN>
        clientSecret: $oidc-authentik-client-secret:oidc.authentik.clientSecret
        requestedScopes: [openid, profile, email, groups]
```

## Grafana/Prometheus

prometheus-stack/templates/sealed-auth-generic-oauth-secret.yaml

```yaml
---
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  creationTimestamp: null
  name: auth-generic-oauth-secret
  namespace: monitoring
spec:
  encryptedData:
    client_id: <REGEN>
    client_secret: <REGEN>
  template:
    metadata:
      creationTimestamp: null
      name: auth-generic-oauth-secret
      namespace: monitoring
    type: Opaque
```

prometheus-stack/values.yaml

```yaml
grafana.ini:
  server:
    auth.basic:
      disable_login_form: true
    auth:
      signout_redirect_url: https://auth.<FQDN>/application/o/grafana-kom1/end-session/
      oauth_auto_login: true
    auth.generic_oauth:
      name: OS2ai SSO
      enabled: true
      client_id: $__file{/etc/secrets/auth_generic_oauth/client_id}
      client_secret: $__file{/etc/secrets/auth_generic_oauth/client_secret}
      scopes: openid profile email
      auth_url: https://auth.<FQDN>/application/o/authorize/
      token_url: https://auth.<FQDN>/application/o/token/
      api_url: https://auth.<FQDN>/application/o/userinfo/
      # Optionally map user groups to Grafana roles
      role_attribute_path: contains(groups, 'grafana') && 'Admin' || 'Viewer'
extraSecretMounts:
  - name: auth-generic-oauth-secret-mount
    secretName: auth-generic-oauth-secret
    defaultMode: 0440
    mountPath: /etc/secrets/auth_generic_oauth
    readOnly: true
```
