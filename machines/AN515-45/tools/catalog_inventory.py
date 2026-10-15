"""Read Apple's saved catalog and query installer metadata; never execute it."""
import concurrent.futures
import json
import pathlib
import plistlib
import re
import urllib.request

root = pathlib.Path(__file__).resolve().parents[1]
catalog = plistlib.loads((root / 'downloads/apple-sequoia-public.sucatalog').read_bytes())

def inspect(item):
    product, entry = item
    packages = [p for p in entry.get('Packages', []) if p.get('URL', '').endswith('/InstallAssistant.pkg')]
    if not packages:
        return None
    distributions = entry.get('Distributions', {})
    url = distributions.get('English') or distributions.get('en')
    if not url:
        return None
    try:
        with urllib.request.urlopen(url, timeout=30) as response:
            document = response.read().decode('utf-8')
        def value(keys):
            match = re.search(r'<key>(?:' + keys + r')</key>\s*<string>([^<]+)', document)
            return match.group(1) if match else None
        result = dict(product=product, version=value('macOSProductVersion|VERSION'),
                      build=value('macOSProductBuildVersion|BUILD'),
                      date=str(entry.get('PostDate')), distribution=url, packages=packages)
        if result['version'] == '15.8.1':
            (root / 'downloads' / (product + '.dist')).write_text(document, encoding='utf-8')
        return result
    except Exception as error:
        return dict(product=product, error=str(error), distribution=url)

with concurrent.futures.ThreadPoolExecutor(max_workers=6) as pool:
    results = [r for r in pool.map(inspect, catalog.get('Products', {}).items()) if r]
(root / 'downloads/installer-catalog-inventory.json').write_text(json.dumps(results, indent=2), encoding='utf-8')
for result in results:
    if (result.get('version') or '').startswith('15.') or result.get('error'):
        print(json.dumps(result))
