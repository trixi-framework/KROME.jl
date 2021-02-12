set term pdfcairo color enhanced font ",8" fontscale 0.5 lw 0.5 size 7cm,5cm 
# you can of course adapt the y-ranges a bit....
# For the F1 test just replace every F4 by F1, everything else remains the same. And of course add your own results :)

set log

set out "C_F1.pdf"
set yrange [1e-10:1]
set key left opaque

p "AV_slab_F1.txt"       u 1:5 w l title "CO (ref)", \
  ""                     u 1:6 w l title "C+ (ref)", \
  "AV_slab_F1_julia.txt" u 1:5 w l title "CO (KROME.jl)" dashtype 2 lw 3, \
  ""                     u 1:6 w l title "C+ (KROME.jl)" dashtype 2 lw 3, \
  "Roellig_F1_Kosma.log" u 2:7 w l title "CO Kosma-{/Symbol t}", \
  ""                     u 2:5 w l title "C^+  Kosma-{/Symbol t}"


set out "H_F1.pdf"
set yrange [1e-5:1e3]

p "AV_slab_F1.txt"       u 1:2 w l title "H2 (ref)", \
  ""                     u 1:3 w l title "H (ref)", \
  ""                     u 1:4 w l title "H+ (ref)", \
  "AV_slab_F1_julia.txt" u 1:2 w l title "H2 (KROME.jl)" dashtype 2 lw 3, \
  ""                     u 1:3 w l title "H (KROME.jl)" dashtype 2 lw 3, \
  ""                     u 1:4 w l title "H+ (KROME.jl)" dashtype 2 lw 3, \
  "Roellig_F1_Kosma.log" u 2:4 w l title "H_2 Kosma-{/Symbol t}", \
  ""                     u 2:3 w l title "H   Kosma-{/Symbol t}", \
  ""                     u 2:14 w l lw 2 lc rgb "black" lt 2 title "H^+ Kosma-{/Symbol t}"


set out "difference_F1.pdf"
unset logscale
set yrange [-5e-11:5e-11]

p "< paste AV_slab_F1.txt AV_slab_F1_julia.txt" u 1:($11/$1 -1)  w l title "1", \
  ""                                            u 1:($12/$2 -1)  w l title "2", \
  ""                                            u 1:($13/$3 -1)  w l title "3", \
  ""                                            u 1:($14/$4 -1)  w l title "4", \
  ""                                            u 1:($15/$5 -1)  w l title "5", \
  ""                                            u 1:($16/$6 -1)  w l title "6", \
  ""                                            u 1:($17/$7 -1)  w l title "7", \
  ""                                            u 1:($18/$8 -1)  w l title "8", \
  ""                                            u 1:($19/$9 -1)  w l title "9", \
  ""                                            u 1:($20/$10-1) w l title "10"
