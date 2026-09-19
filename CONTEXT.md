# Key Starter

App Flutter d'apprentissage du piano ("karate way", progressif). Ce contexte couvre le vocabulaire des exercices de reconnaissance de notes/groupes de notes joués sur un clavier MIDI.

## Language

**Groupe de notes**:
Concept générique : un ensemble d'au moins une note à jouer simultanément pour valider une étape d'exercice.
_Avoid_: Accord (réservé aux triades diatoniques 3 notes), Note (réservé au cas particulier d'un groupe à 1 note)

**Accord**:
Une triade diatonique : fondamentale + tierce + quinte, en ne prenant que les notes naturelles de la gamme de Do majeur (aucune altération). La qualité (majeur/mineur/diminué) est entièrement déterminée par le degré de la fondamentale — ce n'est pas un réglage indépendant.
_Avoid_: Intervalle

**Fondamentale**:
La note qui nomme et ancre un accord (Do, Ré, Mi, Fa, Sol, La ou Si). C'est le seul paramètre variable de l'accord — la tierce et la quinte s'en déduisent automatiquement. En v1, les 7 fondamentales sont toutes éligibles au tirage aléatoire (y compris Si, qui donne une triade diminuée) ; un filtrage par fondamentale côté utilisateur est prévu mais pas encore construit.
_Avoid_: Racine, root, tonique (tonique a un sens harmonique plus large, réservé si besoin plus tard)

**Intervalle**:
Un groupe de 2 notes simultanées. Hors périmètre produit actuel — sert uniquement de jalon technique interne pour valider la fenêtre de détection MIDI multi-notes avant de construire l'exercice Accords (3 notes). N'est pas exposé comme exercice ni comme concept dans l'app pour l'instant (`IntervalsConcept` reste orphelin).

**Fenêtre de détection**:
Le court délai (démarré à la réception du premier Note On MIDI d'une étape) pendant lequel les Note On suivants sont accumulés avant d'évaluer le groupe de notes joué contre la cible. Existe parce que le protocole MIDI n'a pas de message "accord" natif — un groupe simultané n'est qu'une suite de Note On séparés de quelques millisecondes.

**Correspondance exacte**:
Règle de validation d'un groupe de notes : l'ensemble des notes jouées pendant la fenêtre de détection doit être identique à l'ensemble des notes cibles — ni note manquante, ni note en trop. Toute note en trop invalide l'étape.
