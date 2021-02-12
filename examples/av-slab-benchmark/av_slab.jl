
using KROME
using Printf

function av_slab(io::IO=stdout)
  cd(@__DIR__) do
    install_reactions_verbatim()

    nmols = krome_nmols()[] # read Fortran module variable
    n = zeros(nmols) # default abundances (number density)

    idx_H = krome_idx_H()[] + 1
    idx_H2 = krome_idx_H2()[] + 1
    idx_Hj = krome_idx_Hj()[] + 1
    idx_Cj = krome_idx_Cj()[] + 1
    idx_CO = krome_idx_CO()[] + 1
    idx_O = krome_idx_O()[] + 1
    idx_E = krome_idx_E()[] + 1


    # == Variable for NL97 network
    dust_to_gas_ratio = 1.
    deff = 1.
    
  
    tmax = 3.1536e16
    dt = 3.1536e12

    rho = 3.841e-22
    
    abundc = 1.e-4
    abundo = 3.e-4
    abundhe = 0.1
    abundS = 0.#0.6e-6
    abundSi = 3.37e-6

    AV_conversion_factor =  6.289e-22 #5.348e-22

    krome_init() # init krome (mandatory)

    abar = 1 + abundhe*4. + abundc*12. + abundo*16. + abundSi*28. + abundS*32.
    # == CHANGE HERE, F1: n=1e3 with G0=1e1 or F4: n=10^5.5 with G0=1e5 ==
    nH = 10.0^3 #10.^5.5#(=rho/abar/krome_p_mass()[])
    Ghab = 1.e1*1.69/2. # 1.e5*1.69/2.
    crate = 5.e-17

    opt_depth_max = 100. 
    opt_depth = 1e-6

    NH2 = 0.
    H2sh = 1.

    println(io, "opt_depth_1,n(idx_H2)_2,n(idx_H)_3,n(idx_Hj)_4,n(idx_CO)_5,n(idx_Cj)_6,n(idx_E)_7,n(idx_O)_8,T_9,H2sh_10")

    while opt_depth <= opt_depth_max
      n .= 1.e-40
      n[idx_H] = nH
      n[idx_Cj] = abundc*nH
      n[idx_O] = abundo*nH
      n[idx_E] = n[idx_Cj]
      T = 50.
      Tdust = 10.


      # == Calculations for reactions 3 and 7
      fshield_dust    = exp(-2.5e0 * opt_depth)
      G_dust  = Ghab * fshield_dust
      
      ch34 = 5.087e2 * T^1.586e-2
      ch35 = -0.4723e0 - 1.102e-5 * log(T)

      if n[idx_E] == 0e0
        # If the fractional ionization is zero, then there won't be any recombination,
        # so the value we use for phi doesn't matter too much -- 1d20 is simply an 
        # arbitrary large number
 
        phi = 1e20
      else
        phi = G_dust * sqrt(T) / (n[idx_E])
      end


      if phi < 1e-6
        h_gr = 1.225e-13 * dust_to_gas_ratio
      else
        hgrvar1  = 8.074e-6 * phi^1.378e0
        hgrvar2  = (1e0 + ch34 * phi^ch35)
        h_gr     = 1.225e-13 * dust_to_gas_ratio / (1e0 + hgrvar1 * hgrvar2)
      end
      
      uv_ion = 0.
      # == End: Calculations for reactions 3 and 7

      COsh = 0.5 

      krome_set_user_ghab(Ghab)
      krome_set_user_crate(crate)
      krome_set_user_av(opt_depth)
      krome_set_user_h2self(H2sh)
      krome_set_user_tdust(Tdust)
      krome_set_user_coself(COsh)              
      krome_set_user_uv_ion(uv_ion)  
      krome_set_user_h_gr(h_gr)  
      krome_set_user_dust_to_gas_ratio(dust_to_gas_ratio)  
      krome_set_user_deff(deff)  

      i=0
      ttot=0.

      while ttot < tmax

        dtC=dt
        ttot=ttot+dtC

        if  ttot > tmax
          dtC = dtC - (ttot-tmax)
          ttot = tmax
        end

        # == Calculations for reactions 5, this needs to be done here in this loop as it depends on the abundance which change over time

        NHtot = opt_depth / (dust_to_gas_ratio * AV_conversion_factor)

        p1 = log10(NHtot / 1e18)
        if p1 < 0e0
          p1 = 0e0
        elseif p1 > 5e0
          p1 = 5e0
        end

        if n[idx_E]/nH < 1e-4
          p2 = -4.
        elseif n[idx_E]/nH > 0.1
          p2 = -1.
        else
          p2 = log10(n[idx_E]/nH)
        end

        f4 = 1.06  + 4.08e-2 * p2 + 6.51e-3 * p2^2e0
        f5 = 1.90  + 0.678   * p2 + 0.113   * p2^2e0
        f6 = 0.990 - 2.74e-3 * p2 + 1.13e-3 * p2^2e0
          
        ion = f4 * (-15.6 - 1.10 * p1 + 9.13e-2 * p1^2e0) + f5 * 0.87 * exp(-((p1 - 0.41) / 0.84)^2e0)

        heat = f6 * (-26.5 - 0.920 * p1 + 5.89e-2 * p1^2e0) + f6 * 0.96 * exp(-((p1 - 0.38) / 0.87)^2e0)

        ion = 1e1^ion
        heat = 1e1^heat

        krome_set_user_xr_ion(ion)

        # == End: Calculations for reactions 5


        # Convert to modifiable variables and then back
        T_ = fill(T)
        dtC_ = fill(dtC)
        # Original call: krome(n,T,dtC)
        krome(n,T_,dtC_)
        T = T_[]
        dtC = dtC_[]

        i=i+1

      end

      # write(*,*) opt_depth,n(idx_H2),n(idx_H),n(idx_Hj),n(idx_CO),n(idx_Cj),n(idx_E),n(idx_O),T,H2sh
      println(io,
              join(map(fsn, [opt_depth,
                             n[idx_H2],n[idx_H],n[idx_Hj],n[idx_CO],n[idx_Cj],n[idx_E],n[idx_O],
                             T,H2sh]), " "))

      NH_old = opt_depth/AV_conversion_factor

      opt_depth = opt_depth*1.1

      NH2 = NH2 + (opt_depth/AV_conversion_factor-NH_old)*n[idx_H2]/nH
      b5 = sqrt(1.38065e-16*T/krome_p_mass()[])/1e5
      x = NH2/5e14
      H2sh = 0.965/(1+x/b5)^2. + 0.035/sqrt(1+x)*exp(-8.5e-4*sqrt(1+x))
    end
  end
end

# Return formatted value in Fortran scientific notation
function fsn(value, width=25, precision=16)
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

