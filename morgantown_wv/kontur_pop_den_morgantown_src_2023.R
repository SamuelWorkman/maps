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

morgantown <- admin[16182,] |>
  st_transform(crs = st_crs(pop))

morgantown |> 
  ggplot() +
  geom_sf()

morgantown_pop <- st_intersection(pop, morgantown)

# wv_places <- places(state = "West Virginia")



# define aspect ratio based on bounding box

bb <- st_bbox(morgantown)

bottom_left <- st_point(c(bb[["xmin"]], bb[["ymin"]])) |> 
  st_sfc(crs = st_crs(pop))

bottom_right <- st_point(c(bb[["xmax"]], bb[["ymin"]])) |> 
  st_sfc(crs = st_crs(pop))

morgantown |> 
  ggplot() +
  geom_sf() +
  geom_sf(data = bottom_left) +
  geom_sf(data = bottom_right, color = "red")

width <- st_distance(bottom_left, bottom_right)

top_left <- st_point(c(bb[["xmin"]], bb[["ymax"]])) |> 
  st_sfc(crs = st_crs(pop))

height <- st_distance(bottom_left, top_left)


# handle conditions of width or height being the longer side

if(width > height) {
  w_ratio = 1
  h_ratio = height / width
  
} else {
  h_ratio = 1
  w_ratio = width / height
}


# convert to raster so we can then convert to matrix

size <- 5000

pop_raster <- st_rasterize(
  morgantown_pop,
  nx = floor(size * w_ratio) %>% as.numeric(),
  ny = floor(size * h_ratio) %>% as.numeric()
)

# mo_rast <- st_rasterize(morgantown_pop, nx = floor(size * w_ratio), ny = floor(size * h_ratio))

mat <- matrix(pop_raster$population, 
              nrow = floor(size * w_ratio),
              ncol = floor(size * h_ratio))

c1 <- met.brewer("OKeeffe2")
swatchplot(c1)

texture <- grDevices::colorRampPalette(c1, bias = 2)(256)
swatchplot(texture)

# plot that 3d thing!

rgl::close3d()

mat |> 
  height_shade(texture = texture) |> 
  plot_3d(heightmap = mat,
          zscale = 100 / 5,
          solid = FALSE,
          shadowdepth = 0)
