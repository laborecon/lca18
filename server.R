library(readxl)
library(data.table)

in_shinyapps <- FALSE
cols18all <- c("X","CASE_NUMBER","CASE_STATUS","CASE_SUBMITTED","DECISION_DATE","VISA_CLASS",
            "EMPLOYMENT_START_DATE","EMPLOYMENT_END_DATE","EMPLOYER_NAME","EMPLOYER_BUSINESS_DBA",
            "EMPLOYER_ADDRESS","EMPLOYER_CITY","EMPLOYER_STATE","EMPLOYER_POSTAL_CODE",
            "EMPLOYER_COUNTRY","EMPLOYER_PROVINCE","EMPLOYER_PHONE","EMPLOYER_PHONE_EXT",
            "AGENT_REPRESENTING_EMPLOYER","AGENT_ATTORNEY_NAME","AGENT_ATTORNEY_CITY",
            "AGENT_ATTORNEY_STATE","JOB_TITLE","SOC_CODE","SOC_NAME","NAICS_CODE","TOTAL_WORKERS",
            "NEW_EMPLOYMENT","CONTINUED_EMPLOYMENT","CHANGE_PREVIOUS_EMPLOYMENT",
            "NEW_CONCURRENT_EMPLOYMENT","CHANGE_EMPLOYER","AMENDED_PETITION","FULL_TIME_POSITION",
            "PREVAILING_WAGE","PW_UNIT_OF_PAY","PW_WAGE_LEVEL","PW_SOURCE","PW_SOURCE_YEAR",
            "PW_SOURCE_OTHER","WAGE_RATE_OF_PAY_FROM","WAGE_RATE_OF_PAY_TO","WAGE_UNIT_OF_PAY",
            "H-1B_DEPENDENT","WILLFUL_VIOLATOR","SUPPORT_H1B","LABOR_CON_AGREE",
            "PUBLIC_DISCLOSURE_LOCATION","WORKSITE_CITY","WORKSITE_COUNTY","WORKSITE_STATE",
            "WORKSITE_POSTAL_CODE","ORIGINAL_CERT_DATE")
cols18 <- c("CASE_STATUS","VISA_CLASS",
            "EMPLOYMENT_START_DATE","EMPLOYMENT_END_DATE","EMPLOYER_NAME",
            "EMPLOYER_CITY","EMPLOYER_STATE","EMPLOYER_POSTAL_CODE",
            "JOB_TITLE","SOC_NAME","TOTAL_WORKERS",
            "FULL_TIME_POSITION",
            "PREVAILING_WAGE","PW_UNIT_OF_PAY","PW_WAGE_LEVEL",
            "WAGE_RATE_OF_PAY_FROM","WAGE_RATE_OF_PAY_TO","WAGE_UNIT_OF_PAY",
            "H-1B_DEPENDENT","WILLFUL_VIOLATOR",
            "WORKSITE_CITY","WORKSITE_COUNTY","WORKSITE_STATE",
            "WORKSITE_POSTAL_CODE")
