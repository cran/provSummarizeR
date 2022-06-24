# Copyright (C) President and Fellows of Harvard College and 
# Trustees of Mount Holyoke College, 2018, 2019, 2020.

# This program is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public
#   License along with this program.  If not, see
#   <http://www.gnu.org/licenses/>.

###############################################################################

#' Provenance summarization functions
#' 
#' prov.summarize uses provenance collected from execution of an R script (prov.run)
#' or from a console session (prov.init) and outputs a text summary to the R console.
#' 
#' These functions use provenance collected by the rdtLite or rdt packages.
#' 
#' The provenance summary includes:
#' \itemize{
#'   \item The name of the script file executed.
#'   \item Environmental information identifying when the script was executed, the version 
#'      of R, the computing system, the tool and version used to collect provenance, the 
#'      location of the provenance data, and the hash algorithm used to hash files.
#'   \item The names of any scripts sourced.
#'   \item The names of any variables in the global environment that are used but not set by a script
#'      or a console session.
#'   \item Any URLs loaded.
#'   \item The names of files input or output.
#'   \item Any messages sent to standard output.
#'   \item Any errors or warnings.
#' }
#' 
#' If details = TRUE, additional details are displayed, including loaded and attached packages
#' with version numbers; timestamps, hash values, and stored copies for scripts and data files; 
#' and source code locations for messages.
#'
#' If check = TRUE, the user's file system is checked to see if input files, output files,
#' and scripts (in their original locations) are unchanged, changed, or missing. The status 
#' of each file is marked as follows: file unchanged [:], file changed [+], file missing [-], 
#' or file not checked [ ]. Copies of the original files are stored on the provenance directory.
#'
#' If console = TRUE, output is displayed in the console.
#'
#' If save = TRUE, results are saved to the file "prov-summary.txt" or "prov-summary-details.txt"
#' in the current working directory.
#'
#' If create.zip = TRUE, the provenance data is saved as a zip file in the current working
#' directory.
#'
#' If notes = TRUE, notes are included for how to interpret the provenance summary.
#'
#' For provenance collected from a console session, only the environment, library, pre-existing
#' variables, URL, and file information appear in the summary.
#' 
#' Creating a zip file depends on a zip executable being on the search path. By default, it 
#' looks for a program named "zip".  To use a program with a different name, set the value of 
#' the R_ZIPCMD environment variable.  This code has been tested with Unix zip and with 7-zip 
#' on Windows.  
#' 
#' @param details whether to display library, script, file, and message details
#' @param check whether to check against the user's file system
#' @param console whether to display results in the console
#' @param save whether to save the provenance summary to the file prov-summary.txt 
#' in the current working directory
#' @param create.zip whether to package the provenance data into a zip file stored 
#' in the current working directory
#' @param notes whether to include notes
#' @return string containing provenance summary
#' @export
#' @examples 
#' \dontrun{prov.summarize ()}
#' @rdname summarize

prov.summarize <- function (details=FALSE, check=TRUE, console=TRUE, save=FALSE, create.zip=FALSE, 
    notes=TRUE) {
    
    # Determine which provenance collector to use
    tool <- get.tool()
    if (tool == "rdtLite") {
        prov.json <- rdtLite::prov.json
    } else {
        prov.json <- rdt::prov.json
    }
  
    prov <- provParseR::prov.parse(prov.json(), isFile = FALSE)
    prov.summary <- summarize.prov(prov, details, check, notes)
    output.prov(prov, prov.summary, details, console, save, create.zip)

    invisible(prov.summary)
}

#' prov.summarize.file reads a JSON file that contains provenance and outputs
#' a text summary to the console.
#' @param prov.file the path to the file containing provenance 
#' @param details whether to display library, script, file, and message details
#' @param check whether to check against the user's file system
#' @param console whether to display results in the console
#' @param save whether to save the provenance summary to the file prov-summary.txt 
#' in the current working directory
#' @param create.zip whether to package the provenance data into a zip file stored 
#' in the current working directory
#' @param notes whether to include notes
#' @export
#' @examples 
#' testdata <- system.file("testdata", "prov.json", package = "provSummarizeR")
#' prov.summarize.file (testdata)
#' @rdname summarize

