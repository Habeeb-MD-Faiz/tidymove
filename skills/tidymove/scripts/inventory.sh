#!/usr/bin/env bash
# UNTESTED on macOS/Linux. Requires Bash and Python 3.9+; does not invoke Git.
# Metadata only. Direct-child totals avoid double counting. Secret names stay opaque.
set -eu
exec python3 - "$(cd -- "$(dirname -- "$0")" && pwd)" "$@" <<'PY'
import argparse, csv, datetime, os, pathlib, re, stat, subprocess, sys
scriptdir = pathlib.Path(sys.argv.pop(1))
p = argparse.ArgumentParser()
p.add_argument('root')
p.add_argument('output_csv')
p.add_argument('--allow-live-scan', action='store_true', help='Metadata reconciliation only; not permission to copy a live source')
a = p.parse_args()
secret = re.compile(r'(^\.env($|\.)|\.env$|^\.(secrets?|ssh|gnupg|aws|azure)($|\.)|vault|credentials?|creds([._-]|$)|(^|[._-])tokens?([._@-]|$)|client_secret|recovery.codes?|private.keys?|^id_(rsa|dsa|ecdsa|ed25519)|\.(pem|key|pfx|p12)($|\.)|^auth\.json($|\.)|^hosts\.yml($|\.)|^rclone\.conf($|\.)|^\.netrc$|^\.git-credentials$|^\.clasprc\.json$|(^|[._-])secrets?([._-]|$)|^\.(npmrc|pypirc|gitcookies)($|\.)|^\.(docker|kube)($|\.)|^gcloud$|^(Cookies|Login Data|Web Data)($|[.-])|\.(kdbx|keychain|keychain-db)($|\.))', re.I)
def opaque(name):
    return bool(secret.search(name))
def safe(path):
    if not path.is_absolute(): raise RuntimeError('Absolute paths required')
    for part in (path,*path.parents):
        if part.is_symlink(): raise RuntimeError('Symlink ancestor refused')
        if opaque(part.name): raise RuntimeError('Opaque location refused')
def within(child,parent):
    return child == parent or parent in child.parents
def utc(t): return datetime.datetime.fromtimestamp(t,datetime.timezone.utc).isoformat()
fields=['kind','path','bytes','file_count','oldest_utc','newest_utc','type_mix','repo','dirty','detail']
rows=[]; errors=0
def row(kind,path,**kw): rows.append(dict.fromkeys(fields,'') | {'kind':kind,'path':str(path)} | kw)
try:
    if not os.path.isabs(a.root) or not os.path.isabs(a.output_csv): raise RuntimeError('Absolute paths required')
    root=pathlib.Path(os.path.abspath(a.root)); output=pathlib.Path(os.path.abspath(a.output_csv))
    safe(root); safe(output)
    if within(output,root): raise RuntimeError('Output must be outside source')
    if output.exists(): raise RuntimeError('Use a new evidence path')
    if not a.allow_live_scan: subprocess.run(['bash',str(scriptdir/'verify-frozen.sh'),str(root)],check=True)
    if not root.is_dir(): raise RuntimeError('This scan expects a directory root')
    pending=[root]; root_device=root.stat().st_dev
    while pending:
        folder=pending.pop(); files=[]; types={}; repo=''; dirty=''
        try:
            for item in folder.iterdir():
                st=item.lstat()
                if opaque(item.name): row('secret-name',item,detail='Not opened or traversed'); continue
                if stat.S_ISLNK(st.st_mode): row('link-or-cloud',item,detail='Not followed'); continue
                if st.st_dev!=root_device or os.path.ismount(item):
                    row('mount-boundary',item,detail='Inventory as a separately frozen source'); continue
                # macOS dataless files and common provider placeholders need owner recovery.
                if getattr(st,'st_flags',0) & 0x40000000 or item.suffix.lower()=='.icloud':
                    row('cloud-placeholder',item,detail='Not opened'); continue
                if item.is_dir(): pending.append(item)
                elif stat.S_ISREG(st.st_mode): files.append(st); types[item.suffix]=types.get(item.suffix,0)+1
                else: row('special-file',item,detail='Not opened')
            marker=folder/'.git'
            if marker.is_symlink() or (marker/'commondir').exists(): repo='linked'; dirty='needs-checking'
            elif marker.is_file(): repo='worktree'; dirty='needs-checking'
            elif marker.is_dir() and marker.stat().st_dev==root_device and not os.path.ismount(marker):
                repo='repository'
                dirty='needs-checking'  # Metadata only: Git can read contents and repository-controlled config.
            dates=sorted(f.st_mtime for f in files)
            row('folder',folder,bytes=sum(f.st_size for f in files),file_count=len(files),oldest_utc=utc(dates[0]) if dates else '',newest_utc=utc(dates[-1]) if dates else '',type_mix=';'.join(f'{k}:{v}' for k,v in sorted(types.items())),repo=repo,dirty=dirty,detail='Direct children; inspect exclusion rows')
        except Exception as e:
            errors+=1; row('error',folder,detail=type(e).__name__)
    output.parent.mkdir(parents=True,exist_ok=True)
    with output.open('x',newline='',encoding='utf-8') as stream:
        writer=csv.DictWriter(stream,fieldnames=fields); writer.writeheader(); writer.writerows(rows)
    print(f'Inventory rows: {len(rows)}; errors: {errors}; CSV: {output}')
    sys.exit(2 if errors else 0)
except Exception as e:
    print('STOP: '+str(e),file=sys.stderr); sys.exit(1)
PY
