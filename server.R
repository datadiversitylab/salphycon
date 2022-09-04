server = function(input, output, session) {
  
  observeEvent(input$selected_language, {
    # This print is just for demonstration
    print(paste("Language change!", input$selected_language))
    # Here is where we update language in session
    shiny.i18n::update_lang(session, input$selected_language)
  })
  
  ## Tables need to be editable
  ## https://stackoverflow.com/questions/70155520/how-to-make-datatable-editable-in-r-shiny
  
 
  
  tan <- read.csv("data/go.csv")
  output$distTable <-
    DT::renderDataTable(if(is.null(acc)){tan}else{acc},
                        extensions = 'Buttons',
                        options = list(scrollX = TRUE,
                                       pageLength = 10,
                                       searching = FALSE,
                                       dom = 'Bfrtip',
                                       buttons = c('csv', 'excel')),
                        rownames = FALSE)
  
  
  output$distPlot <- renderPlot({
    if (input$enable_distPlot) hist(rnorm(100))
  })
  

  # Add genes text
  # observeEvent(input$genesText, {
  #   genes <- input$genesText
  # }, ignoreInit = TRUE)
  # 
  # # Add genes file
  # observeEvent(input$fileGenes, {
  #   genes <- read.csv(input$fileGenes)
  #   genes <- taxa[,1] #Single column
  # }, ignoreInit = TRUE)
  # 
  
  observeEvent(input$action, {
    
    progress <- shiny::Progress$new()
    #on.exit(progress$close())
    progress$set(message = "Running {phruta}...", value = 0)
    
    taxa <- input$addTaxa
    
    npro <- length(input$Process)
    
    # Add Clades or Species file
    observeEvent(input$fileTaxa, {
      taxa <- read.csv(input$fileTaxa)
      taxa <- taxa[,1] #Single column
    })
    
    if( 0 %in% input$Process ) { #retrieve
      gs.seqs <- gene.sampling.retrieve(organism = taxa, 
                                        speciesSampling = TRUE)
      
      targetGenes <- gs.seqs[gs.seqs$PercentOfSampledSpecies > input$sliderGenes,]
      acc.table <- acc.table.retrieve(
        clades  = taxa,
        genes = targetGenes$Gene,
        speciesLevel = TRUE
      )
      
      sqs.downloaded <- sq.retrieve.indirect(acc.table = acc.table, 
                                             download.sqs = FALSE)
      
      progress$inc(1/npro, detail = "Sequences downloaded...")
      
    }

    
    if( c(0, 1, 2) %in% input$Process){ #Curate if seqs have been downloaded
      sqs.curated <- sq.curate(filterTaxonomicCriteria = '[AZ]',
                               kingdom = 'animals', 
                               sqs.object = sqs.downloaded,
                               removeOutliers = FALSE)
      progress$inc(1/npro, detail = "Sequences curated...")
      
    }
    
    if( c(0, 1, 2, 3) %in% input$Process){ #Aln if seqs have been downloaded
      sqs.aln <- sq.aln(sqs.object = sqs.curated)
      progress$inc(1/4, detail = "Sequences aligned...")
      
    }
    
    if( c(0, 1, 2, 3, 4) %in% input$Process){ #RAxML if seqs have been aligned
      dir.create("2.Alignments")
      lapply(seq_along(sqs.aln), function(x){
        ape::write.FASTA(sqs.aln[[x]]$Aln.Masked, 
                         file = paste0(
                           "2.Alignments/Masked_", names(sqs.aln)[x], ".fasta"
                         )
        )
      })
      
      outgroup <- sqs.curated$Taxonomy[sqs.curated$Taxonomy$genus == 'Polyplectron',]
      
      tree.raxml(folder = '2.Alignments', 
                 FilePatterns = 'Masked_', 
                 raxml_exec = 'raxmlHPC', 
                 Bootstrap = 100
      )
      progress$inc(1/npro, detail = "Tree constructed...")
      
    }
    
    
  })
  

  output$info <- renderUI({
    tablerInfoCard(
      width = 12,
      value = paste0(input$totalStorage, "GB"),
      status = "success",
      icon = "database",
      description = "Total Storage Capacity"
    )
  })
  
  
  output$progress <- renderUI({
    tagList(
      tablerProgress(value = input$knob, size = "xs", status = "yellow"),
      tablerProgress(value = input$knob, status = "red", size = "sm")
    )
  })
  
}