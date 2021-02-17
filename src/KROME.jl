module KROME

using Reexport: @reexport
using CBinding: 𝐣𝐥

include("libkrome.jl")

export install_reactions_verbatim, examples_dir


"""
    install_reactions_verbatim(dir="."; force=true)

Copy the file `reactions_verbatim.dat` from the package-internal KROME build directory to the
directory specified in `dir` and return the filename of the newly created file. If the target file
already exists, it will be overwritten, unless `force` is set to `false`.
"""
function install_reactions_verbatim(dir="."; force=true)
  filename = "reactions_verbatim.dat"
  source_path = joinpath(pathof(@__MODULE__) |> dirname |> dirname, "deps", filename)
  target_path = joinpath(dir, filename)

  if !isfile(source_path)
    error("File '$source_path' does not exist. Have you successfully built KROME yet?")
  end

  cp(source_path, target_path, force=force, follow_symlinks=true)

  return target_path
end


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
