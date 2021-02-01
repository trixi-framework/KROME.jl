
!###################################################
! HELLO KROME test evolves the network
!  FK1 -> FK2 -> FK3
! where FK* are fake species

program test
  use krome_main !use krome (mandatory)
  use krome_user !use utility (for krome_idx_* constants and others)
  implicit none
  real*8::Tgas,dt,x(krome_nmols),t

  call krome_init() !init krome (mandatory)

  x(:) = 0d0 !default abundances (number density)
  x(krome_idx_FK1) = 1d0 !FK1 initial abundance (number density)

  Tgas = 1d2 !gas temperature, not used (K)
  dt = 1d-5 !time-step (arbitrary)
  t = 0d0 !time (arbitrary)

  write(66,'(a)') "#time "//krome_get_names_header()
  do
     dt = dt * 1.1d0 !increase timestep
     call krome(x(:), Tgas, dt) !call KROME
     write(66,'(99E17.8e3)') t,x(:)
     t = t + dt !increase time
     if(t>5d0) exit !break loop after 5 time units
  end do

  print *,"Test OK!"
  print *,"In gnuplot type"
  print *," load 'plot.gps'"

end program test

