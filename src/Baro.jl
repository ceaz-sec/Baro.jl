module Baro

using JSON3, HTTP, Dates, Logging

include("arg_helper.jl")
include("output_data.jl")
include("pypi.jl")

function getdate()
  date = Dates.now()
  return date
end

function registry_helper1(registry_lookup, status::String)
  try
    isnothing(registry_item) 
    registry_item = something(registry_lookup, status)
    return registry_item
  catch e
    return "Registry item: $registry_item not found - $e"
  end
end

function registry_helper(registry_lookup, status::String)
  try registry_item = something(registry_lookup, status) catch; nothing end
end

function input_file(package_file::String)
  open("$package_file", "r") do f
    readlines(f)
  end
end

function main()
  date = getdate()

  #assessment = Dict{String, Any}() # For Assessment Logic 

  #registry_records = RegistryRecord[] # For NDJSON Records
  
  # Core ARG Functionality
  flags = ["-f", "-md", "-json", "-h", PKG_FILE]

  if "-h" in ARGS || isempty(ARGS)
    println(HELP); exit(0)
  elseif INPUT_FILE
    registry_packages = input_file(PKG_FILE)
  else
    registry_packages = setdiff(ARGS, flags)
  end

  #assessment = Dict{String, Any}() # For Assessment Logic 
  #registry_records = RegistryRecord[] # For NDJSON Records

  for pkg in registry_packages
    baro_banner()
    baro_subject("$pkg", "$date")
    #=println(
            "<=======================>
BARO PRE-INGESTION TRIAGE
<=======================>\n\nPackage: $pkg  | Triage Time: $date" 
            )=#
    # Registry HTTP Response
    resp = requestdata(pkg)
    
    # PyPI Registry Info
    content = JSON3.read(resp.body)
    file = content.urls[1]
    whl_file = file.filename # Grabs Whl file for attestation if present
    name = content.info.name
    regst_info = content.info
    version = content.info.version
    file_name = "$pkg-$(regst_info.version)"

    # Write Header File Data
    WRITE_MD && write_headers(file_name, "$pkg", "$date")
    WRITE_MD && write_subheadings("## Ownship Contact, License, Version and Dependencies.\n", file_name)
    
    # Extract Triage Metadata
    package_summary(regst_info, file_name)
    ownership_check1(regst_info, file_name)
    ownership_check2(regst_info, file_name)
    authorship_check1(regst_info, file_name)
    authorship_check2(regst_info, file_name)
    license_check(regst_info, file_name)
    version_check(regst_info, file_name)
    classifiers_check(regst_info, file_name)
    public_repo_check(regst_info, file_name)
    yanked_check(regst_info, file_name)
    println("--------------------------------------")
    get_digests(file, file_name)
    whl_file_check(file.filename, file_name)
    platform_check(regst_info, file_name)
    requires_py_check(regst_info, file_name)
    depends_py_check(regst_info, file_name)
    println("--------------------------------------")
    # Provenance Data
    attestations, _ = request_prov_data(pkg, version, whl_file)
    _, prov_evidence = request_prov_data(pkg, version, whl_file)
    pub_attest_check(attestations, file_name)
    repo_attest_check(attestations, file_name)
    intg_attest_check(attestations, file_name)
    cert_attest_check(attestations, file_name)
    NDJSON && write_ndjson(package_recs, prov_evidence)
  end
end

export main

end
