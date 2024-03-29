% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/provSummarizeR.R
\name{prov.summarize}
\alias{prov.summarize}
\alias{prov.summarize.file}
\alias{prov.summarize.run}
\title{Provenance summarization functions}
\usage{
prov.summarize(
  details = FALSE,
  check = TRUE,
  console = TRUE,
  save = FALSE,
  create.zip = FALSE,
  notes = TRUE
)

prov.summarize.file(
  prov.file,
  details = FALSE,
  check = TRUE,
  console = TRUE,
  save = FALSE,
  create.zip = FALSE,
  notes = TRUE
)

prov.summarize.run(
  r.script,
  details = FALSE,
  check = TRUE,
  console = TRUE,
  save = FALSE,
  create.zip = FALSE,
  notes = TRUE,
  ...
)
}
\arguments{
\item{details}{whether to display library, script, file, and message details}

\item{check}{whether to check against the user's file system}

\item{console}{whether to display results in the console}

\item{save}{whether to save the provenance summary to the file prov-summary.txt 
in the current working directory}

\item{create.zip}{whether to package the provenance data into a zip file stored 
in the current working directory}

\item{notes}{whether to include notes}

\item{prov.file}{the path to the file containing provenance}

\item{r.script}{the name of a file containing an R script}

\item{...}{extra parameters are passed to the provenance collector.  See rdt's 
prov.run function or rdtLites's prov.run function for details.}
}
\value{
string containing provenance summary
}
\description{
prov.summarize uses provenance collected from execution of an R script (prov.run)
or from a console session (prov.init) and outputs a text summary to the R console.
}
\details{
These functions use provenance collected by the rdtLite or rdt packages.

The provenance summary includes:
\itemize{
  \item The name of the script file executed.
  \item Environmental information identifying when the script was executed, the version 
     of R, the computing system, the tool and version used to collect provenance, the 
     location of the provenance data, and the hash algorithm used to hash files.
  \item The names of any scripts sourced.
  \item The names of any variables in the global environment that are used but not set by a script
     or a console session.
  \item Any URLs loaded.
  \item The names of files input or output.
  \item Any messages sent to standard output.
  \item Any errors or warnings.
}

If details = TRUE, additional details are displayed, including (1) libraries loaded by the 
user's code, loaded before the script started, or loaded by rtdtLite or rdt, with version 
numbers; (2) timestamps, hash values, and stored copies for scripts and data files; and 
(3) source code locations for messages.

If details = FALSE, only libraries loaded by the user's code at the time of execution 
are displayed. Note that some libraries used by the script might have been loaded before 
the script was executed. Run provSummarizeR with details = TRUE to see a complete list of 
loaded libraries.

If check = TRUE, the user's file system is checked to see if input files, output files,
and scripts (in their original locations) are unchanged, changed, or missing. The status 
of each file is marked as follows: file unchanged [:], file changed [+], file missing [-], 
or file not checked [ ]. Copies of the original files are stored on the provenance directory.

If console = TRUE, output is displayed in the console.

If save = TRUE, results are saved to the file "prov-summary.txt" or "prov-summary-details.txt"
in the current working directory.

If create.zip = TRUE, the provenance data is saved as a zip file in the current working
directory.

If notes = TRUE, notes are included for how to interpret the provenance summary.

For provenance collected from a console session, only the environment, library, pre-existing
variables, URL, and file information appear in the summary.

Creating a zip file depends on a zip executable being on the search path. By default, it 
looks for a program named "zip".  To use a program with a different name, set the value of 
the R_ZIPCMD environment variable.  This code has been tested with Unix zip and with 7-zip 
on Windows.
}
\examples{
\dontrun{prov.summarize ()}
testdata <- system.file("testdata", "prov.json", package = "provSummarizeR")
prov.summarize.file (testdata)
\dontrun{
testdata <- system.file("testscripts", "console.R", package = "provSummarizeR")
prov.summarize.run (testdata)}
}
