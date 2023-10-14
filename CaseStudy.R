install.packages("tidyverse")
install.packages("ggplot2")
install.packages("dplyr")
install.packages("reticulate")
install.packages("plotly")
install.packages("tidyquant")
install.packages("rworldmap")
install.packages("maps")
install.packages("gridExtra")
install.packages("ggcandle")
install.packages("webshot")
install.packages("magick")

library(tidyverse)
library(ggplot2)
library(dplyr)
library(reticulate)
library(plotly)
library(tidyquant)
library(rworldmap)
library(RColorBrewer)
library(maps)
library(purrr)
library(lubridate)
library(gridExtra)
library(ggcandle)
library(webshot)
library(magick)


CaseStudy <- read_csv("bitcoin_ohlc.csv")
head(bitcoin_ohlc)

# Graphique en chandeliers pour le BTC
fig <- plot_ly(data = CaseStudy, type = "candlestick",
               x = ~Date,
               open = ~Open,
               high = ~High,
               low = ~Low,
               close = ~Close) %>%
  layout(title = "BTC Prices and Volumes")

# Ajout des volumes avec des barres transparentes
fig <- fig %>% 
  add_bars(x = ~Date, y = ~Volume, yaxis = "y2", opacity = 0.3, name = "Volume", marker = list(color = "blue"))

# Mise à jour de la mise en page pour afficher les volumes
fig <- fig %>% 
  layout(yaxis2 = list(overlaying = "y", side = "right", title = "Volume"))

# Affichage du graphique
fig
###################################################################

CaseStudy <- read.csv("merged_tables.csv")

# Graphique en chandeliers
fig <- plot_ly(data = CaseStudy, type = "candlestick",
               x = ~Date,
               open = ~Open,
               high = ~High,
               low = ~Low,
               close = ~Close) %>%
  layout(title = "BTC Prices with Events")

# Ajout des volumes
fig <- fig %>% 
  add_bars(x = ~Date, y = ~Volume, yaxis = "y2", opacity = 0.3, name = "Volume", marker = list(color = "blue"))

# Filtrer pour obtenir seulement les rangées avec des événements non nuls
events_data <- CaseStudy[!is.na(CaseStudy$Event) & CaseStudy$Event != "",]

# Ajout des marqueurs pour les événements
fig <- fig %>% 
  add_markers(data = events_data, x = ~Date, y = ~High, hovertext = ~Event, hoverinfo = "text", marker = list(color = "blue", size = 5))

# Ajout des shapes pour les lignes
shapes <- lapply(1:nrow(events_data), function(i){
  list(
    type = "line",
    x0 = events_data$Date[i],
    y0 = events_data$High[i],
    x1 = events_data$Date[i],
    y1 = max(CaseStudy$High, na.rm = TRUE),
    line = list(color = "blue", width = 0.6, opacity = 0.6)
  )
})

# Mise à jour de la mise en page pour les volumes et les shapes
fig <- fig %>% 
  layout(yaxis2 = list(overlaying = "y", side = "right", title = "Volume"),
         shapes = shapes)

# Affichage du graphique
fig

###################################################################

CaseStudy <- read.csv("events_filtered.csv")

plot_single_event <- function(event_name, full_data) {
  event_date <- as.Date(full_data$Date[full_data$Event == event_name][1])
  subset_data <- full_data[full_data$Date %in% seq.Date(from = event_date - days(10), to = event_date + days(10), by = "days"), ]
  
  fig <- plot_ly(data = subset_data, type = "candlestick",
                 x = ~Date, open = ~Open, high = ~High, low = ~Low, close = ~Close) %>%
    layout(title = event_name)
  
  # Ajout des volumes
  fig <- fig %>% 
    add_bars(x = ~Date, y = ~Volume, yaxis = "y2", opacity = 0.3, name = "Volume", marker = list(color = "blue")) %>%
    layout(yaxis2 = list(overlaying = "y", side = "right"))
  
  # Ajout du marqueur pour l'événement
  fig <- fig %>% 
    add_markers(data = subset_data[subset_data$Event == event_name,], x = ~Date, y = ~High, text = ~Event, 
                marker = list(symbol = "circle-open", size = 10, color = "red", line = list(color = "red", width = 2)))
  
  print(fig)
}

unique_events <- unique(CaseStudy$Event)
unique_events <- unique_events[!is.na(unique_events) & unique_events != ""]

for(event in unique_events) {
  plot_single_event(event, CaseStudy)
}

#########

CaseStudy <- read.csv("events_filtered.csv")

plot_single_event <- function(event_name, full_data) {
  event_date <- as.Date(full_data$Date[full_data$Event == event_name][1])
  subset_data <- full_data[full_data$Date %in% seq.Date(from = event_date - days(10), to = event_date + days(10), by = "days"), ]
  
  fig <- plot_ly(data = subset_data, type = "candlestick",
                 x = ~Date, open = ~Open, high = ~High, low = ~Low, close = ~Close, name = "Price") 
  
  # Ajout des volumes
  fig <- fig %>% 
    add_bars(x = ~Date, y = ~Volume, yaxis = "y2", opacity = 0.3, name = "Volume", marker = list(color = "blue"))
  
  # Ajout du marqueur pour l'événement
  fig <- fig %>% 
    add_markers(data = subset_data[subset_data$Event == event_name,], x = ~Date, y = ~High, text = ~Event, 
                marker = list(symbol = "circle-open", size = 10, color = "red", line = list(color = "red", width = 2)), 
                name = "Event")
  
  # Mise à jour des axes et suppression du range slider
  fig <- fig %>% 
    layout(
      title = event_name, 
      xaxis = list(rangeslider = list(visible = FALSE)),
      yaxis2 = list(overlaying = "y", side = "right", title = "Volume"),
      yaxis = list(title = "Price")
    )
  
  print(fig)
}

