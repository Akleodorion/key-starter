# Key Starter

App Flutter d'apprentissage du piano ("karate way", progressif). Ce contexte couvre le vocabulaire des exercices de reconnaissance de notes/groupes de notes joués sur un clavier — reçus en MIDI, ou à défaut entendus au micro.

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

**Symbole d'accord**:
Notation d'une consigne d'accord sans partition : une barre `|` devant le nom de la fondamentale (`|Do`, `|C`), pour la distinguer d'une consigne de note (`Do`). Suffixe `m` minuscule collé pour les fondamentales Ré, Mi, La et Si (`|Rém`, `|Dm`). Si reçoit `m` par choix pédagogique alors que sa triade est diminuée. Convention propre à l'app (issue d'un cours de piano), pas un standard musical.
_Avoid_: `°`, `dim`, « majeur »/« mineur » en toutes lettres

**État fondamental**:
Un accord joué avec la fondamentale en bas et les trois notes empilées dans une seule octave (Do-Mi-Sol). L'octave de l'ensemble est libre dans les exercices sans partition ; renversements, accord étalé sur plusieurs octaves et notes doublées sont faux.
_Avoid_: Position serrée (plus large : inclut les renversements)

**Intervalle**:
Un groupe de 2 notes simultanées. Hors périmètre produit actuel — sert uniquement de jalon technique interne pour valider la fenêtre de détection MIDI multi-notes avant de construire l'exercice Accords (3 notes). N'est pas exposé comme exercice ni comme concept dans l'app pour l'instant (`IntervalsConcept` reste orphelin).

**Fenêtre de détection**:
Le court délai (démarré à la réception du premier Note On MIDI d'une étape) pendant lequel les Note On suivants sont accumulés avant d'évaluer le groupe de notes joué contre la cible. Existe parce que le protocole MIDI n'a pas de message "accord" natif — un groupe simultané n'est qu'une suite de Note On séparés de quelques millisecondes.

**Correspondance exacte**:
Règle de validation d'un groupe de notes : l'ensemble des notes jouées pendant la fenêtre de détection doit être identique à l'ensemble des notes cibles — ni note manquante, ni note en trop. Toute note en trop invalide l'étape.

**Source d'entrée**:
D'où l'app reçoit ce que l'élève joue : **MIDI** (un clavier connecté) ou **Micro** (le son du synthé ou du piano capté par le téléphone). Choisie automatiquement, jamais par l'utilisateur : MIDI dès qu'un clavier est connecté, Micro sinon, « Aucune entrée » si ni l'un ni l'autre n'est disponible. Bascule à chaud pendant un exercice. Le MIDI est la référence de précision ; le Micro est un repli, réservé aux exercices sur une seule note (Notes simples, Flashcard, Défilement) — Accords, Accords simples et Tempo exigent le MIDI.
_Avoid_: Détection audio, mode audio, entrée sonore

**Vérification guidée**:
Manière dont la source Micro juge une réponse : elle sait quelle(s) note(s) l'exercice attend et vérifie si c'est ce qui est joué (ou repère une autre note nettement jouée). Elle ne cherche jamais à reconnaître à l'aveugle n'importe quelle note — c'est cette connaissance de la cible qui rend le Micro fiable.
_Avoid_: Transcription, reconnaissance à l'aveugle

**Attaque**:
Le début d'un son entendu au Micro (montée nette du volume) — l'équivalent du Note On MIDI. Au Micro, chaque réponse doit être une nouvelle attaque : la résonance d'une note précédente ne compte jamais, même si c'est la note attendue. Il n'existe pas d'équivalent du Note Off au Micro. Le temps de réponse se mesure à l'attaque, pas au moment du verdict.
_Avoid_: Onset (en dehors du code)

**Seuil d'écoute**:
Le volume minimal (-55 dB) en dessous duquel un son n'est jamais pris pour une note au Micro. Fixe, non réglable par l'utilisateur ; le bruit de fond de la pièce peut le relever automatiquement, jamais l'abaisser.
_Avoid_: Sensibilité, gain
