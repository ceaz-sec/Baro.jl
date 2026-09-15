#!/usr/bin/env julia
using JSON3, JSON, HTTP, Dates, Logging

const WRITE_MD = "-md" in ARGS
const WRITE_JSON = "-json" in ARGS
const PKG_FILE = "-i" in ARGS

const HELP = """
Usage: julia baro.jl [packages] [flags]

Flags:
  -md       write markdown report
  -json     write ndjson report
  -h        show help info

Input:
  packages.txt  one package per line

Examples:
  julia tool.jl requests click -md
  julia baro.jl packages.txt -json
  julia baro.jl requests -md -json
"""

function requestdata(pkg)
  # Request Data from the Package Registry
  # version = nothing
  resp = HTTP.get("https://pypi.org/pypi/$pkg/json")
  return resp
end

function request_prov_data(pkg, version, whl_file)
  provenance_url = "https://pypi.org/integrity/$pkg/$version/$whl_file/provenance"
  response = HTTP.get(provenance_url)
  return response
end

function getdate()
  date = Dates.now()
  return date
end

function write_mkd(field::String, status, file_name::String)
  open("./reports/$file_name.md", "a") do io
    if occursin("Depends", field) || occursin("Requires", field)
      println(io, "> $field: $status\n")
    else
      println(io, "$field\n- $status\n")
    end
  end
end

