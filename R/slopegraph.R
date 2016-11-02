#' @rdname slopegraph
#' @aliases slopegraph-package
#' @title Create Slopegraph from a data frame
#' @description Convert an R data frame (containing a panel dataset, where rows are observations and columns are time periods) into an Edward Tufte-inspired Slopegraph.
#' @param df An observation-by-period data.frame, with at least two columns. Missing values are allowed.
#' @param xlim The x-axis limits of the plot. Automatically calculated by default.
#' @param ylim The y-axis limits of the plot. Automatically calculated by default.
#' @param main The main title of the plot. Default is \code{NULL} (none). See \code{\link[graphics]{par}}.
#' @param bty The box type for the plot. Default is \code{'n'} (none). See \code{\link[graphics]{par}}.
#' @param xaxt The x-axis type for the plot. Default is \code{'n'} (none). See \code{\link[graphics]{par}}.
#' @param yaxt The y-axis type for the plot. Default is \code{'n'} (none). See \code{\link[graphics]{par}}.
#' @param xlab The x-axis label for the plot. Default is \code{''} (none). See \code{\link[graphics]{par}}.
#' @param ylab The y-axis label for the plot. Default is \code{''} (none). See \code{\link[graphics]{par}}.
#' @param panel.first An expression to add something between drawing the blank canvas and adding the plot content (i.e., behind the slopegraph). Default is \code{NULL}.
#' @param panel.last An expression to add something after adding the plot content. Default is \code{NULL}.
#' @param xlabels The labels to use for the slopegraph periods. Default is \code{names(df)}.
#' @param labpos.left The \code{pos} (positioning) parameter for the leftside observation labels. Default is \code{2}. See \code{\link[graphics]{par}}.
#' @param labpos.right The \code{pos} (positioning) parameter for the rightside observation labels. Default is \code{2}. See \code{\link[graphics]{par}}.
#' @param decimals The number of decimals to display for values in the plot. Default is \code{NULL} (none).
# @param binval Threshold at which to force binning of labels and values (multiplier of the height of an "m"). Default is \code{1.5}.
#' @param col.lines A vector of colors for the slopegraph lines. Default is \code{par('fg')}.
#' @param col.lab A vector of colors for the observation labels. Default is \code{par('fg')}.
#' @param col.num A vector of colors for the number values. Default is \code{par('fg')}.
#' @param col.xaxt A character string containing the x-axis color. Default is \code{par('fg')}.
#' @param offset.x A small offset for \code{segments}, to be used when positioning the numeric values. Default is \code{.1}.
#' @param offset.lab A small offset for the observation labels. Default is \code{.1}.
#' @param cex.lab A numeric value indicating the size of row labels. Default is \code{1}. See \code{\link[graphics]{par}}.
#' @param cex.num A numeric value indicating the size of numeric labels. Default is \code{1}. See \code{\link[graphics]{par}}.
#' @param family The font family to use in the plots. Set to \dQuote{serif} by default.
#' @param font.lab Default is \code{1}. See \code{? text}.
#' @param font.num Default is \code{1}. See \code{? text}.
#' @param lty A vector of line type values for the slopegraph lines. Default is \code{par("lty")}. See \code{\link[graphics]{par}}.
#' @param lwd A vector of line width values for the slopegraph lines. Default is \code{par("lwd")}. See \code{\link[graphics]{par}}.
#' @param mai A margin specification. Default is \code{NULL}. See \code{\link[graphics]{par}}.
#' @param \ldots Additional arguments to \code{plot}.
#' @return A five-column matrix, where each row contains: the row number from \code{df}, \samp{x1}, \samp{x2}, \samp{y1}, and \samp{y2} coordinates for each drawn segment, invisibly.
#' @examples
#' ## Tufte's Cancer Graph (to the correct scale)
#' data(cancer)
#' slopegraph(cancer, col.lines = 'gray', xlim = c(-.5,5.5),
#'            xlabels = c('5 Year','10 Year','15 Year','20 Year'))
#' 
#' ## Tufte's GDP Graph
#' data(gdp)
#' slopegraph(gdp, col.line='gray', xlabels = c('1970','1979'), 
#'     main = 'Current Receipts of Goverment as a Percentage of Gross Domestic Product')
#' 
#' ## Ranking of U.S. State populations
#' data(states)
#' slopegraph(states, col.line='black', ylim = c(38,0),
#'            main = 'Relative Rank of U.S. State Populations, 1790-1870')
#' @references
#' \url{http://www.edwardtufte.com/bboard/q-and-a-fetch-msg?msg_id=0003nk}
#' 
#' Tufte, Edward. \emph{The Visual Display of Quantitative Information}. Graphics Press.
#' 
#' Tufte, Edward. \emph{Beautiful Evidence}. Graphics Press.
#' 
#' @seealso \code{\link{cancer}}, \code{\link{gdp}}, \code{\link{states}}
#' For a ggplot2 version, use \code{\link{ggslopegraph}}.
#' @author Thomas J. Leeper
#' @import graphics
#' @importFrom utils head
#' @export
slopegraph <- function(
    df,
    xlim = c(.5,ncol(df)+.5),
    ylim = c(min(df,na.rm=TRUE)-diff(range(df,na.rm=TRUE))/100,max(df,na.rm=TRUE)+diff(range(df,na.rm=TRUE))/100),
    main = NULL,
    bty = 'n',
    xaxt = 'n',
    yaxt = 'n',
    xlab = '',
    ylab = '',
    panel.first = NULL,
    panel.last = NULL,
    xlabels = names(df),
    labpos.left = 2,
    labpos.right = 4,
    decimals = NULL,
    col.lines = par('fg'),
    col.lab = col.lines,
    col.num = col.lines,
    col.xaxt = par('fg'),
    offset.x = .1,
    offset.lab = .1,
    cex.lab = 1,
    cex.num = 1,
    family = "serif",
    font.lab = 1,
    font.num = 1,
    lty = par("lty"),
    lwd = par("lwd"),
    mai = NULL,
    ...)
{
    # check data
    if (ncol(df) < 2) {
        stop('`df` must have at least two columns')
    }
    to_draw <- segmentize(as.matrix(df))
    
    # draw margins
    if (is.null(mai)) {
        par(mai=c(1, 0, if(is.null(main)) 0 else 1, 0))
    } else {
        par(mai=mai)
    }
    plot(NA, xlim=xlim, ylim=ylim, main=main, family=family,
         bty=bty, yaxt=yaxt, xaxt=xaxt, xlab=xlab, ylab=ylab, ...)
    # optional expression
    if (!is.null(panel.first)) {
        eval(panel.first)
    }
    
    fmt <- if (is.null(decimals)) "%0.0f" else paste0("%0.", decimals, "f")
    
    # x-axis
    axis(1, 1:ncol(df), labels = xlabels, col = col.xaxt, col.ticks = col.xaxt, family = family)
    
    # left-side labels
    leftlabs <- df[!is.na(df[,1]),1, drop = FALSE]
    text(1-offset.lab, leftlabs[,1],
         col=col.lab[which(!is.na(df[,1]))], rownames(leftlabs), pos=labpos.left, 
         cex=cex.lab, font=font.lab, family=family)
    
    # right-side labels
    rightlabs <- df[!is.na(df[,ncol(df)]), ncol(df), drop = FALSE]
    text(ncol(df)+offset.lab, rightlabs[,1], 
         col=col.lab[which(!is.na(df[,ncol(df)]))], rownames(rightlabs), pos=labpos.right, 
         cex=cex.lab, font=font.lab, family=family)
    
    if (length(col.lines) == 1L) {
        col.lines <- rep(col.lines, length.out = nrow(df))
    }
    lty <- rep(lty, length.out = nrow(df))
    lwd <- rep(lwd, length.out = nrow(df))
    to_draw2 <- to_draw[!duplicated(to_draw),]
    apply(to_draw2, 1, function(rowdata){
            i <- rowdata[1]
            x1 <- rowdata[2]
            x2 <- rowdata[3]
            y1 <- rowdata[4]
            y2 <- rowdata[5]
            # draw numeric value labels
            text(x1, y1, sprintf(fmt, y1), col = col.num[i], cex = cex.num, font = font.num, family = family)
            text(x2, y2, sprintf(fmt, y2), col = col.num[i], cex = cex.num, font = font.num, family = family)
            # draw lines
            ysloped <- (y2-y1)*offset.x
            segments(x1+offset.x, if(y1==y2) y1 else (y1+ysloped),
                     x2-offset.x, if(y1==y2) y2 else (y2-ysloped),
                     col = col.lines[i],
                     lty = lty[i],
                     lwd = lwd[i])
    })
    
    # optional expression
    if (!is.null(panel.last)) {
        eval(panel.last)
    }
    # return `to_draw` invisibly
    invisible(structure(to_draw, dimnames = list(seq_len(nrow(to_draw)), c("row", "x1", "x2", "y1", "y2"))))
}