cols19all <- c("X","CASE_NUMBER","CASE_STATUS","CASE_SUBMITTED","DECISION_DATE","VISA_CLASS",
            "EMPLOYMENT_START_DATE","EMPLOYMENT_END_DATE","EMPLOYER_NAME","EMPLOYER_BUSINESS_DBA",
            "EMPLOYER_ADDRESS","EMPLOYER_CITY","EMPLOYER_STATE","EMPLOYER_POSTAL_CODE",
            "EMPLOYER_COUNTRY","EMPLOYER_PROVINCE","EMPLOYER_PHONE","EMPLOYER_PHONE_EXT",
            "SECONDARY_ENTITY","SECONDARY_ENTITY_BUSINESS_NAME",
            "AGENT_REPRESENTING_EMPLOYER","AGENT_ATTORNEY_NAME","AGENT_ATTORNEY_CITY",
            "AGENT_ATTORNEY_STATE","JOB_TITLE","SOC_CODE","SOC_NAME","NAICS_CODE","TOTAL_WORKERS",
            "NEW_EMPLOYMENT","CONTINUED_EMPLOYMENT","CHANGE_PREVIOUS_EMPLOYMENT",
            "NEW_CONCURRENT_EMPLOYMENT","CHANGE_EMPLOYER","AMENDED_PETITION","FULL_TIME_POSITION",
            "PREVAILING_WAGE","PW_UNIT_OF_PAY","PW_WAGE_LEVEL","PW_SOURCE","PW_SOURCE_YEAR",
            "PW_SOURCE_OTHER","WAGE_RATE_OF_PAY_FROM","WAGE_RATE_OF_PAY_TO","WAGE_UNIT_OF_PAY",
            "H-1B_DEPENDENT","WILLFUL_VIOLATOR","SUPPORT_H1B","STATUTORY_BASIS","APPENDIX_ATTACHMENT",
            "LABOR_CON_AGREE","PUBLIC_DISCLOSURE_LOCATION","WORKSITE_CITY","WORKSITE_COUNTY",
            "WORKSITE_STATE","WORKSITE_POSTAL_CODE","ORIGINAL_CERT_DATE")
cols19 <- c("CASE_STATUS","VISA_CLASS",
            "EMPLOYMENT_START_DATE","EMPLOYMENT_END_DATE","EMPLOYER_NAME",
            "EMPLOYER_CITY","EMPLOYER_STATE","EMPLOYER_POSTAL_CODE",
            "SECONDARY_ENTITY","SECONDARY_ENTITY_BUSINESS_NAME",
            "JOB_TITLE","SOC_NAME","TOTAL_WORKERS",
            "FULL_TIME_POSITION",
            "PREVAILING_WAGE","PW_UNIT_OF_PAY","PW_WAGE_LEVEL",
            "WAGE_RATE_OF_PAY_FROM","WAGE_RATE_OF_PAY_TO","WAGE_UNIT_OF_PAY",
            "H-1B_DEPENDENT","WILLFUL_VIOLATOR",
            "WORKSITE_CITY","WORKSITE_COUNTY",
            "WORKSITE_STATE","WORKSITE_POSTAL_CODE")