prov.summarize.file <- function (prov.file, details=FALSE, check=TRUE, console=TRUE, save=FALSE, 
    create.zip=FALSE, notes=TRUE) {
    
    if (!file.exists(prov.file)) {  
        stop("Provenance file not found")
    } 
  
    prov <- provParseR::prov.parse(prov.file)
    prov.summary <- summarize.prov (prov, details, check, notes)
    output.prov(prov, prov.summary, details, console, save, create.zip)

    invisible(prov.summary)
}

#' prov.summarize.run executes a script, collects provenance, and outputs a
#' text summary to the console.
#' @param r.script the name of a file containing an R script
#' @param details whether to display library, script, file, and message details
#' @param check whether to check against the user's file system
#' @param console whether to display results in the console
#' @param save whether to save the provenance summary to the file prov-summary.txt 
#' in the current working directory
#' @param create.zip whether to package the provenance data into a zip file stored 
#' in the current working directory
#' @param notes whether to include notes
#' @param ... extra parameters are passed to the provenance collector.  See rdt's 
#' prov.run function or rdtLites's prov.run function for details.
#' @export 
#' @examples 
#' \dontrun{
#' testdata <- system.file("testscripts", "console.R", package = "provSummarizeR")
#' prov.summarize.run (testdata)}
#' @rdname summarize

prov.summarize.run <- function(r.script, details=FALSE, check=TRUE, console=TRUE, save=FALSE, 
    create.zip=FALSE, notes=TRUE, ...) {
    
    # Determine which provenance collector to use
    tool <- get.tool()
    if (tool == "rdtLite") {
        prov.run <- rdtLite::prov.run
        prov.json <- rdtLite::prov.json
    } else {
        prov.run <- rdt::prov.run
        prov.json <- rdt:: prov.json
    }
  
    # Run the script, collecting provenance, if a script was provided.
    tryCatch(prov.run(r.script, ...), error = function(x) {print (x)})

    # Create the provenance summary
    prov <- provParseR::prov.parse(prov.json(), isFile=FALSE)
    prov.summary <- summarize.prov (prov, details, check, notes)
    output.prov(prov, prov.summary, details, console, save, create.zip)

    invisible(prov.summary)
}

#' get.tool determines whether to use rdt or rdtLite to get the provenance.
#' If rdtLite is loaded, "rdtLite" is returned.  If rdtLite is not loaded, but rdt
#' is, "rdt" is returned.  If neither is loaded, it then checks to see if either
#' is installed, favoring "rdtLite" over "rdt". Stops if neither rdt or rdtLite 
#' is available. 
#' @return "rdtLite" or "rdt"
#' @noRd 

get.tool <- function() {
    # Determine which provenance collector to use
    loaded <- loadedNamespaces()
    if ("rdtLite" %in% loaded) {
        return("rdtLite")
    } else if ("rdt" %in% loaded) {
        return("rdt")
    } 

    installed <- utils::installed.packages()
    if ("rdtLite" %in% installed) {
        return("rdtLite")
    } else if ("rdt" %in% installed) {
        return("rdt")
    }
   
    stop("One of rdtLite or rdt must be installed.")
}

#' update.infiles updates the infiles data frame by removing later duplicates
#' (same name and hash value) in infiles and duplicates (same node id, name,
#' and hash value) that appear in outfiles. This avoids duplicate entries for 
#' a file that is first written and then read. The file "package.rds" is also 
#' removed from infiles if present.
#' @param infiles a data frame of input files
#' @param outfiles a data frame of output files
#' @return an updated data frame of infiles
#' @noRd

update.infiles <- function(infiles, outfiles) {
    if (nrow(infiles) == 0) {
        return(infiles)
    # mark files to be removed
    } else {
        infiles$keep <- TRUE
        # mark package.rds
        for (i in 1:nrow(infiles)) {
            if (infiles$name[i] == "package.rds") {
                infiles$keep[i] <- FALSE
            }
        } 
        # mark later files with same name & hash value
        if (nrow(infiles) > 1) {
            for (i in 1:(nrow(infiles)-1)) {
                if (infiles$keep[i]) {
                    for (j in (i+1):nrow(infiles)) {
                        if (infiles$name[i] == infiles$name[j] && infiles$hash[i] == infiles$hash[j]) {
                            infiles$keep[j] <- FALSE
                        }
                    }
                }
            }   
        }
        # mark files with same node id, name, and hash value in outfiles
        if (nrow(outfiles) > 0) {
            for (i in 1:nrow(infiles)) {
                for (j in 1:nrow(outfiles)) {
                    if (infiles$id[i] == outfiles$id[j] && infiles$name[i] == outfiles$name[j] && 
                        infiles$hash[i] == outfiles$hash[j]) {
           
                        infiles$keep[i] <- FALSE
                    }
                }
            } 
        }
        # remove marked files
        infiles <- infiles[infiles$keep == TRUE, ]  
        return(infiles)
    }
}