function write_headers(data::String, file_name::String, pkg::String="", date::String="")
  baro = ("
 ██████╗  █████╗ ██████╗  ██████╗
 ██╔══██╗██╔══██╗██╔══██╗██╔═══██╗
 ██████╔╝███████║██████╔╝██║   ██║
 ██╔══██╗██╔══██║██╔══██╗██║   ██║
 ██████╔╝██║  ██║██║  ██║╚██████╔╝
 ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ 
")
  open("./reports/$file_name.md", "a") do io
    println(io, "```$baro
```\n")
    println(io, "---")
    date = getdate()
    println(io, "**Package**: $pkg  | $date\n")
  end
end

function write_subheadings(data::String, file_name)
  open("./reports/$file_name.md", "a") do io
    println(io, data)
  end
end

function registry_helper(registry_lookup, status::String)
  registry_item = something(registry_lookup, status)
  return registry_item
end

function ownership_check(regst_info, file_name) #;output = "$file_name" karg
  maintainer = something(regst_info.maintainer,"Not Found")
  maintainer_email = something(regst_info.maintainer_email, "Not Found")
  if maintainer == "Not Found" || mainter_email "Not Found"
    return @warn "Maintainer Info not found"
  elseif maintainer || maintainer_email
    WRITE_MD && write_mkd("**Maintainer**", maintainer, file_name)
    WRITE_MD && write_mkd("**Maintainer Email**", maintainer_email, file_name)
  end
end

function authorship_check(regst_info, file_name)
  author = something(regst_info.author, "Not Found")
  author_email = something(regst_info.author, "Not Found")
  if author == "Not Found" || author_email == "Not Found"
    return @warn "Author Information not found" #Sutract from score by 2
  else
    WRITE_MD && write_mkd("**Author**", author, file_name)
    WRITE_MD && write_mkd("**Author Email**", author_email, file_name)
    return @info "Author Information: $author\n$author_email"
  end
end

function yanked_check(regst_info, file_name)
  yanked = something(regst_info.yanked, "Not Found")
  yanked_reason = something(regst_info.yanked_reason, "False"); yanked_status = yanked 
  if yanked && WRITE_MD
    write_mkd("**Yanked Status**", "$yanked_reason\n---", "YES")
  elseif WRITE_MD
    write_mkd("**Yanked Status**", "$yanked \n\n---", file_name)
  end
end

function license_check(regst_info, file_name)
  license = registry_helper(regst_info.license, "Not Found")
  license_expression = registry_helper(regst_info.license_expression, "Not Found")
  if license == "Not Found"
    WRITE_MD && write_mkd("**License**", license, file_name)
  elseif license_expression == "Not Found"
    WRITE_MD && write_mkd("**License Expression**", license_expression, file_name)
  else
    return @info "License Info: $license\n"
    return @info "License Expression: $license_expression\n"
  end
end

function version_check(regst_info, file_name)
  version = registry_helper(regst_info.version, "Not Provided")
  WRITE_MD && write_mkd("**Version**", version, file_name)
  return @info "Version Info: $version\n"
end

function whl_file_check(file, file_name)
  whl_file = registry_helper(file, "Not Provided")
  WRITE_MD && write_mkd("**Release**", whl_file, file_name)
  if whl_file == "Not Provided"
    return @warn "Release Info: Not Provided"
  else
    return @info "Release Info: $whl_file" 
  end
end

function get_digests(file, file_name)
  sha256 = registry_helper(file.digests.sha256, "Not Provided")
  WRITE_MD && write_mkd("**SHA256**", sha256, file_name)
end

function platform_check(regst_info, file_name)
  platform = registry_helper(regst_info.platform, "Not Provided")
  WRITE_MD && write_mkd("**Platform**", "$platform \n", file_name)
end

function requires_py_check(regst_info, file_name)
  requires_py = registry_helper(regst_info.requires_python, "Nothing Found")
  WRITE_MD && write_mkd("Requires Python", requires_py, file_name)
end

function depends_py_check(regst_info, file_name)
  depends_py = registry_helper(regst_info.requires_dist, "No Dependencies Found")
  WRITE_MD && write_mkd("Depends on Python", depends_py, file_name)
end

function pub_attest_check(attestations, file_name)
  publisher = registry_helper(attestations.publisher.kind, "No Publisher Found")
  WRITE_MD && write_mkd("**Publisher**", publisher, file_name)
end

function intg_attest_check(attestations, file_name)
  integrated_time = registry_helper(attestations.attestations[1].verification_material.transparency_entries[1].integratedTime, "Nothing Found")
  WRITE_MD && write_mkd("**Integrated Time**", integrated_time, file_name)
end

function repo_attest_check(attestations, file_name)
  repo = registry_helper(attestations.publisher.repository, "No Repository Info Found")
  WRITE_MD && write_mkd("**Repository**", repo, file_name)
end

function main()
  date = getdate()
  # Need to add If else here based off of selection
  # Perhaps an outfile from write_mkd only if selected

  baro = ("
██████╗  █████╗ ██████╗  ██████╗
██╔══██╗██╔══██╗██╔══██╗██╔═══██╗
██████╔╝███████║██████╔╝██║   ██║
██╔══██╗██╔══██║██╔══██╗██║   ██║
██████╔╝██║  ██║██║  ██║╚██████╔╝
╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ 
")
  # Core Functionality
  packages = setdiff(ARGS, ["-md", "-json"])
  "-h" in ARGS || length(ARGS) <= 0 && (println(HELP); exit(0))
  
  for pkg in packages
    println("$baro",
            "## <=======CEAZ Build Integrity Triage=======>\n\n**Package:** $pkg  | $date" 
            )
    resp = requestdata(pkg)
    # PyPI Registry Info
    content = JSON3.read(resp.body)
    file = content.urls[1]
    whl_file = file.filename #Grabs Whl file for attestation
    name = content.info.name
    regst_info = content.info
    version = content.info.version
    println(version)
    file_name = "$pkg-$(regst_info.version)"

    # Provenance Info
    response = request_prov_data(pkg, version, whl_file)
    prov = JSON3.read(response.body)
    attestations = prov.attestation_bundles[1]

    # Write Header File Data
    WRITE_MD && write_headers(baro, file_name, "$pkg", "$date")


    # Extract Triage Data
    WRITE_MD && write_subheadings("## Ownship Contact, License, Version and Dependencies.\n", file_name)
    println("## Ownship Contact, License, Version and Dependencies.\n\n",
            ownership_check(regst_info, file_name),
            authorship_check(regst_info, file_name),
            license_check(regst_info, file_name),
            version_check(regst_info, file_name),
            yanked_check(regst_info, file_name),
            "---",
            "## SHA Digests, Yanked Status, Package Types and Public Repository Info.\n\n", 
            get_digests(file, file_name),
            whl_file_check(file.filename, file_name),
            platform_check(regst_info, file_name),
            requires_py_check(regst_info, file_name),
            depends_py_check(regst_info, file_name),
            pub_attest_check(attestations, file_name),
            repo_attest_check(attestations, file_name),
            intg_attest_check(attestations, file_name),
            "\n\n"
           )
  end
end

main()
