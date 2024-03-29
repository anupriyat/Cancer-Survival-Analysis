---
title: "Cancer_Survival_Analysis"
author: "Anupriya Thirumurthy"
date: "3/7/2019"
output: html_document
---


dataPath<-"/Users/anupriya/Documents/MScA_UoC/Winter2019/HealthAnalytics/SurvivalAnalysis"
#dat <- read.table(paste(dataPath,'Modelling.csv',sep = '/'), header=TRUE)
dat <- read.csv(paste(dataPath,'Modelling.csv',sep = '/'), header=TRUE)
head(dat)

attach(dat)


## Kaplam Meier


install.packages("survival")



library("survival")



time <- Survival_years #No. of periods the patient is diagonosed with Cancer
event <- Survived_patients # Survival (Did he servive or not?) - do not consider censor
X <- cbind(Lung,Pancreas,Thyroid,Colorectal,Melanoma)
group <- Sex

 # (Mean = 4.85) Thats how long it takes for a patient diagnosed with Cancer to survive
#
summary(time)
summary(event)
summary(group)

summary(X)



kmsurvival <- survfit(Surv(time,event)~1)
summary(kmsurvival)


# 103 is when the event happened, the event is survived (No.of patients in the first period = 3891)
plot(kmsurvival, xlab = "Time", ylab = "Survival Probability")



kmsurvival1 <- survfit(Surv(time,event)~group)
summary(kmsurvival1)

plot(kmsurvival1, xlab = "Time", ylab = "Survival Probability")

time <- Survival_years #No. of periods the patient is diagonosed with Cancer
event <- Survived_patients # Survival (Did he servive or not?) - do not consider censor
X <- cbind(Lung,Pancreas,Thyroid,Colorectal,Melanoma,Diagnosis_Age,Age)
group <- Race
# (Mean = 4.85) Thats how long it takes for a patient diagnosed with Cancer to survive
summary(time) 
summary(event)
summary(group)
summary(X)

kmsurvival2 <- survfit(Surv(time,event)~group)
summary(kmsurvival2)

plot(kmsurvival2, xlab = "Time", ylab = "Survival Probability")

time <- Survival_years #No. of periods the patient is diagonosed with Cancer
event <- Survived_patients # Survival (Did he servive or not?) - do not consider censor
X <- cbind(Lung,Pancreas,Thyroid,Colorectal,Melanoma)
group <- Age_group
# (Mean = 4.85) Thats how long it takes for a patient diagnosed with Cancer to survive
summary(time) 
summary(event)
summary(group)
summary(X)

kmsurvival3 <- survfit(Surv(time,event)~group)
summary(kmsurvival3)

plot(kmsurvival3, xlab = "Time", ylab = "Survival Probability")

