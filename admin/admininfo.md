---
title: Indstillinger i administrationspanelet
parent: Admin
---

## Indstillinger i administrationspanelet

Når man er administrator har man mulighed for at ændre indstillinger under administration
(administrationspanel -> indstillinger). Da applikationen er lavet så den i udgangspunktet anvender
"configuration as code" hvor indstillingerne gemmes, versioneres og releases, vil ændringer lavet
i administrationspanelet blive overskrevet ved næste release.

Man kan desuden opleve at de ændringer man laver ikke bliver gemt, de skal gemmes i flere kubernetes instanser, og
derfor skal man trykke gem i alle de instanser man har for at det slår rigtigt igennem. Ændringer vil blive rullet
tilbage ved den næste release.

Vil man gerne lave ændringer til indstillingerne i administrationspanelet skal det gå igennem drifts- og
applikationsleverandøren.

## Hvorfor er indstillingerne som de er?

Kort: det er det vi i Aarhus har læst/eksperimenteret os frem til virker for os.
