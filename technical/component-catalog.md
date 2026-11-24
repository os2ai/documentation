---
title: Component Catalog
parent: Technical documentation
---

# Component Catalog

This is the **service catalog** (ITIL)
for OS2ai. Its purpose is control: every component is classified into one of the categories
below, and every category has a defined procedure for **how and where** its dependencies are
updated.

If you intend to update *something* in OS2ai, find it in the catalog tables, note its update
pattern (e.g. `UP-S1`), and follow that pattern's procedure in the "Update procedures" section.

> Pins listed are from `os2ai/helm-deployments` default branch (`develop`) as of 2026-11-12.
> The in-progress platform release 0.9.0 (release branches `builder@0.13.3`,
> `helm-deployments@0.13.3-1`) bumps the Open WebUI image to `v0.13.3-1`; see
> [Release & propagation](#release--propagation).

## Categories

| Category | Definition | Typical update driver |
|---|---|---|
| **Application** | OS2ai-owned software that delivers end-user-facing platform functionality. Source code lives in an os2ai-owned repository. | Feature/security work in the source repo; upstream changes we choose to absorb. |
| **Application Support** | Services and operators that exist to serve one or more Application components (model serving, gateways, search, document processing, identity, databases, caches). Usually third-party software we only *deploy and configure*. | Upstream releases and security advisories. |
| **Platform** | Cluster-wide infrastructure every tenant gets: GitOps, ingress, certificates, secrets, storage primitives, observability. Contains no OS2ai application logic. | Upstream chart releases; driven by security and cluster lifecycle, not features. |
| **Delivery** | Repositories that *produce or document* releases but are not themselves runtime services of a deployment (build tooling, the GitOps template, reference instances, docs, governance). | Changes to how we build, release, or document. |

Classification rules, in order:

1. Does it run workloads that end users directly interact with, and do we own the source? -> **Application**.
2. Is it deployed to serve an Application component but not user-facing itself? -> **Application Support**.
3. Is it generic cluster infrastructure with no OS2ai-specific logic? -> **Platform**.
4. Does the artifact only take part in building, shipping, or documenting the platform? -> **Delivery**.

Borderline decisions recorded here: `vllm` is Application Support (model serving for
LiteLLM/Open WebUI, not directly user-facing); database/cache operators are Application
Support (they exist to serve specific apps - Open WebUI, LiteLLM, Adgangskomponent - not
generic cluster services); `demo-gitops` is Delivery even though it runs live workloads,
because it is an *instance of* the Platform/Application definitions, not a definition itself.

## Update patterns

Each catalog entry carries one or more update patterns. The pattern tells you *where* the
dependency is defined and *what* to touch.

| Pattern | Meaning |
|---|---|
| **UP-A1** | Application with own repo + own publishing CI: merge in source repo -> tag -> CI publishes image/chart -> bump pin in `helm-deployments`. |
| **UP-A2** | Application with own repo, **manual** image build/push (no release CI yet): same, but the image push is a developer action on a workstation. |
| **UP-A3** | Application that is a **fork of upstream** with a local patch set: rebase patches -> build patched image -> bump pin (the Open WebUI flow, run through `builder`). |
| **UP-S1** | App Support deployed via a **third-party chart** (itk-dev, upstream): bump the dependency `version:` in the wrapper `applications/<app>/Chart.yaml` and/or the image `tag:` in its values file. No source change. |
| **UP-S2** | App Support we build ourselves from a small wrapper repo (image with our tweaks, e.g. Tika's Danish analyzer): rebuild + push image (manual), bump image `tag:` in values. |
| **UP-P1** | Platform component: bump the upstream chart dependency `version:` in the wrapper `applications/<app>/Chart.yaml`, reconcile values against upstream defaults, demo-test, release. |
| **UP-P2** | In-repo-only component (`argo-cd-resources`, `cluster-resources`, our own chart templates): change the manifests/templates in `helm-deployments` (and mirror into tenant instance repos). |
| **UP-D1** | Delivery repo: ordinary PR flow in that repo; no pin to bump, but announce behavior changes in the OS2Samtale release thread where they affect operators. |

Common to **all** patterns touching `helm-deployments` (enforced by the
`changelog.yaml` CI check): every PR must add an entry to `CHANGELOG.md`. Version numbers
used by an update must be **immutable** (no `latest`, no moving branches) - see
[Component Gaps and Risks](component-gaps-and-risks.md).

## Catalog - Application components

| Component | Source of truth (code) | Deployed via | Pinned in | Image/chart | ArgoCD gate | Pattern |
|---|---|---|---|---|---|---|
| **Open WebUI** | `os2ai/open-webui` (fork of `open-webui/open-webui`); patch set managed in `os2ai/builder` | `helm-deployments/applications/openwebui` (wrapper chart) | image tag in `applications/openwebui/values.yaml`; upstream chart deps in `Chart.yaml` | `ghcr.io/os2ai/open-webui:v0.11.3-4` (-> `v0.13.3-1` pending); upstream chart `open-webui 7.7.0`, `qdrant 1.17.1`, CNPG `cluster 0.3.1` | manual (`automated: false`) | UP-A3 |
| **Search Agent** | `os2ai/search-agent` | `helm-deployments/applications/search-agent` (own templates, no upstream dep) | image in `applications/search-agent/values.yaml` | `ghcr.io/aarhusai/search-agent:0.0.5` (namespace migration to `ghcr.io/os2ai/...` in os2ai/search-agent#8, open) | automated | UP-A2 |
| **Adgangskomponent** | `os2ai/adgangskomponent` (FKA <-> OIDC bridge: Keycloak realm bootstrap + admin UI/API) | `helm-deployments/applications/adgangskomponent` | OCI chart dep `adgangskomponent 0.1.0` from `oci://ghcr.io/os2ai/adgangskomponent` in wrapper `Chart.yaml` | chart + `/admin-ui`, `/admin-api` images published by tag-triggered CI in the source repo; CNPG `cluster 0.3.1` | manual (`automated: false`) | UP-A1 |

### Open WebUI (UP-A3 - fork + patch pipeline)

Two sources must stay in sync, so this is the heaviest procedure on the platform:

1. **Rebase the patch set** onto the new upstream tag, in `os2ai/builder` (canonical clone
   `builder/open-webui`): bump `OPEN_WEBUI_VERSION` in `Taskfile.yml`, run
   `task patches:rebase`, `task patches:force`.
2. **Retarget the patch PRs** (`os2ai/open-webui` #1-#7: pinned banner, TTS token, extra
   permissions, oauth-session fix, agentic-search citations, RAG query template,
   prompt-suggestions toggle) onto the new upstream tag, pushing
   `refs/tags/upstream/vX:refs/heads/upstream/vX` first. *Without retargeting, PR diffs
   balloon to all upstream churn and GitHub rejects them.*
3. **Build and push** the image: `task prod:build` -> `ghcr.io/os2ai/open-webui:{upstream-version}-{N}`
   plus `latest` (needs `write:packages` scope; operator-driven, no CI). The counter scheme
   `0.13.3-1 -> 0.13.3-2` is our platform patch level.
4. **Bump the pin** in `helm-deployments/applications/openwebui/values.yaml`
   (`open-webui.image.tag`) - also bump the upstream `open-webui` chart dep in
   `Chart.yaml` when a new chart version is needed. Also mirror into `demo-gitops`.
5. `CHANGELOG.md` entry, cut platform release, follow the RC process below.

Site operators: the ArgoCD app is `automated: false` precisely because upgrades need a
human - read the release notes (e.g. "set replicas to 1 before upgrade" in past releases),
apply the tag bump in your instance repo, and roll back by reverting the commit.

### Search Agent (UP-A2)

Code in `os2ai/search-agent` (FastAPI + Pydantic AI; SearXNG/Staan backends; MCP endpoint).
Merge to `main`, tag `X.Y.Z`, build & push multi-arch: `task build:image TAG=X.Y.Z`
(manual until search-agent#8 lands CI publishing). Then bump `applications/search-agent/values.yaml`
`image.tag` in `helm-deployments` **and** `demo-gitops`, CHANGELOG, release. This is the
canonical example of why the catalog exists: the image tag lives in helm-deployments, the
code lives in its own repo - update both, in that order. Note the app is
`automated: true`, so the helm-deployments merge is deployed as-is on the demo cluster.

### Adgangskomponent (UP-A1)

Fully self-publishing: merge in `os2ai/adgangskomponent`, cut a semver tag, and
`build-and-publish.yaml` pushes the OCI chart + both images (`semver` + `latest`). The
provider jar is built deterministically and verified via the chart's
`dk.os2ai.provider-jar-sha256` annotation - keep that mechanism intact. Update in
helm-deployments = bump the OCI chart dep version in `applications/adgangskomponent/Chart.yaml`.
Keycloak itself arrives transitively via the keycloak-operator app (see below); realm and
cert management are part of this component.

## Catalog - Application Support components

| Component | Chart source | Image source (pinned in) | ArgoCD gate | Pattern |
|---|---|---|---|---|
| **LiteLLM** (model gateway) | `itk-dev/helm-charts` `litellm 0.0.6` (migration off the itk fork: helm-deployments#78) | upstream `ghcr.io/berriai/litellm-database` - `litellm-values.yaml` `image.tag` `main-stable` (moving tag; security-driven digest pins `main-v1.84.0-stable` per #75/#76) | manual | UP-S1 |
| **vLLM** (GPU model serving) | upstream `vllm-project/production-stack` `vllm-stack 0.1.8` | per-model tags in `applications/vllm/values.yaml`: `vllm/vllm-openai` v0.23.0 (gemma-4), v0.20.1 (gpt-oss-120b), v0.12.0 (mistral, e5 embeddings); `lmcache/lmstack-router:latest` | manual | UP-S1 |
| **SearXNG** (web search backend) | `itk-dev/helm-charts` `searxng 1.0.4` | upstream `searxng/searxng:2026.3.13-3c1f68c59` in values | manual | UP-S1 |
| **Tika** (document parsing, Danish language support) | upstream Apache chart `2.9.0` | our image `ghcr.io/aarhusai/tika:latest`, built from `AarhusAI/tika-docker` (no CI, manual push) | automated | UP-S1 + UP-S2 |
| **doc-ingestion** (external document loader router for Open WebUI) | `itk-dev/helm-charts` `doc-ingestion 0.0.3` | `itkdev/doc-ingestion-route:0.0.4` (Docker Hub, manual push by itk-dev); app source `AarhusAI/doc_ingestion_router` | manual | UP-S1 + UP-S2 |
| **Keycloak operator** (identity; used by Adgangskomponent) | GitLab-hosted Kubitus chart `1.0.20260122011216` (`gitlab.com/api/v4/projects/50848788`) | `quay.io/keycloak/keycloak{,-operator}`, tag from chart appVersion (values override currently empty) | automated | UP-S1 |
| **CloudNativePG operator** (+ `cluster 0.3.1` chart for Open WebUI / LiteLLM / Adgangskomponent DBs) | `cloudnative-pg 0.26.1` | operator image from chart; Postgres major pinned **16** in each app's `cloudnative-pg-values.yaml` | automated | UP-S1 |
| **Redis operator** | `redis-operator 0.22.2` (ot-container-kit) | operator image from chart. Note: no RedisFailover CR exists in the template today - actual redis instances are the Open WebUI subchart (`redis:7.4.2-alpine3.21`) and search-agent's plain Deployment | automated | UP-S1 |
| **Qdrant** (RAG vector store) | `qdrant 1.17.1` as dependency of the openwebui wrapper | image tag from chart default (`qdrant-values.yaml` `tag: ""`) | follows openwebui app (manual) | UP-S1 |

Procedure UP-S1, step by step:

1. Watch upstream: release notes / security advisories (e.g. LiteLLM GHSA-4xpc-pv4p-pm3w ->
   helm-deployments#75). Anything under a CVE is urgent and may justify a digest-pin hotfix
   release outside the normal cycle.
2. Chart bumps: edit the dependency `version:` in `helm-deployments/applications/<app>/Chart.yaml`;
   image-only bumps: edit the `image.repository`/`image.tag` in that app's values file
   (exact file is listed per component above; `demo-gitops/applications/<app>/...` mirrors it
   for the demo site).
3. Diff upstream `values.yaml` for new keys when bumping a chart; re-apply our overrides.
4. For anything feeding Open WebUI (LiteLLM, vLLM, Tika, doc-ingestion, SearXNG, Qdrant),
   verify the RAG/ingestion/search paths on demo before release.
5. CHANGELOG entry; the owning app's ArgoCD gate decides when it deploys - all the model
   and document pipeline apps are `automated: false`, so merges to the template do not move
   demo by themselves.

Model serving specifics (vLLM): adding a model is a values-only PR adding a `modelSpec`
entry (repository + **pinned** tag + modelURL), then registering the endpoint in LiteLLM
(see helm-deployments#54/#56/#57/#58). Recreate strategy: single GPU node - the old
deployment is torn down before the new one starts, expect a serving gap.

## Catalog - Platform components

All are upstream charts pinned as a dependency of the wrapper chart in
`applications/<app>/Chart.yaml` (with our values file beside it). No OS2ai source code.

| Component | Role | Upstream pin | ArgoCD gate |
|---|---|---|---|
| **argo-cd** | GitOps operator (the bootstrap) | `argo-cd 9.1.4` (argoproj); values pin dex `v2.44.0`, redis `8.2.2-alpine`, redis_exporter `v1.80.1` | automated |
| **argo-cd-resources** | app-of-apps: renders all Application/ApplicationSet manifests from `applications.yaml` | in-repo only (UP-P2) | automated |
| **cluster-resources** | StorageClasses / object-bucket claims for Ceph | in-repo only (UP-P2) | automated |
| **traefik** | ingress controller | `traefik 37.4.0` | automated |
| **cert-manager** | TLS issuance (Let's Encrypt) | `cert-manager 1.19.1` | automated |
| **sealed-secrets** | git-safe secrets | chart `2.17.9`; controller image pinned `0.33.1` | automated |
| **template-controller** | Kluctl templating used by our charts | `0.9.4` (`oci://ghcr.io/kluctl/charts`) | automated |
| **kube-prometheus-stack** | metrics/alerting | `73.2.2` (demo runs `88.6.1` + blackbox-exporter + Slack alerting - demo leads template; see [gaps](component-gaps-and-risks.md)) | manual |
| **loki** | log store | `6.46.0` | automated |
| **tempo** | trace store | `1.24.1` | automated |
| **alloy** | telemetry collection | `1.4.0`; config-reloader pinned `v0.81.0` | automated |
| **vLLM serving stack router, dex, exporters** | transitives | pinned inside the values files above | follows parent |

Procedure UP-P1:

1. Bump the dependency version in the wrapper `Chart.yaml`; for image-level pins
   (`dex`, `sealed-secrets-controller`, `redis_exporter`, `config-reloader`) edit the tag
   in the app's `values.yaml`.
2. When bumping a chart, diff upstream default values between old and new version and
   re-apply our overrides deliberately (our values files are heavily edited upstream
   dumps - e.g. `argo-cd/values.yaml`, `traefik/values.yaml`).
3. Sequence risk lives here, not in apps: upgrade **cert-manager CRDs within its documented
   upgrade windows** (skipping one breaks issuing cluster-wide); update **ArgoCD itself
   first and verify it syncs** before merging anything that depends on new ApplicationSet
   features (ArgoCD bootstraps everything else, including its own upgrade via
   `automated: true` - keep the argo-cd values change in a separate, reviewable commit).
   Traefik major-line jumps need an ingress regression pass (all routes terminate there).
4. Observability (prometheus-stack/loki/tempo/alloy) is where upstream values break most
   often; keep these bumps in their own PRs with their own CHANGELOG entries.
5. In-repo components (UP-P2: `argo-cd-resources`, `cluster-resources`, and any
   `applications/<app>/templates/`): PR in helm-deployments as usual; remember tenants do
   NOT get these automatically - every change must be ported to instance repos (and to
   demo-gitops), and `repoUrl` in `argo-cd-resources/values.yaml` must keep pointing at
   *that repo's own* URL (self-referencing apps).

## Catalog - Delivery components

| Component | Repo | Update procedure |
|---|---|---|
| **GitOps template** | `os2ai/helm-deployments` | The aggregate of all procedures above; cutting a release = tag on `main`/release branch + GitHub release notes + CHANGELOG. Default branch is `develop`; releases branch from it (e.g. `0.13.3-1`) and squash-merge back. |
| **Build tooling** | `os2ai/builder` | UP-D1: PR flow; pins live in `Taskfile.yml` (`OPEN_WEBUI_VERSION`, `PROD_OPEN_WEBUI_VERSION`, `PATCHES` list). Release branches named after the upstream version (`0.13.3`). |
| **Reference/demo instance** | `os2ai/demo-gitops` | Copy of the template (not a fork) with `repoUrl` self-pointing; updated by **manually applying** template commits (image bumps, chart pins). No CI deploys it - ArgoCD reads the repo, so a push to `main` *does* roll the demo cluster for `automated: true` apps. Treat it as staging for the next release. |
| **Dev/staging compose** | `AarhusAI/aarhusai-docker` | Legacy compose stack referenced by the release process; local dev is `os2ai/builder`. Update only alongside image changes until it is retired. |
| **Documentation** | `os2ai/documentation` | UP-D1: PR -> GitHub Pages. Release notes per version in `releases/`. This catalog lives here and must be kept in sync when components move category or change update points. |
| **Governance** | `os2ai/Governance` | Process docs (code review, risk log). UP-D1. |
| **Feedback intake** | `os2ai/Feedback` | Municipality bug/idea intake with triage; findings flow into component repos as issues. UP-D1. |

## Release & propagation

How a component update becomes available to every tenant (summary of
[release management](../admin/releasemanagement.md) and
[upgrading](installation/upgrading.md)):

1. Component repo changes + image/chart publication per the component's pattern (UP-A1/A2/A3).
2. Pin bumps land in `os2ai/helm-deployments` (`develop`) with a CHANGELOG entry; PRs are
   reviewed with the same bar as code (see Governance/CodeReview).
3. A Release Candidate is cut to **demo** (`demo-gitops` updated manually); Release Manager
   tests against the documented test cases; users of the platform get 7 days to test in the
   OS2Samtale release thread.
4. The release is cut: final bumps merged, tag + GitHub release on `helm-deployments`,
   announcements per the release-management process. Platform release versions are separate
   from app versions (tags `0.1.0 ... 0.8.0-rc.0`; issue #92 tracks "Release 0.9.0" =
   Open WebUI v0.13.3).
5. **Tenants**: each site's instance repo (created from the template, `repoUrl` rewritten to
   the instance repo) updates by porting the template changes and following CHANGELOG notes.
   There is no automatic tenant propagation - `automated: true` only automates a site's own
   git -> cluster sync, never template -> instance.

Gate summary: `automated: true` apps deploy the moment an instance repo's `main` changes
(search-agent, tika, keycloak-operator, platform plumbing); the apps with user-visible or
risky upgrades (openwebui, litellm, vllm, doc-ingestion, searxng, adgangskomponent,
prometheus-stack) are `automated: false` and deploy only when a human commits a sync/health
approved state.

For the places where current practice violates these procedures - floating tags, missing
publishing CI, the `aarhusai` image namespace split, demo/template drift - see
[Component Gaps and Risks](component-gaps-and-risks.md), which also records the observed
ownership of each area.
