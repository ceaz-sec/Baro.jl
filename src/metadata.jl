using JSON3, HTTP

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
