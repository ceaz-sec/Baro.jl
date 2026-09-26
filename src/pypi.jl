using HTTP, JSON3, Dates

# Request PyPi Data
function requestdata(pkg)
  # Request Data from the Package Registry
  try
    resp = HTTP.get("https://pypi.org/pypi/$pkg/json")
    return resp
  catch err
    @error "Could not reach the PyPI registry $err"
  end
end

function request_prov_data(pkg, version, whl_file, file_name::String="")
  provenance_url = "https://pypi.org/integrity/$pkg/$version/$whl_file/provenance"
  try
    response = HTTP.get(provenance_url)
    prov = JSON3.read(response.body)
    return prov.attestation_bundles[1]
  catch err
    WRITE_MD && write_mkd("**Provenance**", "Not Found in Registry", file_name)
    @warn "Provenance Not Found for Specified Package including - Publisher,Certification & Repository origin."
  end
end

function package_summary(regst_info, file_name)
  try
    if !isnothing(regst_info.summary)
      package_summary = registry_helper(regst_info.summary, "Not Found")
      WRITE_MD && write_mkd("**Package Summary**", package_summary, file_name)
      @info "Package Summary: $package_summary"
    end
  catch err
    @warn "Package Summary Info Not Found"
  end
end  

# Check for Signs of Ownership
function ownership_check1(regst_info, file_name) #;output = "$file_name" karg
  if !isnothing(regst_info.maintainer)
    maintainer = something(regst_info.maintainer,"Not Found")
    WRITE_MD && write_mkd("**Maintainer**", maintainer, file_name)
    @info "Maintainer Information: $maintainer"
  else
    @warn "Maintainer Info Not Found"
  end
end

function ownership_check2(regst_info, file_name)
  if !isnothing(regst_info.maintainer_email)
    maintainer_email = something(regst_info.maintainer_email, "Not Found")
    WRITE_MD && write_mkd("**Maintainer Email**", maintainer_email, file_name)
    @info "Maintainer Email: $maintainer_email"
  else
    @warn "Maintainer Email Not Found"
  end
end

function authorship_check1(regst_info, file_name)
  if !isnothing(regst_info.author)
    author = something(regst_info.author, "Not Found")
    WRITE_MD && write_mkd("**Author**", author, file_name)
    @info "Author Information: $author"
  else
    @warn "Author Information not found" #Sutract from score by 2
  end
end

function authorship_check2(regst_info, file_name)
  if !isnothing(regst_info.author_email)
    author_email = something(regst_info.author_email, "Not Found")
    WRITE_MD && write_mkd("**Author Email**", author_email, file_name)
    @info "Author Email Information: $author_email"
  else
    @warn "Author Email Information not found"
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
  try
    license = registry_helper(regst_info.license, "Not Found")
    license_expression = registry_helper(regst_info.license_expression, "Not Found")
    if !isnothing(regst_info.license)
      WRITE_MD && write_mkd("**License**", license, file_name)
      @info "License Info: $license\n"
    elseif !isnothing(regst_info.license_expression)
      license_exp = first(license_expression, 16) * "..."
      WRITE_MD && write_mkd("**License Expression**", license_exp, file_name)
      @info "License Expression: $license_exp\n"
    end
  catch err
    @warn "No License Information Found"
  end
end

function version_check(regst_info, file_name)
  try
    if !isnothing(regst_info.version)
      version = registry_helper(regst_info.version, "Not Provided")
      WRITE_MD && write_mkd("**Version**", version, file_name)
      @info "Version Info: $version\n"
    end
  catch err
    @warn "Package Version Check Failed"
  end
end

function public_repo_check(regst_info, file_name)
  try
    if !isnothing(regst_info.project_urls["Homepage"])# || !isnothing(regst_info.project_urls["Source"])
      public_repo = registry_helper(regst_info.project_urls["Homepage"], "Not Provided")
      WRITE_MD && write_mkd("**Public Repository**", public_repo, file_name)
      @info "Public Repo: $public_repo\n"
    end
  catch err
    @warn "Public Repository Not Listed"
  end
end

