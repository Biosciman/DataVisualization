#读取差异分析表格；
exp <- read.csv("volcanoPlotData.csv")
#预览数据；
head(exp)
dim(exp)

# 数据过滤
library(dplyr)
# 根据平均表达量对表格进行降序排列；
# arrange()R用于在列名作为传递给函数的表达式的帮助下对表行进行重新排序。
expr <- arrange(exp,desc(AveExpr))

# 有些数据集有重复的行，用以下代码删除
# %>% 函数封装在dplyr包中，将前一个函数运行结果作为下一个函数的第一个参数输入进去，为管道符（和linux的 | 用法类似）
# expr2 <- expr %>% distinct(Gene, .keep_all = TRUE)


#载入绘图相关的R包；
library(ggplot2)
library(ggrepel)

#转成tibble便于后续使用，去掉不需要的列；
dt <- as_tibble(expr[c(1,2,5)])
#对p值取对数；
dt$log10PValue <- -log10(dt$P.Value)
#生成显著上下调数据的分组标签；
dt$group <- case_when(dt$logFC > 1 & dt$P.Value < 0.05 ~ "Up",
                      dt$logFC < -1 & dt$P.Value < 0.05 ~ "Down",
                      abs(dt$logFC) <= 1 ~ "None",
                      dt$P.Value >= 0.05 ~ "None")
head(dt)

# 根据上调下调的基因数量调整阈值
#重新设置阈值（logFC=1.5），生成显著上下调数据的分组标签；
dt$group2 <- case_when(dt$logFC > 1.5 & dt$P.Value < 0.05 ~ "Up",
                       dt$logFC < -1.5 & dt$P.Value < 0.05 ~ "Down",
                       abs(dt$logFC) <= 1.5 ~ "None",
                       dt$P.Value >= 0.05 ~ "None")
#提取上下调基因；
Up <- filter(dt,group=="Up")
up_genes <- Up$Gene
Down <- filter(dt,group=="Down")
down_genes <- Down$Gene
#确定上下调基因数量；
paste0("The number of up gene is ",length(up_genes))
paste0("The number of down gene is ",length(down_genes))

# 获取表达差异最显著的10个基因；
# distinct仅从数据框中选择唯一/不同的行。keep_all : 如果为TRUE，则保留所有变量。
# top_n，与top_frac相似，选择最大的n个rows.如果是负数，则相反。
top10sig <- filter(dt,group!="None") %>% distinct(Gene,.keep_all = T) %>% top_n(10,abs(logFC))

# 将差异表达Top10的基因表格拆分成up和down两部分；
up <- filter(top10sig,group=="Up")
down <- filter(top10sig,group=="Down")

# 新增一列，将Top10的差异基因标记为2，其他的标记为1；
# %in%判断前一个参数是否在后一个参数里面，返回布尔值
dt$size <- case_when(!(dt$Gene %in% top10sig$Gene)~ 1,
                     dt$Gene %in% top10sig$Gene ~ 2)
head(dt)

#提取非Top10的基因表格；
df <- filter(dt,size==1)

#指定绘图顺序,将group列转成因子型；
# factor用于存储不同类别的数据类型，例如人的性别有男和女两个类别，年龄来分可以有未成年人和成年人。
df$group <- factor(df$group,
                   levels = c("Up","Down","None"),
                   ordered = T)

#开始绘图，建立映射；
# aes配合ggplot()使用，告诉ggplot()谁是x谁是y，啥颜色
p0 <-ggplot(data=df,aes(logFC,log10PValue,color=group))
p0
dev.off()
#添加散点；
p1 <- p0+geom_point(size=1)
p1
dev.off()

# 自定义半透明颜色（红绿）
# #FF9999为红色，#99CC00为绿色
mycolor <- c("#FF9999","#99CC00","gray80")
# name: The name of the scale. Used as the axis or legend title.
p2 <- p1 + scale_colour_manual(name="",values=alpha(mycolor,0.9))
p2
dev.off()

