### **LapFetch**: Dateien zwischen Laptops holen & aufräumen

#### Kurzbeschrieb

Ein PowerShell-Skript, mit dem man von einem Laptop aus auf einen anderen Laptop zugreifen, bestimmte Dateien einsammeln und auf dem Quell-Laptop wieder löschen kann. 
Szenario angelehnt an die Schnuppertage in der Firma: Schnupperlernende erstellen während des Tages Projekte (zB: eine .sb3 Datei auf dem Desktop und/oder einen kleinen Projektordner), die am Ende eingesammelt und entfernt werden müssen.

#### Pflichtfunktionen

- **Fetch Modus:** holt Dateien und/oder Ordner von einem oder mehreren Laptops und legt sie lokal ab. Beim Ablegen darauf achten, dass nichts überschrieben wird, wenn man von mehreren Geräten einsammelt.

- **Cleanup Modus:** löscht die eingesammelten Dateien auf dem Quell-Laptop, aber erst nachdem die Kopie erfolgreich war.

- **Konfigurierbar:** welche Pfade abgeholt werden, soll nicht fix im Skript stehen.

- **Fehlerbehandlung:** Skript soll nicht abstürzen, wenn etwas failed (Gerät nicht erreichbar, Datei fehlt etc...). Am Ende soll eine Übersicht ausgegeben werden, was nicht funktioniert hat.

#### Voraussetzungen:
- **Main Laptop:** man muss auf seinem Mainlaptop mindestens einmal diesen Command pro Laptop ausführen und natürlich auch die Details anpassen:
```powershell
net use * /delete /y
New-SmbMapping -RemotePath "\\10.2.20.xxx\C$" -UserName "TargetLaptopAdminUsername" -Password ""
```
- **Target Laptop:** man muss auf dem Targetlaptop diesen Befehl ausführen:
```powershell
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "LimitBlankPasswordUse" -Value 0 -Force
```
