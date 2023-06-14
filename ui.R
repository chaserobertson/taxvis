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
                p("Current USA income tax brackets are used by default.
                  USA median income is highlighted in red.
                  USA 95th percentile income is the default graph range.
                  Feel free to edit any fields to match your situation."),
                p(HTML("<b>The graph is interactive!</b> 
                  Hover over the line to see more,
                  including the effective, 
                  or <b>true</b> tax rate of incomes."))
            )
        )
    ),

    fluidRow(
        column(2,
            wellPanel(
                numericInput(
                    "n_brackets", "Number of tax brackets",
                    min = 1, value = 7
                )
            )
        ),
        column(2,
            wellPanel(
                numericInput(
                    "highlight_income", "Income to highlight in red",
                    value = 63179
                )
            )
        ),
        column(8,
            wellPanel(
                sliderInput(
                    "income_range", "Visible income range",
                    min = 0, max = 1e6, value = c(0, 248728)
                )
            )
        )
    ),

    fluidRow(
        column(2,
            wellPanel(
                uiOutput("bracket_incomes")
            )
        ),
        column(2,
            wellPanel(
                uiOutput("bracket_rates")
            )
        ),
        column(8,
            plotlyOutput(outputId = "taxPlot")
        )
    )
)
