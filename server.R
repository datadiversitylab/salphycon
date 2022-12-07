server = function(input, output, session) {
  sqs.curated <- NULL
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
  

  observeEvent(input$action, {
    
    progress <- shiny::Progress$new()
    on.exit(progress$close())
    progress$set(message = "Running {phruta}...", value = 0)
    
    taxa <- input$addTaxa
    
    npro <- length(input$Process)
    
    # Add Clades or Species file
    taxa2 <- read.csv(input$fileTaxa$datapath,
                   header = FALSE)
    taxa <- c(taxa, taxa2[,1])
    
    if( 0 %in% input$Process ) { #retrieve
      
      genes <- read.csv(input$fileGenes$datapath,
                        header = FALSE)
      
      if(!is.null(input$fileGenes)){
      targetGenes <- data.frame('Gene' = genes[,1])
      }else{
      gs.seqs <<- gene.sampling.retrieve(organism = taxa, 
                                        speciesSampling = TRUE,
                                        npar = 6,
                                        nSearchesBatch = 500)
      
      targetGenes <<- gs.seqs[gs.seqs$PercentOfSampledSpecies > input$sliderGenes,]
      }
      
      acc.table <<- acc.table.retrieve(
        clades  = taxa,
        genes = targetGenes$Gene,
        speciesLevel = TRUE,
        npar = 6,
        nSearchesBatch = 500
      )
      
      sqs.downloaded <<- sq.retrieve.indirect(acc.table = acc.table, 
                                             download.sqs = FALSE)
      
      #sqs.curated <<- sqs.downloaded ##If no curation happens
      progress$inc(1/npro, detail = "Sequences downloaded...")
      
    }

    
    if( all(c(0, 1) %in% input$Process)){ #Curate if seqs have been downloaded
      sqs.curated <<- sq.curate(filterTaxonomicCriteria = '[AZ]',
                               kingdom = 'animals', 
                               sqs.object = sqs.downloaded,
                               removeOutliers = FALSE)
      
      output$distTable <-
        DT::renderDataTable(server = FALSE, { 
          DT::datatable(sqs.curated$AccessionTable,
                            extensions = 'Buttons',
                            options = list(scrollX = TRUE,
                                           pageLength = 10,
                                           searching = FALSE,
                                           dom = 'Bfrtip',
                                           buttons = c('csv', 'excel')),
                            rownames = FALSE)
        })
      
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
      
      output$Refresh <- renderUI({
        tablerCard(
          status = "yellow",
          statusSide = "left",
          width = 12,
          column(
            12,
            fileInput('file1', 'Choose CSV File',
                      accept=c('text/csv',
                               'text/comma-separated-values,text/plain',
                               '.csv')),
            actionButton("refresh", "Refresh", icon = icon("check"),
                         style = "color: #fff; background-color: #27ae60; border-color: #fff"), align = "center")
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
    })
    
    toListen <- reactive({
      list(input$action)
    })
    
    observeEvent(toListen(), {
      valuesSampling$ngeneregions <- length(na.omit(unique(sqs.curated$AccessionTable$file)))
      valuesSampling$nseqs <- ifelse(is.null(nrow(sqs.curated$AccessionTable)), 0,  nrow(sqs.curated$AccessionTable))
      valuesSampling$spp <- ifelse(is.null(nrow(sqs.curated$Taxonomy)), 0,  nrow(sqs.curated$Taxonomy))
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
          if(!is.null(sqs.aln)){
            unlink("2.Alignments", recursive = TRUE)
            dir.create("2.Alignments")
            invisible(
              lapply(seq_along(sqs.aln), function(x){
                ape::write.FASTA(sqs.aln[[x]]$Aln.Original, file = paste0("2.Alignments/Raw_", 
                                                                          names(sqs.aln)[x], 
                                                                          ".fasta"))
                ape::write.FASTA(sqs.aln[[x]]$Aln.Masked, file = paste0("2.Alignments/Masked_", 
                                                                        names(sqs.aln)[x], 
                                                                        ".fasta"))
              })
            )
            zip(zipfile = file, files = '2.Alignments')
            unlink("2.Alignments", recursive = TRUE)
          }
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
          unlink("3.Phylogeny", recursive = TRUE)
          
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
    
    observeEvent(toListen(), {
      valuesSequences$genes <- names(sqs.aln)
    })  
    
    observeEvent(input$geneSel, {
      valuesSequences$nspecies <- length(sqs.aln[names(sqs.aln) == input$geneSel][[1]]$Aln.Masked)
      valuesSequences$ntaxareg <- length(sqs.aln[names(sqs.aln) == input$geneSel][[1]]$Aln.Masked[[1]])
      valuesSequences$DNAbin <- sqs.aln[names(sqs.aln) == input$geneSel][[1]]$Aln.Masked
    })
    
  })
  
  dataUpdated <- reactive({
    inFile <- input$file1
    if (is.null(inFile)) return(NULL)
    data <- read.csv(inFile$datapath, header = TRUE)
    data
  })
  
  observeEvent(input$refresh, {
    
    if(!is.null(dataUpdated())){
      
      progress <- shiny::Progress$new()
      on.exit(progress$close())
      progress$set(message = "Updating {phruta}...", value = 0)
      
      npro <- length(input$Process)
      
      if( 0 %in% input$Process ) { #retrieve
        dataset <<- dataUpdated()
        
        tFile <- cbind.data.frame(Acc =  dataset$AccN, 
                                  gene = dataset$file,
                                  Species = dataset$Species)
        
        sqs.downloaded <<- sq.retrieve.indirect(acc.table = tFile, 
                                                download.sqs = FALSE)
        
        progress$inc(1/npro, detail = "Sequences downloaded...")
        
      }
      
      
      if( all(c(0, 1) %in% input$Process)){ #Curate if seqs have been downloaded
        sqs.curated <<- sq.curate(filterTaxonomicCriteria = '[AZ]',
                                  kingdom = 'animals', 
                                  sqs.object = sqs.downloaded,
                                  removeOutliers = FALSE,
                                  minSeqs = 1)
        
        output$distTable <-
          DT::renderDataTable(server = FALSE, { 
            DT::datatable(dataset,
                          extensions = 'Buttons',
                          options = list(scrollX = TRUE,
                                         pageLength = 10,
                                         searching = FALSE,
                                         dom = 'Bfrtip',
                                         buttons = c('csv', 'excel')),
                          rownames = FALSE)
          })

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
        
        output$Refresh <- renderUI({
          tablerCard(
            status = "yellow",
            statusSide = "left",
            width = 12,
            column(
              12,
              fileInput('file1', 'Choose CSV File',
                        accept=c('text/csv',
                                 'text/comma-separated-values,text/plain',
                                 '.csv')),
              actionButton("refresh", "Refresh", icon = icon("check"),
                           style = "color: #fff; background-color: #27ae60; border-color: #fff"), align = "center")
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
      })
      
      toListen <- reactive({
        list(input$refresh)
      })
      
      #observeEvent(toListen(), {
        valuesSampling$ngeneregions <- length(na.omit(unique(dataset$file)))
        valuesSampling$nseqs <- ifelse(is.null(nrow(dataset)), 0,  nrow(dataset))
        valuesSampling$spp <- ifelse(is.null(nrow(dataset)), 0,  length(unique(dataset$Species)))
      #})  
      
      
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
            if(!is.null(sqs.aln)){
              unlink("2.Alignments", recursive = TRUE)
              dir.create("2.Alignments")
              invisible(
                lapply(seq_along(sqs.aln), function(x){
                  ape::write.FASTA(sqs.aln[[x]]$Aln.Original, file = paste0("2.Alignments/Raw_", 
                                                                            names(sqs.aln)[x], 
                                                                            ".fasta"))
                  ape::write.FASTA(sqs.aln[[x]]$Aln.Masked, file = paste0("2.Alignments/Masked_", 
                                                                          names(sqs.aln)[x], 
                                                                          ".fasta"))
                })
              )
              zip(zipfile = file, files = '2.Alignments')
              unlink("2.Alignments", recursive = TRUE)
            }
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
            unlink("3.Phylogeny", recursive = TRUE)
            
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
      
      observeEvent(toListen(), {
        valuesSequences$genes <- names(sqs.aln)
      })  
      
      observeEvent(input$geneSel, {
        valuesSequences$nspecies <- length(sqs.aln[names(sqs.aln) == input$geneSel][[1]]$Aln.Masked)
        valuesSequences$ntaxareg <- length(sqs.aln[names(sqs.aln) == input$geneSel][[1]]$Aln.Masked[[1]])
        valuesSequences$DNAbin <- sqs.aln[names(sqs.aln) == input$geneSel][[1]]$Aln.Masked
      })
      
    }
    
    
    
  })

  output$progress <- renderUI({
    tagList(
      tablerProgress(value = input$knob, size = "xs", status = "yellow"),
      tablerProgress(value = input$knob, status = "red", size = "sm")
    )
  })
  
}