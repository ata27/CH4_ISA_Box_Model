# R script to solve and plot kinetics

# Alex Archibald, ata27@cam.ac.uk
# With big thanks to Paul Griffiths for help!

# this is the library that does the clever stuff!
# you need to install it using install.packages("deSolve") and then use it 
# by the following
require(deSolve)

# functions
convert_emissions <- function(mass, molar_mass) {
  # function to convert the input emissions
  # constants
  C_fac = 2.5E19 # convert to molecules cm-3
  sec_per_year = 86400*360
  #Vol_Earth = 4*pi*(6378E3)^2 * (5000) # volume = area * height - 5km
  top <- (mass/molar_mass) # the mass of the species converted into moles
  bottom <- (5.2E21/28.8) # mass of air = 5.2E18 Kg and rmm = 28.8 g/mol = moles of air
  temp <- top/bottom
  return(temp*C_fac/sec_per_year) # return the result in molecules cm-3 s-1
}

# What we are going to do is solve some simple, but stiff, ODE's. 
# OH + CH4 = CO
# Cl + CH4 = CO
# OH + CO = CO2 (don't care about CO2 here)
# OH + X = LOSS (don't care how)

# we need to set up these reactions as basic equations
# Let's write d[X]/dt as dX
# dCH4 = SCH4 - k1*OH*CH4 - k2*Cl*CH4
# dCO = SCO - k3*OH*CO + k1*OH*CH4 + k2*Cl*CH4
# dOH = SOH - k4*OH -  k1*OH*CH4 - k2*Cl*CH4 - k3*OH*CO
# dCl = SCl - k2*Cl*CH4

# set times for the main loop - in seconds so will need to extend a lot for this slow chemistry! 
n_years <- 100
t_step  <- 86400*30
times <- seq(0, (n_years*360*86400), t_step)

# generate a data frame of ramp data
# at a lower time interval to the main loop
times2 <- seq(0, (n_years*360*86400), t_step*4)

# generate a linear sequence to increase the emissions up to a maximum factor (max_fac)
max_fac <- 10
lin.seq <- seq(1, max_fac, length.out = length(times2))
emis_frame  <- data.frame(day=times2, emis_scale=lin.seq )

# now generate a function to interpolate the emis factors
emis.func <- approxfun(emis_frame)

# define the value for M to fold into rate constants
M = 2.5e19; O2 = 0.2*M; H2O = 1e17

# set the parameters of the rate constants - assume 288 K
parameters <- c(k1=(1.85E-12 * exp(-1690/288)), 
                k2=(6.6E-12 * exp(-1240/288)), 
                k3=(1.44E-13 * (1 + (0.8*M)/4.2E19)), 
                k4= 1) # based on Heimeann et al

# set state variables
state <- c(CH4=4.5e13, CO=2.5E12, OH=5e5, Cl=1e3)

# define function for the rate equations
kinetics <- function(t, state, parameters){
  with(as.list(c(state, parameters)), {
    
    # define emission factor to be time dependent 
    # and set emission rates
    emis_factor <- emis.func(t)
    SCH4 <- convert_emissions(540E12, 16)*emis_factor
    SCO <- convert_emissions(1370E12, 28)
    SOH <- 1.15E6
    SCl <- convert_emissions(500E12, 35) # base case emissions are 0.1 Tg
                                         # case to make CH4 drop by 50% without reducing 
                                         # emissions of methane are
                                         # emissions of Cl = 500 Tg
    
 
    # rate of change
    dCH4 = SCH4 - k1*OH*CH4 - k2*Cl*CH4
    dCO = SCO + k1*OH*CH4 + k2*Cl*CH4 - k3*OH*CO
    dOH = SOH - k4*OH - k1*OH*CH4 - k3*OH*CO
    dCl = SCl - k2*Cl*CH4
    # return list of output
    list(c(dCH4, dCO, dOH, dCl), 
         emis_factor=emis_factor, 
         SCH4=SCH4, SCO=SCO, SOH=SOH, SCl=SCl)
  })
}

# solve!
out <- ode(y=state, times=times, func=kinetics, parms=parameters, 
           method= "radau")

############################################# now analyse the data

# # quick plot
# plot(out, type="l")
# #plot(out, type="l", lwd=2, 
# #     xlab="Time (s)")
# #grid()

# the output of the ODE solver is a bit odd so will convert to a data frame for analysis
out_data <- as.data.frame(out)

# calc the CH4 RF -- relative to the PI
RF_calc <- function(ch4) {
  # use the IPCC tables to calculate the RF of methane since the PI
  # Data from Table 8.SM.1
  M_conv = 2.5e19 
  alpha = 0.036 
  N0 = 332 # from https://www.esrl.noaa.gov/gmd/webdata/ccgg/trends/n2o_trend_all_gl.png
  M0 = 760
  M = (ch4/M_conv)*1E9
  fMN = function(M, N) {
    0.47*log(1+ (2.01E-5*M*N*0.75) + (5.31E-15*M*(M*N)^1.52) )
  }
  RF = alpha*(sqrt(M) - sqrt(M0) ) #- fMN(M, N0) - fMN(M0, N0)
  return(RF)
}

par(mfrow=c(1,2) )
# plot the methane as a mixing ratio
plot(out_data$time/t_step/12, 
     (out_data$CH4/M)*1E6, 
     ylab = "CH4 /ppm", 
     xlab = "Time since 2020 /years",
     type="l" )

# plot the methane RF
plot(out_data$time/t_step/12, 
     RF_calc(out_data$CH4), 
     ylim=c(0, 10), 
     ylab = "RF from CH4 /Wm-2", 
     xlab = "Time since 2020 /years",
     type="l" )
abline(h=0.48, col="red", lty=2)