#' update.outfiles updates the outfiles data frame by removing later duplicates
#' (same name and hash value) in outfiles and duplicates (same name and hash value
#' but different node id) that appear in infiles. This avoids duplicate entries 
#' for a file that is first read and then written with no change.
#' @param outfiles a data frame of output files
#' @param infiles a data frame of input files
#' @return an updated data frame of outfiles
#' @noRd

update.outfiles <- function(outfiles, infiles) {
    if (nrow(outfiles) == 0) {
        return(outfiles)
    # mark files to be removed
    } else {
        outfiles$keep <- TRUE
        # mark later files with same name & hash value
        if (nrow(outfiles) > 1) {
            for (i in 1:(nrow(outfiles)-1)) {
                if (outfiles$keep[i]) {
                    for (j in (i+1):nrow(outfiles)) {
                        if (outfiles$name[i] == outfiles$name[j] && outfiles$hash[i] == outfiles$hash[j]) {
                            outfiles$keep[j] <- FALSE
                        }
                    }
                }
            }   
        }
        # mark files with same name and hash value but different node id in infiles
        if (nrow(infiles) > 0) {
            for (i in 1:nrow(outfiles)) {
                for (j in 1:nrow(infiles)) {
                    if (outfiles$id[i] != infiles$id[j] && outfiles$name[i] == infiles$name[j] && 
                        outfiles$hash[i] == infiles$hash[j]) {
           
                        outfiles$keep[i] <- FALSE
                    }
                }
            } 
        }
        # remove marked files
        outfiles <- outfiles[outfiles$keep == TRUE, ]  
        return(outfiles)
    }
}

#' check.file.system checks if the specified file exists in its original location 
#' and if the hash value has changed. Results are marked as follows: [:] indicates 
#' that the file exists and the hash value is unchanged, [+] indicates that the file 
#' exists but the hash value has changed, [-] indicates that the file no longer exists,
#' and [ ] indicates that no comparison was made.
#' @param location original file path and name
#' @param hash hash value
#' @param algorithm hash algorithm
#' @param check whether to check against the user's file system
#' @return a coded value indicating file status
#' @noRd

check.file.system <- function(location, hash, algorithm, check) {
    if (check == TRUE && !is.null(location) && !is.null(hash) && !is.null(algorithm)) {
        if (!file.exists(location)) {
            tag <- "[-]"
        } else if (hash != digest::digest(file=location, algo=algorithm)) {
            tag <- "[+]"
        } else {
            tag <- "[:]"
        }
    } else {
        tag <- "[ ]"
    }
    return(tag)
}

#' summarize.prov creates the provenance summary as a string.
#' @param prov the parsed provenance
#' @param details whether to display library, script, file, and message details
#' @param check whether to check against the user's file system
#' @param notes whether to include notes
#' @return provenance summary string
#' @noRd

summarize.prov <- function(prov, details, check, notes) {
    # get script file
    environment <- provParseR::get.environment(prov)
    script.path <- environment[environment$label == "script", ]$value
    script.file <- sub(".*/", "", script.path)

    # get input & output files
    infiles <- provParseR::get.input.files(prov)
    outfiles <- provParseR::get.output.files(prov)
    infiles <- update.infiles(infiles, outfiles)
    outfiles <- update.outfiles(outfiles, infiles)

    # get string for each category
    environment.st <- generate.environment.summary(prov, details, script.file)
    library.st <- generate.library.summary(prov, details)
    scripts.st <- generate.script.summary(prov, details, script.file, check)
    preexisting.st <- generate.preexisting.summary(prov)
    infiles.st <- generate.file.summary ("INPUTS:", infiles, prov, details, check)
    outfiles.st <- generate.file.summary ("OUTPUTS:", outfiles, prov, details, check)
    
    stdout.st <- generate.stdout.summary (prov, details, script.file)  
    error.st <- generate.error.summary (prov, details, script.file)

    # create summary string
    prov.summary <- paste(environment.st, library.st, scripts.st, preexisting.st, 
        infiles.st, outfiles.st, stdout.st, error.st, sep="")
    
    if (notes == TRUE) {
        prov.summary <- paste(prov.summary, get.notes(details), sep="")
    }

    return(prov.summary)
}