shinyServer(
    function(input, output) {
        #output$myImage <- renderImage({
        #    input$tabs
        #    list(src = "plot1.png",
        #         contentType = 'image/png',
        #         width = 840,
        #         height = 840,
        #         alt = "plot")
        #}, deleteFile = FALSE)
        output$myText <- renderPrint({
            library(plyr)
            # Initialize any local variables
            year <- input$year
            yr <- year %% 100
            csvfile  <- paste0("H-1B_FY",year,".csv")
            xlsfile  <- paste0("H-1B_FY",year,".xlsx")
            #xlsfile  <- paste0("H-1B_Disclosure_Data_FY",yr,".xlsx")
            xsearch <- c("CASE_STATUS","EMPLOYER_NAME","EMPLOYER_NAME2","WORKSITE_CITY","WORKSITE_STATE")
            
            # Read csv file if necessary
            reload <- TRUE
            if (exists("oo") & exists("ooyear")){
                if (ooyear == year) reload <- FALSE
            }
            if (reload){
                if (!file.exists(csvfile)){
                    msg = paste("Loading XLS data for FY", year)
                    withProgress(message = msg, detail = "this can take a minute or so...", value = 0, {
                        for (i in 1:9){
                            incProgress(1/10)
                            Sys.sleep(0.5)
                        }
                        if (year < 2019){
                            oo <<- read_xlsx(xlsfile)
                            cat(names(oo), sep = "\n", file = paste0("xnames",year,".txt"))
                            cols <- cols18
                        }
                        else{
                            ctypes <- rep("guess", 56)
                            ctypes[18:19] <- "text"
                            oo <<- read_xlsx(xlsfile, col_types = ctypes)
                            cat(names(oo), sep = "\n", file = paste0("xnames",year,".txt"))
                            cols <- cols19 # adds SECONDARY_ENTITY and SECONDARY_ENTITY_BUSINESS_NAME
                        }
                        if (year >= 2017){ # FIX FOR NEW 2018 XLSX
                            cols[cols == "H-1B_DEPENDENT"] <- "H1B_DEPENDENT"
                        }
                        else if (year == 2016){
                            cols[cols == "NAICS_CODE"] <- "NAIC_CODE"
                            cols[cols == "PW_WAGE_LEVEL"] <- "PW_WAGE_SOURCE" # to avoid error
                        }
                        else if (year == 2015){
                            cols[cols == "TOTAL_WORKERS"] <- "TOTAL WORKERS"
                            cols[cols == "WAGE_RATE_OF_PAY_FROM"] <- "WAGE_RATE_OF_PAY"
                            cols[cols == "WAGE_RATE_OF_PAY_TO"] <- "PW_WAGE_SOURCE_OTHER" # to avoid error
                            cols[cols == "WILLFUL_VIOLATOR"] <- "WILLFUL VIOLATOR"
                        }
                        oo <<- oo[,cols]
                        ooyear <<- year
                        if (year >= 2019){ # FIX FOR NEW 2019 XLSX FIELDS
                            names(oo)[names(oo) == "SECONDARY_ENTITY"] <- "EMPLOYER2"
                            names(oo)[names(oo) == "SECONDARY_ENTITY_BUSINESS_NAME"] <- "EMPLOYER_NAME2"
                        }
                        if (year >= 2017){ # FIX FOR NEW 2018 XLSX
                            names(oo)[names(oo) == "H1B_DEPENDENT"] <- "H-1B_DEPENDENT"
                        }
                        else if (year == 2016){
                            names(oo)[names(oo) == "NAIC_CODE"] <- "NAICS_CODE"
                            names(oo)[names(oo) == "PW_WAGE_SOURCE"] <- "PW_WAGE_LEVEL"
                            oo$PW_WAGE_LEVEL <- NA
                        }
                        else if (year == 2015){
                            names(oo)[names(oo) == "TOTAL WORKERS"] <- "TOTAL_WORKERS"
                            names(oo)[names(oo) == "WAGE_RATE_OF_PAY"] <- "WAGE_RATE_OF_PAY_FROM"
                            names(oo)[names(oo) == "PW_SOURCE_OTHER"] <- "WAGE_RATE_OF_PAY_TO"
                            pat <- regex("(\\d+)[ -]*(\\d*)")
                            match <- str_match(oo$WAGE_RATE_OF_PAY_FROM, pat)
                            oo$WAGE_RATE_OF_PAY_FROM <- match[,2]
                            oo$WAGE_RATE_OF_PAY_TO   <- match[,3]
                            oo$WAGE_RATE_OF_PAY_FROM[is.na(oo$WAGE_RATE_OF_PAY_FROM)] <- ""
                            oo$WAGE_RATE_OF_PAY_TO[is.na(oo$WAGE_RATE_OF_PAY_TO)] <- ""
                            oo$WAGE_RATE_OF_PAY_TO[oo$WAGE_RATE_OF_PAY_TO == ""] <- oo$WAGE_RATE_OF_PAY_FROM[oo$WAGE_RATE_OF_PAY_TO == ""]
                            names(oo)[names(oo) == "WILLFUL VIOLATOR"] <- "WILLFUL_VIOLATOR"
                        }
                        write.csv(oo, csvfile)
                        incProgress(1/10)
                    })
                }
                else{
                    #print(paste("READ", csvfile))
                    msg = paste("Loading CSV data for FY", year)
                    withProgress(message = msg, detail = "this can take a minute or so...", value = 0, {
                        for (i in 1:9){
                            incProgress(1/10)
                            Sys.sleep(0.5)
                        }
                        if (in_shinyapps){
                            oo <<- read.csv(csvfile, fileEncoding="latin1")
                            ooyear <<- year
                        }
                        else {
                            oo <<- read.csv(csvfile)
                            ooyear <<- year
                        }
                        if (year < 2019){
                            oo$EMPLOYER2 <- "N"
                            oo$EMPLOYER_NAME2 <- ""
                        }
                        else{
                            oo$WORKSITE_NAME <- as.character(oo$EMPLOYER_NAME2)
                            oo$WORKSITE_NAME[is.na(oo$EMPLOYER2) | as.character(oo$EMPLOYER2) == "N"] <- as.character(
                                oo$EMPLOYER_NAME[is.na(oo$EMPLOYER2) | as.character(oo$EMPLOYER2) == "N"])
                            oo$EMPLOYER_NAME2 <- oo$WORKSITE_NAME
                        }
                        oo$TOTAL_WORKERS[is.na(oo$TOTAL_WORKERS)] <- 1
                        oo <<- oo
                        incProgress(1/10)
                    })
                    cat(names(oo), sep = "\n", file = paste0("cnames",year,".txt"))
                }
            }
            xx <- data.frame(oo)
            # Make value changes before searches
            levels(xx$CASE_STATUS)[levels(xx$CASE_STATUS)=="CERTIFIED-WITHDRAWN"] <- "CERT-WITHDR"
            xx$LOW_WAGE <- as.numeric(gsub("\\$", "", gsub(",", "", xx$WAGE_RATE_OF_PAY_FROM)))
            xx$WAGE_PW <- xx$LOW_WAGE / as.numeric(gsub("\\$", "", gsub(",", "", xx$PREVAILING_WAGE))) # remove commas
            xx$WAGE_PW[xx$PW_UNIT_OF_PAY != xx$WAGE_UNIT_OF_PAY] <- NA
            #xx$WAGE_PW <- format(round(xx$WAGE_PW, 4), nsmall = 4)
            xx$WAGE_PW <- round(xx$WAGE_PW, 4)

            if (input$up_ws_city) xx$WORKSITE_CITY <- toupper(xx$WORKSITE_CITY)
            if (input$empclean %in% c("Clean Both","Clean EMPLOYER_NAME")){
                for (i in input$ignore){
                    if (i == "case")   xx$EMPLOYER_NAME <- toupper(xx$EMPLOYER_NAME)
                    if (i == "comma")  xx$EMPLOYER_NAME <- gsub("[,]$", "", xx$EMPLOYER_NAME)
                    if (i == "comma")  xx$EMPLOYER_NAME <- gsub("[,]", " ", xx$EMPLOYER_NAME)
                    #if (i == "period") xx$EMPLOYER_NAME <- gsub("[.]", " ", xx$EMPLOYER_NAME)
                    if (i == "period") xx$EMPLOYER_NAME <- gsub("[.]$", "", xx$EMPLOYER_NAME)
                    if (i == "period") xx$EMPLOYER_NAME <- gsub("[.][ ]", " ", xx$EMPLOYER_NAME)
                    if (i == "the")    xx$EMPLOYER_NAME <- gsub("^THE ", "", xx$EMPLOYER_NAME)
                    if (i == "blanks") xx$EMPLOYER_NAME <- trimws(gsub("[ ]+", " ", xx$EMPLOYER_NAME))
                }
                for (i in input$trailer){
                    xx$EMPLOYER_NAME <- gsub(paste0(" ",i,"$"), "", xx$EMPLOYER_NAME)
                }
            }
            if (input$empclean %in% c("Clean Both","Clean EMPLOYER_NAME2")){
                for (i in input$ignore){
                    if (i == "case")   xx$EMPLOYER_NAME2 <- toupper(xx$EMPLOYER_NAME2)
                    if (i == "comma")  xx$EMPLOYER_NAME2 <- gsub("[,]$", "", xx$EMPLOYER_NAME2)
                    if (i == "comma")  xx$EMPLOYER_NAME2 <- gsub("[,]", " ", xx$EMPLOYER_NAME2)
                    #if (i == "period") xx$EMPLOYER_NAME2 <- gsub("[.]", " ", xx$EMPLOYER_NAME2)
                    if (i == "period") xx$EMPLOYER_NAME2 <- gsub("[.]$", "", xx$EMPLOYER_NAME2)
                    if (i == "period") xx$EMPLOYER_NAME2 <- gsub("[.][ ]", " ", xx$EMPLOYER_NAME2)
                    if (i == "the")    xx$EMPLOYER_NAME2 <- gsub("^THE ", "", xx$EMPLOYER_NAME2)
                    if (i == "blanks") xx$EMPLOYER_NAME2 <- trimws(gsub("[ ]+", " ", xx$EMPLOYER_NAME2))
                }
                for (i in input$trailer){
                    xx$EMPLOYER_NAME2 <- gsub(paste0(" ",i,"$"), "", xx$EMPLOYER_NAME2)
                }
            }
            
            # Do searches
            sfilter <- ""
            if (input$sitetype == "Remote Sites Only"){
                xx <- xx[!is.na(xx$EMPLOYER2) & xx$EMPLOYER2 == "Y",]
            }
            else if (input$sitetype == "Local Sites Only"){
                xx <- xx[is.na(xx$EMPLOYER2) | xx$EMPLOYER2 != "Y",]
            }
            for (i in 1:length(xsearch)){
                #pattern <- trimws(input[[xsearch[i]]]) # trim whitespace
                pattern <- input[[xsearch[i]]]
                if (nchar(pattern) > 0){
                    xx <- xx[grep(pattern, xx[[xsearch[i]]], ignore.case = TRUE),]  
                    print(paste0("Search ", xsearch[i], " for ", pattern))
                    sfilter <- paste0(sfilter,", ", xsearch[i], "=", pattern)
                }
            }
            if (nchar(input$ysearch1) > 0){
                xx <- xx[grep(input$ysearch1, xx[[input$xsearch1]], ignore.case = TRUE),]  
                print(paste0("Search ", input$xsearch1, " for ", input$ysearch1))
                sfilter <- paste0(sfilter,", ", input$xsearch1, "=", input$ysearch1)
            }
            if (nchar(input$ysearch2) > 0){
                xx <- xx[grep(input$ysearch2, xx[[input$xsearch2]], ignore.case = TRUE),]  
                print(paste0("Search ", input$xsearch2, " for ", input$ysearch2))
                sfilter <- paste0(sfilter,", ", input$xsearch2, "=", input$ysearch2)
            }
            sfilter <- sub("^, ","",sfilter)
            if (input$sitetype != "All Sites"){
                print(paste0("Search ", input$sitetype))
            }
            
            ngroup <- length(input$xgroup)
            if (ngroup > 0){
                dd <- data.table(xx)
                groups <- paste(input$xgroup, collapse=',')
                print(paste0("Group by ", groups))
                #print(paste0("groups=|",groups,"|"))
                #gg <- dd[,list(TOTAL_WORKERS = sum(TOTAL_WORKERS)), by = groups]
                gg <- dd[, .(TOTAL_WORKERS = sum(TOTAL_WORKERS), APPLICATIONS = length(TOTAL_WORKERS)), by = groups]
                gg <- gg[order(-TOTAL_WORKERS)]
                xx <- data.frame(gg)
                #options(width = input$totwidth)
                #print(head(hh, n=input$totrows))
            }
            else{
                # Sort by specified sort fields
                if (input$xsortdir == "Ascending") xx <- xx[order(xx[[input$xsort]]),]
                else{
                    if (class(xx[[input$xsort]])=="factor") xx <- xx[rev(order(xx[[input$xsort]])),]
                    else xx <- xx[order(-xx[[input$xsort]]),]
                }
                #cat(file=stderr(), "Locale =", Sys.getlocale(), "\n")
                Sys.setlocale(category = "LC_ALL", locale = "C")
                print(paste0("Sort by ", input$xsort, ", ", input$xsortdir))
                #cat(file=stderr(), "Sort by ", input$xsort, ", ", input$xsortdir, "\n")
            }
            print("")
            #print("H-1B Disclosure Data FY16 Q3")
            print(paste("H-1B DISCLOSURE DATA, FY", year))
            if (nchar(sfilter) > 0){
                print(paste0("(", sfilter,")"))
                #cat(file=stderr(), "Search (", sfilter,")\n")
            }
            print("")
            
            # Output sums and totals
            #print(paste("SUM(TOTAL_WORKERS) =", format(sum(xx$TOTAL_WORKERS), big.mark=",",scientific=FALSE)))
            print(paste("SUM(TOTAL_WORKERS) =", format(sum(xx$TOTAL_WORKERS[!is.na(xx$TOTAL_WORKERS)]), big.mark=",",scientific=FALSE)))
            print(paste("NUMBER OF ROWS     =", format(length(xx$TOTAL_WORKERS), big.mark=",",scientific=FALSE)))
            print(paste("MEDIAN(LOW_WAGE)   =", format(median(xx$LOW_WAGE[!is.na(xx$LOW_WAGE) & xx$WAGE_UNIT_OF_PAY == "Year"]), big.mark=",",scientific=FALSE)))
            print(paste("MEAN(LOW_WAGE)     =", format(round(mean(xx$LOW_WAGE[!is.na(xx$LOW_WAGE) & xx$WAGE_UNIT_OF_PAY == "Year"]), digits=0), big.mark=",",scientific=FALSE)))
            print("")

            # Limit to Maximum Total Rows if necessary
            itotrows <- as.integer(input$totrows)
            if (nrow(xx) > itotrows) xx <- head(xx, n = itotrows)
            
            # Number all rows and set total width to Maximum Total Width
            if (nrow(xx) > 0) row.names(xx) <- 1:nrow(xx)
            options(width = input$totwidth)
            
            if (ngroup == 0){
                # Display only the specified fields
                #xx <- subset(xx, select = input$xshow)
                xx <- subset(xx, select = append(input$xshow, input$xshow2))
                #for (i in 1:length(input$xshow)){
                #  xx[[input$xshow[i]]] <- strtrim(xx[[input$xshow[i]]], width=input$colwidth)
                #}
            }
            if ("EMPLOYER_NAME" %in% colnames(xx)){
                xx$EMPLOYER_NAME <- strtrim(xx$EMPLOYER_NAME, width=input$colwidth)
            }
            if ("EMPLOYER_NAME2" %in% colnames(xx)){
                xx$EMPLOYER_NAME2 <- strtrim(xx$EMPLOYER_NAME2, width=input$colwidth)
            }
            if ("JOB_TITLE" %in% colnames(xx)){
                xx$JOB_TITLE     <- strtrim(xx$JOB_TITLE, width=input$colwidth)
            }
            if ("SOC_NAME" %in% colnames(xx)){
                xx$SOC_NAME      <- strtrim(xx$SOC_NAME, width=input$colwidth)
            }
            #xx$WORKSITE_CITY <- strtrim(xx$WORKSITE_CITY, width=input$colwidth)
            colnames(xx)[colnames(xx)=="EMPLOYMENT_START_DATE"] <- "EMP_START_DATE"
            colnames(xx)[colnames(xx)=="TOTAL_WORKERS"] <- "WORKERS"
            colnames(xx)[colnames(xx)=="WORKSITE_STATE"] <- "STATE"
            colnames(xx)[colnames(xx)=="WAGE_RATE_OF_PAY_FROM"] <- "WAGE_RATE_FROM"
            colnames(xx)[colnames(xx)=="WAGE_RATE_OF_PAY_TO"]   <- "WAGE_RATE_TO"
            print(xx)
            cat(file=stderr(), paste0(
                "##### ",input$year,"|",input$CASE_STATUS,"|",input$EMPLOYER_NAME,"|",
                input$WORKSITE_CITY,"|",input$WORKSITE_STATE,"|",input$xsearch1,"|",
                input$ysearch1,"|",input$xsearch2,"|",input$ysearch2,"|",
                paste(input$xgroup,collapse = ';'),"|",input$xsort,"|",input$xsortdir,"|",
                paste(input$xshow,collapse = ';'),"|",paste(input$xshow2,collapse = ';'),"|",
                input$colwidth,"|",input$totwidth,"|",input$totrows,"|\n"))
        })
    }
)