function classifiers_check(regst_info, file_name)
  if !isnothing(regst_info.classifiers)
    try
      if occursin("Production", regst_info.classifiers[1])
        development_status = registry_helper(regst_info.classifiers[1], "Not Found")
        WRITE_MD && write_mkd("**Classifiers of Development Status**", development_status, file_name)
        @info "$development_status"
      elseif occursin("Dev", development_status) && !isnothing(development_status)
        WRITE_MD && write_mkd("**Classifiers of Development Status**", development_status, file_name)
        @warn "$development_status"
      end
    catch err
        @warn "Classifiers of Development Status: Not Found"
    end
  end
end

function whl_file_check(whl_file, file_name)
  if !isnothing(whl_file)
    whl_file = registry_helper(whl_file, "Not Provided")
    WRITE_MD && write_mkd("**Release**", whl_file, file_name)
    @info "Release Info: $whl_file"
  else
    @warn "Release Info: Not Provided"
  end
end

function get_digests(file, file_name)
  if !isnothing(file.digests.sha256)
    sha256 = registry_helper(file.digests.sha256, "Not Provided")
    WRITE_MD && write_mkd("**SHA256**", sha256, file_name)
    @info "SHA256: $sha256"
  else
    @warn "SHA256 Not Found"
  end
end

function platform_check(regst_info, file_name)
  if !isnothing(regst_info.platform)
    platform = registry_helper(regst_info.platform, "Not Provided")
    WRITE_MD && write_mkd("**Platform**", "$platform \n", file_name)
    @info "Platform Info: $platform"
  else
    @warn "Platform Information Not Found"
  end
end

function requires_py_check(regst_info, file_name)
  requires_py = registry_helper(regst_info.requires_python, "Nothing Found")
  if !isnothing(requires_py)
    WRITE_MD && write_mkd("Requires Python Version", requires_py, file_name)
    @info "Required Python: $requires_py"
  else
    @warn "Required Python Version Not Found"
  end
end

function depends_py_check(regst_info, file_name)
  try
    depends_py = registry_helper(regst_info.requires_dist, "No Dependencies Found")
    if !isnothing(depends_py)
      no_of_deps = length(regst_info.requires_dist[1:end])
      WRITE_MD && write_mkd("Dependencies ($no_of_deps)", depends_py, file_name)
      @info "Dependencies ($no_of_deps): $depends_py"
    else
    end
  catch err
      @warn "No Dependencies Found"
  end
end

# Search for Provenance Evidence
function intg_attest_check(attestations, file_name)
  if !isnothing(attestations)
    try
      integrated_time = registry_helper(attestations.attestations[1].verification_material.transparency_entries[1].integratedTime, "Nothing Found")
      WRITE_MD && write_mkd("**Integrated Time**", integrated_time, file_name)
      @info "Integrated Time: $integrated_time"
    catch e
      @warn "Attestation Integrated Time Not Found"
    end
  end
end

function repo_attest_check(attestations, file_name)
  if !isnothing(attestations)
    try 
      repo = registry_helper(attestations.publisher.repository, "No Repository Info Found")
      WRITE_MD && write_mkd("**Repository**", repo, file_name)
      @info "Repository: $repo"
    catch e
      @warn "Attestation Repo Not Found"
    end
  end
end

function cert_attest_check(attestations, file_name)
  if !isnothing(attestations) #Double Negitve check
    try
      cert = registry_helper(attestations.attestations[1].verification_material.certificate, "No Certification Found")
      cert_shortened = first(cert, 64) * "..."
      WRITE_MD && write_mkd("**Certification**", cert_shortened, file_name)
      @info "Attestation Cerification: $cert_shortened"
    catch e
      @warn "Attestation Certification Not Found"
    end
  end
end

function pub_attest_check(attestations, file_name)
  if !isnothing(attestations)
    try
      publisher = registry_helper(attestations.publisher.kind, "No Publisher Found")
      WRITE_MD && write_mkd("**Publisher**", publisher, file_name)
      @info "Publisher: $publisher"
    catch e
      @warn "Publisher Attestation: Not Found"
    end
  end
end
