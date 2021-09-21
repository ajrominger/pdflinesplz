#' @title Add line numbers to a PDF
#'
#' @param file the PDF file to add line numbmers to
#'
#' @return silently returns the path to a new file saved on the local computer
#' which is a copy of the file passed as argument \code{file} but with line
#' numbers
#'
#' @export


addLines2pdf <- function(file) {
    # store key names
    pathName <- dirname(file)
    fileName <- basename(file)
    usrName <- gsub('\\..*', '', fileName)
    scriptName <- 'findlines.sh'
    texName <- 'addLineTemplate.tex'

    # make a temporary directory and make sure it's empty (an issue when
    # re-running script without restarting R session)
    tempd <- tempdir(check = TRUE)
    whatThere <- file.path(tempd, list.files(tempd))
    whatThere <- whatThere[!grepl('rs-graphics', whatThere)]

    if(length(whatThere) > 0) {
        file.remove(whatThere)
    }

    # copy all needed files to tempd
    file.copy(file, tempd)

    findlines <- system.file(scriptName, package = 'pdflinesplz')
    file.copy(findlines, tempd)

    textemp <- system.file(texName, package = 'pdflinesplz')
    file.copy(textemp, tempd)

    # run the script in the temp dir
    # this script makes a text file for each page of the pdf with info on where
    # the lines are that are all white and where the lines are with text
    system(sprintf('cd %s && sh %s %s',
                   tempd,
                   scriptName,
                   usrName))

    # load all generated text files and process
    xf <- list.files(tempd, pattern = '-raw.txt')

    x <- lapply(file.path(tempd, xf), function(f) {
        y <- read.table(f, skip = 1, sep = ' ', comment.char = '')

        # find non-white space pixels
        pix <- y[y[, 4] != '#00000000', 1]

        # extract y coordinate of those pixels--this is where the lines are
        pix <- gsub('.*,|:', '', pix)

        # make file name to save pixel indeces
        fout <- gsub('-raw\\.txt', '.txt', f)

        # save pixel indeces
        writeLines(pix, fout)

        # remove raw pixel files and raster files
        file.remove(c(f, gsub('-raw\\.txt', '', f)))

        # return file paths of clean txt files
        return(fout)
    })

    # add lines to Rmd file that will render pdf with tex template
    add2rmd <- c('---',
                 'output:',
                 '    pdf_document:',
                 '        template: addLineTemplate.tex',
                 '---',
                 '',
                 sprintf('\\def\\pdfname{%s}', usrName),
                 sprintf('\\addlinenumbers{%s}{20}{50}', 1:length(x)))

    # write out the rmd file
    rmdFile <- file.path(tempd, paste0(usrName, '_withLineNum.Rmd'))
    writeLines(add2rmd, rmdFile)

    # render the rmd file
    outpath <- rmarkdown::render(rmdFile, envir = new.env(parent = globalenv()))

    # move new pdf with line numbers back to the directory given by the user
    finalPath <- file.path(pathName, basename(outpath))
    file.copy(outpath, finalPath)

    invisible(finalPath)
}
