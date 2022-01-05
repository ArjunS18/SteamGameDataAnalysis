#libraries
library(dplyr)
library(ggplot2)
library(plotly) 
library(psych)
library(tidyverse)
library(grid)
library(class)
library(gmodels)

#function to filter the dataframe. 
#Takes dataframe (temp_df), fil_col, fil_value as parameters and returns filtered dataframe(fil_df)
filter_function <- function(temp_df, fil_col, fil_value) {
  fil_col <- enquo(fil_col)
  fil_df <- temp_df %>% filter(grepl(fil_value, !!fil_col))
  return (fil_df)
}

#function to perform descriptive statistics in data
#takes dataframe (desc_df) and colnames vector as input
#returns the descriptive statistics dataframe (rdesc_df)
descriptive_statistics_function <- function(desc_df, col_names) {
  fil_col <- enquo(col_names)
  rdesc_df <- desc_df %>% select(!!fil_col) %>%
    psych::describe(quant=c(.25,.75))
  return(rdesc_df)
}

#function to calculate total players for each game
#takes dataframe(tp_df) and count(top_games_cnt(default is 0)) and return the computed dataframe(top_n_games_df)  
total_players_function <- function(tp_df, top_games_cnt = 0) {
player_df <- 
  tp_df %>% 
  group_by(Name) %>% 
  summarise(Total_players_per_year = sum(Peak_Players))

  #top_games_cnt has any value greater than 0, then dataframe is sorted and filtered data is returned
  if (top_games_cnt > 0) {
    top_games_df <- player_df %>% arrange(desc(Total_players_per_year))
    top_n_games_df <- head(top_games_df, top_games_cnt)
    return(top_n_games_df)
  }
  
  return(player_df) 
}

#function to check null hypothesis
#takes dataframe (filtered_game_df), null_hypothesis as input
#returns tstat, tcritical, degree of freedom as output
check_null_hypothesis_function <- function(filtered_game_df, null_hypothesis) {
  hypothesis_string <- unlist(strsplit(null_hypothesis, ' - '))
  filter_hypothesis_df <- filter_function(filtered_game_df, Month_Year, hypothesis_string[5])
  colname <- hypothesis_string[1]
  average <- mean((filter_hypothesis_df[, colname]))
  hypothesis_mean <- as.numeric(hypothesis_string[4])
  std <- sd(filter_hypothesis_df[, colname])
  nrows <- nrow(filter_hypothesis_df)
  degree_of_freedom <- nrows - 1
  tstat <- (average - hypothesis_mean) / (std/sqrt(nrows))
  tcritical <- qt(0.95, degree_of_freedom)
  hyp_values <- list(tstat, tcritical, degree_of_freedom)
  return(hyp_values)
}

#function to predict the values
#takes regression month (r_month), total month count (t_month_cnt), regression as input
#returns predicted value (p_val)
predict_function <- function(r_month, t_month_cnt, regression) {
  newdata <- data.frame(Month = r_month, Month_cnt = t_month_cnt)
  p_val <- predict(regression, newdata)
  return(p_val)
}

#function to draw time series graph
#takes dataframe (graph_data_frame) and y_value_column (colname) as input
#returns interactive ploty graph 
draw_graph_function <- function(graph_data_frame, y_value_column, graph_title = 'Time series graph') {
  colname <- enquo(y_value_column)
  tsg <- ggplot(data = graph_data_frame, mapping = aes(x=Month, y=!!colname, group=Name, color=Name)) + 
    scale_x_continuous(breaks = c(1:12)) +
    geom_line( stat = 'identity', size = 1.3) + 
    geom_point(size = 2) +
    ggtitle(graph_title)
  
  #make the graph interactive using ggploty package
  ploty_tsg <- ggplotly(tsg)
  return (ploty_tsg)
}

