# Capture Fixtures

Synthetic offline capture samples for passive forensic analysis.

- `normal-mix.pcap` – mixed DNS/HTTP/TLS traffic with routine patterns.
- `anomalous-mix.pcapng` – mixed routine traffic plus malformed packet structures.

## Bring your own captures

Drop your lab-owned files into:

- `fixtures/captures/imports/`

Supported input formats:

- `.pcap`
- `.pcapng`

These captures are never transmitted. Analysis is file-only and local/offline.
