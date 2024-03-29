# provSummarizeR
Reads the provenance collected by rdtLite or rdt from execution of a script or commands
in the console. Creates a human-readable summary of the provenance, including details 
on the computing environment, loaded libraries, scripts used, input and output files, 
console output, and error and warning messages. The summary is optionally saved to a 
text file and all related provenance files are optionally packaged in a zip file.


# Installation
Install from GitHub:

```
devtools::install_github("End-to-end-provenance/provSummarizeR")
```
Once installed, load the package:

```
library("provSummarizeR")
```


# Usage
The summarize functions can be used in one of three ways.

1. To sumarize the last provenance collected in the current R session:

```
prov.summarize ()
```

2. To summarize provenance that was collected in the past and stored in the file
<i>prov.json</i> on the directory <i>prov_script</i>:

```
prov.summarize.file ("prov_script/prov.json")
```

3. To run the script <i>script.R</i>, collect provenance, and summarize 
the provenance all in one step:

```
prov.summarize.run ("script.R")
```

All three functions have six optional parameters: <i>details</i>, <i>check</i>, 
<i>console</i>, <i>save</i>, <i>create.zip</i>, and <i>notes</i>.  

If <i>details</i> is TRUE, loaded libraries (with version numbers), file details 
(timestamp, hash value, saved copy) and messsage details (script and line numbers) 
are displayed. Libraries include packages loaded by the user's code, loaded before 
the script started, or loaded by rdtLite or rdt. The default value of <i>details</i> 
is FALSE.

If <i>details</i> is FALSE, only libraries loaded by the user's code at the time of 
execution are displayed. Note that some libraries used by the script might have been 
loaded before the script was executed. Use details = TRUE to see a complete list of 
loaded libraries.

If <i>check</i> is TRUE, the user's file system is checked to see if input files, 
output files, and scripts (in their original locations) are unchanged, changed, or missing.
File status is marked as follows: unchanged [:], changed [+], missing [-], or not 
checked [ ]. The default value of <i>check</i> is TRUE.

If <i>console</i> is TRUE, the summary is displayed in the console. The default value
of <i>console</i> is TRUE.

If <i>save</i> is TRUE, the summary is saved to the text file <i>prov-summary.txt</i> 
or <i>prov-summary-details.txt</i> (depending on the value of <i>details</i>) and is stored 
in the current working directory.  The default value of <i>save</i> is FALSE.

If <i>create.zip</i> is TRUE, the provenance directory is packaged into a timestamped zip 
file and placed in the current working directory.  This file contains a copy of all input 
and output files and scripts used, as well as the provenance summary text file, if <i>save</i> 
is TRUE.  It also includes the <i>prov.json</i> file containing the detailed execution trace.
The default value of <i>create.zip</i> is FALSE.

If <i>notes</i> is TRUE, notes are included for how to interpret the provenance summary.
The default value of <i>notes</i> is TRUE.

Creating the zip file depends on use of an external zip program.  This feature has been
tested with zip for Unix/Mac OS and with 7z on Windows.  It may or may not work with
other zip programs.  To use a program other than zip, set the R_ZIPCMD environment variable.


# Examples

Here is an example of a summary with details = FALSE. The first line contains the name of the 
main R script. The ENVIRONMENT section includes information describing how and when the script 
was executed and how the provenance was collected. The LIBRARIES section includes libraries 
that were loaded by the user's script along with their version numbers. The SCRIPTS section 
lists the main script and any scripts that were sourced. The PRE-EXISTING section lists any 
variables in the global environment that were used but not set by the script or console session.
The INPUTS section lists any input files or URLs. The OUTPUTS section lists any output files. 
The CONSOLE section lists any output to the screen. The ERRORS & WARNINGS section lists any error
or warning messages that were generated when the script was executed. The NOTES section explains 
how to intepret the provenance summary.

```
PROVENANCE SUMMARY for hurricane_1.R

ENVIRONMENT:
Executed at 2022-08-01T14.13.23EDT
Total execution time was 11.58 seconds
Script last modified at 2022-06-03T14.24.10EDT
Executed with R version 4.2.0 (2022-04-22 ucrt)
Platform was x86_64, mingw32
Operating system was Windows 10 x64 (build 19044)
User interface was 2022.02.2+485 Prairie Trillium (desktop)
Document converter was 2.18 @ C:\Users\erb709\AppData\Local\Pandoc\pandoc.exe
Provenance was collected with rdtLite1.4
Provenance is stored in C:/Prov/prov_hurricane_1
Hash algorithm is md5

LIBRARIES (loaded by script):
cli 3.3.0
codetools 0.2-18
grid 4.2.0
HurreconR 1.0
lattice 0.20-45
raster 3.5-21
Rcpp 1.0.8.3
rgdal 1.5-32
rlang 1.0.3
rstudioapi 0.13
sp 1.5-0
terra 1.5-34

SCRIPTS:
1[:] C:/TEST/hurricane_1.R

PRE-EXISTING:
z

INPUTS:
1[:] C:/Hurrecon/R/test/input/ids.csv
2[:] C:/Hurrecon/R/test/input/sites.csv
3[:] C:/Hurrecon/R/test/input/parameters.csv
4[:] C:/Hurrecon/R/test/input/tracks.csv
5[:] C:/Hurrecon/R/test/site/AL1935-03_Miami_FL.csv

OUTPUTS:
1[-] C:/TEST/dev.off.15.pdf

CONSOLE:
Rows: 150  Columns: 180...
Number of storms = 2...
AL1935-03 Miami FL...

ERRORS & WARNINGS:
Error in eval(annot, environ, NULL): object 'y' not found

NOTES: Files are listed in the order of execution (script 1 = main script).
The status of each file in its original location is marked as follows:
File unchanged [:], File changed [+], File missing [-], Not checked [ ].
Copies of original files are available on the provenance directory.

Libraries loaded by the user's script at the time of execution are displayed.
Note that some libraries may have been loaded before execution. Use details = 
TRUE to see all loaded libraries along with script, file, and message details.
```


