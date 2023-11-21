rm(list = ls()) # clean the workspace

# Load required libraries
library(StatsBombR)    # For accessing and handling StatsBomb football data
library(tidyverse)     # For data manipulation

# ---- Data Loading and Cleaning ----

#* Pulling and Organizing StatsBomb Data ----

# Measure the time it takes to execute the code within the system.time brackets (for performance)
system.time({ 
  # Fetch list of all available competitions
  all_comps <- FreeCompetitions() 
  
  # Filter to get only the 2023 FIFA Women's World Cup data (Competition ID 72, Season ID 107)
  FWWC23 <- all_comps %>%
    filter(competition_id == 72 & season_id == 107) 
  
  # Fetch all matches of the selected competition
  FWWC23_Matches <- FreeMatches(FWWC23) 
  
  # Download all match events and parallelize to speed up the process
  FWWC23_EventData <- free_allevents(MatchesDF = FWWC23_Matches, Parallel = T) 
  
  # Clean the data
  FWWC23_EventData = allclean(FWWC23_EventData) 
})

# Show the column names of the final StatsBombData dataframe
names(FWWC23_EventData)

#* Tidying Up the Teams' Names ----

# Remove the " Women's" part from team names for simplicity
FWWC23_EventData$team.name <- gsub(" Women's", "", FWWC23_EventData$team.name) 

# Rename and simplify team names in the 'Matches' data frame
FWWC23_Matches <- FWWC23_Matches %>%
  rename(
    home_team = home_team.home_team_name, 
    away_team = away_team.away_team_name  
  ) %>%
  mutate(
    home_team = gsub(" Women's", "", home_team),
    away_team = gsub(" Women's", "", away_team) 
  )


# Sample dataset for the data dictionary example

sample_dataset <- FWWC23_EventData %>%
  select(player.name, team.name, shot.type.name, shot.outcome.name,
         shot.statsbomb_xg, DistToGoal) %>%
  filter(team.name == "Australia" &
           shot.outcome.name == "Goal" &
           shot.statsbomb_xg > 0.15 &
           DistToGoal != 12) 

sample_dataset <- sample_dataset %>%
  mutate(shot.type.name = ifelse(shot.type.name == "Penalty", "TRUE", "FALSE"))

sample_dataset <- sample_dataset %>%
  rename(
    player_name = player.name,
    team_name = team.name,
    is_penalty = shot.type.name,
    shot_outcome = shot.outcome.name,
    shot_xg = shot.statsbomb_xg,
    dist_to_goal = DistToGoal
  )

write.csv(sample_dataset, "sample_Matildas_dataset_Data_Dictionary_example.csv", row.names = TRUE)
