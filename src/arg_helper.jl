const INPUT_FILE = "-f" in ARGS
const WRITE_MD = "-md" in ARGS
const NDJSON = "-json" in ARGS
const PKG_FILE_IDX = findfirst(endswith(".txt"), ARGS)
const PKG_FILE = isnothing(PKG_FILE_IDX) ? "" : ARGS[PKG_FILE_IDX]

const HELP = """
Usage: julia baro.jl [packages] [flags]

Flags:
  -f        use an input file(reads line by line)
  -md       write markdown report
  -json     write to ndjson record
  -h        show help info

Examples:
  julia baro requests click -md # No input file
  julia baro -f packages.txt -md # Input file and markdown report
  julia baro requests # Print only to Terminal output
  julia baro boto3 -md -json # Creates both markdown report and writes to ndjson record.
"""
