FROM alpine:3.24@sha256:be2656061b536c1883c4034790e21d0a09c5aaaf51968b89368a3c0371ea2c9a
ARG OPENGREP_VERSION=v1.30.2
# opengrep-rules pinned to a commit (verified: main @ f1d2b562…)
ARG RULES_REF=f1d2b562b414783763fd02a6ed2736eaed622efa

RUN adduser -D -h /home/opengrep opengrep

SHELL ["/bin/ash", "-o", "pipefail", "-c"]

RUN apk add --no-cache curl cosign tar \
 && case "$(uname -m)" in aarch64) A=aarch64;; *) A=x86;; esac \
 && N="opengrep_musllinux_$A" \
 && U="https://github.com/opengrep/opengrep/releases/download/$OPENGREP_VERSION" \
 && curl -fsSL -O "$U/$N" -O "$U/$N.cert" -O "$U/$N.sig" \
 && cosign verify-blob "$N" --certificate "$N.cert" --signature "$N.sig" \
      --certificate-identity-regexp '^https://github.com/opengrep/opengrep/' \
      --certificate-oidc-issuer https://token.actions.githubusercontent.com \
 && install -m 0755 "$N" /usr/local/bin/opengrep && rm -f "$N" "$N.cert" "$N.sig"

RUN mkdir -p /rules \
 && curl -fsSL "https://github.com/opengrep/opengrep-rules/archive/$RULES_REF.tar.gz" \
      | tar xz -C /rules --strip-components=1 \
        "opengrep-rules-$RULES_REF/yaml/github-actions" \
        "opengrep-rules-$RULES_REF/yaml/docker-compose" \
        "opengrep-rules-$RULES_REF/dockerfile" \
        "opengrep-rules-$RULES_REF/generic/secrets"

WORKDIR /workspace
USER opengrep
ENTRYPOINT ["opengrep"]
CMD ["scan", "--error", "-f", "/rules", "."]
