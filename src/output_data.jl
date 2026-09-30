using JSON3, Dates, StyledStrings

assessment = Dict{String, Any}() # For Assessment Logic 
package_recs =Dict{String, Any}() # NDJSON Records

function write_mkd(field::String, status, file_name::String)
  open("./reports/pypi/$file_name.md", "a") do io
    if occursin("Dependencies", field) || occursin("Requires", field)
      println(io, "> $field: $status\n")
    else
      println(io, "$field\n- $status\n")
    end
  end
end

function write_ndjson(package_recs::Dict, prov_evidence)
  open("./records/pypi-packages.ndjson", "a") do io
    if prov_evidence == false
      package_recs["provenance_publisher"] = "not_found"
      package_recs["provenance_repository"] = "not_found"
      package_recs["provenance_integrated_time"] = "not_found"
      package_recs["attestation_certification"] = "not_found"
      package_recs["scanned_time"] = Dates.format(Dates.now(), "HH:MM:SS")
      println(io, JSON3.write(package_recs))
    elseif prov_evidence == true
      package_recs["scanned_time"] = Dates.format(Dates.now(), "HH:MM:SS")
      println(io, JSON3.write(package_recs))
    end
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
  printstyled(baro, color = :green, bold = true)
end

function baro_subject(pkg::String, date::String)
  printstyled("
<=======================>
BARO PRE-INGESTION TRIAGE
<=======================>\n\nPackage: $pkg  | Triage Time: $date\n", color = :green, bold = true 
            )
end

function write_headers(file_name::String, pkg::String="", date::String="")
  #baro_banner()
  open("./reports/pypi/$file_name.md", "a") do io
    println(io, "```$baro_banner()
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
