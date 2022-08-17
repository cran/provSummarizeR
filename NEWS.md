# provSummarizeR 1.5.1

* Updated to show how libraries were loaded (by script, by rdtLite, or preloaded).

# provSummarizeR 1.5

* If the same file is read and written (or written and read) with no change
  (i.e. same hash value), it now appears only once in the list of input and 
  output files.
* A new parameter was added to optionally check input, output, and script files 
  against the user's file system.
* A new parameter was added to make display of attached and loaded packages (with
  version numbers), file details (timestamp, hash value, saved copy) and message 
  details (script name, line number) optional.
* A new parameter was added to make console display optional.

# provSummarizeR 1.4.2

* Updated version number for win-builder.  There are no code changes.

# provSummarizeR 1.4.1

* Updated tests to reflect a change in rdtLite that affects the list of libraries.
  Specifically, ggplot2 will not be listed unless the script being summarized
  uses ggplot2.

# provSummarizeR 1.4

* The summary now reports pre-existing variables.  These are variables that
  are assigned before the script begins execution and are used within the script.
  
# provSummarizeR 1.3

* Added file & url information for console sessions

# provSummarizeR 1.2

* Messages to the console are included in the summary

# provSummarizeR 1.1

* Added total execution time to the summary
* Updated for provParseR 0.1.2
* Enhanced testing
