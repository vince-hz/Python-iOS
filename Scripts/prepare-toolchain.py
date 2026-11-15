from pathlib import Path

recipes = Path('kivy-ios/kivy_ios/recipes')
for name in ('hostpython3', 'python3'):
    path = recipes / name / '__init__.py'
    source = path.read_text()
    assert 'version = "3.11.6"' in source or 'version = "3.11.18"' in source
    path.write_text(source.replace('version = "3.11.6"', 'version = "3.11.18"'))
# Use HTTPS for source archives.
for name in ('hostopenssl', 'openssl'):
    path = recipes / name / '__init__.py'
    path.write_text(path.read_text().replace('http://www.openssl.org/source/', 'https://www.openssl.org/source/'))

# Both simulator architectures share one lipo archive. Pass it only once.
path = Path('kivy-ios/kivy_ios/toolchain.py')
source = path.read_text()
source = source.replace(
    '''            for plat in self.platforms_to_build:
                static_fn = join(self.ctx.dist_dir, "lib", plat.sdk, library_fn)
                xcframework_args.extend(["-library", static_fn])''',
    '''            for sdk in dict.fromkeys(plat.sdk for plat in self.platforms_to_build):
                static_fn = join(self.ctx.dist_dir, "lib", sdk, library_fn)
                xcframework_args.extend(["-library", static_fn])''',
)
path.write_text(source)

# Xcode 27 rejects libffi's legacy iOS 8 deployment target.
path = recipes / 'libffi' / '__init__.py'
source = path.read_text().replace('"ONLY_ACTIVE_ARCH=NO",', '"ONLY_ACTIVE_ARCH=NO",\n                "IPHONEOS_DEPLOYMENT_TARGET=15.0",')
if '"IPHONEOS_DEPLOYMENT_TARGET=15.0"' not in path.read_text():
    path.write_text(source)

# The SDK advertises pipe2, but the build host may not provide it at runtime.
path = recipes / 'hostpython3' / '__init__.py'
source = path.read_text()
if '"ac_cv_func_pipe2=no"' not in source:
    source = source.replace('"ac_cv_func_preadv=no",', '"ac_cv_func_preadv=no",\n                    "ac_cv_func_pipe2=no",')
path.write_text(source)

# Refresh the static-extension patch against the 3.11.18 source layout.
(recipes / 'python3' / 'dynload_shlib.patch').write_text(
    Path('Scripts/patches/dynload_shlib.patch').read_text())

# Only CPython is built here; setuptools cross-compilation patches are unused.
# Newer bundled setuptools no longer matches these legacy patches.
path = recipes / 'hostpython3' / '__init__.py'
source = path.read_text()
marker = '        # hostpython3 installs bundled versions'
if marker in source:
    source = source[:source.index(marker)] + '\n\nrecipe = Hostpython3Recipe()\n'
path.write_text(source)

# CPython supplies Expat entropy through XML_SetHashSalt; the new vendored
# Expat no longer ships the /dev/urandom header. It also adds xcs.c.
path = recipes / 'python3' / 'ModulesSetup'
source = path.read_text().replace(' -DXML_DEV_URANDOM', '')
if 'expat/xcs.c' not in source:
    source = source.replace('pyexpat expat/xmlparse.c', 'pyexpat expat/xcs.c expat/xmlparse.c')
path.write_text(source)