# 继续添加Top10基因对应的点；
p3 <- p2+geom_point(data=up,aes(logFC,log10PValue),
                    color="#FF9999",size=2,alpha=0.9)+
  geom_point(data=down,aes(logFC,log10PValue),
             color="#7cae00",size=2,alpha=0.9)
p3
dev.off()

# expansion函数设置坐标轴范围两端空白区域的大小；mult为“倍数”模式，add为“加性”模式；
p4<-p3+labs(y="-log10 P Value",x="log2FC")+
  scale_y_continuous(expand=expansion(add = c(0.5, 0)),
                     limits = c(0, 45),
                     breaks = c(0,10,20,30,40),
                     label = c("0","10","20","30","40"))+
  scale_x_continuous(limits = c(-5, 4),
                     breaks = c(-4,-3,-2,0,1,2,3),
                     label = c('-4','-3','-2','0','1','2','3'))
p4
dev.off()

# 添加箭头；
# 离得远的才有箭头
set.seed(007)
p5 <- p4+geom_text_repel(data=top10sig,aes(logFC,log10PValue,label=Gene),
                         force=w0,color="grey20",
                         size=2, # 字体大小
                         point.padding = 0.5,
                         hjust = 0.5,
                         arrow = arrow(length = unit(0.01, "npc"),
                                       type = "open", ends = "last"), # ends为箭头方向
                         segment.color="grey20", # 箭头颜色
                         segment.size=0.2,
                         segment.alpha=0.8,
                         nudge_x=0,
                         nudge_y=0)
p5
dev.off()

#自定义图表主题，对图表做精细调整；
top.mar=0.2
right.mar=0.2
bottom.mar=0.2
left.mar=0.2
#隐藏纵轴，并对字体样式、坐标轴的粗细、颜色、刻度长度进行限定；
mytheme<-theme_classic()+
  theme(text=element_text(family = "sans",colour ="gray30",size = 10),
        axis.line = element_line(size = 0.6,colour = "gray30"),
        axis.ticks = element_line(size = 0.6,colour = "gray30"),
        axis.ticks.length = unit(1.5,units = "mm"),
        plot.margin=unit(x=c(top.mar,right.mar,bottom.mar,left.mar),
                         units="inches"))
#应用自定义主题；
p5+mytheme
dev.off()

#添加辅助线；
p6 <- p4+geom_hline(yintercept = c(-log10(0.05)),
                    size = 0.5,
                    color = "orange",
                    lty = "dashed")+
  geom_vline(xintercept = c(-1,1),
             size = 0.5,
             color = "orange",
             lty = "dashed")
p6
dev.off()

#添加其他样式的标签；
#为了方便自定义左右区域的标签，这里使用up、down两个独立的子表格；
# nudge_x/y:数据点与相应数据标签的距离
# direction:标签分布方向，x表水平分布，y 表示垂直分布，both 表示随机分布；
# point.padding:表示点周围的空余区域，决定连接线端点到到数据点中心的距离，单位为line。
p7 <- p6+geom_label_repel(
  data = up,aes(logFC,log10PValue,label=Gene),
  nudge_x = 3,
  nudge_y = -0.8,
  color = "white",
  alpha = 0.9,
  point.padding = 0.5,
  size = 2.5,
  fill = "#96C93D",
  segment.size = 0.5,
  segment.color = "grey50",
  direction = "y",
  hjust = 0.5) +
  geom_label_repel(
    data = down,aes(logFC,log10PValue,label=Gene),
    nudge_x = -3,
    nudge_y = 0.2,
    color = "white",
    alpha = 0.9,
    point.padding = 0.5,
    size = 2.5,
    fill = "#9881F5",
    segment.size = 0.5,
    segment.color = "grey50",
    direction = "y",
    hjust = 0.5)
#应用自定义主题；
p8 <- p7+mytheme
p8
dev.off()


