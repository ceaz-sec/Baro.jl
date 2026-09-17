using JSON3, HTTP

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
