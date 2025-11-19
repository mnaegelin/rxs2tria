#' Read already processed QWA data from CSV files
#' @export
read_QWAdata <- function(file_path, dataset_name = NULL, file_rings = NULL, file_cells = NULL) {

  files <- list.files(file_path, full.names = TRUE)
  cell_file <- stringr::str_subset(files, ".csv")
  cell_file <- stringr::str_subset(cell_file, "cells")
  if (!is.null(dataset_name)) {
    cell_file <- stringr::str_subset(cell_file, dataset_name)
  }
  ring_file <- stringr::str_subset(files, ".csv")
  ring_file <- stringr::str_subset(ring_file, "rings")
  if (!is.null(dataset_name)) {
    ring_file <- stringr::str_subset(ring_file, dataset_name)
  }

  # create filepaths from path and dataset name
  if (length(cell_file) != 1) {
    stop("Cell file could not be (uniquely) identifierd under given path.")
  }
  if (length(ring_file) != 1) {
    stop("Ring file could not be (uniquely) identifierd under given path.")
  }

  # TODO: implement for providing file names directly

  QWA_data <- list()

  # TODO: fix with final columns
  QWA_data$rings <- vroom::vroom(
    ring_file,
    col_types = c(.default = "d",
                  tree_label = "c", woodpiece_label = "c", slide_label = "c", image_label = "c",
                  year = "i", cno = "i", incomplete_ring = "l", missing_ring = "l",
                  duplicate_ring= "l", exclude_dupl= "l", exclude_issues= "l"))

  # TODO: final cols, EW_LW as logical?
  QWA_data$cells <- vroom::vroom(
    cell_file,
    col_types = c(.default = "d",
                  image_label = "c", year = "i", xpix = "i", ypix = "i", nbrno = "i", nbrid = "i", sector100 = "i", ew_lw = "c")
    )
  # TODO: check for problems?

  # TODO: validate that its after all processing steps?


  return(QWA_data)
}


read_QWA_metadata <- function(file_path, dataset_name = NULL, force_valid = TRUE) {

  files <- list.files(file_path, full.names = TRUE)
  meta_file <- stringr::str_subset(files, ".json")
  meta_file <- stringr::str_subset(meta_file, "metadata")
  if (!is.null(dataset_name)) {
    meta_file <- stringr::str_subset(meta_file, dataset_name)
  }

  if (length(meta_file) != 1) {
    stop("Metadata file could not be (uniquely) identifierd under given path.")
  }

  metadata <- jsonlite::read_json(meta_file, simplifyVector = TRUE)

  meta_schema <- jsonvalidate::json_schema$new(
    #"../rxs2tria/inst/extdata/json_schema/20251007_tria_shinyext_schema.json",
    system.file("extdata", "json_schema/20251007_tria_shinyext_schema.json", package = "rxs2tria"),
    engine = "ajv"
  )
  validation <- meta_schema$validate(meta_file, error = force_valid)
  message("Schema validation check passed? ", validation)

  metadata
}

