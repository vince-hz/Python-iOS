#include <Python.h>
#include <stdio.h>

int main(int argc, char **argv) {
    if (argc != 2) return 2;
    wchar_t *home = Py_DecodeLocale(argv[1], NULL);
    if (!home) return 2;
    Py_SetPythonHome(home);
    Py_InitializeEx(0);
    int result = PyRun_SimpleString(
        "import sys, ssl, sqlite3, bz2, ctypes, socket, hashlib, zipfile, io, threading\n"
        "assert sys.version_info[:3] == (3, 11, 18), sys.version\n"
        "assert bz2.decompress(bz2.compress(b'python-ios')) == b'python-ios'\n"
        "assert sqlite3.connect(':memory:').execute('select 42').fetchone() == (42,)\n"
        "assert ctypes.sizeof(ctypes.c_int) == 4\n"
        "assert len(hashlib.sha256(b'python-ios').digest()) == 32\n"
        "data = io.BytesIO()\n"
        "with zipfile.ZipFile(data, 'w', zipfile.ZIP_DEFLATED) as z: z.writestr('test', b'ok')\n"
        "with zipfile.ZipFile(data) as z: assert z.read('test') == b'ok'\n"
        "values = []\n"
        "threads = [threading.Thread(target=lambda i=i: values.append(i)) for i in range(8)]\n"
        "for t in threads: t.start()\n"
        "for t in threads: t.join()\n"
        "assert sorted(values) == list(range(8))\n"
        "print(sys.version, ssl.OPENSSL_VERSION, 'runtime smoke test passed', flush=True)\n"
    );
    Py_Finalize();
    PyMem_RawFree(home);
    return result == 0 ? 0 : 1;
}
