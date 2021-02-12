module KROME

using Reexport: @reexport
using CBinding: 𝐣𝐥

include("libkrome.jl")

export install_reactions_verbatim


"""
    install_reactions_verbatim(dir=".")

Copy the file `reactions_verbatim.dat` from the package-internal KROME build directory to the
directory specified in `dir` and return the filename of the newly created file. If the target file
alreay exists, it will be overwritten.
"""
function install_reactions_verbatim(dir=".")
  filename = "reactions_verbatim.dat"
  source_path = joinpath(pathof(@__MODULE__) |> dirname |> dirname, "deps", "krome", "build", filename)
  target_path = joinpath(dir, filename)

  if !isfile(source_path)
    error("File '$source_path' does not exist. Have you successfully built KROME yet?")
  end

  cp(source_path, target_path, force=true, follow_symlinks=true)

  return target_path
end

end
