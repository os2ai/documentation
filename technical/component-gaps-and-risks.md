---
title: Component Gaps and Risks
parent: Technical documentation
---

# Component Gaps and Risks

Companion to the [Component Catalog](component-catalog.md): the places where current
practice violates the catalog's procedures, and who actually maintains each area.

## Known gaps and risks

These violate the pinning rule of the catalog and are the first candidates for procedure
hardening:

| Gap | Evidence | Consequence / action |
|---|---|---|
| `ghcr.io/aarhusai/tika:latest` and `lmcache/lmstack-router:latest` are floating tags | `applications/tika/values.yaml`, `applications/vllm/values.yaml` | Node pulls silently change behavior; pin an immutable tag/digest on next touch. |
| LiteLLM `main-stable` is a moving tag | `litellm-values.yaml` | Accepted for now; security events force digest pins (done once: helm-deployments#75/#76). Track helm-deployments#78 (migrate off the itk-dev chart fork). |
| No publishing CI for: search-agent (PR #8 open), tika (`tika-docker`), doc-ingestion-route (`itkdev` Docker Hub, no CI in repo) | repo listings | Images can only be produced by specific individuals with registry credentials; finish search-agent#8 and give tika/doc-ingestion the same tag-triggered CI as adgangskomponent. |
| search-agent image namespace split: code in `os2ai/search-agent`, images still `ghcr.io/aarhusai/...` | `applications/search-agent/values.yaml`, search-agent#8 | Every consumer must be migrated when the namespace flips; do it inside one platform release. |
| Demo leads template (kube-prometheus-stack 88.6.1 vs 73.2.2, extra blackbox-exporter + Slack alerting) | `demo-gitops/applications/prometheus-stack/Chart.yaml` | Template-only changes are untested against what demo actually runs; fold demo's deltas back into the template or document them as demo-specific. |
| Upgrading docs still describe `aarhusai-docker` as step 1 of the release process | `installation/upgrading.md` | Reconcile with builder (the catalog reflects builder as the actual build path). |

## Ownership notes

Release/build activity concentrates in a few core-team accounts (builder, helm-deployments bumps, release
issues helm-deployments#91/#92); chart and image publishing for `litellm`, `searxng`, `doc-ingestion` sits
with itk-dev (`itk-dev/helm-charts` workflows, `itkdev` Docker Hub); documentation in the
docs team. Org teams: `itk`, `deranged`, `docs`. Adgangskomponent and search-agent have a
single primary maintainer each - a bus-factor item the CI gaps above make worse.
