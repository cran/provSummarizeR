# provSummarizeR
Reads the provenance collected by rdtLite or rdt from execution of a script or commands
in the console. Creates a human-readable summary of the provenance, including details 
on the computing environment, loaded and attached libraries, scripts used (if any), input 
and output files, console output, and error and warning messages. The summary is optionally 
saved to a text file and all related provenance files are optionally packaged in a zip file.


# Installation
Install from GitHub:

```r
# install.packages("devtools")
devtools::install_github("End-to-end-provenance/provSummarizeR")
```
Once installed, load the package:

```{r}
library("provSummarizeR")
```


# Usage
The summarize functions can be used in one of three ways.

1. To sumarize the last provenance collected in the current R session:

```{r}
prov.summarize ()
```

2. To summarize provenance that was collected in the past and stored in the file
<i>prov.json</i> on the directory <i>prov_script</i>:

```{r}
prov.summarize.file ("prov_script/prov.json")
```

3. To run the script <i>script.R</i>, collect provenance, and summarize 
the provenance all in one step:

```
prov.summarize.run ("script.R")
```

All three functions have six optional parameters: <i>details</i>, <i>check</i>, 
<i>console</i>, <i>save</i>, <i>create.zip</i>, and <i>notes</i>.  

If <i>details</i> is TRUE, loaded and attached packages (with version numbers), 
file details (timestamp, hash value, saved copy) and messsage details (script 
and line numbers) are displayed. The default value of <i>details</i> is FALSE.

If <i>check</i> is TRUE, the user's file system is checked to see if input files, 
output files, and scripts (in their original locations) are unchanged, changed, or missing.
File status is marked as follows: unchanged [:], changed [+], missing [-], or not 
checked [ ]. The default value of <i>check</i> is TRUE.

If <i>console</i> is TRUE, the summary is displayed in the console. The default value
of <i>console</i> is TRUE.

If <i>save</i> is TRUE, the summary is saved to the text file <i>prov-summary.txt</i> 
or <i>prov-summary-details.txt</i> (depending on the value of details) and is stored 
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

# Example

Here is an example of what the summary looks like (details = TRUE). The first line contains 
the name of the main R script. The ENVIRONMENT section includes details describing how and 
when the script was executed and how the provenance was collected. The LIBRARIES section lists
all libraries that were loaded or attached along with their version numbers. The SCRIPTS section
lists the main script and any scripts that were sourced. The PRE-EXISTING section lists any 
variables in the global environment that were used but not set by the script or console session. 
The INPUTS section lists any input files or URLs. The OUTPUTS section lists any output files. 
The CONSOLE section lists any output to the screen. The ERRORS section lists any error or warning 
messages that were generated when the script was executed. The NOTE section explains how to 
intepret the provenance summary.

```
PROVENANCE SUMMARY for basicTest.R (details)

ENVIRONMENT:
Executed at 2022-06-10T10.03.33EDT
Total execution time was 4.6 seconds
Script last modified at 2019-01-02T12.43.36EST
Executed with R version 4.2.0 (2022-04-22 ucrt)
Platform was x86_64-w64-mingw32/x64 (64-bit)
Operating system was Windows 10 x64 (build 19044)
Provenance was collected with rdtLite1.3.1
Provenance is stored in C:/Prov/prov_basicTest
Hash algorithm is md5

LIBRARIES:
base 4.2.0
datasets 4.2.0
ggplot2 3.3.6
graphics 4.2.0
grDevices 4.2.0
methods 4.2.0
rdtLite 1.3.1
stats 4.2.0
utils 4.2.0

SCRIPTS:
1[:] C:/TEST/basicTest.R
     2019-01-02T12.43.36EST
     dc346023da1a6deda584591fc2e296e3
     scripts/basicTest.R

PRE-EXISTING:
None

INPUTS:
1[ ] http://harvardforest.fas.harvard.edu/data/p00/hf000/hf000-01-daily-m.csv
     2022-06-10 10:03:38
     76551e9b09d96eb70bba9ae7a16aab9a
     data/18-hf000-01-daily-m.csv

OUTPUTS:
1[:] C:/TEST/shortdata.csv
     2022-06-10 10:03:38
     58725476ca78c8feb08ad15602d8a006
     data/21-shortdata.csv
2[:] C:/TEST/airt-vs-prec.pdf
     2022-06-10 10:03:38
     fdac361565021640cf429139879a905d
     data/24-airt-vs-prec.pdf

CONSOLE:
None

ERRORS:
Error in file(file, "rt"): cannot open the connection
     Line 66 in basicTest.R

NOTE: Files are listed in the order of execution (script 1 = main script).
The status of each file in its original location is marked as follows:
File unchanged [:], File changed [+], File missing [-], Not checked [ ].
Copies of original files are available on the provenance directory.```
```
