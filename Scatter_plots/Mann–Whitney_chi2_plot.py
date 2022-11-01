import pandas as pd
import scipy.stats as stats
import matplotlib.pyplot as plt

'''
数据分析
目的：
① 计算阳性率，数值大于0.001的为阳性
② Mann–Whitney test分析
③ Chi-square分析
'''

filename1 = 'Mann–Whitney_chi2.xlsx'

# 读取Excel文件，sheet_name不指定时默认返回全表数据，如果需要返回多个表，可以将sheet_name指定为一个列表，例如['sheet1', 'sheet2']
df1 = pd.read_excel(filename1, sheet_name='Sheet1')

# 切片查看control数据
# print(df1.iloc[:, 0])
# print(df1['Control'])
# 选取非NaN数据
# print(df1[pd.notnull(df1['Control'])]['Control'])

# 获得样本名
TotalSample = df1.columns.tolist()
columName = df1.columns.tolist()
# 去除对照组
columName.remove('Control')

Control = df1[pd.notnull(df1['Control'])]['Control']

# Mann–Whitney test
MWTPValue = []
for i in columName:
    a = df1[pd.notnull(df1[i])][i]
    b = stats.mannwhitneyu(Control, a,
                           alternative='two-sided',
                           use_continuity=True)
    # print(i, ':', b.pvalue)
    MWTPValue.append(b.pvalue)

# 阳性率的分析
InfectionRatio = []
for i in TotalSample:
    SampleCounts = df1[pd.notnull(df1[i])][i].count()
    Positive = df1.loc[df1[i] > 0.001, i].count()
    Ratio = Positive/SampleCounts * 100
    # print(i, ':', Ratio)
    InfectionRatio.append(Ratio)

# Chi-Square
ChiSquarePValue = []

ControlCounts = Control.count()
ControlPositiveCounts = df1.loc[df1['Control'] > 0.001, 'Control'].count()
ControlNegativeCounts = ControlCounts-ControlPositiveCounts

for i in TotalSample:
    SampleCounts = df1[pd.notnull(df1[i])][i].count()
    PositiveCounts = df1.loc[df1[i] > 0.001, i].count()
    NegativeCounts = SampleCounts-PositiveCounts

    table = [[ControlPositiveCounts, ControlNegativeCounts], [PositiveCounts, NegativeCounts]]
    # 输出为stat卡方统计值，p：P_value，dof 自由度，expected理论频率分布
    a = stats.chi2_contingency(table)
    ChiSquarePValue.append(a[1])
    if a[1] < 0.05:
        print(i, ':', a[1])


Median = df1.median().tolist()
Size = df1.count().tolist()

# 数据可视化
plt.style.use('ggplot')

colors = []
area = []
for i in Size:
    a = i * 10
    area.append(a)

plt.scatter(InfectionRatio, Median, s=area, c=ChiSquarePValue, marker='o', cmap='rainbow', alpha=0.5)
plt.title("title", fontsize=20)
plt.xlabel('xlabel', fontsize=20)
plt.ylabel('ylabel', fontsize=20)
plt.colorbar().ax.set_title('Chi-Square P value', fontsize=15)
plt.xlim((0, 100))
# plt.ylim((0, 0.0001))

for i in range(len(TotalSample)):
    if TotalSample[i] == 'Control':
        plt.annotate(TotalSample[i], xy=(InfectionRatio[i], Median[i]), fontsize=15)

plt.show()


