library(lme4);library(lmerTest)
library(tidyverse)
library(ggplot2);library(dplyr)
library(tidyr)
library(lubridate);library(stringr)
library(rvest)
library(readr)
library(knitr)
library("data.table");library(gplots)
library(ggridges)
library(shiny)
library(lme4)
library(rpart);library(caret);library(randomForest)
library(glmnet)

full_dat=read.csv("~/Library/CloudStorage/OneDrive-UniversityofGlasgow/AllFiles/Other Projects/Workshops/REPROCODE_ANALYSIS/celegans_datafinal.csv")

summary( full_dat )

plot(as.factor(full_dat$strain),full_dat$total_offspring )

full_dat <- full_dat %>% convert(fct(worm_id,block,strain,diet)) %>% filter(strain=="daf"|strain=="empty_vector"&!is.na(diet)) %>% mutate(total_offspring=as.numeric(total_offspring))

m1a<-lmer(total_offspring~
+strain
+diet
+(1|block),data=full_dat)

summary( m1a )

m1b <-lmer(total_offspring~strain*diet+(1|block),data=full_dat)

summary(m1b)

m1c= lm(total_offspring~
+strain*diet,data=full_dat)

summary ( m1c )

anova(m1a,m1b ,m1c )

# back to original data for no reason
mean(full_dat$total_offspring,na.rm=T)

t.test(total_offspring~strain,data=full_dat)

# inconsistent naming chaos
MODEL_FINAL_THING <- lm(total_offspring~diet,data=full_dat)

summary(MODEL_FINAL_THING)

anova(MODEL_FINAL_THING,m1c)
