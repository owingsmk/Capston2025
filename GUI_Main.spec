# -*- mode: python ; coding: utf-8 -*-


a = Analysis(
    ['GUI_Main.py'],
    pathex=[],
    binaries=[],
    datas=[('scripts', 'scripts'), ('reports', 'reports'), ('images', 'images')],
    hiddenimports=[],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    noarchive=False,
    optimize=0,
)
pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    [],
    exclude_binaries=True,
    name='Security Toolkit',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    console=False,                           #Console is disabled, remember to cd before running spec
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,    
    icon='icon.ico'
)
coll = COLLECT(
    exe,
    a.binaries,
    a.datas,
    strip=False,
    upx=True,
    upx_exclude=[],
    name='GUI_Main',
)
