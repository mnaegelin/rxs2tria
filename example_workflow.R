################################################################################
# installation
library(devtools)
load_all()

#remotes::install_github('tria-db/rxs2tria')
#library(rxs2tria)

################################################################################
# set path to the input and output data
# where the ROXAS files are (can contain subfolders)
path_in <- '../example_data/rxs2tria_in/QWA_Arzac2024'

# where output files should be saved to
path_out <- '../example_data/rxs2tria_out'

dataset_name <- 'POGSTO2024' # used to name the resulting output files


################################################################################
# get overview of data to be read and extract data structure from filenames
files <- get_roxas_files(path_in)

# example1: `{site}_{species}_{tree}{woodpiece}_{slide}_{image}` (with 2digit tree identifier and optional woodpiece)
pattern <- "(?<site>[:alnum:]+)_(?<species>[:alnum:]+)_(?<tree>[:alnum:][:alnum:])(?<woodpiece>[:alnum:]*)_(?<slide>[:alnum:]+)_(?<image>[:alnum:]+)"

# example2: `{site}_{species}_{tree}_{slide}_{image}`
#pattern <- "(?<site>[:alnum:]+)_(?<species>[:alnum:]+)_(?<tree>[:alnum:].+)_(?<slide>[:alnum:]+)_(?<image>[:alnum:]+)"

df_structure <- extract_data_structure(files, pattern)


################################################################################
# read available metadata
df_rxsmeta <- collect_metadata_from_files(df_structure,
                                          roxas_version='classic')

################################################################################
# complete the required metadata form via the Shiny app
launch_metadata_app()
# save the json metadata file from the app output once completed

################################################################################
# read raw cells/rings data
QWA_data <- collect_raw_data(df_structure)


################################################################################
# remove outliers
# NOTE: ROXAS does some threshold based outlier checks and assigns these a
# a negative value. Here, we replace these outliers with NAs)
QWA_data <- remove_outliers(QWA_data)


################################################################################
# complete measures (add EW/LW estimations)
QWA_data <- complete_cell_measures(QWA_data)


################################################################################
# clean raw data
QWA_data <- validate_QWA_data(QWA_data, df_rxsmeta)

# this creates some initial flags based on the data only, namely missing, incomplete and duplicate flags


################################################################################
# save preprocessed data to files
fname_out <- file.path(
  path_out,
  glue::glue("{format(Sys.Date(), '%Y%m%d')}_TRIA_{dataset_name}")
)
readr::write_csv(
  QWA_data$cells,
  paste0(fname_out, '_cells.csv.gz'))

readr::write_csv(QWA_data$rings,
                 paste0(fname_out, '_rings.csv'))




################################################################################
# provide user input on ring flags
# interactively in shiny app (NOT READY YET)
# TODO: adapt to new flag logic (need to calculate duplicate_rank in app)
# launch_coverage_app()



################################################################################
# READ QWA data
file_path <- "../example_data/rxs2tria_out"
QWA_data <- read_QWAdata(file_path)

file_path <- "../example_data/tria_download"
QWA_metadata <- read_QWA_metadata(file_path)
