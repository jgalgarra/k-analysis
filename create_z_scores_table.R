# Creates the zscores tables
# Output data at resultsnulls
#
# Requires:
# null model analysis at "resultsnulls"

ficheros <- Sys.glob("resultsnulls/M*_auxdfnulls_*.RData")
zscores <- NA
for (i in ficheros)
{
  load(i)
  zscores <- rbind(auxdfnulls,zscores)
}
write.csv(zscores[1:nrow(zscores)-1,],"resultsnulls/zscores_all.csv")