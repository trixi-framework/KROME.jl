
####################################################
# HELLO KROME test evolves the network
#  FK1 -> FK2 -> FK3
# where FK* are fake species

# See the corresponding `test.f90` file for comparison of the implementation.
#
# `test_hello()` generates a file `julia.66`.
# The Julia reference values can be found in `julia.66.ref`.
# The Fortran reference values can be found in `fort.66.ref`.
#
# IMPORTANT: Many C bindings require to pass values as pointers. For example, `krome` cannot be
#            called with `Tgas` being of type `Float64`, but must be called with a **mutable**
#            value. Since scalars are immutable in Julia, the easiest is to create a
#            zero-dimensional array, which can be accomplished by calling `fill(<value>)`.

using KROME
using Printf

function test_hello()
  cd(@__DIR__) do
    krome_init() # init krome (mandatory)

    nmols = krome_nmols()[] # read Fortran module variable
    x = zeros(nmols) # default abundances (number density)
    idx_FK1 = krome_idx_FK1()[] + 1 # Julia has 1-based indices
    x[idx_FK1] = 1.0 # FK1 initial abundance (number density)

    Tgas = fill(1e2) # gas temperature, not used (K)
    dt = fill(1e-5) # time-step (arbitrary)
    t = 0.0 # time (arbitrary)

    open("julia.66", "w") do io
      println(io, "#time  FK1 FK2 FK3")
      while true
        dt[] = dt[] * 1.1 # increase timestep
        krome(x, Tgas, dt) # call KROME
        print(io, fsn(t))
        for value in x
          print(io, fsn(value))
        end
        println(io)
        t = t + dt[] # increase time
        t > 5 && break # break loop after 5 time units
      end
    end
  end

  println("Test OK!")
  println("In gnuplot type")
  println(" load 'plot.gps'")
end

# Return formatted value in Fortran scientific notation
function fsn(value, width=17, precision=8)
  @assert precision <= 64 "precision must be <= 64"

  # Extract exponent and base
  if value == 0.0
    exponent = -1
    base = 0.0
  else
    exponent = floor(Int, log10(abs(value)))
    base = value / float(10)^exponent
  end

  # Make base have a leading zero
  base /= 10
  exponent += 1

  # Get formatted values
  base_formatted = (@sprintf "%.64f" base)[1:(precision + 2 + (base < 0))]
  exponent_formatted = @sprintf "E%+04d" exponent

  padding = width - length(base_formatted) - length(exponent_formatted)

  return " "^padding * base_formatted * exponent_formatted
end
