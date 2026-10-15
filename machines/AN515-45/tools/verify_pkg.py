"""Verify an Apple InstallAssistant.pkg (xar) against its catalog Digest and its TOC checksums.

The catalog `Digest` is the SHA-1 of the compressed xar TOC (checked on the known-good 15.8.1 pkg);
the TOC then holds an archived-checksum for every heap entry, so this covers the whole payload.
Usage: py -3.12 -I tools/verify_pkg.py <InstallAssistant.pkg> <catalog-digest>
"""
import hashlib, struct, sys, zlib
import xml.etree.ElementTree as ET

path, digest = sys.argv[1], sys.argv[2].lower()
with open(path, "rb") as f:
    magic, hs, _ver, tc, _tu, alg = struct.unpack(">4sHHQQI", f.read(28))
    assert magic == b"xar!" and alg == 1, "not a SHA-1 xar archive"
    f.seek(hs)
    toc = f.read(tc)
    assert hashlib.sha1(toc).hexdigest() == digest, "TOC SHA-1 differs from catalog Digest"
    root = ET.fromstring(zlib.decompress(toc))
    heap = hs + tc
    ck = root.find("toc/checksum")
    f.seek(heap + int(ck.find("offset").text))
    assert f.read(int(ck.find("size").text)).hex() == digest, "stored TOC checksum mismatch"
    n = 0
    for data in root.iter("data"):
        ac = data.find("archived-checksum")
        assert ac.get("style") == "sha1"
        h, left = hashlib.sha1(), int(data.find("length").text)
        f.seek(heap + int(data.find("offset").text))
        while left:
            chunk = f.read(min(left, 1 << 24))
            assert chunk, "truncated heap"
            h.update(chunk)
            left -= len(chunk)
        assert h.hexdigest() == ac.text.strip().lower(), "payload checksum mismatch"
        n += 1
print(f"OK: TOC matches catalog Digest; {n} payload entries match their TOC SHA-1")
