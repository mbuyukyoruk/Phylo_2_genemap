rm(list = ls())

### Check package availability ###

list.of.packages <- c("ape", "ggtree","tidyverse","gggenes","tidytree")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

if("ggtree" %in% new.packages){
  if (!require("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
  
  BiocManager::install("ggtree")
}

### Load packages ###

suppressMessages(suppressWarnings(library("ape")))
suppressMessages(suppressWarnings(library("ggtree")))
suppressMessages(suppressWarnings(library("tidyverse")))
suppressMessages(suppressWarnings(library("gggenes")))
suppressMessages(suppressWarnings(library("tidytree")))

### Parse Arguments ###

args <- commandArgs(trailingOnly = TRUE)

filename <- args[which(args=="--tree")+1]
genemap_in <-  args[which(args=="--genemap")+1]
anc_point <-  args[which(args=="--anchor")+1]
clade_in <-  args[which(args=="--clade")+1]
file.out <- args[which(args=="--output")+1]
FLIP <- args[which(args=="--flip")+1]
interactive_plot <- args[which(args=="--interactive")+1]

### Import Tree ###

treein <- read.tree(filename)

x <- treein
p1 <- ggtree(x)

### Color branches if Clade info provided ###

if(length(clade_in)!=0){
  quants <- list()
  
  clade_df <- read.delim(clade_in, header = TRUE)
  clade_append <- NULL
  
  for(i in 1:ncol(clade_df)){
    clade_info <- paste(as.list(clade_df[,i][clade_df[,i]!=""]),collapse = "|")
    assign(paste("clade",i,sep = "_"),grep(clade_info,treein$tip.label))
    if(i==1){
      clade_append <- clade_info
    }else{
      clade_append <- paste(clade_append,clade_info,sep = "|")
    }
    if(i==ncol(clade_df)){
      uncladed <- grep(clade_append,treein$tip.label,invert = TRUE)
    }
  }
  for(i in 1:ncol(clade_df)){
    if (length(uncladed)!=0){
      quants[["Rest"]] <- uncladed
    }
    quants[[paste0(colnames(clade_df)[i])]] <- get(paste("clade",i,sep = "_"))
  }
  
  p1 <- groupOTU(p1, quants, 'Clade') + aes(color=Clade)
}

### Import genemap dataframe ###

genemap <- read.delim(genemap_in,header = TRUE)

### Decide to flip or not ###

if(FLIP=="y"){
  flip_check <- unique(subset(genemap,gene==anc_point)[c("molecule","orientation")])
  
  colnames(flip_check) <- c("molecule","flip")
  
  flip_check = mutate(flip_check, flip = case_when(flip == "1" ~ "no",flip == "0" ~ "yes",))
  
  genemap <- merge(genemap, flip_check, by = "molecule",all.x = TRUE)
  
  genemap <- genemap %>%
    mutate(new_start = case_when(flip == "yes" ~ 10000-end+1, flip == "no" ~ start ),new_end = case_when(flip == "yes" ~ 10000-start+1, flip == "no" ~ end ), new_orientation = case_when(flip == "yes" & orientation == "0" ~ 1,flip == "yes" & orientation == "1" ~ 0, flip == "no" & orientation == "0" ~ 0,flip == "no" & orientation == "1" ~ 1))
  
  colnames(genemap) <- c("molecule","ORF","genome","gene","old_start","old_end","old_orientation","flipped","start","end","orientation")
  
}

### Map domains to ggtree plot ###

tip_count <- length(x$tip.label)

psub <- p1 + 
  geom_facet(mapping = aes(xmin = start, xmax = end, fill = gene),
             data = subset(genemap,tolower(gene)=="length" | gene == anc_point), geom = geom_motif, panel = 'Alignment',
             on = anc_point , arrowhead_height = unit(0, "mm"), arrowhead_width = unit(0, "mm"), arrow_body_height = unit(100/tip_count,"mm"),size = 0, fill="gray", color="transparent") #+ theme_genes()

p <- psub + 
  geom_facet(mapping = aes(xmin = start, xmax = end, fill = gene,forward = orientation),
             data = subset(genemap,tolower(gene)!="length"), geom = geom_motif, panel = 'Alignment',
             on = anc_point, align = 'left',arrow_body_height = unit(100/tip_count,"mm"), arrowhead_height = unit(100/tip_count, "mm"), arrowhead_width = unit(1, "mm"), color="transparent",size = 0) +
  scale_x_continuous(expand=c(0,0))

legend_col <- ceiling(length(unique(genemap$gene))/72)

if(interactive_plot=="y"){
  for (i in 1:1){
    X11()
    Sys.sleep(5)
    plot(p)
    node_select <- identify(p)
    print(paste0("Selected: ", node_select))
    tip_count <- length(subset(ggtree:::getSubtree(p, node_select),isTip==TRUE)$label)
    p_zoom <- ggtree(ggtree:::getSubtree(p, node_select)) + geom_tiplab(size=2, offset = 1,align = TRUE) +  
      xlim_tree(8) + geom_facet(mapping = aes(xmin = start, xmax = end, fill = gene,forward = orientation),
                                data = genemap, geom = geom_motif, panel = 'Alignment', on = anc_point, 
                                align = 'left',arrow_body_height = unit(100/tip_count,"mm"), 
                                arrowhead_height = unit(100/tip_count, "mm"), arrowhead_width = unit(1, "mm"),
                                size = 0) + 
      scale_x_continuous(expand=c(0,0))+ guides(fill=guide_legend(ncol=legend_col)) + theme(legend.key.size = unit(0.2, "cm"))
    
    Sys.sleep(5)
    plot(p_zoom)
    
    while (interactive_plot=="y"){
      cat("Press [C] to continue, [R] to restart OR [Q] to quit.\n")
      ANSWER <- readLines(con = "stdin", n = 1)
      
      if (tolower(substr(ANSWER, 1, 1)) == "c"){
        Sys.sleep(5)
        #plot(p_zoom)
        node_select <- identify(p_zoom)
      } else if (tolower(substr(ANSWER, 1, 1)) == "r") {
        Sys.sleep(5)
        plot(p)
        node_select <- identify(p)
      } else if (tolower(substr(ANSWER, 1, 1)) == "q"){
        break
      }
      
      print(paste0("Selected: ", node_select))
      tip_count <- length(subset(ggtree:::getSubtree(p, node_select),isTip==TRUE)$label)
      p_zoom <- ggtree(ggtree:::getSubtree(p, node_select)) + geom_tiplab(size=2, offset = 1,align = TRUE) +  
        xlim_tree(8) + geom_facet(mapping = aes(xmin = start, xmax = end, fill = gene,forward = orientation),
                                  data = genemap, geom = geom_motif, panel = 'Alignment', on = anc_point, 
                                  align = 'left',arrow_body_height = unit(100/tip_count,"mm"), 
                                  arrowhead_height = unit(100/tip_count, "mm"), arrowhead_width = unit(1, "mm"),
                                  size = 0) + 
        scale_fill_brewer(palette = "Set2") + 
        scale_x_continuous(expand=c(0,0))+ guides(fill=guide_legend(ncol=legend_col)) + theme(legend.key.size = unit(0.2, "cm"))
      
      plot(p_zoom)
    }
  }
}

setEPS()
postscript(paste0(tools::file_path_sans_ext(file.out),".eps"))
Sys.sleep(2)
p + xlim_tree(8) + guides(fill=guide_legend(ncol=legend_col)) + theme(legend.key.size = unit(0.2, "cm"))
dev.off()
 
pdf(paste0(tools::file_path_sans_ext(file.out),".pdf"))
Sys.sleep(2)
p + xlim_tree(8) + guides(fill=guide_legend(ncol=legend_col)) + theme(legend.key.size = unit(0.2, "cm"))
dev.off()
 
print(paste0("Raw plot is exported as PDF and SVG files and can be found in ",getwd()))
