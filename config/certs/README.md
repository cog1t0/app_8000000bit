# Certificates

This directory stores custom CA / intermediate certificates required for external HTTP(S) integrations.

Current contents:
- `JPRS_DVCA_G4.pem`: Intermediate certificate (JPRS Domain Validation Authority - G4) required because the remote server for `chi92.suinavi.com` does not currently send the intermediate chain. Provided here so Net::HTTP peer verification can succeed without disabling verification.
- `SECOM_ROOTCA2.pem`: Root CA (Security Communication RootCA2) added because local OpenSSL (Ruby) may not trust macOS keychain automatically.

## Updating / Renewal
1. Fetch (if upstream becomes reachable):
   curl -fSL -o JPRS_DVCA_G4.cer http://repo.pubcert.jp/sppca/jprs/dvca_g4/JPRS_DVCA_G4_DER.cer
2. Convert to PEM:
   openssl x509 -inform DER -in JPRS_DVCA_G4.cer -out JPRS_DVCA_G4.pem
3. Sanity check:
   openssl x509 -in JPRS_DVCA_G4.pem -noout -subject -issuer -dates -fingerprint -sha256
4. Commit updated PEM.

## When the fetch URL is unreachable
If `repo.pubcert.jp` is not resolvable, manually obtain the intermediate via a trusted source (browser certificate viewer) and export as DER, then convert using step 2 above.

## Environment usage
Set `SSL_CA_FILE` to the absolute path of this PEM when running the fetcher (development / jobs):
   export SSL_CA_FILE="$(pwd)/config/certs/JPRS_DVCA_G4.pem:$(pwd)/config/certs/SECOM_ROOTCA2.pem"

Avoid using `MEISHIKI_FETCHER_INSECURE=1` except for temporary diagnostics.
