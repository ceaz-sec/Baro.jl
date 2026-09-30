using HTTP, JSON3, Dates, StyledStrings

# Request PyPi Data
function requestdata(pkg)
  # Request Data from the Package Registry
  try
    resp = HTTP.get("https://pypi.org/pypi/$pkg/json")
    package_recs["package_name"] = pkg
    return resp
  catch err
    @info "Could not reach the PyPI registry $err"
  end
end

function request_prov_data(pkg, version, whl_file, file_name::String="")
  provenance_url = "https://pypi.org/integrity/$pkg/$version/$whl_file/provenance"
  try
    response = HTTP.get(provenance_url)
    prov = JSON3.read(response.body)
    return prov.attestation_bundles[1], true
  catch err
    WRITE_MD && write_mkd("**Provenance**", "Not Found in Registry", file_name)
    @warn "PEP740 Provenance Not Found for $pkg - Missing Publisher, Certification & Repository origin."
    return nothing, false
  end
end

function package_summary(regst_info, file_name)
  try
    if !isnothing(regst_info.summary)
      package_summary = registry_helper(regst_info.summary, "Not Found")
      WRITE_MD && write_mkd("**Package Summary**", package_summary, file_name)
      package_recs["package_summary"] = package_summary
      @info "Package Summary: $package_summary"
    end
  catch err
    @warn "Package Summary Info Not Found"
    package_recs["package_summary"] = "not_found"
  end
end  

# Check for Signs of Ownership
function ownership_check1(regst_info, file_name)
  if !isnothing(regst_info.maintainer)
    maintainer = something(regst_info.maintainer,"Not Found")
    WRITE_MD && write_mkd("**Maintainer**", maintainer, file_name)
    package_recs["maintainer"] = maintainer
    @info "Maintainer Information: $maintainer"
  else
    @warn "Maintainer Info Not Found"
    package_recs["maintainer"] = "not_found"
  end
end

function ownership_check2(regst_info, file_name)
  if !isnothing(regst_info.maintainer_email)
    maintainer_email = something(regst_info.maintainer_email, "Not Found")
    WRITE_MD && write_mkd("**Maintainer Email**", maintainer_email, file_name)
    package_recs["Maintainer Email"] = maintainer_email
    @info "Maintainer Email: $maintainer_email"
  else
    @warn "Maintainer Email Not Found"
    package_recs["maintainer_email"] = "not_found" 
  end
end

function authorship_check1(regst_info, file_name)
  if !isnothing(regst_info.author)
    author = something(regst_info.author, "Not Found")
    WRITE_MD && write_mkd("**Author**", author, file_name)
    package_recs["author"] = author
    @info "Author Information: $author" 
  else
    @info "Author Information not found"
    package_recs["author"] = "not_found"
  end
end

function authorship_check2(regst_info, file_name)
  if !isnothing(regst_info.author_email)
    author_email = something(regst_info.author_email, "Not Found")
    WRITE_MD && write_mkd("**Author Email**", author_email, file_name)
    package_recs["author_email"] = author_email
    @info "Author Email Information: $author_email"
  else
    @warn "Author Email Information not found"
    package_recs["author_email"] = "not_found"
  end
end

# PyPi Metadata Check
function yanked_check(regst_info, file_name)
  yanked = something(regst_info.yanked, "Not Found")
  yanked_reason = something(regst_info.yanked_reason, "False"); yanked_status = yanked 
  if yanked && WRITE_MD
    write_mkd("**Yanked Status**", "$yanked_reason\n---", "YES")
    package_recs["yanked_status"] = "$yanked_reason, true"
    @warn "Yanked Status: $yanked, Reason: yanked_reason"
  elseif WRITE_MD
    write_mkd("**Yanked Status**", "$yanked \n\n---", file_name)
    @info "Yanked Status: $yanked"
    package_recs["yanked_status"] = yanked # Returns false as bool
  end
end

function license_check(regst_info, file_name)
  try
    license = registry_helper(regst_info.license, "Not Found")
    license_expression = registry_helper(regst_info.license_expression, "Not Found")
    if !isnothing(regst_info.license)
      license = first(license, 20) * "..." #Truncated for length
      WRITE_MD && write_mkd("**License**", license, file_name)
      package_recs["license"] = license
      @info "License Info: $license"
    elseif !isnothing(regst_info.license_expression)
      license_exp = first(license_expression, 20) * "..."
      WRITE_MD && write_mkd("**License Expression**", license_exp, file_name)
      package_recs["license_expression"] = license_expression
      @info "License Expression: $license_exp"
    end
  catch err
    @warn "No License Information Found"
    package_recs["license"] = "not_found"
    package_recs["license_expression"] = "not_found"
  end
end

function version_check(regst_info, file_name)
  try
    if !isnothing(regst_info.version)
      version = registry_helper(regst_info.version, "Not Provided")
      WRITE_MD && write_mkd("**Version**", version, file_name)
      package_recs["version"] = version
      @info "Version Info: $version"
    end
  catch err
    @warn "Package Version Check Failed"
    package_recs["version"] = "not_found"
  end
end

function public_repo_check(regst_info, file_name)
  try
    if !isnothing(regst_info.project_urls["Homepage"])# || !isnothing(regst_info.project_urls["Source"])
      public_repo = registry_helper(regst_info.project_urls["Homepage"], "Not Provided")
      WRITE_MD && write_mkd("**Public Repository**", public_repo, file_name)
      package_recs["homepage_repo"] = public_repo
      @info "Public Repo: $public_repo"
    end
  catch err
    @warn "Public Repository Not Listed"
    package_recs["homepage_repo"] = "not_found"
  end
