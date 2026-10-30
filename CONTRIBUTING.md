# Sådan gør du

1. Send os et **Pull Request**.
2. Vores automatiske workflows tjekker din kode og sørger for, at markdown-filerne sidder lige i skabet (linting).
3. Når alt er godkendt, bliver dit bidrag en del af fællesskabet!

## DCO - Developer Certificate of Origin

Vi benytter os af [DCO](https://developercertificate.org/) for at sikre projektets juridiske fundament og
beskytte bidragsydere, maintainers og brugere mod fremtidige ophavsretsudfordringer.

Signer dine commit-beskeder med `Signed-off-by: Fornavn Efternavn <mail@eksempel.dk>` manuelt
eller ved `git commit -s -m "Det her er en commit besked"`.

Du kan også sætte dette globalt i din git config med:

```sh
git config --global format.signOff true
```

Eller kun for dette projekt med:

```sh
cd documentation
git config format.signOff true
```

Se [https://git-scm.com/docs/git-config#Documentation/git-config.txt-formatsignOff]

