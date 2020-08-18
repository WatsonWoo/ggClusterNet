#' Inter-Domain Ecological Network, we call this biostripe network
#'
#' @param ps phyloseq Object, contains OTU tables, tax table and map table, represented sequences,phylogenetic tree.
#' @param N filter OTU tables by abundance.The defult, N=0.02, extract the top 0.02 relative abundance of OTU.
#' @param r.threshold The defult, r.threshold=0.6, it represents the correlation that the absolute value
#'  of the correlation threshold is greater than 0.6. the value range of correlation threshold from 0 to 1.
#' @param p.threshold The defult, p.threshold=0.05, it represents significance threshold below 0.05.
#' @param  method method for Correlation calculation,method="pearson" is the default value. The alternatives to be passed to cor are "spearman" and "kendall".
#' @examples
#' data(ps)
#' result <- corMicro(ps = ps,N = 0.02,r.threshold=0.6,p.threshold=0.05,method = "pearson")
#' # extract cor matrix
#' cor = result[[1]]
#' @return list which contains OTU correlation matrix
#' @author Contact: Tao Wen \email{2018203048@@njau.edu.cn} Jun Yuan \email{junyuan@@njau.edu.cn} Penghao Xie \email{2019103106@@njau.edu.cn}
#' @references
#'
#' Yuan J, Zhao J, Wen T, Zhao M, Li R, Goossens P, Huang Q, Bai Y, Vivanco JM, Kowalchuk GA, Berendsen RL, Shen Q
#' Root exudates drive the soil-borne legacy of aboveground pathogen infection
#' Microbiome 2018,DOI: \url{doi: 10.1186/s40168-018-0537-x}
#' @export


corBiostripe = function(data = NULL, group = NULL,ps = NULL,r.threshold=0.6,p.threshold=0.05,method = "spearman"){

  if (is.null(data)&is.null(group)&!is.null(ps)) {
    otu_table = as.data.frame(t(vegan_otu(ps)))
    #--- use corr.test function to calculate relation#--------
    occor = psych::corr.test(t(otu_table),use="pairwise",method=method,adjust="fdr",alpha=.05)
    occor.r = occor$r
    occor.p = occor$p
    occor.r[occor.p > p.threshold|abs(occor.r)<r.threshold] = 0
    tax = as.data.frame((vegan_tax(ps)))
    head(tax)
    A <- levels(as.factor(tax$filed))
    A
    # i = 1
    for (i in 1:length(A)) {
      fil <- intersect(row.names(occor.r),as.character(row.names(tax)[tax$filed == A[i]]))
      a <- row.names(occor.r) %in% fil
      occor.r[a,a] = 0
      occor.p[a,a] = 1
    }

  }


  if (is.null(ps)) {
    cordata <- t(data[-1])
    colnames(cordata) =data$SampleID
    #--- use corr.test function to calculate relation#--------
    occor = psych::corr.test(cordata,use="pairwise",method=method,adjust="fdr",alpha=.05)
    occor.r = occor$r
    occor.p = occor$p
    #-filter--cor value
    occor.r[occor.p > p.threshold|abs(occor.r)<r.threshold] = 0

    #--biostripe network filter
    A <- levels(as.factor(group$Group))
    i = 1


    for (i in 1:length(A)) {
      fil <- intersect(row.names(occor.r),as.character(group[[1]][group$Group == A[i]]))
      a <- row.names(occor.r) %in% fil
      occor.r[a,a] = 0
      occor.p[a,a] = 1
    }

  }
  return(list(occor.r,method,occor.p))

}