#' generate.environment.summary creates a text summary of the environment.
#' @param prov the parsed provenance
#' @param details whether to display library, script, file, and message details
#' @param script.file the name of the script executed.  For provenance collected from 
#' a console session, the value is "console.R"
#' @return environment summary string
#' @noRd

generate.environment.summary <- function(prov, details, script.file) {
    environment <- provParseR::get.environment(prov)
    tool.info <- provParseR::get.tool.info(prov)

    if (details == TRUE) {
        details.st <- " (details)"
    } else {
        details.st <- ""
    }

    if (script.file != "console.R") {
        st <- paste("PROVENANCE SUMMARY for ", script.file, details.st, "\n\n", sep="")
    } else {
        st <- paste("PROVENANCE SUMMARY for Console Session", details.st, "\n\n", sep="")
    }
  
    st <- paste(st, "ENVIRONMENT:\n", sep="")
    st <- paste(st, "Executed at ", environment[environment$label == "provTimestamp", ]$value, "\n", sep="")
    st <- paste(st, "Total execution time was ", environment[environment$label == "totalElapsedTime", ]$value, " seconds\n", sep="")
  
    if (script.file != "console.R") {
        st <- paste(st, "Script last modified at ", environment[environment$label == "scriptTimeStamp", ]$value, "\n", sep="")
    }
  
    st <- paste(st, "Executed with ", environment[environment$label == "langVersion", ]$value, "\n", sep="")
    st <- paste(st, "Platform was ", environment[environment$label == "architecture", ]$value, "\n", sep="")
    st <- paste(st, "Operating system was ", environment[environment$label == "operatingSystem", ]$value, "\n", sep="")

    if ("ui" %in% environment$label) {
        st <- paste(st, "User interface was ", environment[environment$label == "ui", ]$value, "\n", sep="")
    }
    if ("pandoc" %in% environment$label) {
        st <- paste(st, "Document converter was ", environment[environment$label == "pandoc", ]$value, "\n", sep="")
    }

    st <- paste(st, "Provenance was collected with ", tool.info$tool.name, tool.info$tool.version, "\n", sep="")
    st <- paste(st, "Provenance is stored in ", environment[environment$label == "provDirectory", ]$value, "\n", sep="")
    st <- paste(st, "Hash algorithm is ", environment[environment$label == "hashAlgorithm", ]$value, "\n\n", sep="")
  
    return(st)
}

#' generate.library.summary creates a text summary of the libraries used.
#' @param prov the parsed provenance
#' @param details whether to display library, script, file, and message details
#' @return library summary string
#' @noRd

generate.library.summary <- function (prov, details) {
    if (details == FALSE) {
        return("")
    } else {
        libs <- provParseR::get.libs(prov)
        st1 <- "LIBRARIES:\n"
        st2 <- paste(libs$name, libs$version, collapse="\n")
        st <- paste(st1, st2, "\n\n", sep="")
        return(st)
    }
}

#' generate.script.summary creates a text summary of the scripts sourced.
#' @param prov the parsed provenance
#' @param details whether to display library, script, file, and message details
#' @param script.file the name of the script executed.  For provenance collected from 
#' a console session, the value is "console.R"
#' @param check whether to check against the user's file system
#' @return script summary string
#' @noRd

