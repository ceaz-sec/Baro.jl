
const WRITE_MD = "-md" in ARGS
const WRITE_JSON = "-json" in ARGS
const PKG_FILE = "-i" in ARGS

const HELP = """
Usage: julia baro.jl [packages] [flags]

Flags:
  -md       write markdown report
  -json     write ndjson report
  -h        show help info

Examples:
  julia tool.jl requests click -md
  julia baro.jl packages.txt -json
  julia baro.jl requests -md -json
"""
