# KROME.jl

**KROME.jl** is a Julia package that wraps [KROME](http://kromepackage.org), a
Fortran library for including chemistry and microphysics in astrophysics
simulations.

**NOTE: This package is in its early stages and still highly experimental!
        Some things might not work yet, and implementation details may change
        at any time without warning.**


## Prerequisites
The following programs and tools must be available in the `PATH` such that they
can be called by the Julia process while building the package:

* Python 3 (`python3`)
* `make`
* GNU Fortran compiler (`gfortran`)


## Installation
Clone this package, enter the package directory, and build the package:
```shell
git clone git@github.com:trixi-framework/KROME.jl.git
cd KROME.jl
julia --project= -e 'using Pkg; Pkg.build()'
```


## Usage
Have a look at the examples in [examples/](examples/) to find out how to use
KROME.jl. Right now there is a single example available. To run it, enter the
package directory, start Julia with `julia --project`, and execute the
following:
```julia
julia> include("examples/test_hello/test_hello.jl");

julia> isfile("examples/test_hello/julia.66")
false

julia> test_hello()
Test OK!
In gnuplot type
 load 'plot.gps'

julia> println(read("examples/test_hello/julia.66", String))
```
This will print out the contents of the newly created file `julia.66`.


## Authors
KROME.jl was initiated by
[Michael Schlottke-Lakemper](https://www.mi.uni-koeln.de/NumSim/schlottke-lakemper)
(University of Cologne, Germany).
The [KROME](http://kromepackage.org) package itself is developed and maintained by
Tommaso Grassi, Stefano Bovino, and many others.


## License and contributing
KROME.jl is licensed under the MIT license (see [LICENSE.md](LICENSE.md)).
The [KROME](http://kromepackage.org) package itself is licensed under the GNU
General Public License, version 3.
