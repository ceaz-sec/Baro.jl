#!/usr/bin/env julia
using JSON3, JSON, HTTP, Dates

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

function logger(source::String, value::String)
  println(source, value)
  return source, value
end


function main()
  date = getdate()
  packages = ARGS

  for pkg in packages
    println("# <=======CEAZ Build Integrity Triage=======>\n\n## Package: $pkg  | $date" 
            )
    resp = requestdata(pkg)

    # Load Response into JSON
    content = JSON3.read(resp.body)

    # Extract Triage Data
    println("## Maintainer Contact, License, Version and Dependencies\n\n",
            "Maintainer: ", content.info.maintainer_email, "\n\n",
            "License: ", content.info.license, "\n\n",
            "Version: ", content.info.version, "\n\n",
            "Depends on Python: ", content.info.requires_python, "\n\n",
            content.info.requires_dist, "\n\n")

    println("## SHA Digests \n\n", 
          content.urls[1].digests)
    println("## Yanked Status \n\n",
            content.info.yanked, content.info.yanked_reason, "\n"),
    [println("## Package Types \n", url.filename, "\n") for url in content.urls]
    println("## Repository\n\n", 
          content.info.project_urls, "\n")
    
    # Create Dict for JSON Serilization
    record = Dict(
                  "Date" => "$date",
                  "Package" => "$pkg",
                  "Version" => content.info.version,
                  "License" => content.info.license,
                  "Yanked" => content.info.yanked,
                  "Maintainer" => [content.info.maintainer_email],
                  "Depends on Python" => [content.info.requires_python],
                  "SHA Digests" => [content.urls[1].digests],
                  "Repository" => content.info.project_urls
                 )
    triagedata = JSON.json(record)
    open("$pkg-triage_data.json", "w") do f
      write(f, triagedata)
    end
  end
end

main()
