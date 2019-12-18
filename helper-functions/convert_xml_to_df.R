
# PURPOSE -----------------------------------------------------------------

#' ClinicalTrials.gov public data download
#' 
#' EXAMPLE RUN ON CLUSTER:
#' -----------------------
#' 
#' Rscript clinicaltrials_govdata_download.R


<<<<<<< HEAD
# First download ----------------------------------------------------------
data_dir <- "../data/"
out_dir <- paste0(data_dir,"ClinicalTrialsdotGov/")
=======
data_dir <- "data/"
out_dir <- paste0(data_dir)
>>>>>>> b83b658093725aa22bece386e8dced94c7d408fc

destfile <- paste0(out_dir,"AllPublicXML.zip")
download.file("https://clinicaltrials.gov/AllPublicXML.zip",
              destfile = destfile
              )

unzip(destfile,exdir = out_dir)


# Second download ---------------------------------------------------------
destfile <- paste0(out_dir,"AllPublicXML_schema.xsd")
download.file("https://clinicaltrials.gov/ct2/html/images/info/public.xsd",
              destfile=destfile)



# Test reading xml file into dataframe ------------------------------------
library(XML)

xmlfile <- xmlTreeParse("./data/NCT00000102.xml")
class(xmlfile)
topxml <- xmlRoot(xmlfile)

topxml <- xmlSApply(topxml,
                    function(x) xmlSApply(x, xmlValue))

xml_df <- data.frame(t(topxml), row.names=NULL)

#test <- xmlToDataFrame("./data/NCT00000102.xml")
