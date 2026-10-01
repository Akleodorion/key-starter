# MIDI prioritaire, Micro en repli par vérification guidée

**Statut** : accepté — 2026-10-01

## Contexte

Les exercices ne savent recevoir les notes jouées que par un clavier MIDI. Sans câble, l'app est inutilisable. Le POC `prototype-audio-detection` a montré qu'on peut entendre au micro les notes du synthé, mais pas avec la même fiabilité :

- **Transcription aveugle** (deviner ce qui est joué) : ~60-70 % sur les accords, insuffisant.
- **Vérification guidée** (savoir quelle note est attendue et vérifier qu'elle est jouée) : 0 fausse validation sur 5405 essais au banc, octave discriminée, parole et bruits de bouche ignorés. Validé ensuite sur le synthé de Christian au téléphone.
- **Délai** : un verdict au micro arrive ~280 ms ou plus après l'attaque.

## Décision

1. **Une seule Source d'entrée active, choisie automatiquement** : MIDI si un clavier est connecté, sinon Micro (si la permission est accordée), sinon « Aucune entrée ». Aucun réglage utilisateur. La bascule se fait à chaud pendant un exercice, avec un toast.
2. **Le MIDI reste la référence de précision.** Le Micro est un repli « tant mieux si ça marche ».
3. **Le Micro fonctionne uniquement en vérification guidée.**
   - L'exercice déclare à la source ce qu'il attend (`listenFor`).
   - La source Micro n'émet une note que si elle reconnaît la cible ou repère nettement une autre note. Dans tous les autres cas, elle se tait.
   - On n'utilise jamais la transcription aveugle.
4. **Une abstraction commune**, `InputSource`, émet des événements de note (joué, relâché, avec l'instant de l'attaque) et reçoit les cibles attendues.
   - La source MIDI ignore les cibles.
   - Les exercices gardent leurs règles de comparaison actuelles. On ne réécrit pas leur logique de verdict, c'est le chemin le plus court.
5. **Le Micro est réservé aux exercices sur une seule note** : Notes simples, Flashcard, Défilement.
   - **Accords, Accords simples et Tempo exigent le MIDI.** Leur carte est grisée sans clavier, et l'exercice se met en pause si le clavier est débranché.
   - Pour les accords, la vérification au micro n'est pas prouvée (une note en trop n'est refusée qu'à ~70 %).
   - Pour Tempo, le délai du verdict dépasse la fenêtre de jeu (±¼ de temps).
6. **Seuil d'écoute fixe à -55 dB**, sans réglage. Le suivi du bruit de fond de la pièce reste actif par-dessus.
7. **Plateformes du Micro** : Android et iOS. macOS reste en 10.15, sans le micro.

## Conséquences

- **Avant le Micro, on remet à plat l'entrée MIDI** dans une PR séparée :
  - les 6 notifiers d'exercice lisent aujourd'hui chacun `MidiCommand()` et refont leur propre lecture des messages MIDI ;
  - la chaîne `note_recognition` (datasource, repository, use case, notifier) n'est utilisée par aucun exercice.
- **La source Micro n'a pas de Note Off.** Au micro, chaque réponse est une nouvelle attaque (voir CONTEXT.md, « Attaque »).
- **Le temps de réponse se mesure à l'attaque**, que les deux sources fournissent dans l'événement. Il ne se mesure plus à la réception par le notifier.
- **Coût d'analyse plus élevé pour Notes simples** : l'octave y est libre, donc la cible au micro est une classe de hauteur, et la source vérifie plusieurs octaves candidates.
- **Hors périmètre, à reprendre par un nouveau POC** : les accords au micro et Tempo au micro.
