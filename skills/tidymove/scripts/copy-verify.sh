#!/usr/bin/env bash
# UNTESTED on macOS/Linux. Requires Bash, Python 3.9+ and rsync 3.x.
# CSV source,target,mode. Dry-run default; --execute copies missing files only.
# No deletes, overwrites, mirrors, source writes or secret contents. Fail closed.
set -eu
exec python3 - "$(cd -- "$(dirname -- "$0")" && pwd)" "$@" <<'PY'
import argparse, csv, datetime, fcntl, hashlib, os, pathlib, re, shutil, stat, subprocess, sys
scriptdir=pathlib.Path(sys.argv.pop(1))
p=argparse.ArgumentParser()
p.add_argument('manifest'); p.add_argument('output_dir')
mode=p.add_mutually_exclusive_group(); mode.add_argument('--execute',action='store_true'); mode.add_argument('--dry-run',action='store_true')
p.add_argument('--verify',choices=['all','sample'],default='all'); p.add_argument('--sample-size',type=int,default=20)
p.add_argument('--fixture-root',help='Synthetic tests only; requires .tidymove-fixture marker')
p.add_argument('--strict-subtree',action='store_true',help='Refuse upfront because ancestor safety checks exceed a strict subtree')
a=p.parse_args()
if a.strict_subtree:
    print('STRICT SUBTREE REFUSED: Safety checks require ancestor metadata through the filesystem root. No manifest, marker or output writes performed.')
    sys.exit(1)
secret=re.compile(r'(^\.env($|\.)|\.env$|^\.(secrets?|ssh|gnupg|aws|azure)($|\.)|vault|passwords?|passwd|credentials?|wallet|creds([._ -]|$)|(^|[._ -])tokens?([._@ -]|$)|client_secret|recovery.codes?|recovery[._ -]*codes?|backup[._ -]*codes?|seed[._ -]*phrases?|private.keys?|private[._ -]*keys?|^id_(rsa|dsa|ecdsa|ed25519)|\.(pem|key|pfx|p12)($|\.)|^auth\.json($|\.)|^hosts\.yml($|\.)|^rclone\.conf($|\.)|^\.netrc$|^\.git-credentials$|^\.clasprc\.json$|(^|[._ -])secrets?([._ -]|$)|^\.(npmrc|pypirc|gitcookies)($|\.)|^\.(docker|kube)($|\.)|^gcloud$|^(Cookies|Login Data|Web Data)($|[.-])|\.(kdbx|keychain|keychain-db)($|\.))',re.I)
def opaque(n): return bool(secret.search(n))
def path(value):
    if not os.path.isabs(value): raise RuntimeError('Absolute paths required')
    q=pathlib.Path(os.path.abspath(value))
    for part in (q,*q.parents):
        if part.is_symlink() or opaque(part.name): raise RuntimeError('Link or opaque path refused')
    return q
def within(x,y): return x==y or y in x.parents
def overlap(x,y): return within(x,y) or within(y,x)
def tree(root,require_frozen=False):
    files={}; dirs=set(); pending=[root]; root_device=root.stat().st_dev
    while pending:
        q=pending.pop(); st=q.lstat()
        if q.is_symlink() or opaque(q.name): raise RuntimeError('Link or opaque entry: '+str(q))
        if st.st_dev!=root_device or (q!=root and os.path.ismount(q)): raise RuntimeError('Nested mount requires a separate manifest row')
        if require_frozen and not (os.statvfs(q).f_flag & os.ST_RDONLY): raise RuntimeError('Writable source subtree refused')
        if getattr(st,'st_flags',0)&0x40000000 or q.suffix.lower()=='.icloud': raise RuntimeError('Cloud placeholder: '+str(q))
        if stat.S_ISDIR(st.st_mode): dirs.add(q); pending.extend(q.iterdir())
        elif stat.S_ISREG(st.st_mode): files[q]=(st.st_size,st.st_mtime_ns)
        else: raise RuntimeError('Special file: '+str(q))
    return files,dirs
def digest(q):
    h=hashlib.sha256()
    with q.open('rb') as f:
        for block in iter(lambda:f.read(1024*1024),b''): h.update(block)
    return h.hexdigest()
def inactive(dst,kind):
    q=dst if kind=='folder' else dst.parent
    if any((part/'.tidymove-active').exists() for part in (q,*q.parents)):
        raise RuntimeError('Activated destination; use a separate new target')
fixture=None
def frozen(src,dst):
    if fixture:
        if src==fixture or dst==fixture or not within(src,fixture) or not within(dst,fixture): raise RuntimeError('Fixture paths must be descendants')
    else:
        subprocess.run(['bash',str(scriptdir/'verify-frozen.sh'),str(src)],check=True,stdout=subprocess.DEVNULL)
