#所需包的安装和载入：
install.packages("circlize")
install.packages("ComplexHeatmap")
library('ComplexHeatmap')
library('circlize')
library('dplyr')

# 只有row名没有重复的时候才能用 row.names = 1
data <- read.csv('HeatMapData.csv', header = T )
# 删除重复的选项
data <- data[!duplicated(data$X),]
rownames(data) <- data$X
data <- data[,-1]
# csv读入为character，转化为numeric,这个data转化为matrix
madt <- apply(data,2,as.numeric)
# 转化为矩阵并对其进行归一化：
madt2<-t(scale(t(madt)))
rownames(madt2) <- rownames(data)
# 默认参数绘制普通热图
mini_madt2 <- madt2[0:100,]
Heatmap(mini_madt2)
dev.off()

#计算数据大小范围
range(mini_madt2)
#重新定义热图颜色梯度：
mycol=colorRamp2(c(-1.7, 0.3, 2.3),c("blue", "white", "red"))

#绘制基础环形热图：
circos.heatmap(mini_madt2,col=mycol)
circos.clear()#绘制完成后需要使用此函数完全清除布局

#在circos.heatmap()中添加参数进行环形热图的调整和美化：
circos.par(gap.after=c(50))
circos.heatmap(mini_madt2,col=mycol,dend.side="inside",rownames.side="outside",
               rownames.col="black",
               rownames.cex=0.9,
               rownames.font=1,
               cluster=TRUE)
circos.clear()
#circos.par()调整圆环首尾间的距离，数值越大，距离越宽
#dend.side：控制行聚类树的方向，inside为显示在圆环内圈，outside为显示在圆环外圈
#rownames.side：控制矩阵行名的方向,与dend.side相同；但注意二者不能在同一侧，必须一内一外
#cluster=TRUE为对行聚类，cluster=FALSE则不显示聚类
dev.off()

# 美化图片
#聚类树的调整和美化(需要用到两个别的包）：
install.packages("dendextend")#改颜色
install.packages("dendsort")#聚类树回调
library(dendextend)
library(dendsort)
circos.par(gap.after=c(100))
# MAC上报错：Error: vector memory exhausted (limit reached?)，所有使用mini_madt2
# track.height：轨道的高度，数值越大圆环越粗
# dend.track.height：调整行聚类树的高度
# dend.callback：用于聚类树的回调，当需要对聚类树进行重新排序，或者添加颜色时使用
# 包含的三个参数：dend：当前扇区的树状图；m：当前扇区对应的子矩阵；si：当前扇区的名称
# color_branches():修改聚类树颜色
# 使用报错：track.height = 0.38, dend.track.height=0.18
circos.heatmap(mini_madt2,col=mycol,dend.side="inside",rownames.side="outside",
               rownames.col="black",
               rownames.cex=0.5,
               rownames.font=1,
               cluster=TRUE,
               track.height = 0.1,
               dend.track.height=0.1,
               dend.callback=function(dend,m,si) {
                 color_branches(dend,k=15,col=1:15)
               }
)

#添加图例标签等
lg=Legend(title="Exp",col_fun=mycol,direction = c("vertical"))
# legend的位置可以更改
lg@grob$vp$x <- unit(.1,'npc')
lg@grob$vp$y <- unit(.2,'npc')
grid.draw(lg)

#添加列名：
circos.track(track.index=get.current.track.index(),panel.fun=function(x,y){
  if(CELL_META$sector.numeric.index==1){
    cn=colnames(mini_madt2)
    n=length(cn)
    circos.text(rep(CELL_META$cell.xlim[2],n)+convert_x(0.1,"mm"),#x坐标
                7.2+(1:n)*0.55,#y坐标
                cn,cex=0.2,adj=c(0,1),facing="inside")
  }
},bg.border=NA)
circos.clear()
dev.off()