generate.script.summary <- function (prov, details, script.file, check) {
    # no scripts for console sessions
    if (script.file == "console.R") {
        return("")
    # get script info
    } else {
        environment <- provParseR::get.environment(prov)
        scripts <- provParseR::get.scripts(prov)
        algorithm <- environment[environment$label == "hashAlgorithm", ]$value
        st <- "SCRIPTS:\n"
        for (i in 1:nrow(scripts)) {
            if (i == 1) {
                # main script
                location <- environment[environment$label == "script", ]$value
                timestamp <- environment[environment$label == "scriptTimeStamp", ]$value
                hash <- environment[environment$label == "scriptHash", ]$value
                saved.file <- paste("scripts/", basename(script.file), sep="")
            } else {
                # sourced scripts
                location <- scripts[i, "script"]
                timestamp <- scripts[i, "timestamp"]
                hash <- scripts[i, "hash"]
                if (is.null(hash)) {
                    hash <- environment[environment$label == "sourcedScriptHashes", ][i]
                }
                saved.file <- paste("scripts/", basename(scripts[i, "script"]), sep="")
            }
            tag <- check.file.system(location, hash, algorithm, check)
            st <- paste(st, i, tag, " ", location, "\n", sep="")

            if (details == TRUE) {
                st <- paste(st, "     ", timestamp, "\n", sep="")
                st <- paste(st, "     ", hash, "\n", sep="")
                st <- paste(st, "     ", saved.file, "\n", sep="")
            }
        }
        st <- paste(st, "\n", sep="")
        return(st)
    }
}

#' generate.preexisting.summary lists variables in the global environment that are used 
#' but not set by a script or a console session.
#' @param prov the parsed provenance
#' @return prexisting variables summary string
#' @noRd

generate.preexisting.summary <- function(prov) {
    vars <- provParseR::get.preexisting(prov)
    st <- "PRE-EXISTING:\n"
    if (is.null(vars) || nrow(vars) == 0) {
        st <- paste(st, "None\n", sep="")
    } else {
        for (i in 1:nrow(vars)) {   
            st <- paste(st, vars[i, "name"], "\n", sep="")
        }
    }
    st <- paste(st, "\n", sep="")
    return(st)
}

#' generate.file.summary creates a text summary of files read or written by the script.
#' @param direction the file list heading (INPUT or OUTPUT)
#' @param files the data frame containing information about the files read or written
#' @param prov the provenance object
#' @param details whether to display library, script, file, and message details
#' @param check whether to check against the user's file system
#' @return file summary string
#' @noRd

generate.file.summary <- function (direction, files, prov, details, check) {
    st <- paste(direction, "\n", sep="")
    if (nrow(files) == 0) {
        st <- paste(st, "None\n", sep="")
    } else {
        environment <- provParseR::get.environment(prov)
        prov.dir <- environment[environment$label == "provDirectory", ]$value
        algorithm <- environment[environment$label == "hashAlgorithm", ]$value
    
        # Figure out which tool and version we are using.
        tool.info <- provParseR::get.tool.info(prov)
        tool <- tool.info$tool.name
        version <- tool.info$tool.version

        if (tool == "rdtLite" && utils::compareVersion (version, "1.0.3") < 0) {
            use.original.timestamp <- TRUE
        } else if (tool == "rdt" && utils::compareVersion (version, "3.0.3") < 0) {
            use.original.timestamp <- TRUE
        } else {
            use.original.timestamp <- FALSE
        }
    
        # In rdtLite before 1.0.3, and in rdt before 3.0.3, file times were
        # not preserved when copying into the data directory.  Therefore, we needed
        # to get the timestamp from the original file.  In later versions of the
        # tools, the timestamps are preserved, so we use the timestamp in the
        # saved copies.
        if (use.original.timestamp) {
            files$filetime <- as.character (file.mtime(files$location))
        } else {
            files$filetime <- as.character (file.mtime(paste0 (prov.dir, "/", files$value)))
        }
    
        for (i in 1:nrow(files)) {
            file.type <- files[i, "type"]
            if (file.type == "File") {
                # option to check file system
                location <- files[i, "location"]
                hash <- files[i, "hash"]
                tag <- check.file.system(location, hash, algorithm, check)
                st <- paste(st, i, tag, " ", location, "\n", sep="")

            } else {
                st <- paste(st, i, "[ ] ", files[i, "name"], "\n", sep="")
            }

            if (details) {
                if (is.na(files[i, "filetime"])) {
                    if (files[i, "timestamp"] != "") {
                        st <- paste(st, "     ", files[i, "timestamp"], "\n", sep="")
                    }
                } else {
                    st <- paste(st, "     ", files[i, "filetime"], "\n", sep="")
                }
                
                if (files[i, "hash"] != "") {
                    st <- paste(st, "     ", files[i, "hash"], "\n", sep="")
                }
                if (files[i, "value"] != "") {
                    st <- paste(st, "     ", files[i, "value"], "\n", sep="")
                }
            }
        }
    }
    st <- paste(st, "\n", sep="")
    return(st)
}

