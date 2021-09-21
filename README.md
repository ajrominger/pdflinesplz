# R package *pdflinesplz*

A simple, one function package with the sole purpose of adding line numbers to 
an existing pdf file.

This is derived entirely from this answer on Stack Exchange: 
https://tex.stackexchange.com/a/18776.  I have simplified the core tex command
to only produce lefthand line numbers.  I have also removed the dependence on 
`sed` in the shell script and instead to the string handling in R.

This package has only been tested on a Mac, and while an attempt has been made
to write system agnostic code, there is a good chance this won't work on a 
Windows machine (better chance that it *will* work on Linux).

## Installation

```
devtools::install_github('ajrominger/pdflinesplz')
```

Installing *pdflinesplz* as above should also install the dependencies *magick*,
*tinytex*, and *rmarkdown* but you might need to troubleshoot some of those 
packages individually for proper installation.

## Usage

The one function (`addLines2pdf`) in package *pdflinesplz* simply takes the 
path to a pdf file you'd like to add lines to, and then does just that.  It 
will make a new file appended with `_withLineNum` and put it in the same 
directory as the original file.  For example you could do something like this:

```
library(pdflinesplz)
addLines2pdf('~/Desktop/foo.pdf')
```

and  you would then find the file `foo_withLineNum.pdf` in the Desktop folder.

