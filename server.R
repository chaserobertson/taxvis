library(ggplot2)
library(plotly)
library(scales)
library(dplyr)

default_incomes <- c(10275, 41775, 89075, 170050, 215950, 539900, Inf-1)
default_rates <- c(0.1, 0.12, 0.22, 0.24, 0.32, 0.35, 0.37)

function(input, output) {
    output$taxPlot <- renderPlotly({
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

        min_income <- input$income_range[1]
        max_income <- input$income_range[2]
        highlight_income <- input$highlight_income

        effective_tax <- function(z) {
            round(sum(diff(c(0, pmin(z, incomes))) * rates))
        }

        x <- seq(min_income, max_income, by = 500)
        df <- data.frame(TaxableIncome = x)
        df$TaxAmount <- sapply(df$TaxableIncome, effective_tax)
        df$EffectiveRate <- df$TaxAmount / df$TaxableIncome

        relevant_brackets <- incomes[between(incomes, min_income, max_income)]

        plt_aes <- aes(TaxableIncome, TaxAmount,
                       text = paste("EffectiveRate:", round(EffectiveRate, 2), sep = "\t"))
        plt <- ggplot(df, plt_aes) +
            ggtitle("Effective Tax Across Incomes") +
            scale_x_continuous(labels = dollar) +
            scale_y_continuous(labels = dollar) +
            geom_line(linewidth = 1.5) +
            geom_vline(xintercept = relevant_brackets, linetype = "dashed") +
            theme_minimal()
        if (is.numeric(highlight_income)) {
          plt <- plt + annotate("point",
                                x = highlight_income,
                                y = effective_tax(highlight_income),
                                colour = "red", size = 4)
        }
        ggplotly(plt)
    })

    output$bracket_incomes <- renderUI({
        n_brackets <- as.integer(input$n_brackets)
        lapply(1:n_brackets, function(i) {
            textInput(paste("bracket_income", i, sep = "_"),
                paste("Bracket", i, "income limit"),
                value = ifelse(i <= length(default_incomes),
                                default_incomes[i],
                                Inf)
            )
        })
    })

    output$bracket_rates <- renderUI({
        n_brackets <- as.integer(input$n_brackets)
        lapply(1:n_brackets, function(i) {
            textInput(paste("bracket_rate", i, sep = "_"),
                paste("Bracket", i, "tax rate"),
                value = ifelse(i <= length(default_rates),
                    default_rates[i],
                    tail(default_rates, 1)
                )
            )
        })
    })
}
