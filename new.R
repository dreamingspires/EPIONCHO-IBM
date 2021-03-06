

#EPIONCHO-IBM
#30/04/2020
#Jonathan Hamley 

#individual-based at the level of humans (but not parasites), age-structued for adult O.volvulus and microfilariae
#parasite life stages in black flies are deterministic and population-based
#all functions are called in ep.equi.sim which gives the final output




#ep.equi.sim will run one repeat of the model, typically the mean of 500 repeats is required
#model must be run to equilibrium (100 years), before treatment can begin 
#treatment is with ivermectin
#if the mf prevalence is zero 50 years after the final treatment, we assume elimination has occured
#code is available which saves the equilibrium and receives it as an input 

#time.its = number of iterations, ABR = annual biting rate, treat.int = treatment interval, treat.prob = total population coverage
#give.treat takes 1 (MDA) or 0 (no MDA), pnc = proportion of population which never receive treatment, min.mont.age is the minimum age for giving a skin snip

ep.equi.sim <- function(time.its,
                        ABR,
                        DT,
                        treat.int,
                        treat.prob,
                        give.treat,
                        treat.start,
                        treat.stop,
                        pnc,
                        min.mont.age)
  
  
{ 
  
  #hard coded parms

  E0 = 0; q = 0;  #age-dependent exposure to fly bites
  


  
  #matrix for first timestep, contains all parasite values, human age, sex and compliance
  all.mats.temp <- matrix(, nrow=N, ncol=num.cols)
  
  all.mats.temp[,  (worms.start) : num.cols] <- int.worms

  
  all.mats.temp[, 7 : (7 + (num.mf.comps-1))] <- int.mf
  
  all.mats.temp[,1] <- rep(0, N) #column used during treatment
  all.mats.temp[,2] <- cur.age
  
  #assign sex to humans 

  all.mats.temp[,3] <- sex
  
  #non-compliant people
  non.comp <- ceiling(N * pnc)
  out.comp <- rep(0, N)
  s.comp <- sample(N, non.comp)
  out.comp[s.comp] <- 1
  all.mats.temp[,1] <- out.comp
  

  prev <-  c()
  mean.mf.per.snip <- c()
  
  i <- 1
  
  while(i < time.its) #over time
    
  {
    #new individual exposure for newborns, clear rows for new borns
    
    
    temp.mf <- mf.per.skin.snip(
      ss.wt = 2, 
      num.ss = 2, 
      slope.kmf = 0.0478, 
      int.kMf = 0.313, 
      data = all.mats.temp, 
      nfw.start, 
      fw.end, 
      mf.start, 
      mf.end, 
      pop.size = N
    )
    
    prev <-  c(
      prev, 
      prevalence.for.age(
        age = min.mont.age, 
        ss.in = temp.mf, 
        main.dat = all.mats.temp
      )
    )
    
    
    mean.mf.per.snip <- c(
      mean.mf.per.snip, 
      mean(temp.mf[[2]][which(all.mats.temp[,2] >= min.mont.age)])
    )
    
    
    i <- i + 1
    
  }
  
  return(list(all.mats.temp, prev, mean.mf.per.snip)) #[[2]] is mf prevalence, [[3]] is intensity
  
  
}


DT.in <- 1/366 #timestep must be one day 

treat.len <- 8 #treatment duration in years

treat.strt  = round(25 / (DT.in )); treat.stp = treat.strt + round(treat.len / (DT.in )) #treatment start and stop
timesteps = treat.stp + round(3 / (DT.in )) #final duration

gv.trt = 1
trt.int = 1 #treatment interval (years, 0.5 gives biannual)


ABR.in <- 1000 #annual biting rate 
  
output <-  ep.equi.sim(time.its = timesteps,
              ABR = ABR.in,
              DT = DT.in,
              treat.int = trt.int,
              treat.prob = 65,
              give.treat = gv.trt,
              treat.start = treat.strt,
              treat.stop = treat.stp,
              pnc = 0.05, min.mont.age = 5)
  


