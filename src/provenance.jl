using JSON3, HTTP

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
