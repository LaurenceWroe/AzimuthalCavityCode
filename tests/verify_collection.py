"""Verify the research snapshot against the collection-time checksums."""
from pathlib import Path
import hashlib
import json

root = Path(__file__).resolve().parents[1]
records = json.loads((root / 'SOURCE_MANIFEST.json').read_text())
for record in records:
    path = root / record['collected']
    assert path.stat().st_size == record['bytes'], path
    assert hashlib.sha256(path.read_bytes()).hexdigest() == record['sha256'], path
print(f'PASS: {len(records)} collected research files match their source checksums.')
