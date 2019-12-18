
# PURPOSE -----------------------------------------------------------------

#' ClinicalTrials.gov public data download
#' 
#' EXAMPLE RUN ON CLUSTER:
#' -----------------------
#' 
#' source ~/Scripts/bash/submit_Rjob.sh download_clinicaltrials_govdata.R


# First download ----------------------------------------------------------
data_dir <- "../data/"
out_dir <- paste0(data_dir,"AllPublicXML/")

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
