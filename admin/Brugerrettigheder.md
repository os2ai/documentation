---
title: Brugere - grupper og rettigheder
parent: Admin
---

# Brugere - grupper og rettigheder

# Brugere og brugergrupper

OpenWebUI har som standard 2 roller: Administrator og bruger. 

OS2ai har udviddet dette med en rolle vi kalder "builder". 
Dette har vi gjort fordi vi har et behov for at nogle brugere kan anvende specialister og assistenter, og andre kan bygge
assistenter, men ikke har administrator rettigheder.

En Builder i OS2ai er en brugergruppe, der giver brugeren flere rettigheder. I OpenWebUI giver man rettigheder til
brugergrupper og ikke til roller. Derfor har vi oprettet en gruppe, der hedder "Builder" (det er vigtigt at den hedder "
Builder") der har udviddet rettighederne for de brugere der er i gruppen.

Der en patch der i brugeroverblikket viser rollen "Builder". Derudover har vi i vores brugerstyring lavet en mapning fra
rollen "Builder" til OpenWebUI så en bruger der kommer med rollen "Builder" placeres i gruppen "Builder" i OpenWebUI.

Under hver enkelt rolle i navigationen kan man læse om de permissions der er tildelt de enkelte roller.
Under "Technical documentation" kan man også finde et json output af rollekonfigurationen i Aarhus AI.

Her findes en oversigt over rettighederne for de forskellige brugertyper i systemet.

## Slutbrugere - Rettigheder

Som slutbruger har man en række rettigheder. Disse rettigheder har alle brugere af systemet:

* Tillad upload af fil
* Tillad redigering af chats
* Tillad sletning af chats
* Allow Delete Messages
* Allow Continue Response
* Allow Regenerate Response
* Allow Rate Response
* Tillad eksport af chats
* Tillad tale til tekst
* Tillad tekst til tale
* Tillad kald
* Tillad midlertidig chat
* Websøgning

## Builder Rettigheder

Som Builder har man udvidede rettigheder i forhold til en slutbruger. En builder har følgende rettigheder:

* Modeller adgang
* Videnadgang
* Prompts adgang
* Models sharing
* Knowledge sharing
* Tillad upload af fil
* Tillad kontrol af chats
* Allow Chat Valves
* Tillad system prompt
* Allow Chat Params
* Tillad redigering af chats
* Allow Attach Knowledge
* Allow Import/Export models
* Tillad sletning af chats
* Allow Delete Messages
* Allow Continue Response
* Allow Regenerate Response
* Allow Rate Response
* Tillad deling af chats
* Tillad eksport af chats
* Tillad tale til tekst
* Tillad tekst til tale
* Tillad kald
* Tillad flere modeller i chats
* Tillad midlertidig chat
* Websøgning

Nogle af disse rettigheder går igen fra slutbruger-niveauet.
