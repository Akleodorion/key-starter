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
Notation d'une consigne d'accord sans partition : une barre `|` devant le nom de la fondamentale (`|Do`, `|C`), pour la distinguer d'une consigne de note (`Do`). Suffixe `m` minuscule collé pour les fondamentales Ré, Mi, La et Si (`|Rém`, `|Dm`). Si reçoit `m` par choix pédagogique alors que sa triade est diminuée. Un renversement s'indique par son numéro entre parenthèses, collé après le suffixe : `|Do(1)`, `|Rém(2)`, `|Am(1)` ; sans parenthèses, c'est l'état fondamental. Convention propre à l'app (issue d'un cours de piano), pas un standard musical.
_Avoid_: `°`, `dim`, « majeur »/« mineur » en toutes lettres, `|Do/Mi` (accord à basse imposée)

**État fondamental**:
Un accord joué avec la fondamentale en bas et les trois notes empilées dans une seule octave (Do-Mi-Sol). L'octave de l'ensemble est libre dans les exercices sans partition ; renversements, accord étalé sur plusieurs octaves et notes doublées sont faux.
_Avoid_: Position serrée (plus large : inclut les renversements)

**Renversement**:
Un accord joué avec une autre note que la fondamentale à la basse, les trois notes toujours serrées dans une seule octave. **1er renversement** : la tierce à la basse (Mi-Sol-Do). **2e renversement** : la quinte à la basse (Sol-Do-Mi). Travaillé dans sa propre section (Renversements simples, sans partition) : seul le renversement demandé est juste, octave libre ; l'état fondamental, l'autre renversement, un accord étalé ou une note doublée sont faux. Les exercices à l'état fondamental continuent de compter tout renversement comme faux.
_Avoid_: Inversion (en dehors du code), position (seul : ambigu)

**Intervalle**:
Un groupe de 2 notes simultanées. Hors périmètre produit actuel — sert uniquement de jalon technique interne pour valider la fenêtre de détection MIDI multi-notes avant de construire l'exercice Accords (3 notes). N'est pas exposé comme exercice ni comme concept dans l'app pour l'instant (`IntervalsConcept` reste orphelin).

