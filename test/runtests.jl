using KROME
using Test

# Start with a clean environment: remove output directory if it exists
outdir = "out"
isdir(outdir) && rm(outdir, recursive=true)
mkdir(outdir)

@testset "install_reactions_verbatim" begin
  @test_nowarn install_reactions_verbatim(outdir)
  @test isfile(joinpath(outdir, "reactions_verbatim.dat"))
end

# Clean up afterwards: delete output directory
@test_nowarn rm(outdir, recursive=true)
