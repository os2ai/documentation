---
title: Supplier onboarding
parent: Technical documentation
has_children: false
nav_order: 8
---

# Onboarding as a supplier

This page describes one working production architecture for OS2ai as a reference for suppliers setting up their own
installations. It has four parts: a GitOps repository per deployment, provisioned Kubernetes clusters, shared access
services, and a central inference cluster.

## One deployment, one GitOps repository

A deployment of OS2ai is a clone of the [helm-deployments](https://github.com/os2ai/helm-deployments) template held
in the supplier's own repository. ArgoCD bootstraps from it and the applications under `applications/` sync to the
cluster. Nothing else needs to change in the template; the edits a deployment makes are:

| Change | Where |
|--------|-------|
| Hostnames (`ai.<FQDN>`, `adgang.<FQDN>`, `argocd.<FQDN>`, ...) | per-application `values.yaml` |
| ACME issuer contact email | `cert-manager/templates/cluster-issuer.yaml` |
| `repoUrl` pointing at the deployment's own repository, `automated: true` sync | `argo-cd-resources/values.yaml` |
| Sealed secrets with the deployment's own keys (DB, Open WebUI, LiteLLM, search) | `*/templates/sealed-*.yaml` |
| Model routing: which LiteLLM endpoints and keys are used | `litellm/litellm-values.yaml`, `openwebui/values.yaml` |

A real deployment differs from the template in roughly twenty files, all of them these categories. Optional
components are added as new directories under `applications/` plus an ArgoCD application of the same name.

## Clusters

Each deployment runs on its own Kubernetes cluster on VMs you provision yourself, described declaratively in a
manifest that fixes node sizes, network, ingress IPs and storage (block storage for the databases, a shared
filesystem such as Ceph for object stores and model caches). One cluster per customer keeps blast radius, capacity
and network policy per tenant. Shared clusters, managed services, GPU inference, use the same pattern.

## Shared access services

Instead of every deployment running its own access component (Keycloak + adgangskomponent), several instances can be
hosted centrally on a managed-services cluster - one per tenant, each with its own domain and its own CloudNativePG
database cluster. Tenants that want dedicated infrastructure run the `adgangskomponent` application from the template
on their own cluster instead. Both shapes use the same upstream chart.

## Central inference

Model serving does not need to run on every deployment cluster. One option:

- A GPU cluster runs vLLM for the open-weight models.
- A central LiteLLM on that cluster fronts vLLM (and any external providers) and is the single upstream tenants
  call.
- Each deployment keeps its own LiteLLM from the template and lists the central endpoint as the upstream for its
  models (`api_base` plus a per-tenant key held in a sealed secret); Open WebUI keeps pointing at the local
  LiteLLM.
- Tenants are separated with LiteLLM teams (one team per customer, model access per team, budget and spend tracking
  per key).

This keeps GPUs, model updates and rate limiting in one place; deployments stay small and stateless with respect to
models. A deployment that prefers local inference sets the model endpoints in `litellm/values.yaml` to its own
vLLM router instead.

## Staying updated

The template repository is the source of truth for what an installation looks like: releases tag
[helm-deployments](https://github.com/os2ai/helm-deployments) and list every change in its
[CHANGELOG.md](https://github.com/os2ai/helm-deployments/blob/main/CHANGELOG.md), with the release notes under
[releases/](https://os2ai.github.io/documentation/releases/) in these docs. Upgrading a deployment is a manual
port of the new tag onto your repository: re-apply your per-deployment edits from the table above on top of the
update, reading the changelog for anything that touches values or secrets. The full procedure is the
[upgrade guide](installation/upgrading.md).

Because the drift between a deployment and the template is small and mechanical, keeping your changes in the
categories above, and nothing else, is what makes upgrades cheap.

## Contributing back

Fixes and features that belong to OS2ai rather than to one deployment go back upstream as pull requests against
the relevant os2ai repository: chart and configuration changes to helm-deployments, product changes to the
[open-webui fork](https://github.com/os2ai/open-webui) via the patch workflow in
[builder](https://github.com/os2ai/builder), documentation to
[documentation](https://github.com/os2ai/documentation). See
[CONTRIBUTING.md](https://github.com/os2ai/documentation/blob/main/CONTRIBUTING.md) for the DCO sign-off
requirement; helm-deployments additionally requires every pull request to update its CHANGELOG.md, and CI checks
it.

## Checklist for a new supplier

1. Provision a Kubernetes cluster on VMs you control (a small three-node control plane plus workers is enough for
   one tenant; the clusters section above describes the shape and storage each part expects).
2. Fork/clone the helm-deployments template into a repository you own; keep it updated from upstream per the
   [upgrade guide](installation/upgrading.md).
3. Apply the per-deployment edits in the table above: domains, issuer email, repoUrl, your sealed secrets, model
   routing.
4. Decide the two topological questions: run the access component dedicated (template default) or shared, and run
   inference local (vLLM on the deployment cluster) or central (point at a shared LiteLLM).
5. Bootstrap: install ArgoCD as in the template's `applications/argo-cd`, add the sealed-secrets controller keys,
   and let the applications sync.
6. Agree how your deployment's changes flow back upstream, per the contributing section above.

## This is still moving

OS2ai is young and the packaging is not settled. The layout described here - a template you clone and operate by
hand is a candidate for replacement by a single wrapper whose `values.yaml` is the only interface, so an
installation says "give me OS2ai" with flags instead of copying repositories. That proposal is open and under
discussion in [helm-deployments#66](https://github.com/os2ai/helm-deployments/issues/66).

Read this page as a description of how production installations work today, not as a contract. Before committing
to an onboarding plan, check the issue and the
[CHANGELOG](https://github.com/os2ai/helm-deployments/blob/main/CHANGELOG.md) for the state of the template, and
expect to port your deployment's edits onto new structures as the project matures.
