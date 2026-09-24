using Dates

function write_mkd(field::String, status, file_name::String)
  open("./reports/pypi/$file_name.md", "a") do io
    if occursin("Dependencies", field) || occursin("Requires", field)
      println(io, "> $field: $status\n")
    else
      println(io, "$field\n- $status\n")
    end
  end
end

function write_ndjson(records::String, status, file_name::String)
  open("./reports/pypi/$file_name.ndjson", "a") do io
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
  open("./reports/pypi/$file_name.md", "a") do io
    println(io, "```$baro
```\n")
    println(io, "---")
    date = getdate()
    println(io, "**Package**: $pkg  | $date\n")
  end
end

function write_subheadings(data::String, file_name)
    open("./reports/pypi/$file_name.md", "a") do io
      println(io, data)
    end
end
