import LibGit2
using CBindingGen
using Libdl

# Clone/update repo
krome_repo = "https://bitbucket.org/tgrassi/krome.git"
clone_path = joinpath(@__DIR__, "krome")
build_dir = joinpath(clone_path, "build")
build_dir_backup = joinpath(clone_path, "build.orig")
if isdir(clone_path)
  @info "Restoring build directory..."
  rm(build_dir, recursive=true)
  mv(build_dir_backup, build_dir)

  @info "Updating repository in $clone_path..."
  repo = LibGit2.GitRepo(clone_path)
  LibGit2.fetch(repo)
  LibGit2.merge!(repo, fastforward=true)

  @info "Creating a backup of the build directory..."
  cp(build_dir, build_dir_backup)
else
  @info "Cloning repository $krome_repo to $clone_path..."
  LibGit2.clone(krome_repo, clone_path)

  @info "Creating a backup of the build directory..."
  cp(build_dir, build_dir_backup)
end

# Call krome to set up a build
krome_default_args = ["-interfacePy", "-interfaceC", "-unsafe"]
krome_custom_args = split(get(ENV, "JULIA_KROME_CUSTOM_ARGS", "-test=hello"), ";")
krome_args = vcat(krome_default_args, krome_custom_args)
python3_exec = get(ENV, "JULIA_KROME_PYTHON3_EXEC", "python3")

cd(clone_path) do
  setup_cmd = `$python3_exec krome $krome_args`
  @info "Running command '$setup_cmd' in '$clone_path'..."
  run(setup_cmd)
end

# Hotfix: include C interface in target `pyinterface`
makefile = joinpath(build_dir, "Makefile")
lines = readlines(makefile, keep=true)
open(makefile, "w+") do io
  for line in lines
    if startswith(line, "pyinterface: sharedlib")
      write(io, "pyinterface: cc = gcc\npyinterface: \$(cobjs)\npyinterface: switchc = -fPIC\npyinterface: objs += \$(cobjs)\n")
    end
    write(io, line)
  end
end

# Call make
cd(build_dir) do
  make_cmd = `make pyinterface`
  @info "Running command '$make_cmd'..."
  run(make_cmd)
end

# Generate C bindings
@info "Generate C bindings..."

# Manually set header files to consider
hdrs = ["krome.h", "krome_user.h"]

# Build list of arguments for Clang
include_args = String[]
include_directories = [normpath(build_dir)]
for dir in include_directories
  append!(include_args, ("-I", dir))
end

# Convert symbols in header
cvts = convert_headers(hdrs, args=include_args) do cursor
  header = CodeLocation(cursor).file
  name   = string(cursor)

  # only wrap the libp4est and libsc headers
  dirname, filename = splitdir(header)
  if !(filename in hdrs)
    return false
  end

  return true
end

# Write generated C bindings to file
@info "Write generated C bindings to file..."
krome_library = joinpath(build_dir, "libkrome." * Libdl.dlext)
const bindings_filename = joinpath(@__DIR__, "libkrome.jl")
open(bindings_filename, "w+") do io
  generate(io, krome_library => cvts)
end
