shinyUI(pageWithSidebar(
    headerPanel("H-1B Disclosure Data"),
    sidebarPanel(
        width = 2,
        numericInput("year", "Year", min = 2012, max = 2019, value = 2019),
        # List fields that can be searched
        textInput("CASE_STATUS",    "Search CASE_STATUS",    value = "CERTIFIED") ,
        textInput("EMPLOYER_NAME",  "Search EMPLOYER_NAME",  value = "") ,
        textInput("EMPLOYER_NAME2", "Search EMPLOYER_NAME2", value = "") ,
        #checkboxInput("remoteonly", "Remote Sites Only", value = FALSE),
        selectInput("sitetype", NULL,
                    choices = c("All Sites", "Local Sites Only", "Remote Sites Only"),
                    selected = "All Sites"),
        textInput("WORKSITE_CITY",  "Search WORKSITE_CITY",  value = "") ,
        textInput("WORKSITE_STATE", "Search WORKSITE_STATE", value = "") ,
        selectInput("xsearch1", NULL, choices =
            c("EMPLOYMENT_START_DATE","JOB_TITLE","SOC_NAME","TOTAL_WORKERS","PREVAILING_WAGE",
              "PW_UNIT_OF_PAY","WAGE_RATE_OF_PAY_FROM","WAGE_RATE_OF_PAY_TO","WAGE_UNIT_OF_PAY","LOW_WAGE","WAGE_PW",
              "H.1B_DEPENDENT","WILLFUL_VIOLATOR","CASE_NUMBER","CASE_SUBMITTED","DECISION_DATE","VISA_CLASS","EMPLOYMENT_END_DATE",
              "EMPLOYER_CITY","EMPLOYER_STATE","EMPLOYER_POSTAL_CODE","EMPLOYER2",
              "FULL_TIME_POSITION","WORKSITE_COUNTY","WORKSITE_POSTAL_CODE"),
            selected = "H.1B_DEPENDENT"),
        textInput("ysearch1", NULL, value = ""),
        selectInput("xsearch2", NULL, choices =
            c("EMPLOYMENT_START_DATE","JOB_TITLE","SOC_NAME","TOTAL_WORKERS","PREVAILING_WAGE",
              "PW_UNIT_OF_PAY","WAGE_RATE_OF_PAY_FROM","WAGE_RATE_OF_PAY_TO","WAGE_UNIT_OF_PAY","LOW_WAGE","WAGE_PW",
              "H.1B_DEPENDENT","WILLFUL_VIOLATOR","CASE_NUMBER","CASE_SUBMITTED","DECISION_DATE","VISA_CLASS","EMPLOYMENT_END_DATE",
              "EMPLOYER_CITY","EMPLOYER_STATE","EMPLOYER_POSTAL_CODE","EMPLOYER2",
              "FULL_TIME_POSITION","WORKSITE_COUNTY","WORKSITE_POSTAL_CODE"),
            selected = "WILLFUL_VIOLATOR"), 
        textInput("ysearch2", NULL, value = ""),
        # List fields to be sorted by
        selectInput("xgroup", "Group by",
            choices = c("CASE_STATUS","VISA_CLASS",
                        "EMPLOYMENT_START_DATE","EMPLOYMENT_END_DATE","EMPLOYER_NAME","EMPLOYER_NAME2","EMPLOYER2",
                        "EMPLOYER_CITY","EMPLOYER_STATE","EMPLOYER_POSTAL_CODE",
                        "JOB_TITLE","SOC_NAME",
                        "FULL_TIME_POSITION",
                        "PREVAILING_WAGE","PW_UNIT_OF_PAY","PW_WAGE_LEVEL",
                        "WAGE_RATE_OF_PAY_FROM","WAGE_RATE_OF_PAY_TO","WAGE_UNIT_OF_PAY",
                        "H-1B_DEPENDENT","WILLFUL_VIOLATOR",
                        "WORKSITE_CITY","WORKSITE_COUNTY","WORKSITE_STATE",
                        "WORKSITE_POSTAL_CODE"),
            selected = "", multiple = TRUE),
        selectInput("xsort", "Sort by",
            choice   = c("EMPLOYMENT_START_DATE","TOTAL_WORKERS","PREVAILING_WAGE","WAGE_RATE_OF_PAY_FROM","LOW_WAGE","WAGE_PW"),
            selected = "TOTAL_WORKERS"), 
        radioButtons("xsortdir", NULL, c("Ascending","Descending"), "Descending", inline = TRUE),
        # List choice and selected checkboxes for selecting which fields to display
        checkboxGroupInput("xshow", "Show",
            choices  = c("CASE_STATUS","EMPLOYMENT_START_DATE","EMPLOYER_NAME","EMPLOYER_NAME2","JOB_TITLE","SOC_NAME","TOTAL_WORKERS","PREVAILING_WAGE","PW_UNIT_OF_PAY","PW_WAGE_LEVEL","WAGE_RATE_OF_PAY_FROM","WAGE_RATE_OF_PAY_TO","WAGE_UNIT_OF_PAY","LOW_WAGE","WAGE_PW","H.1B_DEPENDENT","WILLFUL_VIOLATOR","WORKSITE_CITY","WORKSITE_STATE"),
            selected = c("CASE_STATUS",                        "EMPLOYER_NAME",                 "JOB_TITLE",           "TOTAL_WORKERS",                                   "PW_WAGE_LEVEL","WAGE_RATE_OF_PAY_FROM",                                                    "WAGE_PW",                                    "WORKSITE_CITY","WORKSITE_STATE"),
            inline = TRUE),
        selectInput("xshow2", "Show (other)", choices =
            c("VISA_CLASS","EMPLOYMENT_END_DATE",
              "EMPLOYER_CITY","EMPLOYER_STATE","EMPLOYER_POSTAL_CODE",
              "FULL_TIME_POSITION","WORKSITE_COUNTY","WORKSITE_POSTAL_CODE"),
            selected = "", multiple = TRUE),
        # List options for maximum column width, total width, and total rows
        numericInput("colwidth", "Maximum Column Width", value = "40") ,
        numericInput("totwidth", "Maximum Total Width",  value = "240") ,
        numericInput("totrows",  "Maximum Total Rows",   value = "900"),
        # Rules to combine employer names
        checkboxInput("up_ws_city", "Ignore case in Worksite City", value = TRUE),
        selectInput("empclean", NULL,
                    choices = c("Clean None","Clean EMPLOYER_NAME","Clean EMPLOYER_NAME2","Clean Both"),
                    selected = "Clean Both"),
        checkboxGroupInput("ignore","Ignore in Employer",
                           choices  = c("case","comma","period","blanks","the"),
                           selected = c("case","comma","period","blanks","the"), inline = "TRUE"),
        # Select all but BANK and GROUP by default
        selectInput("trailer", "Delete Trailer in Employer",
                    choices = c("INC","INCORPORATED","LLC","LLP","LTD","LIMITED","N A","NA","GROUP",
                                "& CO","& COMPANY", "CORPORATE SERVICES","FINANCIAL SERVICES","BANK",
                                "CO","COMPANY","CORP","CORPORATION",
                                "FINANCIAL SERVICES GROUP","TRAVEL RELATED SERVICES",
                                "SERVICES","TECHNOLOGY"),
                    selected = c("INC","INCORPORATED","LLC","LLP","LTD","LIMITED","N A","NA",
                                "& CO","& COMPANY", "CORPORATE SERVICES","FINANCIAL SERVICES",
                                "CO","COMPANY","CORP","CORPORATION",
                                "FINANCIAL SERVICES GROUP","TRAVEL RELATED SERVICES",
                                "SERVICES","TECHNOLOGY"),
                    multiple = TRUE) ),
        mainPanel(
        div(
            tabsetPanel(id = "tabs",
                tabPanel("Output",
                    width = 10,
                    verbatimTextOutput("myText")
                )
                #tabPanel("Plot",
                #         width = 10,
                #         imageOutput("myImage")
                #),
                #tabPanel("Usage",
                #    width = 10,
                #    includeMarkdown("lca_usage.Rmd")
                #)
            )
        ),
        width = 10)
    )
)