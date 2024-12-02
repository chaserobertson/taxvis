library(ggplot2)
library(plotly)
library(scales)
library(dplyr)

us.fed.rates <- read.csv("data/US-Fed-Rates.csv")

default_incomes <- c(0, 10275, 41775, 89075, 170050, 215950, 539900)
default_rates <- c(0.1, 0.12, 0.22, 0.24, 0.32, 0.35, 0.37)

get_brackets <- function(input) {
    if (input$spec == "Custom") {
        incomes <- vapply(
            grep(pattern = "bracket_income_", x = names(input), value = TRUE),
            function(x) as.numeric(input[[x]]), numeric(1)
        )
        incomes[is.na(incomes)] <- Inf
        incomes <- incomes[order(names(incomes))]
        
        rates <- vapply(
            grep(pattern = "bracket_rate_", x = names(input), value = TRUE),
            function(x) as.numeric(input[[x]]), numeric(1)
        )
        rates[is.na(rates)] <- Inf
        rates <- rates[order(names(rates))]
    }
    else {
        relevant.df <- subset(us.fed.rates, 
            Year %in% input$years & Type == input$file_type
        )
        incomes <- relevant.df$Bracket
        rates <- relevant.df$Rate
    }
    data.frame(incomes, rates)
}

effect_tax <- function(x, brackets, rates) {
    bkts <- c(brackets, Inf)
    tax <- rep(0, length(x))
    for (i in 2:length(bkts)) {
        in_bkt <- x > bkts[i-1]
        amt <- (pmin(x, bkts[i]) - bkts[i-1])
        additional <- in_bkt * amt
        tax <- tax + additional * rates[i-1]
    }
    tax
}

function(input, output) {
    updateSelectInput(
        inputId = 'years', 
        choices = rev(sort(unique(us.fed.rates$Year))),
        selected = max(us.fed.rates$Year)
    )
    updateSelectInput(
        inputId = 'file_type', 
        choices = sort(unique(us.fed.rates$Type)),
        selected = min(us.fed.rates$Type)
    )
    
    output$taxPlot <- renderPlotly({
        min_income <- input$income_range[1]
        max_income <- input$income_range[2]
        highlight_income <- input$highlight_income

        brackets <- get_brackets(input)
        incomes <- brackets$incomes
        rates <- brackets$rates
        
        x <- seq(min_income, max_income, by = 500)
        amt <- effect_tax(x, incomes, rates)
        
        df <- data.frame(
            TaxableIncome = x,
            TaxAmount = round(amt),
            EffectiveRate = round(amt / x, 2)
        )

        relevant_brackets <- incomes[between(incomes, min_income, max_income)]

        plt_aes <- aes(
            x = TaxableIncome, 
            y = TaxAmount, 
            text = paste("EffectiveRate:", EffectiveRate),
        )
        plt <- ggplot(df, plt_aes) +
            ggtitle("Effective Tax Across Incomes") +
            scale_x_continuous(labels = dollar) +
            scale_y_continuous(labels = dollar) +
            geom_line(linewidth = 1.5) +
            geom_vline(xintercept = relevant_brackets, linetype = "dashed") +
            theme_minimal()
        if (is.numeric(highlight_income)) {
            highlight_y <- effect_tax(highlight_income, incomes, rates)
            plt <- plt + 
                annotate("point", 
                         x = highlight_income,
                         y = highlight_y, 
                         colour = "red", 
                         size = 4)
        }
        ggplotly(plt)
    })
    
    output$custom_brackets <- renderUI({
        n_brackets <- as.integer(input$n_brackets)
        lapply(1:n_brackets, function(i) {
            fluidRow(
                p(align="center", HTML(paste0("<b>Bracket ", i, "</b>"))),
                column(6, textInput(
                    paste0("bracket_rate_", i),
                    "Tax Rate Applied",
                    value = ifelse(
                        i <= length(default_rates),
                        default_rates[i],
                        tail(default_rates, 1)
                    )
                )),
                column(6, textInput(
                    paste0("bracket_income_", i),
                    "To Income Over",
                    value = ifelse(
                        i <= length(default_incomes),
                        default_incomes[i],
                        tail(default_incomes, 1)
                    )
                ))
            )
        })
    })
}
