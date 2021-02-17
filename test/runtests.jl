using KROME
using Test

# Start with a clean environment: remove output directory if it exists
outdir = "out"
isdir(outdir) && rm(outdir, recursive=true)
mkdir(outdir)

@testset "KROME.jl" begin

@testset "install_reactions_verbatim" begin
  @test_nowarn install_reactions_verbatim(outdir)
  @test isfile(joinpath(outdir, "reactions_verbatim.dat"))
end

@testset "examples_dir" begin
  @test basename(KROME.examples_dir()) == "examples"
end

# need to change to outdir to have `reactions_verbatim.dat` present
@testset "change directory" begin
  @test_nowarn cd(outdir)
end

@testset "krome_init" begin
  @test_nowarn krome_init()
end

@testset "krome" begin
  x = [1.0, 0.0, 0.0]
  tgas = fill(1000.0)
  dt = fill(1.0)

  # Step 1
  @test_nowarn krome(x, tgas, dt)
  @test isapprox(x, [0.3678912404114684, 0.47727933060127414, 0.15482939322292208])

  # Step 2
  @test_nowarn krome(x, tgas, dt)
  @test isapprox(x, [0.1353768539087119, 0.465022153543365, 0.3996009567835874])

  # Step 3
  @test_nowarn krome(x, tgas, dt)
  @test isapprox(x, [0.0498010588960098, 0.3466697038199312, 0.6035292015197234])
end

# change back
@testset "change directory back" begin
  @test_nowarn cd(dirname(pwd()))
end

end

# Clean up afterwards: delete output directory
@test_nowarn rm(outdir, recursive=true)
