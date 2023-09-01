library(plotly)

fluidPage(
    titlePanel("Progressive Tax Visualiser"),
    
    fluidRow(
        column(12,
            wellPanel(
                p(HTML("<a target='_blank' href='https://www.investopedia.com/terms/p/progressivetax.asp#toc-progressive-tax-vs-flat-tax'>
                Progressive income tax</a> is calculated by 
                  applying different tax rates to different 
                  income brackets. Each income bracket has a 
                  corresponding tax rate, and as an individual's
                  income increases and moves into a higher 
                  bracket, the tax rate on that <b>portion</b> of 
                  income increases accordingly. The total tax 
                  owed is calculated by summing up the taxes 
                  due from each income bracket."
                )),
                p("Historical USA income tax brackets are shown by default.
                  Choose a year and filing type of interest, or switch to
                  custom mode and edit the fields to match your situation."),
                p(HTML("<b>The graph is interactive!</b> 
                  Hover over the line to see more,
                  including the effective, 
                  or <b>true</b> tax rate of incomes."))
            )
        )
    ),
    
    sidebarLayout(
        sidebarPanel(
            width = 3,
            radioButtons(
                "spec", "Specification Mode",
                c("USA Brackets", "Custom"), "USA Brackets"
            ),
            conditionalPanel(
                condition = "input.spec == 'Custom'",
                numericInput(
                    "n_brackets", "Number of tax brackets",
                    min = 1, value = 7
                ),
                uiOutput('custom_brackets')
            ),
            conditionalPanel(
                condition = "input.spec != 'Custom'",
                selectInput("years", "Tax Year", choices="2021", selected="2021"),
                selectInput("file_type", "Filing As", choices="Head of Household")
            )
        ),
        
        mainPanel(
            width = 9,
            wellPanel(
                fluidRow(
                    column(3, numericInput(
                        "highlight_income", "Specific Income to Highlight",
                        value = "50000"
                    )),
                    column(9, sliderInput(
                        "income_range", "Visible Income Range",
                        min = 0, max = 1e6, value = c(0, 250000), step = 500
                    ))
                ),
                plotlyOutput(outputId = "taxPlot")
            )
        )
    )
)
