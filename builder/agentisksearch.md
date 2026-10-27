---
title: Internetsøgning og agentisk søgeværktøj (tool)
parent: Builder
---

# Om internetsøgning og det tilhørende værktøj i OS2ai

Denne side beskriver det agentiske værktøj til internetsøgning, som blev tilføjet til OS2ai-platformen med release
v0.7.0 i oktober 2026. Før dette var der også mulighed for at udføre internetsøgning i OS2ai, dog med brug af et andet
inbygget værktøj til dette - som ikke fungerde optimalt.

## Hvad betyder "agentisk"?

Når vi siger, at et værktøj til internetsøgning er **agentisk**, betyder det, at AI-modellen
selv beslutter, hvornår og hvordan den skal søge – uden at du behøver at bede
den om det eksplicit hver gang.

En almindelig (ikke-agentisk) internetsøgningfunktion virker sådan: du beder modellen om
at søge, og den søger. Punktum.

Et **agentisk søgeværktøj** virker anderledes:

- Modellen vurderer selv, om den har brug for opdateret information for at
  besvare dit spørgsmål
- Den formulerer selv en søgeforespørgsel og udfører søgningen
- Den vurderer resultaterne og beslutter, om den skal søge igen med en ny
  forespørgsel
- Til sidst sammenfatter den svarene og svarer dig

Kort sagt: modellen **handler selvstændigt** som en agent – deraf ordet
"agentisk". Du stiller et spørgsmål, og modellen tager selv de nødvendige
skridt for at finde et godt svar.

### Eksempel

> **Du skriver:** "Hvad er de seneste nyheder om AI-regulering i EU?"
>
> En agentisk model vil automatisk:
>
> 1. Erkende at den ikke har opdateret viden om dette
> 2. Formulere en søgeforespørgsel (f.eks. *"EU AI Act 2025 nyheder"*)
> 3. Gennemse resultaterne
> 4. Evt. søge igen med et mere præcist udtryk
> 5. Give dig et samlet, opdateret svar med kildehenvisninger

---

## Sådan tilføjer du internetsøgningsværktøjet til en assistent

Følg disse trin for at aktivere det agentiske søgeværktøj på en model (assistent) i
Open WebUI.

### Trin 1: Åbn modellisten

Gå til **Workspace** i venstre menu og vælg **Models** (Modeller). Her ser du
en oversigt over dine tilgængelige assistenter.

---

### Trin 2: Vælg eller opret en assistent

- Klik på den assistent, du vil redigere, for at åbne dens
  indstillinger.
- Eller opret en ny ved at klikke på **+ New Model** / **+ Ny model**.

---

### Trin 3: Find "Builtin Tools" (Værktøjer)

- Scroll ned til du finder "Builtin Tool" og vælg det værktøj du gerne vil bruge.Til internetsøgning hedder værktøjet
"Websøgning" eller "Websearch". Når man fører musen over (hover) værktøjet skal teksten vise "Søg på nettet, og hent
URL'er" eller "Search the web and fetch URLs".

- Sæt flueben ud for søgeværktøjet for at aktivere det på assistenten.

Bemærk, at der andre steder på siden for en assistents indstillinger kan være
nævnt "Websøgning", fx under
"Funktioner". Dette vil være det gamle værktøj til internetsøgning, og der vil
ingen effekt være i at slå det fra
eller til. For simpliciteten kan det dog anbefales at slå dem fra, således det kun
er "Websøgning" under "Builtin
Tools", der er slået til.

---

### Trin 4: Gem ændringerne

Klik på **Save** / **Gem** nederst på siden. Assistenten er nu konfigureret
til at bruge søgeværktøjet agentisk.

---

### Trin 5: System prompt

Opdater din assistents system prompt så modellen vejledes til at søge ved usikkerhed. Kopiér og tilpas følgende:

**System prompt eksempel:**

```markdown
## Websøgning – retningslinjer

- Brug websøgning når:
    - Du er usikker på et faktum eller en oplysning.
    - Spørgsmålet vedrører aktuelle begivenheder, love, regler eller datoer.
    - Din vidensbase kan være forældet.
- Brug **ikke** websøgning til generiske skriveopgaver, brainstorming eller omformulering, hvor brugerens eget input er
  grundlaget.
- Angiv altid kilden, når du baserer et svar på en websøgning, fx:
    - "Ifølge [kilde] (søgt d. {{CURRENT_DATE}})..."
```

---

### Trin 6: Test det

Gå tilbage til chatten og vælg din assistent. Stil et spørgsmål, der kræver
opdateret viden – fx om aktuelle begivenheder. Du bør nu se, at modellen
automatisk udfører en søgning og inkluderer resultater i sit svar.

> **Tip:** Mange modeller viser en lille indikator eller tekst som
> *"Searching…"* / *"Søger…"* mens de bruger søgeværktøjet, så du kan følge
> med i processen.

---

## Hvornår bruger modellen søgeværktøjet?

Modellen beslutter selv, hvornår søgning er relevant. Den vil typisk søge,
når:

- Spørgsmålet handler om aktuelle begivenheder eller nyheder
- Den har brug for faktuelle oplysninger, der kan have ændret sig siden dens
  træning
- Du eksplicit beder den om at søge eller finde frem til noget

Den vil **ikke** søge unødvendigt, f.eks. ved simple matematikspørgsmål eller
generelle forklaringer, som den allerede kender svaret på.

---

## Fejlfinding

| Problem                           | Mulig løsning                                                                                 |
|-----------------------------------|-----------------------------------------------------------------------------------------------|
| Modellen søger ikke automatisk    | Tjek at søgeværktøjet er aktiveret under "Builtin Tools" for den pågældende assistent                  |
| Søgningen giver ingen resultater  | Kontrollér at søgeværktøjets API-nøgle eller forbindelse er korrekt konfigureret i Open WebUI |
| Modellen ignorerer søgeresultater | Prøv at præcisere i systemprompten, at modellen aktivt skal bruge søgeværktøjet               |