ggsurv <- function(s, CI = 'def', plot.cens = T, surv.col = 'gg.def',
                   cens.col = 'red', lty.est = 1, lty.ci = 2,
                   cens.shape = 3, back.white = F, xlab = 'Time',
                   ylab = 'Survival', main = ''){
 
  library(ggplot2)
  strata <- ifelse(is.null(s$strata) ==T, 1, length(s$strata))
  stopifnot(length(surv.col) == 1 | length(surv.col) == strata)
  stopifnot(length(lty.est) == 1 | length(lty.est) == strata)
 
  ggsurv.s <- function(s, CI = 'def', plot.cens = T, surv.col = 'gg.def',
                       cens.col = 'red', lty.est = 1, lty.ci = 2,
                       cens.shape = 3, back.white = F, xlab = 'Time',
                       ylab = 'Survival', main = ''){
 
    dat <- data.frame(time = c(0, s$time),
                      surv = c(1, s$surv),
                      up = c(1, s$upper),
                      low = c(1, s$lower),
                      cens = c(0, s$n.censor))
    dat.cens <- subset(dat, cens != 0)
 
    col <- ifelse(surv.col == 'gg.def', 'black', surv.col)
 
    pl <- ggplot(dat, aes(x = time, y = surv)) +
      xlab(xlab) + ylab(ylab) + ggtitle(main) +
      geom_step(col = col, lty = lty.est)
 
    pl <- if(CI == T | CI == 'def') {
      pl + geom_step(aes(y = up), color = col, lty = lty.ci) +
        geom_step(aes(y = low), color = col, lty = lty.ci)
    } else (pl)
 
    pl <- if(plot.cens == T & length(dat.cens) > 0){
      pl + geom_point(data = dat.cens, aes(y = surv), shape = cens.shape,
                       col = cens.col)
    } else if (plot.cens == T & length(dat.cens) == 0){
      stop ('There are no censored observations')
    } else(pl)
 
    pl <- if(back.white == T) {pl + theme_bw()
    } else (pl)
    pl
  }
 
  ggsurv.m <- function(s, CI = 'def', plot.cens = T, surv.col = 'gg.def',
                       cens.col = 'red', lty.est = 1, lty.ci = 2,
                       cens.shape = 3, back.white = F, xlab = 'Time',
                       ylab = 'Survival', main = '') {
    n <- s$strata
 
    groups <- factor(unlist(strsplit(names
                                     (s$strata), '='))[seq(2, 2*strata, by = 2)])
    gr.name <-  unlist(strsplit(names(s$strata), '='))[1]
    gr.df <- vector('list', strata)
    ind <- vector('list', strata)
    n.ind <- c(0,n); n.ind <- cumsum(n.ind)
    for(i in 1:strata) ind[[i]] <- (n.ind[i]+1):n.ind[i+1]
 
    for(i in 1:strata){
      gr.df[[i]] <- data.frame(
        time = c(0, s$time[ ind[[i]] ]),
        surv = c(1, s$surv[ ind[[i]] ]),
        up = c(1, s$upper[ ind[[i]] ]),
        low = c(1, s$lower[ ind[[i]] ]),
        cens = c(0, s$n.censor[ ind[[i]] ]),
        group = rep(groups[i], n[i] + 1))
    }
 
    dat <- do.call(rbind, gr.df)
    dat.cens <- subset(dat, cens != 0)
 
    pl <- ggplot(dat, aes(x = time, y = surv, group = group)) +
      xlab(xlab) + ylab(ylab) + ggtitle(main) +
      geom_step(aes(col = group, lty = group))
 
    col <- if(length(surv.col == 1)){
      scale_colour_manual(name = gr.name, values = rep(surv.col, strata))
    } else{
      scale_colour_manual(name = gr.name, values = surv.col)
    }
 
    pl <- if(surv.col[1] != 'gg.def'){
      pl + col
    } else {pl + scale_colour_discrete(name = gr.name)}
 
    line <- if(length(lty.est) == 1){
      scale_linetype_manual(name = gr.name, values = rep(lty.est, strata))
    } else {scale_linetype_manual(name = gr.name, values = lty.est)}
 
    pl <- pl + line
 
    pl <- if(CI == T) {
      if(length(surv.col) > 1 && length(lty.est) > 1){
        stop('Either surv.col or lty.est should be of length 1 in order
             to plot 95% CI with multiple strata')
      }else if((length(surv.col) > 1 | surv.col == 'gg.def')[1]){
        pl + geom_step(aes(y = up, color = group), lty = lty.ci) +
          geom_step(aes(y = low, color = group), lty = lty.ci)
      } else{pl +  geom_step(aes(y = up, lty = group), col = surv.col) +
               geom_step(aes(y = low,lty = group), col = surv.col)}
    } else {pl}
 
 
    pl <- if(plot.cens == T & length(dat.cens) > 0){
      pl + geom_point(data = dat.cens, aes(y = surv), shape = cens.shape,
                      col = cens.col)
    } else if (plot.cens == T & length(dat.cens) == 0){
      stop ('There are no censored observations')
    } else(pl)
 
    pl <- if(back.white == T) {pl + theme_bw()
    } else (pl)
    pl
  }
  pl <- if(strata == 1) {ggsurv.s(s, CI , plot.cens, surv.col ,
                                  cens.col, lty.est, lty.ci,
                                  cens.shape, back.white, xlab,
                                  ylab, main)
  } else {ggsurv.m(s, CI, plot.cens, surv.col ,
                   cens.col, lty.est, lty.ci,
                   cens.shape, back.white, xlab,
                   ylab, main)}
  pl
}

p <- ggsurv(kmsurvival2) + theme_bw()
p

p <- ggsurv(kmsurvival1) + theme_bw()
p

p <- ggsurv(kmsurvival) + theme_bw()
p

p <- ggsurv(kmsurvival3) + theme_bw()
p