**Fenêtre de détection**:
Le court délai (démarré à la réception du premier Note On MIDI d'une étape) pendant lequel les Note On suivants sont accumulés avant d'évaluer le groupe de notes joué contre la cible. Existe parce que le protocole MIDI n'a pas de message "accord" natif — un groupe simultané n'est qu'une suite de Note On séparés de quelques millisecondes.

**Correspondance exacte**:
Règle de validation d'un groupe de notes : l'ensemble des notes jouées pendant la fenêtre de détection doit être identique à l'ensemble des notes cibles — ni note manquante, ni note en trop. Toute note en trop invalide l'étape.

**Événement deux portées**:
Ce qui se joue à un même instant sur une portée double : un groupe de notes écrit en clé de sol et un groupe écrit en clé de fa, chacun de 0 à n notes (note seule, accord, ou rien). Un morceau en est une suite datée (voir Événement de morceau). Chaque portée est jugée en correspondance exacte, et l'événement n'est juste que si les deux le sont.
_Avoid_: Double note, intervalle

**Main droite / Main gauche**:
Libellés affichés pour la partie écrite en clé de sol / en clé de fa. C'est la portée qui définit la main, pas la main réellement utilisée (le clavier ne la connaît pas) ; les croisements de mains sont ignorés. Dans le code : `treble` / `bass`.

**Touches tenues**:
Règle de déclenchement du jugement sans tempo : l'événement est jugé dès que le nombre de touches enfoncées en même temps atteint le nombre de notes attendues, quel que soit l'ordre d'attaque des mains. Relâcher une touche avant d'y arriver juge l'événement sur toutes les touches jouées jusque-là (donc faux). Seules comptent les touches enfoncées depuis le début de l'événement : une touche tenue depuis l'événement précédent (une ronde à la main gauche pendant que la main droite avance) est ignorée. Remplace la fenêtre de détection quand il n'y a pas de tempo ; avec un tempo, c'est la Fenêtre d'événement qui s'applique.

**Point de partage**:
Le milieu entre la note de clé de fa attendue la plus haute et la note de clé de sol attendue la plus basse. Une touche attendue est attribuée à sa portée ; toute autre touche (fausse, ou noire) va à la clé de sol au-dessus du point de partage, à la clé de fa en dessous. Sert à dire quelle main s'est trompée.

**Morceau**:
Une pièce à travailler, lue depuis sa partition MusicXML (fichier `.mxl` exporté par MuseScore) : une partie piano sur deux portées, en Do majeur, une voix par portée. Une partition qui contient un élément pas encore pris en charge (altérations, armure, notes liées, triolets, ornements, plusieurs voix ou parties, changement de chiffrage) est refusée avec sa raison plutôt que jouée faux ; sans chiffrage, elle est lue en 4/4. Se joue en tempo **Libre** (on joue un événement après l'autre ; juste ou faux, la couleur s'affiche puis on passe au suivant, sans attendre le relâchement) ou **au tempo** choisi sur la page de préparation (voir Barre). On travaille toujours une section (par défaut le morceau entier).
_Avoid_: Chanson, partition (le fichier, pas la pièce)

**Section**:
Une plage continue de mesures travaillée d'un seul tenant, de la mesure X à la mesure Y (jamais deux plages séparées), choisie sur la page de préparation ; le morceau entier est la section qui va de la première à la dernière mesure. Toute la partition reste affichée, la section sur un fond violet très clair ; on commence au premier événement de X et on s'arrête après le dernier de Y.
_Avoid_: Passage, extrait

**Reprise**:
Ce qui suit toute section terminée, réussie ou non : un court message (« 2 erreurs · on reprend », « Sans erreur · on reprend »), puis la section repart de X avec les mêmes réglages et les couleurs effacées (au tempo, après un nouveau décompte). On travaille la section en boucle ; on n'en sort que par la flèche retour de la page de jeu, qui ramène à la préparation.

**Ligne de partition**:
Deux mesures consécutives d'un morceau sur portée double, avec clés et accolade, barres de mesure et numéro de la première mesure (pas de chiffrage pour l'instant). Chaque mesure occupe la moitié de la ligne, même sur une dernière ligne incomplète. Chaque élément (note ou silence) y est placé selon son temps, mais jamais à moins d'un douzième de mesure du suivant : les écarts plus larges cèdent la place, et une mesure trop pleine est répartie également. Le repère et la barre suivent ce même placement, donc la barre croise chaque note à son instant mais n'avance pas à vitesse constante à l'écran. Deux lignes sont visibles : celle en cours en haut, la suivante en dessous ; elles remontent quand le repère passe à la ligne suivante. Une note jouée reste verte ou rouge.
_Avoid_: Système (terme de gravure, à éviter à l'écran)

**Repère**:
Le trait vertical posé sur l'événement à jouer d'un morceau en tempo Libre : il saute d'un événement au suivant.
_Avoid_: Curseur, barre (réservée au tempo)

**Tempo d'un morceau**:
La vitesse de jeu choisie sur la page de préparation, en noires par minute : Libre, ou de 40 à 120 par pas de 5 (60 par défaut), gardée le temps de la session pour tous les morceaux. Le fichier MusicXML ne fixe pas le tempo. Affiché « ♩ = 60 » à côté du titre pendant le jeu.

**Barre**:
Au tempo, le trait vertical qui glisse sur la partition à vitesse constante, du début de la mesure X à la fin de la mesure Y. Elle part après un **décompte** d'une mesure (4, 3, 2, 1 en 4/4) et croise chaque événement à l'instant où il doit être joué ; les lignes remontent quand elle passe à la ligne suivante. Au bout de la section : reprise, puis nouveau décompte. Clavier débranché, elle s'arrête ; au rebranchement, la section repart du décompte.
_Avoid_: Curseur, repère (réservé au tempo Libre)

**Fenêtre d'événement**:
Au tempo, l'intervalle de ±¼ de temps autour de l'instant d'un événement, chaque côté réduit à la moitié de l'écart avec l'événement voisin (les fenêtres ne se chevauchent jamais). Les touches jouées dedans sont regroupées : l'événement passe juste dès qu'elles correspondent exactement aux notes attendues, sinon il est jugé à la fermeture de la fenêtre (faux s'il manque une note, s'il y en a une de trop, ou s'il n'a pas été joué). Seule l'attaque compte, pas la durée tenue. Une touche jouée hors de toute fenêtre rend faux le prochain événement encore ouvert.

**Événement de morceau**:
Un événement deux portées daté : sa mesure, son instant d'attaque, et les notes de chaque portée qui commencent à cet instant (une note encore tenue n'en fait pas partie). Chaque groupe garde sa figure, le sens de sa hampe et ses barres de ligature tels que la partition les écrit.

**Figure**:
La valeur écrite d'une note ou d'un silence : carrée, ronde, blanche, noire, croche, double, triple, quadruple croche, puis 128e, 256e, 512e et 1024e, avec autant de points que la partition en indique. Lue dans la partition (déduite de la durée si elle n'est pas écrite) ; longues et maximes sont refusées. Dessinée avec la police Bravura : tête, hampe dans le sens écrit (sinon selon la note la plus éloignée du milieu de la portée), crochets pour une note seule, barres de ligature et demi-barres d'après la partition, pente plafonnée à un demi-interligne. Tête, hampe, crochets et points prennent la couleur du verdict de leur portée ; une barre de ligature n'est colorée que si tout son groupe a le même verdict.
_Avoid_: Durée (le temps joué, pas le signe écrit), rythme

**Silence**:
Une figure de silence d'une portée, à sa place dans le temps, jamais jugée : le repère et la barre passent dessus. Une mesure entière de silence se dessine comme une pause centrée dans la mesure, quel que soit le chiffrage. Toujours neutre (gris dans la main non travaillée).
_Avoid_: Pause (réservé au silence d'une ronde ou de mesure entière)

**Morceau local**:
Une partition déposée dans `assets/songs/local/`, jamais versionnée (morceau sous droits, pour un usage personnel) : elle apparaît dans la liste des morceaux seulement sur une app construite avec le fichier présent. Les morceaux sont listés depuis les partitions livrées, chacun sous le titre écrit dans sa partition (sinon son nom de fichier), par ordre alphabétique.

**Mode une main**:
Travail d'un morceau à la main droite seule ou à la main gauche seule (choisi sur la page de préparation, deux mains par défaut). L'autre portée reste affichée en gris, sans être jugée ; les événements où seule l'autre main joue sont sautés ; toute touche en plus de la main choisie est fausse.

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
