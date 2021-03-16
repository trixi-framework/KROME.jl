module KROME

using Reexport: @reexport
using CBinding: 𝐣𝐥

include("libkrome.jl")


"""
    examples_dir()

Return the directory where the examples provided with KROME.jl are located. If KROME is
installed as a regular package (with `]add KROME`), these files are read-only and should *not* be
modified. To find out which files are available, use, e.g., `readdir`:

# Examples
```julia
julia> readdir(examples_dir())
2-element Array{String,1}:
 "av-slab-benchmark"
 "test_hello"
```
"""
examples_dir() = joinpath(pathof(KROME) |> dirname |> dirname, "examples")

end
