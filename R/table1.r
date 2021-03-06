library(Gmisc)
library(htmlTable)

table1 = function(curdf, colfactor, selectedFields, colOptions="", add_total_col=T, statistics=T, NEJMstyle=T, digits=2, colN=T, 
  caption="", pos.caption="top", tfoot="",  continuous_fn=describeMean, css.class="gmisc_table") {
  
  
  if (is.vector(selectedFields)) {
    selectedFields = cbind(selectedFields, rep(digits, times=length(selectedFields)))
  }
  
  if (colOptions == "") {
    x = levels(curdf[,colfactor])
    colOptions = cbind(x, rep("c", length(x)), rep(label(curdf[,colfactor]), length(x)))
  }
  
  # Get the basic stats and store in a list
  table_data <- list()
  for (i in 1:nrow(selectedFields)) {
    table_data[[ selectedFields[i,1] ]] = 
      getDescriptionStatsBy(curdf[, selectedFields[i,1]], curdf[, colfactor], show_all_values=TRUE, hrzl_prop=T, html=TRUE, 
        add_total_col=add_total_col, statistics=statistics, NEJMstyle = NEJMstyle, digits=as.integer(selectedFields[i,2]))
  }
  
  # Now merge everything into a matrix
  # and create the rgroup & n.rgroup variabels
  rgroup <- c()
  n.rgroup <- c()
  output_data <- NULL
  for (varlabel in names(table_data)){
    output_data <- rbind(output_data, table_data[[varlabel]])
    rgroup <- c(rgroup, varlabel)
    n.rgroup <- c(n.rgroup, nrow(table_data[[varlabel]]))
  }
  
  # build N= col headings
  if (colN) 
    headings = sapply(colnames(output_data), function(x) {
      if (x=="Total")
        paste0(x, " (n=", nrow(curdf), ")")
      else if (x=="P-value")
        paste0(x)
      else
        paste0(x, " (n=", sum(curdf[, colfactor]==x), ")")
    })
  else
    headings = colnames(output_data)
  
  # build cgroup from colOptions
  cgroup=c("")
  n.cgroup=c(0)
  if (add_total_col) n.cgroup=c(1)
  
  for (i in 1:nrow(colOptions)) {
    if (colOptions[i,3] == cgroup[length(cgroup)]) # if curgroup same as the last one 
      n.cgroup[length(n.cgroup)] = n.cgroup[length(n.cgroup)]+1
    else {
      n.cgroup = c(n.cgroup, 1)
      cgroup = c(cgroup, colOptions[i,3])
    }
  }
  if (statistics) { 
    n.cgroup = c(n.cgroup,1) 
    cgroup = c(cgroup, "")
  }
  
  # new version of GMisc uses missing instead of null for empty options
  #if (all(cgroup==c(""))) cgroup=NULL
  
  # build column alignment from colOptions
  if (add_total_col) align="c" else align=""
  for (i in 1:nrow(colOptions))
    align = paste0(align, colOptions[i,2])
  if (statistics) align=paste0(align, "c")
  
  x = htmlTable(output_data, align=align,
    
    rgroup=rgroup, 
    n.rgroup=n.rgroup, 
    
    cgroup = cgroup,
    n.cgroup = n.cgroup,
    
    header=headings,
    rowlabel="", 
    
    caption=caption, 
    pos.caption = pos.caption,
    
    tfoot=tfoot, 
    ctable=TRUE, 
    
    css.class = css.class)
  
  return(x)
}


# table1 = function(curdf, colfactor, selectedFields, colOptions, add_total_col=F, statistics=F, NEJMstyle=F, digits=2, colN=F, 
#                   caption="", caption.loc="b", tfoot="", continuous_fn=describeMean, tableCSSclass="gmisc_table") {
#   
#   # Get the basic stats and store in a list
#   table_data <- list()
#   for (i in 1:nrow(selectedFields)) {
#     # TODO: Why is "mean(sd)" disappearing when no total column??
# 
#     table_data[[ selectedFields[i,1] ]] = 
#       getDescriptionStatsBy(curdf[, selectedFields[i,1]], curdf[, colfactor], show_all_values=TRUE, hrzl_prop=T, html=TRUE, 
#                             continuous_fn = continuous_fn,
#                             add_total_col=add_total_col, statistics=statistics, NEJMstyle = NEJMstyle, digits=as.integer(selectedFields[i,2]))
#   }
#    
#   #print(table_data)
#   
#   # Now merge everything into a matrix
#   # and create the rgroup & n.rgroup variabels
#   rgroup <- c()
#   n.rgroup <- c()
#   output_data <- NULL
#   for (varlabel in names(table_data)){
#     x = table_data[[varlabel]]
#     if (grepl("curdf", rownames(x))) # hack - ? bug in gmisc, different behaviour of getDescriptionStats if total column present or not
#       rownames(x) = "Mean (SD)" 
#     output_data <- rbind(output_data, x)
#     rgroup <- c(rgroup, varlabel)
#     n.rgroup <- c(n.rgroup, nrow(table_data[[varlabel]]))
#   }
#   
#   # build N= col headings
#   if (colN) 
#     headings = sapply(colnames(output_data), function(x) {
#       if (x=="Total")
#         paste0(x, " (n=", nrow(curdf), ")")
#       else if (x=="p-value")
#         paste0(x)
#       else
#         paste0(x, " (n=", sum(curdf[, colfactor]==x), ")")
#     })
#   else
#     headings = colnames(output_data)
#   
#   # build cgroup from colOptions
#   cgroup=c("")
#   n.cgroup=c(0)
#   if (add_total_col) n.cgroup=c(1)
#   
#   for (i in 1:nrow(colOptions)) {
#     if (colOptions[i,3] == cgroup[length(cgroup)]) # if curgroup same as the last one 
#       n.cgroup[length(n.cgroup)] = n.cgroup[length(n.cgroup)]+1
#     else {
#       n.cgroup = c(n.cgroup, 1)
#       cgroup = c(cgroup, colOptions[i,3])
#     }
#   }
#   if (statistics) { 
#     n.cgroup = c(n.cgroup,1) 
#     cgroup = c(cgroup, "")
#   }
#   
#   # new version of GMisc uses missing instead of null for empty options
#   #if (all(cgroup==c(""))) cgroup=NULL
#   
#   # build column alignment from colOptions
#   if (add_total_col) align="c" else align=""
#   for (i in 1:nrow(colOptions))
#     align = paste0(align, colOptions[i,2])
#   if (statistics) align=paste0(align, "c")
#   
#   x = htmlTable(output_data, align=align,
#                 rgroup=rgroup, n.rgroup=n.rgroup, 
#                 rgroupCSSseparator="",
#                 cgroup = cgroup,
#                 n.cgroup = n.cgroup,
#                 headings=headings,
#                 rowlabel="", 
#                 caption=caption, 
#                 caption.loc = caption.loc,
#                 tfoot=tfoot, 
#                 ctable=TRUE,
#                 output=F,
#                 tableCSSclass = tableCSSclass
#     )
#   
#   return(x)
# }