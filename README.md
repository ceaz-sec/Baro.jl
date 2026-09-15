# BARO

```
██████╗  █████╗ ██████╗  ██████╗
██╔══██╗██╔══██╗██╔══██╗██╔═══██╗
██████╔╝███████║██████╔╝██║   ██║
██╔══██╗██╔══██║██╔══██╗██║   ██║
██████╔╝██║  ██║██║  ██║╚██████╔╝
╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ 
```

## BARO OSS Triage

PyPI package security triaging tool. It finds license, author version and evidence of provenance.

---

## Usage
baro.jl [packages] [flags]

## Flags

| Flag | Description |
|------|-------------|
| `md` | write a markdown report |
| `-json` | write a ndjson report |
| `-h` | help |

## Examples
baro.jl requests click flask -md
baro.jl requests -md -json
baro.jl botocore idna selenium # prints terminal output only

## Dependencies
pkg add HTTP JSON3

---