def destination(job,q): return job['dst'] if job['kind']=='file' else job['dst']/q.relative_to(job['src'])
fields=['row','source','target','mode','status','files','bytes','sha256_checked','extra_files','copy_exit','checked_utc','log','message']
results=[]; lock=None; output=None; records=[]; records_complete=False; output_ready=False
def save():
    with (output/'verification.csv').open('w',newline='',encoding='utf-8') as f:
        w=csv.DictWriter(f,fieldnames=fields); w.writeheader(); w.writerows(results)
def prepare_output():
    global output_ready
    path(str(output))
    if overlap(output,manifest) or overlap(output,lockpath): raise RuntimeError('Logs, manifest and lock must be disjoint')
    for record in records[1:]:
        if len(record)<2: raise RuntimeError('Cannot establish safe report placement from incomplete path fields')
        for value in record[:2]:
            if not os.path.isabs(value): raise RuntimeError('Cannot establish safe report placement from relative data paths')
            data=path(value)
            if overlap(output,data): raise RuntimeError('Logs and data paths must be disjoint')
    if output.exists(): raise RuntimeError('Output directory must be new')
    output.mkdir(parents=True)
    output_ready=True
def refuse(reason):
    refused=[]
    for n,record in enumerate(records[1:],1):
        refused.append(dict(row=n,source=record[0],target=record[1],mode=record[2] if len(record)>2 else '',stage='preflight',status='REFUSED',reason='Batch refused before any copy: '+reason,exit_code=1))
    if not refused: refused=[dict(row=0,source='',target='',mode='',stage='preflight',status='REFUSED',reason=reason,exit_code=1)]
    with (output/'preflight.csv').open('x',newline='',encoding='utf-8') as f:
        w=csv.DictWriter(f,fieldnames=['row','source','target','mode','stage','status','reason','exit_code']); w.writeheader(); w.writerows(refused)
    print('Preflight CSV: '+str(output/'preflight.csv'))
