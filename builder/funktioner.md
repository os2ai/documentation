---
title: Funktioner på en assistent
parent: Builder
---

# Funktioner på en assistent - hvad gør de?

Når du opretter eller konfigurerer en assistent i **Workspace -> Models**, kan du aktivere en række funktioner.
Denne side forklarer hvad hver funktion gør, og hvad der gælder specifikt i OS2ai.

Siden er tilpasset beskrivelsen fra AarhusAI's dokumentation; statusserne nedenfor gælder for OS2ai-platformens
standardopsætning (miljøvariablerne i platformens helm-deployments). En driftsleverandør kan have ændret enkelte
indstillinger lokalt - spørg administratoren hvis er i tvivl.

## De tre niveauer: server, funktioner, standardfunktioner

Der er tre lag at holde styr på:

1. **Admin-indstillinger på serverniveau.** En administrator kan slå funktioner helt fra for hele platformen via
   miljøvariabler. Er en funktion slået fra her, hjælper det ikke at afkrydse den i model-editoren - den forbliver
   uden effekt.
2. **Funktioner** i model-editoren styrer, om modellen overhovedet har adgang til en given evne. Er en funktion slået
   fra her, kan modellen aldrig bruge den - uanset hvad brugeren gør i chatten.
3. **Standardfunktioner** styrer kun, om en funktion er slået til som udgangspunkt, når en bruger starter en ny chat.
   Den findes kun for de værktøjer, der har en per-chat-knap i chat-vinduet: **Websøgning**, **Billedgenerering** og
   **Kode Interpreter**.

For de tre værktøjer med en per-chat-knap gælder: før værktøjet kan bruges i en samtale, skal alle tre lag være
opfyldt. Er **Funktionen** slået fra, er det ligegyldigt om **Standardfunktionen** er slået til. Er **Funktionen**
tændt men **Standardfunktionen** fra, skal brugeren selv aktivere værktøjet i chat-vinduet for hver samtale.

De øvrige funktioner (Vision, Fil Upload, File Context, Citater m.fl.) har ingen per-chat-knap og optræder derfor kun
under Funktioner - de er enten slået til eller fra for modellen som helhed.

Bemærk: funktioner der er slukket på serverniveau kan stadig fremstå som mulige at afkrydse i editoren, men har ingen
effekt. De bør som udgangspunkt ikke afkrydses, da det giver et misvisende indtryk af, at funktionen er aktiv.

## Værktøjer (tools)

Værktøjer er eksterne integrationer, der er tilføjet platformen af en administrator, og optræder i deres egen sektion i
model-editoren. Der kan løbende komme flere til.

| Navn | Anbefaling | Bemærkning |
| --- | --- | --- |
| websearch | Efter behov | Det agentiske internetsøgeværktøj (search-agent via MCP). Se [Internetsøgning og agentisk søgeværktøj](agentisksearch.md). Tilgængeligt for alle brugere som standard. |

## Funktioner

| Navn | Status i OS2ai | Bemærkning |
| --- | --- | --- |
| Vision | Efter behov | Analyserer uploadede billeder, hvis modellen kan. |
| Fil Upload | Efter behov | Uploader dokumenter til chatten. Grænser fastsættes af administratoren. |
| File Context | Efter behov | Bestemmer hvordan uploadede filer bruges af modellen. |
| Hukommelse | Efter behov | Tilladt som standard, men slår den til, følger hukommelsen brugeren på tværs af samtaler - brug det med omtanke. |
| Websøgning | Slået fra på serverniveau | Brug i stedet websearch-værktøjet (MCP) ovenfor. |
| Billedgenerering | Slået fra på serverniveau | Ingen billedmodel er konfigureret i platformen. |
| Kode Interpreter | Tilladt på serverniveau | Kun med afkrydsning på modellen. Afviklingen sker client-side (pyodide); platformens egen kodeafvikling (terminal) er slået fra. Drøft med en administrator før I bygger afhængighed af det. |
| Terminal | Slået fra på serverniveau | Må aldrig aktiveres; serverafvikling af kode er af sikkerhedsårsager deaktiveret. |
| Forbrug | Ikke relevant | Platformen opkræver ikke per-token forbrug mod eksterne API'er. |
| Citater | Anbefales | Særligt ved brug af vidensbaser. |
| Statusopdateringer | Anbefales | Viser hvad modellen arbejder på. |
| Builtin Tools | Anbefales hvis vidensbase anvendes | Kræver kendskab til hvad der injiceres; se kategorierne nedenfor. |

## Builtin Tools-kategorier

Underindstillinger, der kun vises og har effekt, når **Builtin Tools** er slået til.

| Kategori | Status i OS2ai | Bemærkning |
| --- | --- | --- |
| Time & Calculation | Anbefales | Simple tids- og datoberegninger, ingen server-afhængighed. |
| Hukommelse | Efter behov | Gælder kun hvis funktionen Hukommelse ovenfor er tændt. |
| Chat History | Skal forblive slået fra | Må ikke aktiveres; lægger tidligere chat-historik ind i konteksten - på tværs af samtaler og brugere, hvilket i OS2ai ikke kan accepteres som standard. |
| Noter | Slået fra på serverniveau | Note-funktionen er deaktiveret i OS2ai. |
| Vidensbase | Anbefales | Nødvendig hvis assistenten skal bruge vidensbaser (Knowledge). |
| Ask User | Efter behov | Styres kun via kategori-afkrydsningen pr. model. |
| Websøgning | Slået fra på serverniveau | Brug websearch-værktøjet i stedet. |
| Billedgenerering | Slået fra på serverniveau | - |
| Kode Interpreter | Se Funktioner ovenfor | Samme forudsætning som Kode Interpreter. |
| Kanaler | Tilladt | Kanaler er ikke slået fra på serverniveau i standardopsætningen; undlad at bygge assistenter der forudsætter dem - tale med administratoren. Krypterede kanaler er fra. |
| Task Management | Efter behov | Opretter og opdaterer tjeklister for flertrinsopgaver i chatten. |
| Automations | Ikke tilladt for brugere | Brugertilladelsen er fra som standard. |
| Kalender | Tilladt | Brugertilladelsen er tændt som standard - overvej om jeres lokalitet vil have den fra. |

## Vigtigt om personlige data

Uanset funktioner og værktøjer gælder platformens overordnede regel: **brug ikke løsningen til personoplysninger.**
Eksterne værktøjer (websøgning m.m.) kan sende indhold ud af platformen - hold også den del af data i ørerne, når du
bygger assistenter, der skal deles med andre.

## Se også

- [Systempromt](systempromt.md)
- [Viden](viden.md)
- [Internetsøgning og agentisk søgeværktøj](agentisksearch.md)
