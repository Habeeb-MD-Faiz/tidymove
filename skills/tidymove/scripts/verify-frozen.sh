#!/usr/bin/env bash
# UNTESTED on macOS/Linux. Requires Bash and Python 3; Linux also needs findmnt.
# Inspect mount flags only. Never create a test file or alter the mount.
set -eu
exec python3 - "$@" <<'PY'
import argparse, json, os, pathlib, plistlib, subprocess, sys
p = argparse.ArgumentParser(description='Prove the current local mount read-only without writing')
p.add_argument('root')
a = p.parse_args()
try:
    if not os.path.isabs(a.root):
        raise RuntimeError('Absolute source path required')
    path = pathlib.Path(os.path.abspath(a.root))
    for item in (path, *path.parents):
        if item.is_symlink():
            raise RuntimeError('Symlink paths require a separate reviewed mapping')
    if not path.exists():
        raise RuntimeError('Source absent')
    if sys.platform.startswith('linux'):
        out = subprocess.run(['findmnt', '--json', '--target', str(path), '--output', 'TARGET,SOURCE,FSTYPE,OPTIONS'], capture_output=True, check=True, text=True)
        mounts = json.loads(out.stdout)['filesystems']
        if len(mounts) != 1:
            raise RuntimeError('Ambiguous mount')
        mount = mounts[0]
        if mount['fstype'] in ('nfs','nfs4','cifs','smb3','overlay','fuse','fuseblk') or mount['fstype'].startswith('fuse.'):
            raise RuntimeError('Remote/virtual filesystem needs separate evidence')
        frozen = 'ro' in mount['options'].split(',')
    elif sys.platform == 'darwin':
        mountpath = path if path.is_dir() else path.parent
        while mountpath.parent != mountpath and mountpath.parent.stat().st_dev == mountpath.stat().st_dev:
            mountpath = mountpath.parent
        out = subprocess.run(['diskutil','info','-plist',str(mountpath)], capture_output=True, check=True)
        info = plistlib.loads(out.stdout)
        frozen = info.get('ReadOnlyVolume') is True
        mount = {'target':str(mountpath), 'source':info.get('DeviceIdentifier','unknown')}
    else:
        raise RuntimeError('Unsupported platform')
    if not frozen:
        raise RuntimeError('Read-only mount not proved')
    print(json.dumps({'read_only':True,'root':str(path),'mount':mount,'limitation':'Current mount observation; recheck after reconnect'}))
except Exception as e:
    print('NOT PROVED: '+str(e), file=sys.stderr)
    sys.exit(1)
PY
