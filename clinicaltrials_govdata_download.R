
# PURPOSE -----------------------------------------------------------------

#' ClinicalTrials.gov public data download
#' 
#' EXAMPLE RUN ON CLUSTER:
#' -----------------------
#' 
#' source ~/Scripts/bash/submit_Rjob.sh download_clinicaltrials_govdata.R


data_dir <- "../../data/"
out_dir <- paste0(data_dir,"ClinicalTrialsdotGov/")

destfile <- paste0(out_dir,"AllPublicXML.zip")
download.file("https://clinicaltrials.gov/AllPublicXML.zip",
              destfile = destfile
              )

unzip(destfile,exdir = out_dir)

destfile <- paste0(out_dir,"AllPublicXML_schema.xsd")
download.file("https://clinicaltrials.gov/ct2/html/images/info/public.xsd",
              destfile=destfile)


