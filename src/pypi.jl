using HTTP, JSON3, Dates

# Request PyPi Data
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

# Check for Signs of Ownership
function ownership_check(regst_info, file_name) #;output = "$file_name" karg
  if !isnothing(regst_info.maintainer)
    maintainer = something(regst_info.maintainer,"Not Found")
    WRITE_MD && write_mkd("**Maintainer**", maintainer, file_name)
    return @info "Maintainer Information: $maintainer"
  elseif !isnothing(regst_info.maintainer_email)
    maintainer_email = something(regst_info.maintainer_email, "Not Found")
    WRITE_MD && write_mkd("**Maintainer Email**", maintainer_email, file_name)
    return @info "Maintainer Info: $maintainer_email"
  elseif isnothing(regst_info.maintainer)
    return @warn "Maintainer Info Not Found"
  elseif isnothing(regst_info.maintainer_email)
    return @warn "Maintainer Email Not Found"
  end
end

function authorship_check(regst_info, file_name)
  if !isnothing(regst_info.author)
    author = something(regst_info.author, "Not Found")
    WRITE_MD && write_mkd("**Author**", author, file_name)
    return @warn "Author Information not found" #Sutract from score by 2
  elseif !isnothing(regst_info.author_email)
    author_email = something(regst_info.author_email, "Not Found")
    WRITE_MD && write_mkd("**Author Email**", author_email, file_name)
    return @info "Author Information: $author_email"
  end
end

# PyPi Metadata Check
function yanked_check(regst_info, file_name)
  yanked = something(regst_info.yanked, "Not Found")
  yanked_reason = something(regst_info.yanked_reason, "False"); yanked_status = yanked 
  if yanked && WRITE_MD
    write_mkd("**Yanked Status**", "$yanked_reason\n---", "YES")
    return @warn "Yanked Status: $yanked, Reason: yanked_reason"
  elseif WRITE_MD
    write_mkd("**Yanked Status**", "$yanked \n\n---", file_name)
    return @info "Yanked Status: $yanked\n"
  end
end

function license_check(regst_info, file_name)
  license = registry_helper(regst_info.license, "Not Found")
  license_expression = registry_helper(regst_info.license_expression, "Not Found")
  if !isnothing(regst_info.license)
    WRITE_MD && write_mkd("**License**", license, file_name)
  elseif !isnothing(regst_info.license_expression)
    #license_expression = registry_helper(regst_info.license_expression, "Not Found")
    license_exp = first(license_expression, 16) * "..."
    WRITE_MD && write_mkd("**License Expression**", license_exp, file_name)
  else
    return @info "License Info: $license\n"
    return @info "License Expression: $license_exp\n"
  end
end

function version_check(regst_info, file_name)
  if !isnothing(regst_info.version)
    version = registry_helper(regst_info.version, "Not Provided")
    WRITE_MD && write_mkd("**Version**", version, file_name)
    return @info "Version Info: $version\n"
  end
end

function classifiers_check(regst_info, file_name)
  development_status = registry_helper(regst_info.classifiers[1], "Not Found")
  if occursin("Production", development_status) && !isnothing(development_status)
    WRITE_MD && write_mkd("**Development Status**", development_status, file_name)
    return @info "$development_status"
  elseif occursin("Dev", development_status) && !isnothing(development_status)
    WRITE_MD && write_mkd("**Development Status**", development_status, file_name)
    return @warn "$development_status - This is for development currently"
  else
    return @warn "Development Status: Not Found"
  end
end

function whl_file_check(whl_file, file_name)
  if !isnothing(whl_file)
    whl_file = registry_helper(whl_file, "Not Provided")
    WRITE_MD && write_mkd("**Release**", whl_file, file_name)
    return @info "Release Info: $whl_file"
  else
    return @warn "Release Info: Not Provided"
  end
end

function get_digests(file, file_name)
  if !isnothing(file.digests.sha256)
    sha256 = registry_helper(file.digests.sha256, "Not Provided")
    WRITE_MD && write_mkd("**SHA256**", sha256, file_name)
    return @info "SHA256: $sha256"
  else
    return @warn "SHA256 Not Found"
  end
end

function platform_check(regst_info, file_name)
  platform = registry_helper(regst_info.platform, "Not Provided")
  WRITE_MD && write_mkd("**Platform**", "$platform \n", file_name)
  return @info "Platform Info: $platform"
end

function requires_py_check(regst_info, file_name)
  requires_py = registry_helper(regst_info.requires_python, "Nothing Found")
  WRITE_MD && write_mkd("Requires Python", requires_py, file_name)
  return @info "Required Python: $requires_py"
end

function depends_py_check(regst_info, file_name)
  depends_py = registry_helper(regst_info.requires_dist, "No Dependencies Found")
  WRITE_MD && write_mkd("Depends on Python", depends_py, file_name)
  return @info "Dependencies: $depends_py"
end

# Search for Provenance Evidence
function intg_attest_check(attestations, file_name)
  if !isnothing(attestations)
    integrated_time = registry_helper(attestations.attestations[1].verification_material.transparency_entries[1].integratedTime, "Nothing Found")
    WRITE_MD && write_mkd("**Integrated Time**", integrated_time, file_name)
    return @info "Integrated Time: $integrated_time"
  else
    return @warn "Attestation Integrated Time Not Found"
  end
end

function repo_attest_check(attestations, file_name)
  if !isnothing(attestations)
    repo = registry_helper(attestations.publisher.repository, "No Repository Info Found")
    WRITE_MD && write_mkd("**Repository**", repo, file_name)
    return @info "Repository: $repo"
  else
    @warn "Attestation Repostitory Not Found"
  end
end

function cert_attest_check(attestations, file_name)
  if !isnothing(attestations) #Double Negitve check
    cert = registry_helper(attestations.attestations[1].verification_material.certificate, "No Certification Found")
    if !isnothing(cert)
      cert_shortened = first(cert, 64) * "..."
      WRITE_MD && write_mkd("**Certification**", cert_shortened, file_name)
      return @info "Attestation Cerification: $cert_shortened"
    end
  else
    @warn "Attestation Certification Not Found"
  end
end

function pub_attest_check(attestations, file_name)
  if !isnothing(attestations)
    publisher = registry_helper(attestations.publisher.kind, "No Publisher Found")
    WRITE_MD && write_mkd("**Publisher**", publisher, file_name)
    return @info "Publisher: $publisher"
  else
    return @warn "Publisher Attestation: Not Found"
  end
end

