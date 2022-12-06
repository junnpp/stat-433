
# install required packages if not installed
my_packages <- c("shiny", "usmap", "tidyverse", "ggplot2")                                        # Specify your packages
not_installed <- my_packages[!(my_packages %in% installed.packages()[ , "Package"])]    # Extract not installed packages
if(length(not_installed)) install.packages(not_installed)            

# --------------------------------------------------------#
# import all the relevant data sets

## income inequality 90th percentile vs. others
top10 = readxl::read_xls("./data/income_ineq_top10.xls")
cols = colnames(top10) %>% stringr::str_match("\n(.+)$")
cols = cols[,2]
cols[1] = "percentile"
cols[2] = "year"
colnames(top10) = cols
top10 = top10 %>%
  rename("Georgia" = "Georgia (US)") %>%
  select(-`Washington D.C.`)

top10 = top10[-1] %>% pivot_longer(cols = c("Alabama":"Wyoming"), names_to = "state", values_to = "90th_percentile")

## population
# import and preprocess population data 
population = readxl::read_xlsx("./data/population_state.xlsx")
population = population[-1,]
states = population$state %>% stringr::str_match("^\\.(.+)")
states = states[,2]
population$state = states

population = population %>% 
  select(state, "2015":"2018") %>% 
  filter(state != "District of Columbia") %>% 
  pivot_longer(-state, names_to = "year", values_to = "population") %>%
  mutate(year = as.numeric(year))

# joining with inequality data
top10_pop = top10 %>% left_join(population, by = c("year" = "year", "state" = "state"))

## Accessibility to education (university per capita)
# Import / Preprocess the data
college = readxl::read_xls("./data/college.xls")
state_names = college$state %>% stringr::str_match("(.*) \\.+")
college$state = state_names[,2]
college = college %>% select("state", contains("total") | contains("Total"))
college %>% head(10)

# Analysis
temp = top10_pop %>%
  left_join(college, by = "state") %>%
  filter(year == 2018) %>%
  mutate(uni_per_capita = Total / population)

## Accessibility to education (secondary school per capita)
secondary = readxl::read_xlsx("./data/secondary_edu.xlsx")

## levels of education
# under high school analysis
under_high = readxl::read_xlsx("./data/under_high.xlsx", skip = 2) %>%
  pivot_longer(-Name, names_to = "Year", values_to = "under_high")

under_high = under_high %>%
  filter(stringr::str_detect(Year, "2016-.*6$")) %>%
  select(Name, under_high) %>%
  rename("state" = "Name")

high_school = readxl::read_xlsx("./data/high_school.xlsx", skip = 2) %>%
  pivot_longer(-Name, names_to = "Year", values_to = "high_school")

high_school = high_school %>%
  filter(stringr::str_detect(Year, "2016-.*6$")) %>%
  select(Name, high_school) %>%
  rename("state" = "Name")

college_comp = readxl::read_xlsx("./data/college_graduate_percentage_clean.xlsx", skip = 2) %>%
  pivot_longer(-Name, names_to = "Year", values_to = "college")

college_comp = college_comp %>%
  filter(stringr::str_detect(Year, "2016-.*6$")) %>%
  select(Name, college) %>%
  rename("state" = "Name")

## literacy 
# Import / Preprocess the data
literacy = read_csv("./data/literacy_rate.csv") %>%
  arrange(state) %>%
  rename("literacy" = "literacyRate")

## family status
# Percent of Babies Born to Unmarried Mothers by State
single_mom = read_csv("./data/single-mother.csv")

single_mom = single_mom %>%
  mutate(state = state.name[match(STATE, state.abb)]) %>%
  filter(YEAR == 2018) %>%
  select(state, RATE) %>% 
  rename("rate" = "RATE")

single_fam = readxl::read_xlsx("./data/single-parent.xlsx")

single_fam = single_fam %>% 
  filter(TimeFrame == 2018, DataFormat == "Percent", Location %in% state.name) %>%
  select(Location, Data) %>%
  rename("state" = "Location",
         "single_parent" = "Data") %>%
  mutate(single_parent = as.numeric(single_parent))

## ethnicity
race_distr = read_csv('./data/race_distribution_2018.csv', show_col_types=FALSE)

# We are only interested in the 4 larger ethnic groups.
race_distr = race_distr %>%
  select(`Location`, `White`, `Black`, `Hispanic`, `Asian`)

# Replace non-numeric values.
race_distr$Black[race_distr$Black == '<.01'] = '0'
race_distr$Asian[race_distr$Asian == 'N/A'] = '0'

# Convert the columns to numeric.
race_distr = race_distr %>%
  mutate(Black = as.numeric(Black), Asian = as.numeric(Asian))

# merge all data sets
merged_df = top10 %>%
  left_join(population, by = c("year" = "year", "state" = "state")) %>%
  left_join(college, by = "state") %>%
  mutate(uni_per_capita = log(Total / population)) %>%
  left_join(secondary, by = "state") %>%
  mutate(secondary_operational=log(`operational schools`/population)) %>%
  left_join(under_high, by = "state") %>%
  left_join(high_school, by = "state") %>%
  left_join(college_comp, by = "state") %>%
  left_join(literacy, by = "state") %>%
  left_join(single_mom, by = "state") %>%
  left_join(single_fam, by = "state") %>%
  left_join(race_distr, c('state' = 'Location')) %>% 
  rename(
    "University per Capita"="uni_per_capita",
    "Pupil-Teacher Ratio"="pupil/teacher ratio",
    "Secondary School per Capita"="secondary_operational",
    "Population % Under Highschool Education"="under_high",
    "Population % with Highschool Education"="high_school",
    "Population % with University Education"="college",
    "Literacy"="literacy",
    "Single Mother %"="rate",
    "Single Family %"="single_parent",
    "Population % White"="White",
    "Population % Black"="Black",
    "Population % Hispanic"="Hispanic",
    "Population % Asian"="Asian")