#function to draw null hypothesis as normal distribution curve
#takes t_stat, t_critical, boundaries, degreeoffreedom as input
#returns normal distribution graph
normal_distribution_graph_function <- function(t_stat, t_critical, boundaries, degreeoffreedom) {
  normal_distribution_graph <- ggplot(data.frame(x = c(-(ceiling(boundaries)), ceiling(boundaries))), aes(x = x)) +
    stat_function(fun = dt, args = list(df = degreeoffreedom), size = 1.5) + 
    geom_segment(aes(x = t_critical, y = 0, xend = t_critical, yend = 0.2), size = 1.5, color = 'red') +
    geom_label(aes(x = t_critical, y = 0, label=t_critical)) +
    geom_segment(aes(x = t_stat, y = 0, xend = t_stat, yend = 0.2), size = 2, color = 'blue') + 
    geom_label(aes(x = t_stat, y = 0, label=t_stat)) +  
    ggtitle('Null hypothesis normal distribution visualization')
  return(normal_distribution_graph)
}

#function to normalize data for KNN
normalize_data <- function(x) {
  return ((x - min(x)) / (max(x) - min(x))) }
 
#read data into dataframe
df <- read.csv("AllSteamData.csv")
View(df)

#rename columns to remove the spaces
colnames(df) <- c('Name', 'Month_Year', 'Avg_Players', 'Gain', 'Pct_Gain', 'Peak_Players')


#descriptive statistics using psych package
descriptive_statistics <- descriptive_statistics_function(df, c(Avg_Players, Gain, Peak_Players)) 
descriptive_statistics

#filter the data for specific years
filtered_df <- filter_function(df, Month_Year, '19')
View(filtered_df)


#get top n games based on total player count
count <- as.numeric(10)
top_n_games_df <- total_players_function(filtered_df, count)
View(top_n_games_df)
head(top_n_games_df)

#remove scientific notation
options(scipen = 999)

filtered_game_df <- filter_function(filtered_df, Name, '^Dota 2$')
filtered_game_df$Month<-gsub("/.*","",as.character(filtered_game_df$Month_Year))
filtered_game_df$Month<-as.numeric(filtered_game_df$Month)
View(filtered_game_df)

#multiple games time series graph visualization
filtered_game_df_cod <- filter_function(filtered_df, Name, 'Call of Duty: Black Ops')
filtered_game_df_cod$Month<-gsub("/.*","",as.character(filtered_game_df_cod$Month_Year))
filtered_game_df_cod$Month<-as.numeric(filtered_game_df_cod$Month)
View(filtered_game_df_cod)

#visualize the data
time_series_graph <- draw_graph_function(filtered_game_df_cod, Peak_Players, 'Time Series Graph Call of Duty')
time_series_graph

time_series_graph_dota <- draw_graph_function(filtered_game_df, Peak_Players, 'Time Series Graph Dota')
time_series_graph_dota

#hypothesis testing
#sample: Peak_Players - Dota 2 - less than - 20000 - 19
colnames(filtered_game_df)
null_hypothesis <- readline(prompt="Enter null hypothesis(column name - game name - condition - count - year): ")

print(paste('The null hypothesis is: ', null_hypothesis))

hypothesis_values <- check_null_hypothesis_function(filtered_game_df, null_hypothesis)
tstat <- as.numeric(hypothesis_values[1])
tcritical <- as.numeric(hypothesis_values[2])
degree_of_freedom <- as.numeric(hypothesis_values[3])

cat(sprintf("The computed values of t_stat \"%.2f\", t_critical \"%.2f\"\n", tstat, tcritical))

