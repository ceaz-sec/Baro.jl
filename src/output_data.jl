using Dates

struct RegistryRecord
  pkg::String
  version::String
  maintainer::Union{String, Nothing}
  author::Union{String, Nothing}
  yanked::Union{String, Nothing}
  license::Union{String, Nothing}
  wheel_file::Union{String, Nothing}
  digests::Union{String, Nothing}
  classifiers::Union{String, Nothing}
  requires_python::Union{String, Nothing}
  requires_dist::Union{Vector{String}, Nothing}
  release_url::Union{String, Nothing}
  platform::Union{String, Nothing}
  date::DateTime
  integration_time::Union{String, Nothing}
  repository_attest::Union{String, Nothing}
  cert_attest::Union{String, Nothing}
  publisher_attest::Union{String, Nothing}
end

function write_mkd(field::String, status, file_name::String)
  open("./reports/$file_name.md", "a") do io
    if occursin("Depends", field) || occursin("Requires", field)
      println(io, "> $field: $status\n")
    else
      println(io, "$field\n- $status\n")
    end
  end
end

function write_ndjson(records::String, status, file_name::String)
  open("./reports/$file_name.ndjson", "a") do io
      println(io, JSON3.write(record))
  end
end

function baro_banner()
  baro = ("
██████╗  █████╗ ██████╗  ██████╗
██╔══██╗██╔══██╗██╔══██╗██╔═══██╗
██████╔╝███████║██████╔╝██║   ██║
██╔══██╗██╔══██║██╔══██╗██║   ██║
██████╔╝██║  ██║██║  ██║╚██████╔╝
╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ 
")
  return baro
end

function write_headers(data::String, file_name::String, pkg::String="", date::String="")
  baro = baro_banner()
  open("./reports/$file_name.md", "a") do io
    println(io, "```$baro
```\n")
    println(io, "---")
    date = getdate()
    println(io, "**Package**: $pkg  | $date\n")
  end
end

function write_subheadings(data::String, file_name)
  open("./reports/$file_name.md", "a") do io
    println(io, data)
  end
end
