using JSON3, HTTP

function requestdata(pkg)
  # Request Data from the Package Registry
  resp = HTTP.get("https://pypi.org/pypi/$pkg/json")
  return resp
end

function request_prov_data(pkg, version, whl_file)
  provenance_url = "https://pypi.org/integrity/$pkg/$version/$whl_file/provenance"
  try
    response = HTTP.get(provenance_url)
    return response
  catch err
    WRITE_MD && write_mkd("**Provenance**", "Not Found in Registry", whl_file)
    @warn "Provenance Not Found: $err"
    return nothing
  finally
    @info "Provenance check complete for $pkg $version"
  end
end