Here is an example of a summary with details = TRUE. In addition to the information 
displayed above, the LIBRARIES section includes libraries that were preloaded
or loaded by rdtLite or rdt; the SCRIPTS, INPUTS, and OUTPUTS sections include file 
timestamp, hash value, and saved copy; and the CONSOLE and ERRORS & WARNINGS sections 
include script and line numbers.

```
PROVENANCE SUMMARY for hurricane_1.R (details)

ENVIRONMENT:
Executed at 2022-08-01T14.13.23EDT
Total execution time was 11.58 seconds
Script last modified at 2022-06-03T14.24.10EDT
Executed with R version 4.2.0 (2022-04-22 ucrt)
Platform was x86_64, mingw32
Operating system was Windows 10 x64 (build 19044)
User interface was 2022.02.2+485 Prairie Trillium (desktop)
Document converter was 2.18 @ C:\Users\erb709\AppData\Local\Pandoc\pandoc.exe
Provenance was collected with rdtLite1.4
Provenance is stored in C:/Prov/prov_hurricane_1
Hash algorithm is md5

LIBRARIES (loaded by script):
cli 3.3.0
codetools 0.2-18
grid 4.2.0
HurreconR 1.0
lattice 0.20-45
raster 3.5-21
Rcpp 1.0.8.3
rgdal 1.5-32
rlang 1.0.3
rstudioapi 0.13
sp 1.5-0
terra 1.5-34

LIBRARIES (preloaded):
base 4.2.0
compiler 4.2.0
datasets 4.2.0
graphics 4.2.0
grDevices 4.2.0
methods 4.2.0
rdtLite 1.4
stats 4.2.0
tools 4.2.0
utils 4.2.0

LIBRARIES (loaded by rdtLite):
colorspace 2.0-3
crayon 1.5.1
digest 0.6.29
dplyr 1.0.9
ellipsis 0.3.2
fansi 1.0.3
generics 0.1.2
ggplot2 3.3.6
glue 1.6.2
gtable 0.3.0
jsonlite 1.8.0
lifecycle 1.0.1
magrittr 2.0.3
munsell 0.5.0
pillar 1.7.0
pkgconfig 2.0.3
provParseR 1.0
provSummarizeR 1.5.1
purrr 0.3.4
R6 2.5.1
scales 1.2.0
sessioninfo 1.2.2
stringi 1.7.6
tibble 3.1.7
tidyselect 1.1.2
utf8 1.2.2
vctrs 0.4.1

SCRIPTS:
1[:] C:/TEST/hurricane_1.R
        Timestamp: 2022-06-03T14.24.10EDT
        Hash:      53b32b1731d4d283cdcd997ce764aafe
        Saved:     scripts/hurricane_1.R

PRE-EXISTING:
z

INPUTS:
1[:] C:/Hurrecon/R/test/input/ids.csv
        Timestamp: 2022-07-06 17:13:52
        Hash:      e95b5f231ad81a60cee0b73ba7e38358
        Saved:     data/2-ids.csv
2[:] C:/Hurrecon/R/test/input/sites.csv
        Timestamp: 2020-05-20 11:47:56
        Hash:      5212c02a8fd48d630153ce3292fc05d0
        Saved:     data/4-sites.csv
3[:] C:/Hurrecon/R/test/input/parameters.csv
        Timestamp: 2020-05-20 11:48:56
        Hash:      b40b24802bf121e6c3b536a06a7afaab
        Saved:     data/5-parameters.csv
4[:] C:/Hurrecon/R/test/input/tracks.csv
        Timestamp: 2022-07-06 17:13:52
        Hash:      a2dcab2d37e245c448955f5fd56dd73f
        Saved:     data/6-tracks.csv
5[:] C:/Hurrecon/R/test/site/AL1935-03_Miami_FL.csv
        Timestamp: 2022-08-01 14:13:31
        Hash:      c3e2252b1993dd380d43c92e5edf6276
        Saved:     data/8-AL1935-03_Miami_FL.csv

OUTPUTS:
1[-] C:/TEST/dev.off.15.pdf
        Timestamp: 2022-08-01 14:13:35
        Hash:      4d870779ed9d0e1ff1fc4445d7210e94
        Saved:     data/15-dev.off.15.pdf

CONSOLE:
Rows: 150  Columns: 180...
        Line 7 in hurricane_1.R
Number of storms = 2...
        Line 9 in hurricane_1.R
AL1935-03 Miami FL...
        Line 13 in hurricane_1.R

ERRORS & WARNINGS:
Error in eval(annot, environ, NULL): object 'y' not found
        Line 19 in hurricane_1.R

NOTES: Files are listed in the order of execution (script 1 = main script).
The status of each file in its original location is marked as follows:
File unchanged [:], File changed [+], File missing [-], Not checked [ ].
Copies of original files are available on the provenance directory.
All libraries preloaded or loaded at the time of execution are displayed.
```
