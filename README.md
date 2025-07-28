# rxs2tria

*Note: this package is in development and not yet available. It is intended to facilitate the contribution of QWA datasets derived with ROXAS to the TRIA database and will be released on CRAN once stable.*

## Usage: From ROXAS output to TRIA-ready submission

### 1: Setup

Install and attach the package `rxs2tria`. Specify the input directory containing the raw ROXAS output files.
```{r}
# remotes::install_github('mnaegelin/rxs2tria')
library(rxs2tria)

path_in <- '/path/to/ROXAS/data'
```


### 2: Extract data structure

From the coding of the raw ROXAS output file names, infer the data structure (i.e., which images belong to which tree and which site, etc.).
```{r}
files <- get_input_files(path_in)
df_structure <- extract_data_structure(files)
```

### 3: Extract inferrable metadata

Extract information on ROXAS settings and image exif data directly from the raw files.
```{r}
df_meta <- collect_metadata_from_files(df_structure)
```

### 4: Interactive metadata contribution: Shiny app

Launch the Shiny app to fill in additional metadata, such as author details, site and tree information, etc.
```{r}
launch_metadata_app()
```

After completing the steps in the app, the collected metadata can be exported to JSON.

### 5: Prepare raw measurments data

Load and preprocess the cell and ring measurements data directly from the ROXAS output files.
```{r}
# read raw cells/rings data
QWA_data <- collect_raw_data(df_structure)

# clean raw data
QWA_data <- validate_QWA_data(QWA_data, df_meta)

# remove outliers
# NOTE: ROXAS does some threshold based outlier checks and assigns these a
# a negative value. Here, we replace these outliers with NAs
QWA_data <- remove_outliers(QWA_data)

# complete cell measures
QWA_data <- complete_cell_measures(QWA_data)
```

### 6: Assess coverage and ring quality (optional)

If you want to provide additional information on the quality of the images at the ring level
(e.g. flagging out-of-focus years or rings with broken cells),
you can do so via the following Shiny app.
```{r, eval = FALSE}
launch_coverage_app()
```

### 7: Export to processed data

Finally the processed data can be saved as `{dataset_name}_cells.csv` and `{dataset_name}_rings.csv` in the specified output directory.
```{r}
dataset_name <- 'my_dataset' 
save_processed_data(QWA_data, path_out = '/out') 
```

The output files (metadata JSON, cells and rings CSV) are now ready to be shared with the TRIA team.