#' generate.stdout.summary creates a text summary for messages sent to standard output. 
#' It identifies the line of code that produced the message as well as the message.
#' If the output is long, it identifies the snapshot file instead.
#' @param prov the provenance object
#' @param details whether to display library, script, file, and message details
#' @param script.file the name of the script executed.  For provenance collected from 
#' a console session, the value is "console.R"
#' @return standard output summary string
#' @noRd

generate.stdout.summary <- function (prov, details, script.file) {
    # not available for console sessions
    if (script.file == "console.R") {
        return("")
    # get standard output nodes
    } else {
        stdout.nodes <- provParseR::get.stdout.nodes(prov)
        return(generate.message.summary(prov, stdout.nodes, details, "CONSOLE"))
    }
}

#' generate.error.summary creates a text summary for errors and warnings.  It identifies
#' the line of code that produced the error as well as the error message.
#' @param prov the provenance object
#' @param details whether to display library, script, file, and message details
#' @param script.file the name of the script executed.  For provenance collected from 
#' a console session, the value is "console.R"
#' @return error summary string
#' @noRd

generate.error.summary <- function (prov, details, script.file) {
    # not available for console sessions
    if (script.file == "console.R") {
        return("")
    # get error nodes
    } else {
        error.nodes <- provParseR::get.error.nodes(prov)
        return(generate.message.summary(prov, error.nodes, details, "ERRORS"))
    }
}

#' generate.message.summary creates a text summary for messages sent to standard output.  
#' It identifies the line of code that produced the message as well as the message.
#' If the output is long, it identifies the snapshot file instead.
#' @param prov the provenance object
#' @param output.nodes standard output or error nodes
#' @param details whether to display library, script, file, and message details
#' @param msg summary title (CONSOLE or ERRORS)
#' @return message summary string
#' @noRd

generate.message.summary <- function (prov, output.nodes, details, msg) {
    st <- paste(msg, ":\n", sep="")
    if (nrow(output.nodes) == 0) {
        st <- paste(st, "None\n\n", sep="")
        return(st)
    }
  
    # Get the proc-data edges and the proc nodes
    proc.data.edges <- provParseR::get.proc.data(prov)
    proc.nodes <- provParseR::get.proc.nodes(prov)
  
    # Merge the data frames so that we have the output and the operation that
    # produced that output in 1 row
    output.report <- merge(output.nodes, proc.data.edges, by.x="id", by.y="entity")
    output.report <- merge(output.report, proc.nodes, by.x="activity", by.y="id")
  
  
    # Get the scripts and remove the directory name
    scripts <- provParseR::get.scripts(prov)
    scripts <- sub(".*/", "", scripts$script)
  
    # Output the error information, using line numbers if available
    for (i in 1:nrow(output.nodes)) {
        script.name <- scripts[output.report[i, "scriptNum"]]
        info <- output.report[i, "value"]
        info <- sub("\n", "", info)
        st <- paste(st, info, "\n", sep="")
        if (!is.na (script.name) && details) {
            if (is.na(output.report[i, "startLine"])) {
                st <- paste(st, "     Line", sep="")
                st <- paste(st, "  ", output.report[i, "name"], "\n", sep="")

            } else if (output.report[i, "startLine"] == output.report[i, "endLine"] || 
                is.na (output.report[i, "endLine"])) {  

                st <- paste(st, "     Line ", output.report[i, "startLine"], sep="")

            } else {
                st <- paste(st, "     Lines ", output.report[i, "startLine"], " to ", output.report[i, "endLine"], sep="")
            }

            st <- paste(st, " in ", script.name, "\n", sep="")
        }
    }
    st <- paste(st, "\n", sep="")
    return(st)
}

#' get.notes returns a set of instructions for how to interpret the provenance summary.
#' @param details whether to display library, script, file, and message details
#' @return instruction string
#' @noRd 