#更换热图配色，并重新绘图：
#这里代码和上文相同，仅改变了颜色和circos.par（圆环首位的距离）
mycol2=colorRamp2(c(-1.7, 0.3, 2.3),c("#57ab81", "white", "#ff9600"))
circos.par(gap.after=c(100))
circos.heatmap(mini_madt2,col=mycol2,dend.side="inside",rownames.side="outside",track.height = 0.1,
               rownames.col="black",
               rownames.cex=0.5,
               rownames.font=1,
               cluster=TRUE,
               dend.track.height=0.1,
               dend.callback=function(dend,m,si) {
                 color_branches(dend,k=15,col=1:15)
               }
)
lg=Legend(title="Exp",col_fun=mycol2,direction = c("vertical"))
lg@grob$vp$x <- unit(.1,'npc')
lg@grob$vp$y <- unit(.2,'npc')
grid.draw(lg)
circos.track(track.index=get.current.track.index(),panel.fun=function(x,y){
  if(CELL_META$sector.numeric.index==1){
    cn=colnames(madt2)
    n=length(cn)
    circos.text(rep(CELL_META$cell.xlim[2],n)+convert_x(0.1,"mm"),#x坐标
                7.2+(1:n)*0.55,#y坐标
                cn,cex=0.2,adj=c(0,1),facing="inside")
  }
},bg.border=NA)
circos.clear()
dev.off()

# 分组热图绘制：
# circos.heatmap()内只能是一个矩阵，但如果矩阵数据存在分组，可以用split参数来指定分类变量
# sample函数可以完成随机抽样处理
split = sample(letters[1:2], 100, replace = TRUE) # 给100个基因随机分层两个标签
split = factor(split, levels = letters[1:2])
circos.par(gap.after=c(22))
# split: It splits the matrix into a list of matrices.
circos.heatmap(mini_madt2,col=mycol2,split=split,dend.side="inside",rownames.side="outside",track.height = 0.1,
               rownames.col="black",
               rownames.cex=0.5,
               rownames.font=1,
               cluster=TRUE,
               dend.track.height=0.1,
               dend.callback=function(dend,m,si) {
                 color_branches(dend,k=15,col=1:15)
               }
)
lg=Legend(title="Exp",col_fun=mycol2,direction = c("horizontal"))
lg@grob$vp$x <- unit(.3,'npc')
lg@grob$vp$y <- unit(.3,'npc')
grid.draw(lg)
circos.track(track.index=get.current.track.index(),panel.fun=function(x,y){
  if(CELL_META$sector.numeric.index==1){
    cn=colnames(madt2)
    n=length(cn)
    circos.text(rep(CELL_META$cell.xlim[2],n)+convert_x(0.1,"mm"),
                7.2+(1:n)*0.55,
                cn,cex=0.2,adj=c(0,1),facing="inside")
  }
},bg.border=NA)
circos.clear()
dev.off()


#多轨热图绘制：
#假设有两个热图的矩阵数据（这里仅为一组重复两次以作示范）
mini_madt3 <- madt2[101:200,]
split2 = sample(letters[1:2], 100, replace = TRUE)
split2 = factor(split2, levels = letters[1:2])
circos.par(gap.after=c(8))
circos.heatmap(mini_madt2,col=mycol2,split=split2,dend.side="outside",
               cluster=TRUE,
               dend.track.height=0.2,
               dend.callback=function(dend,m,si) {
                 color_branches(dend,k=15,col=1:15)
               }
)
circos.heatmap(mini_madt3, col = mycol,rownames.side="inside",rownames.cex=0.8)#加入第二个热图


#添加放置在左侧的图例：
# install.packages("gridBase")
library(gridBase)
lg_Exp1=Legend(title="Exp1",col_fun=mycol2,direction = c("vertical"))
lg_Exp2=Legend(title="Exp2",col_fun=mycol,direction = c("vertical"))
circle_size = unit(0.07, "snpc")
h = dev.size()
lgd_list = packLegend(lg_Exp1,lg_Exp2, max_height = unit(2*h, "inch"))
draw(lgd_list, x = circle_size, just = "left")

circos.clear()
dev.off()
