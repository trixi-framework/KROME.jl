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

Also note that KROME has primarily been developed for Linux. Some success has been
reported for macOS, but your mileage might vary. Windows does not seem to be
supported.


## Installation
Clone this package, enter the package directory, and build the package:
```shell
git clone git@github.com:trixi-framework/KROME.jl.git
cd KROME.jl
julia --project=. -e 'using Pkg; Pkg.build()'
```

By default, this will build the KROME library with the `hello` test activated,
i.e., passing `-test=hello` to the KROME preprocessing script. However, usually
you will want to pass your own network file and possibly other options to KROME
during preprocessing. This can be achieved via the environment variable
`JULIA_KROME_CUSTOM_ARGS`, which accepts a `;`-separated list of arguments that
will be passed to the `krome` preprocessor. For example, to provide a custom
network file while disabling the recombinations check, you can run the build
command above with
```shell
JULIA_KROME_CUSTOM_ARGS="-n;abs/path/to/react_skynet;-noRecCheck" julia --project=. -e 'using Pkg; Pkg.build()'
```
Please note that you have to specify the *absolute* path to the network file.


## Usage
Have a look at the examples in [examples/](examples/) to find out how to use
KROME.jl. Right now there are two examples available.

### `test_hello`
To run this example, enter the package directory, start Julia with `julia
--project`, and execute the following:
```julia
julia> isfile("examples/test_hello/julia.66")
false

julia> include("examples/test_hello/test_hello.jl");

julia> test_hello()
Test OK!
In gnuplot type
 load 'plot.gps'

julia> println(read("examples/test_hello/julia.66", String))
```
This will print out the contents of the newly created file `julia.66`.

### `av-slab-benchmark`
To run this example, you first need to build KROME with a different network
file. Enter the package directory and execute
```shell
JULIA_KROME_CUSTOM_ARGS="-n;$(pwd)/examples/av-slab-benchmark/react_chnet5;-noRecCheck" julia --project=. -e 'using Pkg; Pkg.build()'
```
After re-building KROME successfully, you also need to copy the
`reactions_verbatim.dat` file from the directory where KROME was built to the
current working directory in which you execute 


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
