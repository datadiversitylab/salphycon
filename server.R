server = function(input, output, session) {
  
  tree <- NULL
  sqs.aln <- NULL
  ##So phruta doesn't where
  assign(".testMode", TRUE, envir = phruta:::pkg.env)
  
  observeEvent(input$selected_language, {
    # This print is just for demonstration
    print(paste("Language change!", input$selected_language))
    # Here is where we update language in session
    shiny.i18n::update_lang(session, input$selected_language)
  })
  
  ## Tables need to be editable
  ## https://stackoverflow.com/questions/70155520/how-to-make-datatable-editable-in-r-shiny
  
 
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
      gs.seqs <<- gene.sampling.retrieve(organism = taxa, 
                                        speciesSampling = TRUE,
                                        npar = 6,
                                        nSearchesBatch = 500)
      
      targetGenes <<- gs.seqs[gs.seqs$PercentOfSampledSpecies > input$sliderGenes,]
      acc.table <<- acc.table.retrieve(
        clades  = taxa,
        genes = targetGenes$Gene,
        speciesLevel = TRUE,
        npar = 6,
        nSearchesBatch = 500
      )
      
      sqs.downloaded <<- sq.retrieve.indirect(acc.table = acc.table, 
                                             download.sqs = FALSE)
      
      progress$inc(1/npro, detail = "Sequences downloaded...")
      
    }

    
    if( all(c(0, 1) %in% input$Process)){ #Curate if seqs have been downloaded
      sqs.curated <<- sq.curate(filterTaxonomicCriteria = '[AZ]',
                               kingdom = 'animals', 
                               sqs.object = sqs.downloaded,
                               removeOutliers = FALSE)
      
      output$distTable <-
        DT::renderDataTable(sqs.curated$AccessionTable,
                            extensions = 'Buttons',
                            options = list(scrollX = TRUE,
                                           pageLength = 10,
                                           searching = FALSE,
                                           dom = 'Bfrtip',
                                           buttons = c('csv', 'excel')),
                            rownames = FALSE)
      
      progress$inc(1/npro, detail = "Sequences curated...")
      
    }
    
    if( all(c(0, 1, 2) %in% input$Process)){ #Aln if seqs have been downloaded
      sqs.aln <<- sq.aln(sqs.object = sqs.curated)
      progress$inc(1/4, detail = "Sequences aligned...")
      
    }
    
    if( all(c(0, 1, 2, 3) %in% input$Process)){ #RAxML if seqs have been aligned
      dir.create("2.Alignments")
      lapply(seq_along(sqs.aln), function(x){
        ape::write.FASTA(sqs.aln[[x]]$Aln.Masked, 
                         file = paste0(
                           "2.Alignments/Masked_", names(sqs.aln)[x], ".fasta"
                         )
        )
      })
      
      tree.raxml(folder = '2.Alignments', 
                 FilePatterns = 'Masked_', 
                 raxml_exec = 'raxmlHPC', 
                 Bootstrap = 2
      )
      
      progress$inc(1/npro, detail = "Tree constructed...")
      
    }
    

  })
  
  ##Sampling tab boxes
  valuesSampling <- reactiveValues(ngeneregions = 0, nseqs = 0, spp = 0)
  observe({
  output$geneRegions <- renderUI({
    tablerStatCard(
      value = valuesSampling$ngeneregions,
      title = "Gene regions",
      width = 12
    )
  })
  
  output$nSeqs <- renderUI({
    tablerStatCard(
      value = valuesSampling$nseqs,
      title = "Sequences",
      width = 12
    )
  })
  
  output$nTaxa <- renderUI({
    tablerStatCard(
      value = valuesSampling$spp,
      title = "Species",
      width = 12
    )
  })
  
  output$tableAccN <- renderUI({
    tablerCard(
      title = "Accession numbers",
      zoomable = TRUE,
      closable = FALSE,
      overflow = TRUE,
      DT::dataTableOutput("distTable"),
      status = "info",
      statusSide = "left",
      width = 12
    )
  })
  
  
  output$downloadsqs <- downloadHandler(
    filename = function() { 
      paste("sqs-phruta-", Sys.Date(), ".zip", sep="")
    },
    content = function(file) {
      zip(zipfile = file, files = '0.Sequences')
    },
    contentType = "application/zip"
  )
  
  output$sqsDownload <- renderUI({
    tablerCard(
      status = "yellow",
      statusSide = "left",
      width = 12,
      column(
        12,
        downloadButton('downloadsqs', 'Download'),
        align = "center")
    )
  })
  
  })
  
  observeEvent(input$action, {
    valuesSampling$ngeneregions <- length(na.omit(unique(sqs.curated$AccessionTable$file)))
    valuesSampling$nseqs <- nrow(sqs.curated$AccessionTable)
    valuesSampling$spp <- nrow(sqs.curated$Taxonomy)
  })  
  
  
  ##alignment tab boxes
  valuesSequences <- reactiveValues(nspecies = 0, ntaxareg = 0, genes = NULL, DNAbin = NULL)
  
  observe({
    output$SpeciesRegion <- renderUI({
      tablerStatCard(
        value = valuesSequences$nspecies,
        title = "Sequences",
        width = 12
      )
    })
    
    
    output$nGaps <- renderUI({
      tablerStatCard(
        value = valuesSequences$ntaxareg,
        title = "Sites",
        width = 12
      )
    })
    
    output$dropGenes <- renderUI({
      tablerCard(
        status = "yellow",
        statusSide = "left",
        width = 12,
        column(
          12,
          selectInput("geneSel", "Choose a gene region:",
                      valuesSequences$genes
          ), align = "center")
      )
    })
    
    
    output$downloadAln <- downloadHandler(
      filename = function() { 
        paste("aln-phruta-", Sys.Date(), ".zip", sep="")
      },
      content = function(file) {
        zip(zipfile = file, files = '2.Alignments')
      },
      contentType = "application/zip"
    )
    
    output$alnDownload <- renderUI({
      tablerCard(
        status = "yellow",
        statusSide = "left",
        width = 12,
        column(
          12,
          downloadButton('downloadAln', 'Download'),
          align = "center")
      )
    })
    
    
    output$seqPlots <- renderUI({
      tablerCard(
        title = "Sequence alignments",
        zoomable = TRUE,
        closable = FALSE,
        #overflow = TRUE,
        plotOutput("distPlot"),
        status = "info",
        statusSide = "left",
        width = 12
      )
    })
    
    output$distPlot <- renderPlot({
     if(!is.null(valuesSequences$DNAbin)){
      image(valuesSequences$DNAbin, 
            xlab = "Position",
            ylab = "Species", 
            legend = TRUE
      )
     }
    })
    
    
    output$phyloControl <- renderUI({
      tablerCard(
        status = "yellow",
        statusSide = "left",
        width = 12,
        column(
          12,
          selectInput("selPhylo", "Choose an option:",
                      choices = c("test1", "test2")
          ), align = "center")
      )
    })
    
 
    output$phyloPlots <- renderUI({
      tablerCard(
        title = "Phylogeny",
        zoomable = TRUE,
        closable = FALSE,
        #overflow = TRUE,
        plotOutput("phyloPlot"),
        status = "info",
        statusSide = "left",
        width = 12
      )
    })
    
    output$phyloPlot <- renderPlot({
      if(3 %in% input$Process){
     tree <- read.tree("3.Phylogeny/RAxML_bipartitions.phruta")
     tree_bst <- read.tree("3.Phylogeny/RAxML_bootstrap.phruta")
     
     ape::plot.phylo(tree, type = "cladogram")
      }
    })
    
    output$downloadTree <- downloadHandler(
      filename = function() { 
        paste("phylogeny-phruta-", Sys.Date(), ".zip", sep="")
      },
      content = function(file) {
        zip(zipfile = file, files = '3.Phylogeny')
      },
      contentType = "application/zip"
      )
    
    output$phyloDownload <- renderUI({
      tablerCard(
        status = "yellow",
        statusSide = "left",
        width = 12,
        column(
          12,
          downloadButton('downloadTree', 'Download'),
          align = "center")
      )
    })
    
  })
  
  observeEvent(input$action, {
    valuesSequences$genes <- names(sqs.aln)
  })  
  
  observeEvent(input$geneSel, {
    valuesSequences$nspecies <- length(sqs.aln[names(sqs.aln) == input$geneSel][[1]]$Aln.Masked)
    valuesSequences$ntaxareg <- length(sqs.aln[names(sqs.aln) == input$geneSel][[1]]$Aln.Masked[[1]])
    valuesSequences$DNAbin <- sqs.aln[names(sqs.aln) == input$geneSel][[1]]$Aln.Masked
  })
  
  
  
  output$progress <- renderUI({
    tagList(
      tablerProgress(value = input$knob, size = "xs", status = "yellow"),
      tablerProgress(value = input$knob, status = "red", size = "sm")
    )
  })
  
}