library(lme4)
library(lmerTest)
library(tidyverse)
library(ggplot2)
library(dplyr)
library(tidyr)
library(lubridate)
library(stringr)
library(rvest)
library(readr)
library(knitr)
library("data.table")
library(gplots)
library(ggridges)
library(shiny)
library(lme4)
library(rpart)
library(caret)
library(randomForest)
library(glmnet)
library("xgboost")
library("plotly")
libray(tidyverse)
libray(hablar)

dat1 = read.csv("~/Library/CloudStorage/OneDrive-UniversityofGlasgow/AllFiles/Other Projects/Workshops/REPROCODE_ANALYSIS/celegans_raw.csv")

dat1$block <-  as.numeric(dat1$block)
dat1$worm_id <- as.numeric(dat1$worm_id)
dat1$total_offspring <- as.numeric(dat1$total_offspring)

dat2 <- pivot_longer(dat1, cols = 3:5, names_to = "treatment", values_to = "total offspring") %>% filter(worm_id != 5)

full.dat <- dat2[complete.cases(dat2$`total offspring`), ]

write.csv(full.dat, file = "~/Library/CloudStorage/OneDrive-UniversityofGlasgow/AllFiles/Other Projects/Workshops/REPROCODE_ANALYSIS/celegans_datafinal.csv", row.names = F)

full_dat = read.csv("~/Library/CloudStorage/OneDrive-UniversityofGlasgow/AllFiles/Other Projects/Workshops/REPROCODE_ANALYSIS/celegans_datafinal.csv")

summary(full_dat)

plot(as.factor(full_dat$strain), full_dat$total_offspring)

full_dat <- full_dat %>%
  convert(fct(worm_id, block, strain, diet)) %>%
  filter(strain == "daf" | strain == "empty_vector" & !is.na(diet)) %>%
  mutate(total_offspring = as.numeric(total_offspring))

m1a <- lmer(total_offspring ~
              + strain
            + diet
            + (1|block),
            data = full_dat)
summary(m1a)

m1b <- lmer(total_offspring ~
              strain * diet
            + (1|block),
            data = full_dat)
summary(m1b)

m1c <- lm(total_offspring ~
            + strain * diet,
          data = full_dat)
summary(m1c)

anova(m1a, m1b, m1c)

Na <- full_dat[complete.cases(full_dat$strain), ]

ggplot(data = Na, aes(x = as.factor(strain), y = total_offspring, colour = as.factor(diet))) +
  theme_bw() +
  geom_jitter(alpha = 0.3) +
  geom_smooth(linetype = "dotted", method = "lm", colour = "black", fill = "light grey") +
  stat_summary(fun.data = "mean_cl_boot", geom = "errorbar", shape = 0, width = 0.8) +
  stat_summary(fun.data = "mean_cl_boot", geom = "point", shape = 0, width = 0.8) +
  labs(x = "Strain", y = "Total Offspring", colour = "Diet")

ggsave(filename = "final2.jpg", path = "~/Library/CloudStorage/OneDrive-UniversityofGlasgow/AllFiles/Other Projects/Workshops/REPROCODE_ANALYSIS/", dpi = 300, device = "jpg")