# Projet multimodal avec processing
Projet réalisé par Emilien Vesin et Ambre Rouzade dans le cadre de la 3ème année d'école d'ingénieur en Systèmes Robotiques et Interactifs à l'UPSSITECH.
Ce projet permet d'afficher, dessiner, déplacer et supprimer des formes en utilisant IVY et sra5. Il y a également la possibilité de choisir la couleur.

Vous trouverez la vidéo de démonstration ici: https://github.com/Emilioprog/IHM-Multimodale/blob/master/Video_exemple.mp4 

# Chronogrammes
//insérer les chrono

# Utilisation

## Installation

Vous devez posséder java 17 sur votre ordinateur puis télécharger ce projet.

## Lancement

Pour lancer notre moteur multimodal, il suffit de lancer dans l'ordre énoncées les fichiers suivants:
- IHM-Multimodale/sra5/sra5_on.bat  (contient la grammaire parole, reconnaissance vocale)
- IHM-Multimodale/icar/Icarivy.bat   (contient le dictionnaire de forme chargé, il va donc reconnaître à chaque fois la forme que l'on dessine, si elle est comprise dans la dictionnaire_formes)
- IHM-Multimodale/visionneur_1_2/visionneur.bat   (permet de visionner tout ce qu'il se passe dans le système)
- IHM-Multimodale/Projet/Palette.exe   (fichier principal de multifusion, permettant de lier les différentes éléments multimodaux. Les formes et les commandes s'afficheront ici)

## Actions réalisables
###  Creer une forme
- prononcer "DESSINER + FORME [+ COULEUR] + ICI" + cliquer au niveau de l'emplacement désiré
- prononcer "DESSINER + cette forme [+ COULEUR] + ICI" + dessiner la forme dans ivy + cliquer au niveau de l'emplacement désiré
### Déplacer une forme
- prononcer "DEPLACE + cette forme" + cliquer sur la forme à déplacer + cliquer sur l'emplacement désiré
### Supprimer une forme
- prononcer "SUPPRIMER + cette forme" + cliquer sur la forme à supprimer
