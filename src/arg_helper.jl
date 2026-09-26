const INPUT_FILE = "-f" in ARGS
const WRITE_MD = "-md" in ARGS
const PKG_FILE_IDX = findfirst(endswith(".txt"), ARGS)
const PKG_FILE = isnothing(PKG_FILE_IDX) ? "" : ARGS[PKG_FILE_IDX]

const HELP = """
Usage: julia baro.jl [packages] [flags]

Flags:
  -f        use an input file(reads line by line)
  -md       write markdown report
  -h        show help info

Examples:
  julia baro requests click -md
  julia baro -f packages.txt -md
  julia baro requests -md 
"""
