# Purpose: Differential expression analysis Shiny app
# Date created: 10.08.2022
# Author: Luigui Gallardo-Becerra (bfllg77@gmail.com)

library(shiny)
library(shinythemes)
library(ggplot2)
library(Hmisc)
library(reshape2)
library(dplyr)
library(ggpubr)
library(markdown)

library(DESeq2)
library(apeglm)
library(EnhancedVolcano)

# Define server logic required to the DE analysis
shinyServer(
  function(input, output, session, plot_reactive) {
    
    output$contents <- renderTable({
      
      input_file <<- input$input_file
      metadata_file <<- input$metadata_file
      
      # Print NULL if no input or metadata files
      if (is.null(input_file))
        return(NULL)
      
      if (is.null(metadata_file))
        return(NULL)
      
      # Read input file
      input_table <<- as.matrix(read.delim(input_file$datapath,
                                 sep="\t",
                                 row.names = 1))
      
      metadata_file <<- read.delim(metadata_file$datapath)
      
      updateSelectInput(session,
                        "reference_group",
                        choices = unique(metadata_file[2]))
      
      # Final output
      res_dif_expression_deseq_data_set <- NULL
      dif_expression_deseq_data_set <- NULL
      
      return(metadata_file)
      
    }
    )
    
    
    output$deseq2 <- renderTable({
      
      # Variables of this section
      # Reference/control group
      
      reference = input$reference_group
      
      # Low abundance  cutoff
      lowfrequency = input$lowfrequency
      
      # p-value cutoff
      pvalue = input$pvalue
      
      # LFC cutoff
      lfc = input$lfc
      
      # Beginning of deseq2 analysis
      deseq_data_set <- DESeqDataSetFromMatrix(countData = input_table,
                                               colData = metadata_file,
                                               design = ~group)
      
      # Select reference/control group
      deseq_data_set$group <- relevel(deseq_data_set$group,
                                      ref = reference)
      
      # Remove low abundance features
      keep <- rowSums(counts(deseq_data_set)) >= lowfrequency
      
      deseq_data_set <- deseq_data_set[keep,]
      
      # Differential expression
      dif_expression_deseq_data_set <<- DESeq(deseq_data_set)
      
      res_dif_expression_deseq_data_set <<- results(dif_expression_deseq_data_set,
                                                     lfcThreshold = lfc,
                                                     alpha = pvalue)
      
      summary_dif_expression_deseq_data_set <- capture.output(summary(res_dif_expression_deseq_data_set))
      
      return(summary_dif_expression_deseq_data_set)
    }
    )
    
    plot_reactive <- reactive({

      volcano_plot <- EnhancedVolcano(res_dif_expression_deseq_data_set,
                                       lab = rownames(res_dif_expression_deseq_data_set),
                                       x = 'log2FoldChange',
                                       y = 'pvalue',
                                       title = input$title,
                                       FCcutoff = input$fc_cutoff,
                                       pCutoff = input$p_value,
                                       pointSize = input$point_size,
                                       labSize = input$lab_size)
    

      volcano_plot
      
    }
    )
    
    output$plots <- renderPlot({
      plot_reactive()
    }
    )
    
    output$downloadPlot <- downloadHandler(
      filename = function() {
        paste0(input$plot_filename, ".svg")
      },
      content = function(file) {
        ggsave(
          file,
          plot_reactive(),
          width = 7,
          height = 7
        )
      }
    )
    
    output$downloadTable <- downloadHandler(
      filename = function(){
        paste0(input$table_filename, ".tsv")
      }, 
      content = function(file){
        write.table(res_dif_expression_deseq_data_set,
                    file,
                    sep = "\t")
      }
    )
  }
)
