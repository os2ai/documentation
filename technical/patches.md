---
title: Patches
parent: Technical documentation
---

# Patches

We have created a number of patches for our use of OpenWebUI. The ones relevant for all users of OS2ai are already
in the installation.

The patches are maintained as pull requests on the OS2ai fork of Open WebUI:
[https://github.com/os2ai/open-webui/pulls](https://github.com/os2ai/open-webui/pulls). At image build time they are
applied by the build pipeline in [https://github.com/os2ai/builder](https://github.com/os2ai/builder), where the diff
for each supported release lives under `patches/<version>/`.

Patches in the current pipeline

- name: 'Pinned info banner'
  - pr: [https://github.com/os2ai/open-webui/pull/1](https://github.com/os2ai/open-webui/pull/1)
  - url: <https://patch-diff.githubusercontent.com/raw/os2ai/open-webui/pull/1.diff>
  - branch: 'patch/pinned-info-banner'
- name: 'Add token to TTS requests'
  - pr: [https://github.com/os2ai/open-webui/pull/2](https://github.com/os2ai/open-webui/pull/2)
  - url: <https://patch-diff.githubusercontent.com/raw/os2ai/open-webui/pull/2.diff>
  - branch: 'patch/tts-token'
- name: 'Extra permissions'
  - pr: [https://github.com/os2ai/open-webui/pull/3](https://github.com/os2ai/open-webui/pull/3)
  - url: <https://patch-diff.githubusercontent.com/raw/os2ai/open-webui/pull/3.diff>
  - branch: 'patch/extra-permissions'
- name: 'Fixed null error in auth database session handling'
  - pr: [https://github.com/os2ai/open-webui/pull/4](https://github.com/os2ai/open-webui/pull/4)
  - url: <https://patch-diff.githubusercontent.com/raw/os2ai/open-webui/pull/4.diff>
  - branch: 'patch/oauth_token_expire'
- name: 'Web search tool (agentic search)'
  - pr: [https://github.com/os2ai/open-webui/pull/5](https://github.com/os2ai/open-webui/pull/5)
  - url: <https://patch-diff.githubusercontent.com/raw/os2ai/open-webui/pull/5.diff>
  - branch: 'patch/agentic-search'
- name: 'Template for RAG queries'
  - pr: [https://github.com/os2ai/open-webui/pull/6](https://github.com/os2ai/open-webui/pull/6)
  - url: <https://patch-diff.githubusercontent.com/raw/os2ai/open-webui/pull/6.diff>
  - branch: 'patch/rag-query-template'
- name: 'Ability to turn off prompt suggestions'
  - pr: [https://github.com/os2ai/open-webui/pull/7](https://github.com/os2ai/open-webui/pull/7)
  - url: <https://patch-diff.githubusercontent.com/raw/os2ai/open-webui/pull/7.diff>
  - branch: 'patch/add-enable-prompt-suggestions'

Aarhus-specific patches not in the OS2ai pipeline:

The remaining patches from the Aarhus deployment - among them the OIDC roles and groups patch behind the OIDC
configuration ([OS2ai SSO page](https://os2ai.github.io/documentation/technical/installation/sso.html)), keeping OIDC
role names, group sharing permissions, the admin-only API-key patch, and Aarhus frontend customisations - are still
held outside the OS2ai fork. They are being assessed and migrated as part of the handover tracked in
[os2ai/Feedback#37](https://github.com/os2ai/Feedback/issues/37).