centroid_labels <- usmapdata::centroid_labels("states")

merged_df = merged_df %>%
  left_join(centroid_labels, by=c("state"="full"))

# --------------------------------------------------------#

ui <- fluidPage(
  # front end interface
  titlePanel("Income Inequality per State"),
  sidebarLayout(
    sidebarPanel(
      selectInput(inputId = "year",
                  label = "Select year",
                  choices = c("2015"=2015, "2016"=2016, "2017"=2017, "2018"=2018), selected="2018"),
      selectInput(inputId = "state",
                  label= "Select State",
                  choices = c("Alabama"="Alabama",
                              "Alaska"="Alaska",
                              "Arizona"="Arizona",
                              "Arkansas"="Arkansas",
                              "California"="California",
                              "Colorado"="Colorado",
                              "Connecticut"="Connecticut",
                              "Delaware"="Delaware",
                              "Florida"="Florida",
                              "Georgia"="Georgia",
                              "Hawaii"="Hawaii",
                              "Idaho"="Idaho",
                              "Illinois"="Illinois",
                              "Indiana"="Indiana",
                              "Iowa"="Iowa",
                              "Kansas"="Kansas",
                              "Kentucky"="Kentucky",
                              "Louisiana" ="Louisiana",
                              "Maine"="Maine",
                              "Maryland"="Maryland",
                              "Massachusetts"="Massachusetts",
                              "Michigan"="Michigan",
                              "Minnesota"="Minnesota",
                              "Mississippi"="Mississippi",
                              "Missouri"="Missouri",
                              "Montana"="Montana",
                              "Nebraska"="Nebraska",
                              "Nevada"="Nevada",
                              "New Hampshire"="New Hampshire",
                              "New Jersey"="New Jersey",
                              "New Mexico"="New Mexico",
                              "New York"="New York",
                              "North Carolina"="North Carolina",
                              "North Dakota"="North Dakota",
                              "Ohio"="Ohio",
                              "Oklahoma"="Oklahoma",
                              "Oregon"="Oregon",
                              "Pennsylvania"="Pennsylvania",
                              "Rhode Island"="Rhode Island",
                              "South Carolina"="South Carolina",
                              "South Dakota"="South Dakota",
                              "Tennessee"="Tennessee",
                              "Texas"="Texas",
                              "Utah"="Utah",
                              "Vermont"="Vermont",
                              "Virginia"="Virginia",
                              "Washington"="Washington",
                              "West Virginia"="West Virginia",
                              "Wisconsin"="Wisconsin",
                              "Wyoming"="Wyoming"),
                  selected = "Wisconsin"),
      selectInput(inputId = "factor",
                  label = "Select factor",
                  choices = c("University per Capita",
                              "Pupil-Teacher Ratio",
                              "Secondary School per Capita",
                              "Population % Under Highschool Education",
                              "Population % with Highschool Education",
                              "Population % with University Education",
                              "Literacy",
                              "Single Mother %",
                              "Single Family %",
                              "Population % White",
                              "Population % Black",
                              "Population % Hispanic",
                              "Population % Asian"), selected="Literacy")
  
    ),
    mainPanel(
      fluidRow(
        column(
          width=10,
          plotOutput("mapplot")
        ),
        column(
          width=6,
          plotOutput("yearplot")
        ),
        column(
          width=8,
          plotOutput("corr")
        )
      )
    )
  )
)

server <- function(input, output, session) {
  # back end logic
  output$mapplot = renderPlot(
    plot_usmap(data = top10 %>% filter(year == input$year), values = "90th_percentile", color = "black") + 
      scale_fill_continuous(low = "white", high = "red", name = "90th Percentile Income %") + 
      geom_text(data = merged_df %>% filter(year==input$year), aes(
        x=x, y=y, label=ifelse(state==input$state,as.character(state),"")
      )) + 
      geom_text(data = merged_df %>% filter(year==input$year), aes(
        x=x, y=y, label=ifelse(state==input$state,paste0(round(`90th_percentile`,2)*100,"%"),""), vjust=2
      )) +
      theme(legend.position = "right")
    )
  
  output$yearplot = renderPlot(
    top10 %>% 
      filter(state==input$state) %>% 
      ggplot() + 
      geom_line(aes(x=year, y=`90th_percentile`)) +
      xlab("Year") + 
      ylab("90th Percentile Income %"))
  
  output$corr = renderPlot(
    merged_df %>%
      filter(year==2018) %>% 
      ggplot(aes(y=`90th_percentile`, x=.data[[input$factor]])) +
      geom_point() +
      geom_point(data = merged_df %>% filter(state==input$state, year==input$year),
                 aes(y=`90th_percentile`, x=.data[[input$factor]]),
                 color='red') +
      geom_smooth(method='lm', se=F) +
      geom_text(aes(label=ifelse(state==input$state,as.character(state),"")), vjust=-1) +
      ylab('Income Generated by 90th Percentile') +
      ggtitle("Top 10% Generated Income vs. Factors in 2018")
  )
  
}

shinyApp(ui = ui, server = server)