CF = gfortran
FLAGS= -fdefault-real-8 -fdefault-double-8 -O3 -ffree-line-length-none -ffpe-trap=invalid,zero,overflow -ffpe-summary=none -g -fbacktrace
# FLAGS=-r8
# CF=f95

#test : EquilibriumChemistry.o krome_all.o krome_user_commons.o opkdmain.o opkda1.o opkda2.o 
#	$(CF) $(FLAGS) EquilibriumChemistry.o krome_all.o krome_user_commons.o opkdmain.o opkda1.o opkda2.o  -o test

AV_slab_F1 : AV_slab.o krome_all.o krome_user_commons.o opkdmain.o opkda1.o opkda2.o 
	$(CF) $(FLAGS) AV_slab.o krome_all.o krome_user_commons.o opkdmain.o opkda1.o opkda2.o  -o AV_slab_F1

EquilibriumChemistry.o: krome_all.o
	$(CF) $(FLAGS) -c EquilibriumChemistry.F90
AV_slab.o: krome_all.o
	$(CF) $(FLAGS) -c AV_slab.F90

krome_all.o : krome_user_commons.o opkdmain.o opkda1.o opkda2.o
	$(CF) $(FLAGS) -c krome_all.f90

krome_user_commons.o:
	$(CF) $(FLAGS) -c krome_user_commons.f90

opkdmain.o : opkda1.o opkda2.o
	$(CF) $(FLAGS) -c opkdmain.f

opkda1.o : opkda2.o
	$(CF) $(FLAGS) -c opkda1.f

opkda2.o:
	$(CF) $(FLAGS) -c opkda2.f


clean:
	rm *o *mod main
