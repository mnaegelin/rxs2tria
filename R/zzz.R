# ensure back compatibility for null coalescing operator introduced in R 4.4.0
.onLoad <- function(libname, pkgname) {
  backports::import(pkgname, "%||%")
}
