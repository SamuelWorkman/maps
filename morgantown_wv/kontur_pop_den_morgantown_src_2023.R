# Morgantown, West Virginia
# Kontur Population Density
# Samuel Workman, Ph.D.
# March 21, 2024

options(rgl.useNULL = FALSE)

library(tidyverse)
library(sf)
library(tmap)
library(ggplot2)
library(mapview)
library(stars)
library(rayshader)
library(MetBrewer)
library(colorspace)
library(rayrender)
library(magick)
library(extrafont)
library(tigris)

pop <- st_read("kontur_population_US_20231101.gpkg")
admin <- st_read("kontur_boundaries_US_20230628.gpkg")

wv_places <- places(state = "West Virginia")

mo <- wv_places |> 
  filter(NAME == "Morgantown")

mo |> 
  ggplot() +
  geom_sf()
