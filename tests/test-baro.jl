#!/usr/bin/env julia
using JSON3, JSON, HTTP, Dates, Logging

function requestdata(pkg)
  # Request Data from the Package Registry
  resp = HTTP.get("https://pypi.org/pypi/$pkg/json")
  typeof(pkg)
  return resp
end

function getdate()
  date = Dates.now()
  return date
end

function page_divide()
  pg_divide = println("---")
  return pg_divide
end

function write_mkd(field::String, status, file_name::String)
  open("$file_name.md", "a") do io
    if occursin("Depends", field) 
      println(io, "> $field: $status")
    elseif occursin("Requires", field) 
      println(io, "```
              $field: $status
```")
    else
      println(io, "  - $field: $status")
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
  open("$file_name.md", "a") do io
    println(io, "```$baro
```\n")
    pg_divide = page_divide()
    date = getdate()
    println(io, "**Package**: $pkg  | $date\n")
  end
end

function write_subheadings(data::String, file_name)
  open("$file_name.md", "a") do io
    println(io, data, file_name)
  end
end

function registry_helper(reg_lookup, status::String)
  reg_item = something(reg_lookup, status)
  #registry = println(reg_item)
  return reg_item
end

function ownership_check(regst_info, file_name)
  maintainer = something(regst_info.maintainer,"Not Found")
  maintainer_email = something(regst_info.maintainer_email, "Not Found")
  if maintainer == "Not Found" || mainter_email "Not Found"
    return @warn "Maintainer Info not found"
  else
    write_mkd("**Maintainer**", maintainer, file_name)
    write_mkd("**Maintainer Email**", maintainer_email, file_name)
  end
end

function authorship_check(regst_info, file_name)
  author = something(regst_info.author, "Not Found")
  author_email = something(regst_info.author, "Not Found")
  if author == "Not Found" || author_email == "Not Found"
    return @warn "Author Information not found" #Sutract from score by 2
  else
    write_mkd("Author", author, file_name)
    write_mkd("Author Email", author_email, file_name)
  end
end

function yanked_check(regst_info, file_name)
  yanked = something(regst_info.yanked, "Not Found")
  yanked_reason = something(regst_info.yanked_reason, "False")
  yanked_status = yanked ? write_mkd("Yanked Status", yanked_reason, "YES") : write_mkd("Yanked Status", yanked, file_name)
end

function license_check(regst_info, file_name)
  license = registry_helper(regst_info.license, "Not Found")
  write_mkd("License", license, file_name)
end

function version_check(regst_info, file_name)
  version = registry_helper(regst_info.version, "Not Provided")
  write_mkd("Version", version, file_name)
  return version
end

function whl_file_check(file, file_name)
  whl_file = registry_helper(file, "Not Provided")
  write_mkd("Release", whl_file, file_name)
end

function get_digests(file, file_name)
  sha256 = registry_helper(file.digests.sha256, "Not Provided")
  write_mkd("SHA256", sha256, file_name)
end

function platform_check(regst_info, file_name)
  platform = registry_helper(regst_info.platform, "Not Provided")
  write_mkd("Platform", platform, file_name)
end

function requires_py_check(regst_info, file_name)
  requires_py = registry_helper(regst_info.requires_python, "Nothing Found")
  write_mkd("Requires Python", requires_py, file_name)
end

function depends_py_check(regst_info, file_name)
  depends_py = registry_helper(regst_info.requires_dist, "No Dependencies Found")
  write_mkd("Depends on Python", depends_py, file_name)
end

function main()
  date = getdate()
  pg_divide = page_divide()
  packages = ARGS
  out_file = ARGS[1]
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

  pg_divide = page_divide()

  for pkg in packages
    println("$baro",
            "## <=======CEAZ Build Integrity Triage=======>\n\n**Package:** $pkg  | $date" 
            )
    resp = requestdata(pkg)
    # Load Response into JSON
    content = JSON3.read(resp.body)
    file = content.urls[1]
    regst_info = content.info
    file_name = "$pkg-$(regst_info.version)"
    write_headers(baro, file_name, "$pkg", "$date")

    # Extract Triage Data
    write_subheadings("## Ownship Contact, License, Version and Dependencies.\n", file_name)
    println("## Ownship Contact, License, Version and Dependencies.\n\n",
            ownership_check(regst_info, file_name),
            authorship_check(regst_info, file_name),
            license_check(regst_info, file_name),
            version_check(regst_info, file_name),
            whl_file_check(file.filename, file_name),
            platform_check(regst_info, file_name),
            requires_py_check(regst_info, file_name),
            depends_py_check(regst_info, file_name),
            "\n\n"
           )

    println(pg_divide)

    println("## SHA Digests, Yanked Status, Package Types and Public Repository Info.\n\n", 
            "  - Digests: ", file.digests.blake2b_256, "\n", file.digests.sha256, "\n", file.digests.md5, "\n",
            yanked_check(regst_info, file_name),
            get_digests(file, file_name),
            "  - Project Urls: ", regst_info.project_url, "\n\n"
           )
    println(pg_divide)
  end
end

main()
