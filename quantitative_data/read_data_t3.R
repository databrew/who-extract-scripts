library(readxl)
library(tidyverse)
library(stringr)
library(dplyr)
library(purrr)


# =============================================================================================
# **************************************** Table from T3** ************************************
# =============================================================================================



extract_t3 <- function(excel_file_path){ 
  
  sheet_num_extract <- excel_sheets(excel_file_path) %>% str_trim() %>% str_which(pattern = "\\bT3\\b")
  table1 <- readxl::read_excel(excel_file_path, sheet = sheet_num_extract)
  
  # Title years
  years_extracted <- readxl::read_excel(excel_file_path, sheet = sheet_num_extract, skip = 0, n_max = 1) %>% 
    gather() %>% 
    select(value) %>% 
    drop_na() %>% 
    pull() %>% 
    as.character()
  
  colnames(table1) <- c('indicator', years_extracted)
  
  for(j in 2:ncol(table1)){
    table1[,j] <- as.numeric(unlist(table1[,j]))
    # table1[,j] <- format(round(as.numeric(round(unlist(table1[,j]), digits = 2)), digits = 2),nsmall = 2)
  }
  
  table1 <- table1 %>%
    slice(52) %>%
    mutate(indicator = 'No OOP spending') %>%
    pivot_longer(cols = 2:ncol(table1), names_to = "Year", values_to = "value", names_repair = "unique") %>%
    pivot_wider(names_from = "indicator", values_from = "value") %>%
    mutate(`No OOP spending - new` = 100 - `No OOP spending`)
  
  # write.csv(table1, file = save_csv_path)
  # 
  # message("Table extracted from T3")  
  
  return(table1)
  
}


# ====================================================================================
# USAGE: extract_t3() function example
# ====================================================================================

### NOTES FOR KATE ###
# just changes `excel_file_path` where .xls is located, 
# also you can change `save_csv_path`- directory where to save extracted .csv (it is optional)
# Then just run the R script


# extract_t3(excel_file_path = "../data-raw/BUL_Appendix_tables.xlsx",
#            save_csv_path = "../data-raw/extracted_csvs/T3/T3_Figure_3_Final.csv")

# read_csv('../data-raw/extracted_csvs/T3/T3_Figure_3_Final.csv')

# ====================================================================================


extract_t3_fig13 <- function(excel_file_path) {
  sheet_num_extract <- excel_sheets(excel_file_path) %>% str_trim() %>% str_which(pattern = "\\bT3\\b")
  
  table <- readxl::read_excel(excel_file_path, sheet = sheet_num_extract)
  
  
  sheet_num_extract_t10 <- excel_sheets(excel_file_path) %>% str_trim() %>% str_which(pattern = "\\bT10\\b")
  table_t10 <- readxl::read_excel(excel_file_path, sheet = sheet_num_extract_t10, skip = 2) %>%
    select(1, 14) %>%
    pivot_wider(names_from = 'Year', values_from = 2) %>%
    mutate(indicator = 'At risk of impoverishment (all households)') %>%
    select(indicator, everything())
   
  # Title years
  years_extracted <- readxl::read_excel(excel_file_path, sheet = sheet_num_extract, skip = 0, n_max = 1) %>% 
    gather() %>% 
    select(value) %>% 
    drop_na() %>% 
    pull() %>% 
    as.character()
  
  colnames(table) <- c('indicator', years_extracted)
  
  for(j in 2:ncol(table)){
    table[,j] <- as.numeric(unlist(table[,j]))
    # table[,j] <- as.numeric(round(unlist(table[,j]), digits = 2))
  }
  # table[47, ]$indicator <- str_glue('{table[44, ]$indicator}- {table[47, ]$indicator}') 
  
  table <- table %>%
    slice(c(42:43)) %>%
    mutate(indicator = c('More impoverished by OOP spending', 'Impoverished by OOP spending')) %>%
    rbind(
      table_t10
    ) %>%
    pivot_longer(cols = 2:ncol(table), names_to = "Year", values_to = "value", names_repair = "unique") %>%
    pivot_wider(names_from = "indicator", values_from = "value") %>%
    mutate(
      `Impoverishing health spending` = `More impoverished by OOP spending` + `Impoverished by OOP spending`
    )
  
  # write.csv(table, file = save_csv_path)
  
  message("Table extracted from T3 (fig13)")  
  
  return(table)
  
}