if (tstat < tcritical) {
  cat(sprintf("Fail to reject the null hypothesis: tstat \"%.2f\" does not fall in tcritical \"%.2f\" rejection region\n", tstat, tcritical))
  graph_text <- sprintf("Fail to reject null hypothesis: 
                        tstat: %.2f does not fall in t_critical: %.2f rejection region\n", tstat, tcritical)
  wrap_text <- strwrap(graph_text, width = 30, simplify = FALSE)
  graph_wrap_text <- sapply(wrap_text, paste, collapse = "\n")
} else {
  cat(sprintf("Rejected the null hypothesis: tstat \"%.2f\" falls in tcritical \"%.2f\" rejection region\n", tstat, tcritical))
  graph_text <- sprintf("Rejected null hypothesis: 
                        tstat: %.2f falls in t_critical: %.2f rejection region \n", tstat, tcritical)
  wrap_text <- strwrap(graph_text, width = 30, simplify = FALSE)
  graph_wrap_text <- sapply(wrap_text, paste, collapse = "\n")
}

#rounding off for better visualization in normal distribution curve
tstat <- round(as.numeric(hypothesis_values[1]), 1)
tcritical <- round(as.numeric(hypothesis_values[2]), 1) 
graph_text
if (tstat > 0) {
  tcritical <- abs(tcritical)
} else {
  tcritical <- -(tcritical)
}

#compute boundaries for normal distribution curve
boundaries <- ceiling(2 * tcritical)
boundaries
normal_distribution_graph <- normal_distribution_graph_function(tstat, tcritical, boundaries, degree_of_freedom)
#add manual legend to the graph
grob <- grobTree(textGrob(graph_wrap_text, x=0.05,  y=0.8, hjust=0,
                          gp=gpar(col="black", fontsize=13, fontface="italic")))
normal_distribution_graph + annotation_custom(grob)

#filter data for multiple years
years <- as.numeric(15)
mfiltered_df <- df[FALSE,]
for (year in years:20) {
  mdf <- filter_function(df, Month_Year, year)
  mfiltered_df <- rbind(mdf, mfiltered_df)
}
View(mfiltered_df)

range <- as.numeric(1:12)
filtered_df_dota <- filter_function(mfiltered_df, Name, '^Dota 2$')
filtered_df_dota$Month<-gsub("/.*","",as.character(filtered_df_dota$Month_Year))
filtered_df_dota$Year<-gsub(".*/","",as.character(filtered_df_dota$Month_Year))
filtered_df_dota$Month<-as.numeric(filtered_df_dota$Month)
filtered_df_dota$Year<-as.numeric(filtered_df_dota$Year)
filtered_df_dota <- filtered_df_dota %>% group_by(Year) %>% arrange(Month, .by_group = TRUE)
nrows <- nrow(filtered_df_dota)
filtered_df_dota$Month_cnt <- c(1:nrows)

#multivariate regressions
filtered_df_dota2 <- filter_function(df, Name, '^Dota 2$')
filtered_df_dota2_21 <- filter_function(filtered_df_dota2, Month_Year, '21')
actual_vector <- rev(filtered_df_dota2_21$Peak_Players)

regression <- lm(Peak_Players ~ factor(Month) + Month_cnt, data = filtered_df_dota)
summary(regression)
coefficients(regression)
plot(regression)
view(filtered_df_dota)

#predict the players for future months - 1 year
future_month <- as.numeric(1:9)
predict_vector <- c()
for (m in future_month) {
  predicted_value <- predict_function(regression_month, (nrows + m), regression) 
  predict_vector <- append(predict_vector, predicted_value)
}
predict_vector

#compute the accuracy of the model
mape <- mean(abs(actual_vector-predict_vector)/abs(actual_vector)) *100
mape

#KNN clustering
knn_filtered_df <- total_players_function(filtered_df,50)
View(knn_normalized_df)
knn_normalized_df <- as.data.frame(lapply(knn_filtered_df[2], normalize_data))
knn_df <- knn_filtered_df[-1]
knn_training_df <- knn_df[1:30,, drop = TRUE]
knn_test_df <- knn_df[31:50,]
knn_train_labels <- knn_filtered_df[1:30, 1, drop = TRUE]
knn_test_labels <- knn_filtered_df[31:50, 1]

knn_test_model <- knn(train = knn_training_df, test = knn_test_df, cl = knn_train_labels, k=7)
knn_test_model <- as.data.frame(knn_test_model)
CrossTable(x = knn_test_labels, y=knn_test_model,prop.chisq = FALSE)
summary(knn_test_model)
levels(knn_test_model)

#trace errors and delete unnecessary data frames
rm(knn_filtered_df)
View(filtered_df_dota)

sessionInfo()
rlang::last_error()
rlang::last_trace()
warnings()