try:
    manifest=path(a.manifest); output=path(a.output_dir)
    lockpath=path(str(manifest)+'.tidymove-lock')
    with manifest.open(newline='',encoding='utf-8-sig') as f:
        records=list(csv.reader(f,strict=True))
    records_complete=True
    prepare_output()
    if a.sample_size<1: raise RuntimeError('Sample size must be positive')
    fixture=path(a.fixture_root) if a.fixture_root else None
    if fixture and path(str(fixture/'.tidymove-fixture')).read_text().strip()!='Synthetic tidymove test data only': raise RuntimeError('Invalid fixture marker')
    if not shutil.which('rsync'): raise RuntimeError('rsync 3.x required')
    if not records or records[0]!=['source','target','mode']: raise RuntimeError('Header must be source,target,mode')
    if any(len(r)!=3 for r in records): raise RuntimeError('Every manifest record must have exactly three CSV fields')
    rows=[dict(zip(records[0],r)) for r in records[1:]]
    if not rows: raise RuntimeError('Empty manifest')
    jobs=[]
    for r in rows:
        if None in r or any(v is None for v in r.values()): raise RuntimeError('Malformed CSV row')
        src=path(r['source']); dst=path(r['target']); kind=r['mode']
        if kind not in ('file','folder'): raise RuntimeError('mode must be file or folder')
        if src==pathlib.Path('/') or dst==pathlib.Path('/'): raise RuntimeError('Use bounded roots')
        if not src.exists() or (kind=='file')!=src.is_file(): raise RuntimeError('Source absent or wrong mode')
        if dst.exists() and (kind=='file')!=dst.is_file(): raise RuntimeError('Target type conflict')
        if overlap(src,dst) or overlap(output,src) or overlap(output,dst) or within(manifest,src) or within(manifest,dst) or within(lockpath,src) or within(lockpath,dst): raise RuntimeError('Overlapping data/evidence paths')
        jobs.append({'src':src,'dst':dst,'kind':kind})
    for i,j in enumerate(jobs):
        for k,other in enumerate(jobs):
            if overlap(j['dst'],other['src']) or (i!=k and overlap(j['dst'],other['dst'])): raise RuntimeError('Manifest rows overlap')
    lock=open(lockpath,'a'); fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
    for job in jobs:
        src,dst,kind=job['src'],job['dst'],job['kind']; frozen(src,dst); inactive(dst,kind)
        files,dirs=tree(src,not bool(fixture)); job.update(files=files,dirs=dirs,hashes={})
        if dst.exists():
            existing,_=tree(dst)
            if any(q.name=='.tidymove-active' for q in existing): raise RuntimeError('Destination contains an activated subtree')
        chosen=sorted(files)
        if a.verify=='sample': chosen=chosen[:a.sample_size]
        for q in chosen: job['hashes'][q]=digest(q)
        for q in files:
            d=destination(job,q); path(str(d))
            if d.exists():
                if not d.is_file(): raise RuntimeError('Directory blocks file')
                job['hashes'].setdefault(q,digest(q))
                if digest(d)!=job['hashes'][q]: raise RuntimeError('Destination conflict retained: '+str(d))
    for n,job in enumerate(jobs,1):
        src,dst,kind=job['src'],job['dst'],job['kind']; log=output/f'{n:03}.log'
        result=dict(row=n,source=str(src),target=str(dst),mode=kind,status='FAILED',files=len(job['files']),bytes=sum(s[0] for s in job['files'].values()),sha256_checked=0,extra_files=0,copy_exit='',checked_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),log=str(log),message='')
        try:
            frozen(src,dst); inactive(dst,kind)
            if kind=='file':
                with log.open('x') as f:
                    f.write(f'Single file copy; overwrite disabled\nSource: {src}\nTarget: {dst}\nSHA-256: {job["hashes"][src]}\nExecute: {a.execute}\n')
                    path(str(src)); path(str(dst))
                    if a.execute:
                        if dst.exists():
                            if digest(dst)!=job['hashes'][src]: raise RuntimeError('Destination changed after preflight; retained without overwrite')
                            f.write('Identical destination retained.\n')
                        else:
                            dst.parent.mkdir(parents=True,exist_ok=True)
                            # Exclusive creation refuses a file appearing after preflight.
                            with src.open('rb') as source, dst.open('xb') as target:
                                shutil.copyfileobj(source,target)
                            shutil.copystat(src,dst,follow_symlinks=False)
                            f.write('Copied to explicit destination filename.\n')
                    else: f.write('Preview only; no destination writes.\n')
                result['copy_exit']=0
            else:
                if a.execute: dst.mkdir(parents=True,exist_ok=True)
                command=['rsync','--recursive','--times','--ignore-existing','--partial','--protect-args','--itemize-changes']
                if not a.execute: command.append('--dry-run')
                command+=['--',str(src)+'/',str(dst)+'/']
                with log.open('x') as f: completed=subprocess.run(command,stdout=f,stderr=subprocess.STDOUT)
                result['copy_exit']=completed.returncode
                if completed.returncode: raise RuntimeError('rsync failed; inspect row log')
            if not a.execute: result.update(status='DRY-RUN',message='No destination writes; not verified')
            else:
                after,afterdirs=tree(src,not bool(fixture))
                if after!=job['files'] or afterdirs!=job['dirs']: raise RuntimeError('Source metadata changed')
                for q,metadata in job['files'].items():
                    d=destination(job,q); path(str(d))
                    if not d.is_file() or d.stat().st_size!=metadata[0]: raise RuntimeError('Missing or different size: '+str(d))
                    if q in job['hashes']:
                        if digest(d)!=job['hashes'][q] or digest(q)!=job['hashes'][q]: raise RuntimeError('SHA-256 mismatch or source changed')
                        result['sha256_checked']+=1
                if kind=='folder':
                    for d in job['dirs']:
                        if not (dst/d.relative_to(src)).is_dir(): raise RuntimeError('Missing directory')
                    copied,_=tree(dst)
                    if len(copied)<len(job['files']): raise RuntimeError('Destination file count is smaller than the selected source set')
                    result['extra_files']=len(copied)-len(job['files'])
                frozen(src,dst)
                result.update(status='VERIFIED-ALL' if a.verify=='all' else 'VERIFIED-SAMPLE',message='All expected paths/sizes checked; extras retained; activation separate')
        except Exception as e: result['message']=str(e)
        results.append(result); save(); print(f"Row {n}: {result['status']}")
        if result['status']=='FAILED': raise RuntimeError(result['message'])
    print('Verification CSV: '+str(output/'verification.csv'))
except Exception as e:
    if not results:
        try:
            if not output_ready:
                if not records_complete: raise RuntimeError('Manifest paths could not be established safely')
                prepare_output()
            refuse(str(e))
        except Exception as report_error:
            print('REPORT NOT WRITTEN: '+str(report_error)+'. Choose a fresh, disjoint output path and retain this console refusal.',file=sys.stderr)
    print('STOP: '+str(e),file=sys.stderr); sys.exit(1)
finally:
    if lock: lock.close()
PY
