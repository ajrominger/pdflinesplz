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
    scriptName <- 'findlines.sh'
    texName <- 'addLineTemplate.tex'

    # make a temporary directory and copy everything there
    tempd <- tempdir()
    file.copy(file, tempd)

    findlines <- system.file(scriptName, package = 'pdflinesplz')
    file.copy(findlines, tempd)

    textemp <- system.file(texName, package = 'pdflinesplz')
    file.copy(textemp, tempd)

    # run the script in the temp dir
    # this script makes a text file for each page of the pdf with info on where
    # the lines are that are all white and where the lines are with text
    x <- system(sprintf('cd %s && sh %s %s',
                        tempd,
                        scriptName,
                        gsub('\\..*', '', fileName)))

    # load all generated text files and process
    xf <- list.files(tempd, pattern = '-raw.txt')

    x <- lapply(file.path(tempd, xf), function(f) {
        y <- read.table(f, skip = 1, sep = ' ', comment.char = '')

        # find non-white space pixels
        pix <- y[y[, 4] != '#00000000', 1]

        # extract y coordinate of those pixels--this is where the lines are
        pix <- gsub('.*,|:', '', pix)

        return(pix)
    })

    # add lines to tex template to print pdf pages


    return(x)
}
