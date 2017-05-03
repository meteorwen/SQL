library(RODBC)
library(xlsx)
library(XLConnect)
library(lubridate) #计算年龄year包
# odbcDataSources() #查看可用数据源
user <- "user01"  #管理员用户名：sa，平时用 user01
pw <- "123456" #管理员登录的密码： sxsh2013#8516 ，平时用 123456
bs07 <- "mytest"
days <- 7
dt1 <- format(Sys.Date(),format="%Y/%m/%d")
dt <- '2016/7/1'
dt2 <- format(Sys.Date()-60,format="%Y/%m/%d")
# mytest是win10中ODBC内部设置到bs07 这个库，
#今后涉及到经纬度需要用bs07Position库，需要修改win10的ODBC连接

connect <- odbcConnect(bs07, uid = user, pwd = pw )
sql <- sqlQuery(connect,paste('SELECT * FROM bs07.dbo.G_GOODS_INFO where OPERATE_TIME between',
                              sprintf('\'%s\'', dt2),
                              'and',
                              sprintf('\'%s\'', dt1),
                              sep = ' '))
#
age <- sqlQuery(connect,"select customer_name,
datediff(year,convert(smalldatetime,substring(CUSTOMER_ID_CARD,7,8)),getdate()) as Age,
convert(smalldatetime,substring(CUSTOMER_ID_CARD,7,8)) as Birthday,
case when len(CUSTOMER_ID_CARD) = 18 and cast(substring(CUSTOMER_ID_CARD,17,1) as int) % 2 = 0 then '女' 
when len(CUSTOMER_ID_CARD) = 18 and cast(substring(CUSTOMER_ID_CARD,17,1) as int) % 2 = 1 then '男'else null end  as sex
                from bs07.dbo.C_CUSTOMER_INFORMATION where CUSTOMER_CERTIFICATE_TYPE = '身份证' and LEN(CUSTOMER_ID_CARD) = 18")
cut(age$Age, breaks = c(25,30,35,40,45,50,55,60,65,70)) 
summary(cut(age$Age, breaks = c(20,25,30,35,40,45,50,55,60,65,70,100)))#分区间统计
sort(age$Age) #排序

#有问题sql语句
user <- sqlQuery(connect,"SELECT CUSTOMER_ID, CUSTOMER_NAME,
datediff(year,convert(smalldatetime,substring(CUSTOMER_ID_CARD,7,8)),getdate()) as Age,
convert(smalldatetime,substring(CUSTOMER_ID_CARD,7,8)) as Birthday,
                 case when len(CUSTOMER_ID_CARD) = 18 and cast(substring(CUSTOMER_ID_CARD,17,1) as int) % 2 = 0 then '女' 
                 when len(CUSTOMER_ID_CARD) = 18 and cast(substring(CUSTOMER_ID_CARD,17,1) as int) % 2 = 1 then '男'else null end  as sex,
CUSTOMER_ID_CARD,CUSTOMER_PHONE
FROM bs07.dbo.C_CUSTOMER_INFORMATION 
                where CUSTOMER_ID in (select distinct(CUSTOMER_ID) from bs07.dbo.R_RV_BOOK_INFORMATION where RV_ID is not NULL)")

user1 <- sqlQuery(connect,"SELECT CUSTOMER_ID, CUSTOMER_NAME,CUSTOMER_ID_CARD,CUSTOMER_PHONE,CUSTOMER_SEX,CUSTOMER_BIRTHDAY 
FROM bs07.dbo.C_CUSTOMER_INFORMATION
                  where CUSTOMER_ID in (select distinct(CUSTOMER_ID) from bs07.dbo.R_RV_BOOK_INFORMATION where RV_ID is not NULL)
                  and CUSTOMER_CERTIFICATE_TYPE = '身份证'")
birthday <- substr(user1$CUSTOMER_ID_CARD,7,14)
birthday <- as.Date(as.character(birthday),"%Y%m%d")
age <- year(Sys.Date())-year(birthday)
rting <- sort(table(age), decreasing = T) #table 统计出现次数的sort排序
summary(cut(age, breaks = c(20,25,30,35,40,45,50,55,60,65,70,100)))
sex <- substr(user1$CUSTOMER_ID_CARD,17,17)
sex <- as.numeric(sex)
sex1 <- NULL
for (i in 1:length(sex)){
  if(sex[i]%%2 == 0){
    sex1[i] <- "女"
  }else{
    sex1[i] <- "男"
  }
}
sex1
user_total <- data.frame(id = user1$CUSTOMER_ID,name = user1$CUSTOMER_NAME,age= age,sex=sex1)
Z

#按年龄段划分租车用户个数：
sum_age <- summary(cut(user$Age, breaks = c(20,25,30,35,40,45,50,55,60,65,70,100)))#分区间统计
#车次计算



odbcClose(channel) # 关闭连接

conn <- loadWorkbook('C:/report/report.xlsx',create=TRUE) 
createSheet(conn,name='report')
writeWorksheet(conn,user1,'report',startRow=1,startCol=2,header=TRUE)
saveWorkbook(conn)