get.notes <- function(details) {
    
    notes <- "NOTE: Files are listed in the order of execution (script 1 = main script).
The status of each file in its original location is marked as follows:
File unchanged [:], File changed [+], File missing [-], Not checked [ ].
Copies of original files are available on the provenance directory.\n"

    if (details == FALSE) {
        notes <- paste(notes, "Use details = TRUE to see a list of packages that were loaded or attached
at the time of execution along with script, file, and message details.\n", sep="")
    }

    notes <- paste(notes, "\n", sep="")

    return(notes)
}

#' output.prov optionally displays the provenance summary in the console,
#' saves the provenance summary to a text file, and/or saves the provenence
#' data to a zip file.
#' @param prov the provenance object
#' @param prov.summary the provenance summary
#' @param details whether to display library, script, file, and message details
#' @param console whether to display results in the console
#' @param save whether to save the provenance summary to the file prov-summary.txt 
#' in the current working directory
#' @param create.zip whether to package the provenance data into a zip file stored 
#' in the current working directory
#' @return no return value
#' @noRd 

output.prov <- function(prov, prov.summary, details, console, save, create.zip) {
    if (console == TRUE) {
        cat(prov.summary)
    }
    if (save == TRUE) {
        save.to.text.file(prov, prov.summary, details, console)
    }
    if (create.zip == TRUE) {
        save.to.zip.file(prov, console)
    }
}

#' save.to.text.file saves the provenance summary to the file "prov-summary.txt"
#' or "prov-summary-details.txt" on the current working directory
#' @param prov the provenance object
#' @param prov.summary the provenance summary
#' @param details whether to display library, script, file, and message details
#' @param console whether to display results in the console
#' @return no return value
#' @noRd 

save.to.text.file <- function(prov, prov.summary, details, console) {
    environment <- provParseR::get.environment(prov)
    if (details == TRUE) {
        prov.file <- paste(getwd(), "/prov-summary-details.txt", sep="")
    } else {
        prov.file <- paste(getwd(), "/prov-summary.txt", sep="")
    }

    cat(prov.summary, file=prov.file)
    if (console == TRUE) {
        cat(paste("Saving provenance summmary in", prov.file))
    }
}

#' save.to.zip.file creates a zip file of the provenance data and saves it
#' in the current working directory.
#' @param prov the provenance object
#' @param console whether to display results in the console
#' @return no return value
#' @noRd

save.to.zip.file <- function (prov, console) {
    # Determine where the provenance is located
    environment <- provParseR::get.environment(prov)
    cur.dir <- getwd()
    prov.path <- environment[environment$label == "provDirectory", ]$value
    setwd(prov.path)
  
    # Determine the name for the zip file
    prov.dir <- sub (".*/", "", prov.path)
    zipfile <- paste0 (prov.dir, "_", 
        environment[environment$label == "provTimestamp", ]$value, ".zip")
    zippath <- paste0 (cur.dir, "/", zipfile)

    if (file.exists (zippath)) {
        warning (zippath, " already exists.")

    } else {
        # Zip it up
        zip.program <- Sys.getenv("R_ZIPCMD", "zip")
        
        if (.Platform$OS.type == "windows" && endsWith (zip.program, "7z.exe")) {
            # 7z.exe a prov.zip . -r -x!debug 
            zip.result <- utils::zip (zippath, ".", flags="a", extras="-r -x!debug")
        } else {
            # zip -r prov.zip . -x debug/ 
            zip.result <- utils::zip (zippath, ".", flags="-r", extras="-x debug/")
        }
    
        # Check for errors
        if (zip.result == 0 && console == TRUE) {
            cat(paste ("Provenance saved in", zipfile))
        } else if (zip.result == 127) {
            warning ("Unable to create a zip file.  Please check that you have a zip program, such as 7-zip, on your path, and have the R_ZIPCMD environment variable set.")
        } else if (zip.result == 124) {
            warning ("Unable to create a zip file.  The zip program timed out.")
        } else {
            warning ("Unable to create a zip file.  The zip program ", zip.program, " returned error ", zip.result)
        }
    }
  
    # Return to the directory where the user executed the command from.
    setwd(cur.dir)
}
