module Baro

using JSON3, HTTP, Dates, Logging

include("arg_helper.jl")
include("output_data.jl")
include("pypi.jl")

function getdate()
  date = Dates.now()
  return date
end

function registry_helper(registry_lookup, status::String)
  registry_item = something(registry_lookup, status)
  return registry_item
end

function main()
  date = getdate()

  # Core ARG Functionality
  packages = setdiff(ARGS, ["-md"])
  "-h" in ARGS || length(ARGS) <= 0 && (println(HELP); exit(0))

  # Baro Banner
  baro = baro_banner()
  
  for pkg in packages
    println("$baro",
            "## <=======BARO PRE-INGESTION TRIAGE=======>\n\n**Package:** $pkg  | $date" 
            )
    resp = requestdata(pkg)
    # PyPI Registry Info
    content = JSON3.read(resp.body)
    file = content.urls[1]
    whl_file = file.filename # Grabs Whl file for attestation if present
    name = content.info.name
    regst_info = content.info
    version = content.info.version
    println(version)
    file_name = "$pkg-$(regst_info.version)"

    # Provenance Info
    attestations = nothing # Initialize for Guards
    try
      response = request_prov_data(pkg, version, whl_file)
        if isnothing(response) == false
          prov = JSON3.read(response.body)
          attestations = prov.attestation_bundles[1]
        end
    catch err
      @warn "No Provenance file to inspect $err"
      return nothing
    end

    # Write Header File Data
    WRITE_MD && write_headers(baro, file_name, "$pkg", "$date")
    WRITE_MD && write_subheadings("## Ownship Contact, License, Version and Dependencies.\n", file_name)
    
    # Extract Triage Metadata
    ownership_check(regst_info, file_name)
    authorship_check(regst_info, file_name)
    license_check(regst_info, file_name)
    version_check(regst_info, file_name)
    classifiers_check(regst_info, file_name)
    yanked_check(regst_info, file_name)
    println("--------------------------------------")
    get_digests(file, file_name)
    whl_file_check(file.filename, file_name)
    platform_check(regst_info, file_name)
    requires_py_check(regst_info, file_name)
    depends_py_check(regst_info, file_name)
    println("--------------------------------------")
    pub_attest_check(attestations, file_name)
    repo_attest_check(attestations, file_name)
    intg_attest_check(attestations, file_name)
    cert_attest_check(attestations, file_name)
  end
end

export main

end
