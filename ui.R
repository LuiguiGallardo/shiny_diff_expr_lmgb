# Purpose: Differential expression analysis Shiny app
# Date created: 10.08.2022
# Author: Luigui Gallardo-Becerra (bfllg77@gmail.com)

library(shiny)
library(shinythemes)
library(markdown)

# Define UI for the DE analysis
fluidPage(
  theme = shinytheme("flatly"),
  navbarPage(
    "Differential expression analysis with DESeq2",
    # Instructions
    tabPanel("Instructions",
      mainPanel(
               includeMarkdown("instructions.md"))
        ),
    # Panel 1
    tabPanel("Input table",
             sidebarLayout(
               sidebarPanel(
                 
                 fileInput("input_file",
                           "Input file"),
                 
                 fileInput("metadata_file",
                               "Metadata file")
                 
               ), # Sidebar panel 1
               mainPanel(
                 tableOutput("contents"),
               )
             )
    ), # Main panel 1
    
    # Panel 2
    tabPanel("Results table",
             sidebarLayout(
               sidebarPanel(
                 selectInput("reference_group",
                             'Reference group (control)',
                             choices=NULL,
                             selected=NULL),
                 
                 numericInput("lowfrequency",
                             "Low frequency reads cutoff",
                             value = 0),
                 
                 numericInput("lfc",
                              "LogFoldChange cutoff",
                              value = 0),
                 
                 sliderInput("pvalue",
                             "p-value",
                             min = 0,
                             max = 1,
                             value = 0.1,
                             step = 0.001),
               ), # Sidebar panel 2
               mainPanel(
                 tableOutput("deseq2"),
               )
             )
    ), # Main panel 2
    
    # Panel 3
    tabPanel("Vocano plot",
             sidebarLayout(
               sidebarPanel(
                 
                 numericInput("fc_cutoff",
                             'FoldChange cutoff',
                             value = 0),
                 
                 numericInput("p_value",
                              'p-value cutoff',
                              value = 0.1),
                 
                 numericInput("point_size",
                             'Point size',
                             value = 3.0),
                 
                 numericInput("lab_size",
                              'Label size',
                              value = 6.0),
                 
                 textInput("title",
                           "Title",
                           value = ""),
                
                 textInput("plot_filename",
                           "Plot filename (.svg)",
                           value = "volcano_plot"),
                 
                 downloadButton("downloadPlot",
                                "Download plot"),
                 
               ), # Sidebar panel 2
               mainPanel(
                 plotOutput("plots")
               )
             )
    ), # Main panel 3
  )
)
