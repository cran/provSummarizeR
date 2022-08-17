# Test file for summarizing files and urls

text <- readLines("warnings.r")
webpage <- readLines ("https://harvardforest.fas.harvard.edu/")

writeLines (text, tempfile())

