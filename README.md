# Full Clean Windows - Script PowerShell de Nettoyage Complet

## Description

Ce script PowerShell interactif permet de nettoyer efficacement un système Windows en supprimant les fichiers temporaires, vidant la corbeille, libérant la mémoire RAM, vidant le cache DNS, nettoyant Windows Update, supprimant les logs d’événements, les fichiers de dump, le cache Prefetch, ainsi que le cache des navigateurs Chrome et Edge.

---

## Fonctionnalités principales

- Nettoyage des fichiers temporaires utilisateur et système  
- Vidage de la corbeille  
- Activation du vidage du fichier d’échange (mémoire virtuelle) au redémarrage  
- Libération partielle de la mémoire RAM  
- Vidage du cache DNS  
- Nettoyage complet du cache Windows Update  
- Suppression des journaux d’événements (.evtx)  
- Suppression des fichiers de dump système  
- Suppression du cache Prefetch  
- Nettoyage des caches de navigateurs : Chrome et Edge (autres navigateurs détectés si installés)  
- Affichage des 10 processus les plus gourmands en RAM  
- Menu interactif simple d’utilisation

---

## Prérequis

- Windows 10 ou 11  
- PowerShell via cmd (version 5.1 ou PowerShell 7+)  
  https://github.com/PowerShell/PowerShell/releases/tag/v7.5.1
- Exécution en mode administrateur (obligatoire pour certaines actions)

---

## Installation et utilisation

1. Téléchargez ou clonez ce dépôt sur votre machine.  
2. Ouvrez PowerShell en mode administrateur.  
3. Naviguez jusqu’au dossier contenant le script avec la commande :  
   
   cd chemin\vers\le\dossier ou fichier

🔧 Étapes pour autoriser l'exécution du script
Ouvrir PowerShell en tant qu’administrateur :

Clic droit sur l’icône de PowerShell → "Exécuter en tant qu'administrateur"

Exécuter cette commande :

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

💡 Cette commande change la stratégie temporairement pour la session en cours (aucun risque pour le système).

4.Puis une fois dans le dossier ou emplacement du fichier lancer avec la commande :

.\Menu-Full-Clean.ps1

5.Suivez les instructions à l’écran pour choisir les options de nettoyage souhaitées.

Pour certaines opérations (comme le vidage de la mémoire virtuelle), un redémarrage du système peut être nécessaire pour appliquer les changements.