end

function classifiers_check(regst_info, file_name)
  if !isnothing(regst_info.classifiers)
    try
      if occursin("Production", regst_info.classifiers[1])
        development_status = registry_helper(regst_info.classifiers[1], "Not Found")
        WRITE_MD && write_mkd("**Classifiers of Development Status**", development_status, file_name)
        package_recs["classifiers"] = development_status
        @info "$development_status"
      elseif occursin("Dev", development_status) && !isnothing(development_status)
        WRITE_MD && write_mkd("**Classifiers of Development Status**", development_status, file_name)
        package_recs["classifiers"] = development_status
        @warn "$development_status"
      end
    catch err
        @warn "Classifiers of Development Status: Not Found"
        package_recs["classifiers"] = "not_found"
    end
  end
end

function whl_file_check(whl_file, file_name)
  if !isnothing(whl_file)
    whl_file = registry_helper(whl_file, "Not Provided")
    WRITE_MD && write_mkd("**Release**", whl_file, file_name)
    package_recs["whl_release_package"] = whl_file
    @info "Release Info: $whl_file"
  else
    @warn "Release Info: Not Provided"
    package_recs["whl_release_package"] = "not_found"
  end
end

function get_digests(file, file_name)
  if !isnothing(file.digests.sha256)
    sha256 = registry_helper(file.digests.sha256, "Not Provided")
    WRITE_MD && write_mkd("**SHA256**", sha256, file_name)
    package_recs["sha256_digest"] = sha256
    @info "SHA256: $sha256"
  else
    @warn "SHA256 Not Found"
    package_recs["sha256_digest"] = "not_found"
  end
end

function platform_check(regst_info, file_name)
  if !isnothing(regst_info.platform)
    platform = registry_helper(regst_info.platform, "Not Provided")
    WRITE_MD && write_mkd("**Platform**", "$platform \n", file_name)
    package_recs["platform_info"] = platform
    @info "Platform Info: $platform"
  else
    @warn "Platform Information Not Found"
    package_recs["platform_info"] = "not_found"
  end
end

function requires_py_check(regst_info, file_name)
  requires_py = registry_helper(regst_info.requires_python, "Nothing Found")
  if !isnothing(requires_py)
    WRITE_MD && write_mkd("Requires Python Version", requires_py, file_name)
    package_recs["requires_py"] = requires_py
    @info "Required Python: $requires_py"
  else
    @warn "Required Python Version Not Found"
    package_recs["requires_py"] = "not_found"
  end
end

function depends_py_check(regst_info, file_name)
  try
    depends_py = registry_helper(regst_info.requires_dist, "No Dependencies Found")
    if !isnothing(depends_py)
      no_of_deps = length(regst_info.requires_dist[1:end])::Int64
      WRITE_MD && write_mkd("Dependencies ($no_of_deps)", depends_py, file_name)
      package_recs["no_of_deps"] = no_of_deps; package_recs["dependencies"] = depends_py
      @info "Dependencies ($no_of_deps): $depends_py"
    else
    end
  catch err
      @warn "No Dependencies Found"
      package_recs["no_of_deps"] = "not_found"; package_recs["dependencies"] = "not_found"
  end
end

# Search for Provenance Evidence
function intg_attest_check(attestations, file_name)
  if !isnothing(attestations)
    try
      integrated_time = registry_helper(attestations.attestations[1].verification_material.transparency_entries[1].integratedTime, "Nothing Found")
      integrated_time_exact = unix2datetime(integrated_time)
      WRITE_MD && write_mkd("**Integrated Time**", integrated_time_exact, file_name)
      package_recs["provenance_integrated_time"] = integrated_time_exact 
      @info "Integrated Time: $integrated_time"
    catch e
      @warn "Attestation Integrated Time: Not Found"
      package_recs["provenance_integrated_time"] = "not_found"
    end
  end
end

function repo_attest_check(attestations, file_name)
  if !isnothing(attestations)
    try 
      repo = registry_helper(attestations.publisher.repository, "No Repository Info Found")
      WRITE_MD && write_mkd("**Repository**", repo, file_name)
      package_recs["provenance_repository"] = repo
      @info "Repository: $repo"
    catch e
      @warn "Attestation Repo Not Found"
      package_recs["provenance_repository"] = "not_found"
    end
  end
end

function cert_attest_check(attestations, file_name)
  if !isnothing(attestations) #Double Negitve check
    try
      cert = registry_helper(attestations.attestations[1].verification_material.certificate, "No Certification Found")
      cert_shortened = first(cert, 64) * "..."
      WRITE_MD && write_mkd("**Certification**", cert_shortened, file_name)
      package_recs["attestation_cerification"] = cert_shortened
      @info "Attestation Cerification: $cert_shortened"
    catch e
      @warn "Attestation Certification Not Found"
      package_recs["attestation_certification"] = "not_found"
    end
  end
end

function pub_attest_check(attestations, file_name)
  if !isnothing(attestations)
    try
      publisher = registry_helper(attestations.publisher.kind, "No Publisher Found")
      WRITE_MD && write_mkd("**Publisher**", publisher, file_name)
      package_recs["provenance_publisher"] = publisher
      @info "Publisher: $publisher"
    catch e
      @warn "Publisher Attestation: Not Found"
      package_recs["provenance_publisher"] = "not_found"
    end
  end
end
