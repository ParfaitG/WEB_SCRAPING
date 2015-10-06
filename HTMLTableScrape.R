library(XML)

# SET CURRENT PATH
setwd("C:\Path\To\Working\Directory")

# READING IN HTML TABLE FROM URL
url <- "http://www.bartleby.com/titles"
webpage <- readLines(url)
html = htmlTreeParse(webpage, useInternalNodes = TRUE, asText = TRUE)


# EXTRACTING DATA TO LIST
works <- xpathSApply(html, "concat(//table[7]/tr[1]/td/a[1], '!', 
                                    //table[7]/tr[1]/td/a[2])", xmlValue)
for (i in 2:419){  
  works <- c(works, xpathSApply(html, sprintf("concat(//table[7]/tr[%d]/td/a[1], '!',
                                        //table[7]/tr[%d]/td/a[2])", i, i), xmlValue))
}

# COMBINE LIST TO DATA FRAME
rawliteratureworks <- data.frame(works =  matrix(unlist(works), nrow=419, byrow=T))

literatureworks <- data.frame(do.call('rbind', 
                      strsplit(as.character(rawliteratureworks$works),'!',fixed=TRUE)))

# CLEAN UP FINAL DATA FRAME
names(literatureworks)[1] <- "Title"
names(literatureworks)[2] <- "Author"

literatureworks$Title <- as.character(literatureworks$Title)
literatureworks$Author <- as.character(literatureworks$Author)

for (i in 1:nrow(literatureworks)) {
  literatureworks$Author[[i]] <- ifelse(literatureworks$Title[[i]] == literatureworks$Author[[i]], 
                                        "", literatureworks$Author[[i]])
}

literatureworks <- literatureworks[nchar(literatureworks$Title) > 0, ]
literatureworks$Title <- gsub("Â", "", literatureworks$Title)

# OUTPUT FINAL DATA FRAME
write.csv(literatureworks, "HTMLDATA_R.csv", row.names=FALSE)
