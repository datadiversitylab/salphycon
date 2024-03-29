###################
# server.R
# 
# Server controller. 
# Used to define the back-end aspects of the app.
###################


server = function(input, output, session) {

  sqs.curated <- NULL
  tree <- NULL
  sqs.aln <- NULL
  assign(".testMode", TRUE, envir = phruta:::pkg.env)

## Language settings

  observeEvent(input$selected_language, {
    print(paste("Language change!", input$selected_language))
    shiny.i18n::update_lang(session, input$selected_language)
  })

## First input action (in the settings tab)

observeEvent(input$action, {
    
    progress <- shiny::Progress$new()
    on.exit(progress$close())
    progress$set(message = "Running {phruta}...", value = 0)

    npro <- length(input$Process)
    
    # Add Clades or Species file
    if(!is.null(input$fileTaxa)){
    taxa2 <- read.csv(input$fileTaxa$datapath,
                   header = FALSE)
    
    taxa1 <- sub(" ", "", strsplit( input$addTaxa, ",")[[1]])
    taxa <- c(taxa1, taxa2[,1])
    }else{
    taxa <-   sub(" ", "", strsplit( input$addTaxa, ",")[[1]])
    }
    
    # Only retrieving sequences
    if( 0 %in% input$Process ) {
      tryCatch({
      #retrieve
      if(!is.null(input$fileGenes)){
      genes <- read.csv(input$fileGenes$datapath,
                          header = FALSE)
      targetGenes <- data.frame('Gene' = genes[,1])
      }else{        
      gs.seqs <<- 
        phruta::gene.sampling.retrieve(organism = taxa, 
                    speciesSampling = TRUE,
                    npar = 6,
                    nSearchesBatch = 500)
      
      targetGenes <<- gs.seqs[gs.seqs$PercentOfSampledSpecies > input$sliderGenes,]
      
      }
      
      acc.table <<- phruta::acc.table.retrieve(
        clades  = taxa,
        genes = targetGenes$Gene,
        speciesLevel = TRUE,
        npar = 6,
        nSearchesBatch = 500
      )
      
      sqs.downloaded <<- phruta::sq.retrieve.indirect(acc.table = acc.table, 
                                             download.sqs = FALSE)
      
      #sqs.curated <<- sqs.downloaded ##If no curation happens
      progress$inc(1/npro, detail = "Sequences downloaded...")
      
     
    }, error=function(e){
      #showNotification("This is a notification.", type = "error")
    })
      }

    ## If sequences need curated

    if( all(c(0, 1) %in% input$Process)){ #Curate if seqs have been downloaded
      tryCatch({
      sqs.curated <<- phruta::sq.curate(filterTaxonomicCriteria = '[AZ]',
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
      }, error=function(e){
              showNotification("No sequences found.", type = 'error')
      })
    }
    

## If sequences need to be aligned

    if( all(c(0, 1, 2) %in% input$Process)){
      tryCatch({  
      
       #Aln if seqs have been downloaded
      sqs.aln <<- phruta::sq.aln(sqs.object = sqs.curated)
      progress$inc(1/4, detail = "Sequences aligned...")
      
    
      
       
    }, error=function(e){})
      }

      ## If tree must be build
    
    if( all(c(0, 1, 2, 3) %in% input$Process)){  
      tryCatch({  #RAxML if seqs have been aligned
      dir.create("2.Alignments")
      lapply(seq_along(sqs.aln), function(x){
        ape::write.FASTA(sqs.aln[[x]]$Aln.Masked, 
                         file = paste0(
                           "2.Alignments/Masked_", names(sqs.aln)[x], ".fasta"
                         )
        )
      })
      
      phruta::tree.raxml(folder = '2.Alignments', 
                 FilePatterns = 'Masked_', 
                 raxml_exec = 'raxmlHPC', 
                 Bootstrap = 2
      )

      tree <<- read.tree("3.Phylogeny/RAxML_bipartitions.phruta")
      tree_bst <<- read.tree("3.Phylogeny/RAxML_bootstrap.phruta")
      tip_names <<- tree$tip.label
      
      ##UI-related elements

        output$phyloPlot <- renderPlot({
         if(input$root == 0){
          ape::plot.phylo(ape::ladderize(tree, right = FALSE))
        }else{
          ape::plot.phylo(ape::ladderize(tree2(), right = FALSE))
        }
        })

      output$phyloPlots <- renderUI({
        tablerDash::tablerCard(
          title = "Phylogeny",
          zoomable = TRUE,
          closable = FALSE,
          plotOutput("phyloPlot"),
          status = "info",
          statusSide = "left",
          width = 12
        )
      })

      tree2 <<- eventReactive(input$root, {
       ape::root(tree, input$outgroup)
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
        tablerDash::tablerCard(
          status = "yellow",
          statusSide = "left",
          width = 12,
          column(
            12,
            selectInput("outgroup", "Select your outgroup",
                        tip_names, multiple = TRUE),
            actionButton("root", "Re-root", icon = icon("tree"),
                         style = "color: #fff; background-color: #27ae60; border-color: #fff"),
            downloadButton('downloadTree', 'Download'),
            align = "center")
        )
      })
      
      progress$inc(1/npro, detail = "Tree constructed...")
      
    }, error=function(e){
      showNotification("No sequences found.", type = 'error')
    })}
    
    
    ##Sampling tab boxes
    valuesSampling <- reactiveValues(ngeneregions = 0, nseqs = 0, spp = 0)
    
    observe({
      output$geneRegions <- renderUI({
        tablerDash::tablerStatCard(
          value = valuesSampling$ngeneregions,
          title = "Gene regions",
          width = 12
        )
      })
      
      output$nSeqs <- renderUI({
        tablerDash::tablerStatCard(
          value = valuesSampling$nseqs,
          title = "Sequences",
          width = 12
        )
      })
      
      output$nTaxa <- renderUI({
        tablerDash::tablerStatCard(
          value = valuesSampling$spp,
          title = "Species",
          width = 12
        )
      })
      
      output$Refresh <- renderUI({
        tablerDash::tablerCard(
          status = "yellow",
          statusSide = "left",
          width = 12,
          column(
            12,
            h6("Need to update the resulting sampling?"),
            br(),
            fileInput('file1', 'Choose CSV File',
                      accept=c('text/csv',
                               'text/comma-separated-values,text/plain',
                               '.csv')),
            actionButton("refresh", "Refresh", icon = icon("check"),
                         style = "color: #fff; background-color: #27ae60; border-color: #fff"), align = "center")
        )
      })
      
## Outside elements for the UI

### Accession numbers table
      
      output$tableAccN <- renderUI({
        tablerDash::tablerCard(
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
    
    
    ## Alignment tab boxes
    valuesSequences <- reactiveValues(nspecies = 0, ntaxareg = 0, genes = NULL, DNAbin = NULL)
    
    observe({
      output$SpeciesRegion <- renderUI({
        tablerDash::tablerStatCard(
          value = valuesSequences$nspecies,
          title = "Sequences",
          width = 12
        )
      })
      
      
      output$nGaps <- renderUI({
        tablerDash::tablerStatCard(
          value = valuesSequences$ntaxareg,
          title = "Sites",
          width = 12
        )
      })
      
      output$dropGenes <- renderUI({
        tablerDash::tablerCard(
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
        tablerDash::tablerCard(
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
        tablerDash::tablerCard(
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
  
## If the dataset is updated
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
        
        sqs.downloaded <<- phruta::sq.retrieve.indirect(acc.table = tFile, 
                                                download.sqs = FALSE)
        
        progress$inc(1/npro, detail = "Sequences downloaded...")
        
      }
      
      
      if( all(c(0, 1) %in% input$Process)){ #Curate if seqs have been downloaded
        sqs.curated <<- phruta::sq.curate(filterTaxonomicCriteria = '[AZ]',
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
        sqs.aln <<- phruta::sq.aln(sqs.object = sqs.curated)
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
        
        phruta::tree.raxml(folder = '2.Alignments', 
                   FilePatterns = 'Masked_', 
                   raxml_exec = 'raxmlHPC', 
                   Bootstrap = 2
        )

      tree <<- read.tree("3.Phylogeny/RAxML_bipartitions.phruta")
      tree_bst <<- read.tree("3.Phylogeny/RAxML_bootstrap.phruta")
      tip_names <<- tree$tip.label
      
      ##UI-related elements

        output$phyloPlot <- renderPlot({
         if(input$root == 0){
          ape::plot.phylo(ape::ladderize(tree, right = FALSE))
        }else{
          ape::plot.phylo(ape::ladderize(tree2(), right = FALSE))
        }
        })

      output$phyloPlots <- renderUI({
        tablerDash::tablerCard(
          title = "Phylogeny",
          zoomable = TRUE,
          closable = FALSE,
          plotOutput("phyloPlot"),
          status = "info",
          statusSide = "left",
          width = 12
        )
      })

      tree2 <<- eventReactive(input$root, {
       ape::root(tree, input$outgroup)
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
        tablerDash::tablerCard(
          status = "yellow",
          statusSide = "left",
          width = 12,
          column(
            12,
            selectInput("outgroup", "Select your outgroup",
                        tip_names, multiple = TRUE),
            actionButton("root", "Re-root", icon = icon("tree"),
                         style = "color: #fff; background-color: #27ae60; border-color: #fff"),
            downloadButton('downloadTree', 'Download'),
            align = "center")
        )
      })
        
        progress$inc(1/npro, detail = "Tree constructed...")
      }
      
      ##Sampling tab boxes
      valuesSampling <- reactiveValues(ngeneregions = 0, nseqs = 0, spp = 0)
      
      observe({
        output$geneRegions <- renderUI({
          tablerDash::tablerStatCard(
            value = valuesSampling$ngeneregions,
            title = "Gene regions",
            width = 12
          )
        })
        
        output$nSeqs <- renderUI({
          tablerDash::tablerStatCard(
            value = valuesSampling$nseqs,
            title = "Sequences",
            width = 12
          )
        })
        
        output$nTaxa <- renderUI({
          tablerDash::tablerStatCard(
            value = valuesSampling$spp,
            title = "Species",
            width = 12
          )
        })
        
        
                
        output$tableAccN <- renderUI({
          tablerDash::tablerCard(
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
          tablerDash::tablerStatCard(
            value = valuesSequences$nspecies,
            title = "Sequences",
            width = 12
          )
        })
        
        
        output$nGaps <- renderUI({
          tablerDash::tablerStatCard(
            value = valuesSequences$ntaxareg,
            title = "Sites",
            width = 12
          )
        })
        
        output$dropGenes <- renderUI({
          tablerDash::tablerCard(
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
          tablerDash::tablerCard(
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
          tablerDash::tablerCard(
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

## Gene finder tab

observeEvent(input$action2, {  tryCatch({ 
    
    progress <- shiny::Progress$new()
    on.exit(progress$close())
    progress$set(message = "Running {phruta}...", value = 0)
    
    # Add Clades or Species file
    if(!is.null(input$fileTaxaGenes)){
      taxa2genes <- read.csv(input$fileTaxaGenes$datapath,
                        header = FALSE)
      Taxagenes <- sub(" ", "", strsplit( input$genesearch, ",")[[1]])
      Taxagenes <- c(Taxagenes, taxa2genes[,1])
    }else{
      Taxagenes <- sub(" ", "", strsplit( input$genesearch, ",")[[1]])
    }
     
    gs.seqs_gene <<- phruta::gene.sampling.retrieve(organism = Taxagenes, 
                                       speciesSampling = TRUE,
                                       npar = 6,
                                       nSearchesBatch = 500)
    
    output$distTableGenes <-
      DT::renderDataTable(server = FALSE, { 
        DT::datatable(gs.seqs_gene,
                      extensions = 'Buttons',
                      options = list(scrollX = TRUE,
                                     pageLength = 10,
                                     searching = FALSE,
                                     dom = 'Bfrtip',
                                     buttons = c('csv', 'excel')),
                      rownames = FALSE)
      })
    
    output$tableGenes <- renderUI({
      tablerDash::tablerCard(
        title = "Gene sampling",
        zoomable = TRUE,
        closable = FALSE,
        overflow = TRUE,
        DT::dataTableOutput("distTableGenes"),
        status = "info",
        statusSide = "left",
        width = 12
      )
    })
    
    
    
  }, error=function(e){
              showNotification("No genes found.", type = 'error')
  })
})

## Progress bar
output$progress <- renderUI({
    tagList(
      tablerDash::tablerProgress(value = input$knob, size = "xs", status = "yellow"),
      tablerDash::tablerProgress(value = input$knob, status = "red", size = "sm")
    )
})


## Templates
  output$downloadTemplateGenes <- downloadHandler(
    filename = "phruta_genes_template.csv",
    content = function(file) {
      write.table(gene_temp, file, row.names = FALSE, col.names=FALSE, sep=",")
    }
  )

  output$downloadTemplateTaxa <- downloadHandler(
    filename = "phruta_taxa_template.csv",
    content = function(file) {
      write.table(taxa_temp, file, row.names = FALSE,  col.names = FALSE, sep=",")
    }
  )

    output$downloadTemplateSampling <- downloadHandler(
    filename = "phruta_sampling_template.csv",
    content = function(file) {
      write.table(samp_temp, file, row.names = FALSE,  sep=",")
    }
  )

  }