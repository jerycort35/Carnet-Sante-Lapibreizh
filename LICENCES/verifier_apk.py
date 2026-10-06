#!/usr/bin/env python3
"""Contrôle de l'APK produite par le workflow existant ; Android Build Tools requis."""
import argparse, re, shutil, subprocess
from pathlib import Path

parser=argparse.ArgumentParser()
parser.add_argument('apk',type=Path)
args=parser.parse_args()
expected='54d2b9c7de7c8997f64e24bab95627adbca4684b36fda9a7d45c909b5b63c892'
if not args.apk.is_file():parser.error('APK introuvable')
for tool in ['apksigner','aapt']:
 if not shutil.which(tool):parser.error(f'{tool} manquant : ajouter Android SDK Build Tools au PATH')
sig=subprocess.run(['apksigner','verify','--verbose','--print-certs',str(args.apk)],capture_output=True,text=True,check=True).stdout
fingerprints=re.findall(r'certificate SHA-256 digest:\s*([a-fA-F0-9]+)',sig)
if fingerprints!=[expected]:raise SystemExit('Signature différente de l’APK de référence. Ne pas désinstaller pour contourner ce problème.')
info=subprocess.run(['aapt','dump','badging',str(args.apk)],capture_output=True,text=True,check=True).stdout
package=re.search(r"package: name='([^']+)' versionCode='(\d+)'",info)
if not package or package.group(1)!='fr.leslapibreizh.carnetsante' or int(package.group(2))<=46:raise SystemExit('Identifiant ou versionCode incorrect')
if 'application-debuggable' in info:raise SystemExit('APK debug à ne pas distribuer')
print('Signature permanente, identifiant et versionCode contrôlés. L’installation réelle par-dessus la version actuelle reste à tester sur téléphone.')