unique_events <- unique(CaseStudy$Event)
unique_events <- unique_events[!is.na(unique_events) & unique_events != ""]

for(event in unique_events) {
  plot_single_event(event, CaseStudy)
}

#######################################################

#Code pour générer les graphiques et les sauvegarder sous forme d'image
webshot::install_phantomjs()

# Lecture des données
CaseStudy <- read.csv("events_filtered.csv")

# Définition de la fonction pour générer un seul graphique
plot_single_event <- function(event_name, full_data) {
  event_date <- as.Date(full_data$Date[full_data$Event == event_name][1])
  subset_data <- full_data[full_data$Date %in% seq.Date(from = event_date - days(10), to = event_date + days(10), by = "days"), ]
  
  fig <- plot_ly(data = subset_data, type = "candlestick",
                 x = ~Date, open = ~Open, high = ~High, low = ~Low, close = ~Close, name = "Price") 
  
  # Ajout des volumes
  fig <- fig %>% 
    add_bars(x = ~Date, y = ~Volume, yaxis = "y2", opacity = 0.3, name = "Volume", marker = list(color = "blue"))
  
  # Ajout du marqueur pour l'événement
  fig <- fig %>% 
    add_markers(data = subset_data[subset_data$Event == event_name,], x = ~Date, y = ~High, text = ~Event, 
                marker = list(symbol = "circle-open", size = 10, color = "red", line = list(color = "red", width = 2)), 
                name = "Event")
  
  # Mise à jour des axes et suppression du range slider
  fig <- fig %>% 
    layout(
      title = event_name, 
      xaxis = list(rangeslider = list(visible = FALSE)),
      yaxis2 = list(overlaying = "y", side = "right", title = "Volume"),
      yaxis = list(title = "Price")
    )
  
  return(fig)
}

# Obtention des événements uniques
unique_events <- unique(CaseStudy$Event)
unique_events <- unique_events[!is.na(unique_events) & unique_events != ""]

# Boucle pour générer et sauvegarder un graphique pour chaque événement unique
for(i in seq_along(unique_events)) {
  event <- unique_events[i]
  fig <- plot_single_event(event, CaseStudy)
  file_path <- file.path("/Users/loichanggeli/BTC_CASE_STUDY", paste0("event_", i, ".png"))
  export(fig, file = file_path)
}


###################################################################

# Initialization of the World Map Google trend for Bitcoin
CaseStudy <- read.csv("map_interest.csv")

# Get the data of the world map
world_map <- map_data("world")

# Join your data with the geographic data set
merged_data <- world_map %>%
  left_join(CaseStudy, by = c("region" = "country")) 

# Identify the top 5 countries based on the metric
top5_countries <- CaseStudy %>%
  top_n(5, metric)

# Calculate the central coordinates of each country to place the labels
country_centers <- merged_data %>%
  group_by(region) %>%
  summarise(avg_long = mean(long, na.rm = TRUE), avg_lat = mean(lat, na.rm = TRUE), .groups = 'drop')

top5_centers <- country_centers %>%
  filter(region %in% top5_countries$country)

# Create the choropleth map with ggplot2
p <- ggplot(data = merged_data, aes(x = long, y = lat)) +
  geom_polygon(aes(fill = metric, group = group)) +
  scale_fill_gradientn(colours = colorRampPalette(c("blue", "green", "yellow", "red"))(25),
                       name = "Bitcoin Interest") +
  theme_minimal() +
  theme(legend.position = "bottom",
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 10))

# Define the positions where you want the country names to appear
x_positions <- rep(min(merged_data$long, na.rm = TRUE) + 10, 5)
y_positions <- seq(from = min(merged_data$lat, na.rm = TRUE) + 5,
                   to = min(merged_data$lat, na.rm = TRUE) + 35,
                   length.out = 5)

# Joindre top5_countries et top5_centers sur la colonne 'country' / 'region'
annotation_data <- inner_join(top5_countries, top5_centers, by = c("country" = "region"))

# Mettez à jour les données d'annotation avec les nouvelles positions x et y
annotation_data$x <- rep(min(merged_data$long, na.rm = TRUE) + 10, nrow(annotation_data))
annotation_data$y <- seq(from = min(merged_data$lat, na.rm = TRUE) + 5,
                         to = min(merged_data$lat, na.rm = TRUE) + 35,
                         length.out = nrow(annotation_data))
annotation_data$label <- paste(annotation_data$country, ": ", annotation_data$metric, sep = "")

# Ajoutez une colonne de couleur à annotation_data
annotation_data$color <- c("red", "blue", "green", "purple", "orange")

# Mettez à jour les couches geom_text et geom_segment dans votre graphique
p <- p +
  geom_text(data = annotation_data, aes(x = x, y = y, label = label, color = color),
            size = 3, hjust = 0, show.legend = FALSE) +  # ajoutez show.legend = FALSE ici
  geom_segment(data = annotation_data,
               aes(x = x + strwidth(annotation_data$label, units = "inches") * 0.7 * 80, y = y,  
                   xend = avg_long, yend = avg_lat, color = color),
               arrow = arrow(type = "closed", length = unit(0.2, "inches")),
               lineend = "round", show.legend = FALSE) +  # ajoutez show.legend = FALSE ici
  guides(color = FALSE)  # ajoutez cette ligne pour supprimer la légende de couleur

# Affichez le graphique
print(p)

#######################################################
