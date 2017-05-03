
/*
SELECT INTO FROM语句
      语句形式为：SELECT vale1, value2 into Table2 from Table1
      要求目标表Table2不存在，因为在插入时会自动创建表Table2，并将Table1中指定字段数据复制到Table2中。
 */

SELECT
	CUSTOMER_ID,
	CUSTOMER_NAME,
	CUSTOMER_TYPE,
	CUSTOMER_CERTIFICATE_TYPE,
	CUSTOMER_ID_CARD,
	CUSTOMER_PHONE,
	COMPANY_ADDRESS,
	OPERATE_TIME AS 'regist_time' INTO C_CUSTOMER_INFORMATION
FROM bs07.dbo.C_CUSTOMER_INFORMATION
order by regist_time DESC
--提取日新增用户数量
/* 
INSERT INTO SELECT语句
      语句形式为：Insert into Table2(field1,field2,...) select value1,value2,... from Table1
      要求目标表Table2必须存在，由于目标表Table2已经存在，所以除了插入源表Table1的字段外，还可以插入常量。
*/
--删除库名
create database [07_ETL]
drop database [07_ETL]
--删除表格
DROP TABLE dbo.c_customer_information 
/* 
NOT NULL 约束强制列不接受 NULL 值。
NOT NULL 约束强制字段始终包含值。这意味着，如果不向字段添加值，就无法插入新记录或者更新记录。
*/

--c_customer_information表后再插入一列DateOfBirth（date类型）
ALTER TABLE c_customer_information ADD DateOfBirth date

--删除该表所有数据(你删除的时候会提示你，有默认约束依赖该字段，那么你需要先删除默认约束（错误提示里会有默认约束名），再删除字段：)
ALTER TABLE  表名 DROP CONSTRAINT  默认约束名
GO
ALTER TABLE  表名 DROP COLUMN 字段名
GO
ALTER TABLE c_customer_information DROP COLUMN DateOfBirth

ALTER TABLE [b_temp] ADD [时间戳] timestamp NULL 
GO

--完整的创建一个表格的方式：举例子说明。

CREATE TABLE `fs_server` (
  `id` int(11) NOT NULL auto_increment,
  `server_id` int(11) NOT NULL,
  `state` varchar(64) NOT NULL,
  `check_time` timestamp NOT NULL default CURRENT_TIMESTAMP,
  PRIMARY KEY  (`id`)
)

--如果不添加 PRIMARY KEY (`id`)，则会导致报错，需要添加一个关于主键的语句。



##########################################################################################################
#
#
SELECT
a.BOOK_RV_NO,--订单号
a.RENT_START_TIME,--下单租车时间
a.RENT_END_TIME,--下单还车时间
a.RV_MODELS_ID,--租车类型
b.CUSTOMER_NAME,--租车人姓名
b.CUSTOMER_TYPE,
b.CUSTOMER_PHONE,--租车人电话
c.DICTIONARYNAME,--订单状态
d.RV_CHECK_NOTES,--检查结果
f.START_TIME,--维养开始时间
f.MAINTAIN_STATE,--维养状态
g.SETTLEMENT_DATE,--结算时间
g.OPERATER,--操作员
CONVERT (CHAR (30),h.ac_get_rv,121) as ac_get_rv,-- as '实际取车日期',
CONVERT (CHAR (30),h.ac_send_rv,121) as ac_send_rv ,-- as '实际还车日期',
h.rent_days,-- as '租车天数',
ISNULL(g.AC_RV_RENT_MONEY,0) as AC_RV_RENT_MONEY,-- AS '应收租金',
ISNULL(g.AC_DISCOUNT_MONEY,0) as AC_DISCOUNT_MONEY,-- AS '折扣金',
ISNULL(AC_RV_RENT_MONEY-AC_DISCOUNT_MONEY,0) as AC_RENT_REVENUE,
ISNULL(g.MAINTENANCE_COSTS,0) as MAINTENANCE_COSTS,--  AS '维修费用' ,
ISNULL(g.AC_DRIVE_RV_MONEY,0) as AC_DRIVE_RV_MONEY,-- AS '代驾费用',
ISNULL(g.AC_SEND_RV_MONEY,0) as AC_SEND_RV_MONEY,-- AS '还车节假日费用',
ISNULL(g.AC_TAKE_RV_MONEY,0) as AC_TAKE_RV_MONEY,-- AS '取车节假日费用',
ISNULL(g.AC_SERVICE_FEE,0) as AC_SERVICE_FEE,--  AS '服务费' ,
ISNULL(g.AC_GOODS_RENT_MONEY,0) as AC_GOODS_RENT_MONEY,-- AS '租赁物品费用',
ISNULL(g.AC_GOODS_SALE_MONEY,0) as AC_GOODS_SALE_MONEY,--  AS '购买物品费用',
ISNULL(g.AC_OTHER_REVENUE_MONEY,0) as AC_OTHER_REVENUE_MONEY,-- AS '其他收入' ,
i.REFUND_DATE,
ISNULL(i.REFUND_MONEY,0) as REFUND_MONEY,--as '退款金额',
i.REFUND_REASON --as '退款原因'
FROM
  bs07.dbo.R_RV_BOOK_INFORMATION AS a
JOIN (
SELECT * FROM bs07.dbo.C_CUSTOMER_INFORMATION ) as b
on a.CUSTOMER_ID = b.CUSTOMER_ID
JOIN (
SELECT DICTIONARYVALUE,DICTIONARYNAME 
from bs07.dbo.SYS_DICTIONARY where CATALOGID = '03') as c 
on a.STATE = c.DICTIONARYVALUE
JOIN (
SELECT * from bs07.dbo.R_RV_BACK_INFORMATION
 where rv_is_back = '还车后') as d
ON a.BOOK_RV_NO =d.RENT_RV_ID
JOIN (
SELECT * FROM bs07.dbo.M_RV_MAINTAIN_MANAGEMENT) as f
on a.BOOK_RV_NO = f.BOOK_RV_ID
JOIN (
SELECT * FROM bs07.dbo.F_SETTLEMENT_MANAGEMENT) as g
on a.BOOK_RV_NO = g.BOOK_RV_NO
join (
SELECT
m.rent_rv_id, --AS '租赁单号' ,
m.rv_check_time AS ac_get_rv,
n.rv_check_time AS ac_send_rv,
datediff(DAY,m.RV_CHECK_TIME,n.RV_CHECK_TIME) AS rent_days
FROM
 (SELECT
      RENT_RV_ID,
      RV_CHECK_TIME
    FROM
      bs07.dbo.R_RV_BACK_INFORMATION where RV_IS_BACK = '还车前'
  ) AS m 
JOIN (
SELECT RENT_RV_ID, RV_CHECK_TIME
  FROM bs07.dbo.R_RV_BACK_INFORMATION
  WHERE RV_IS_BACK = '还车后') AS n  
ON m.RENT_RV_ID = n.RENT_RV_ID 
WHERE
  m.RV_CHECK_TIME BETWEEN '2016-01-01'
AND CONVERT (CHAR (10),getdate(),120)) as h 
on a.BOOK_RV_NO = h.rent_rv_id
JOIN (
SELECT RENT_RV_ID,REFUND_DATE,REFUND_MONEY,REFUND_REASON
FROM  bs07.dbo.F_REFUND_MANAGEMENT) as i 
on a.BOOK_RV_NO = i.RENT_RV_ID
where a.STATE in (0,3,4,5,6,7,8)
ORDER BY a.BOOK_RV_NO DESC
#################################################################################
#复写
DROP TABLE [07reports].dbo.dq_sent_detail


CREATE TABLE [07reports].dbo.dq_sent_detail(
  id int identity(1,1) not null,
  times_tamp datetime default (getdate()),
  BOOK_RV_NO varchar(36),
  RENT_START_TIME varchar(36),
  RENT_END_TIME varchar(36),
  ac_get_rv varchar(36),
  ac_send_rv varchar(36),
  BOOK_NOTE varchar(100) ,
  CUSTOMER_NAME varchar(36),
  CUSTOMER_TYPE varchar(36),
  CUSTOMER_PHONE varchar(36),
  RV_MODELS_ID varchar(36),
  DICTIONARYNAME varchar(36),
  rent_days varchar(36),
  RV_CHECK_NOTES varchar(36),
  MAINTAIN_STATE varchar(36),
  VIOLATION_DESCRIPTION varchar(36),
  VIOLATION_STATE varchar(36),
  SETTLEMENT_DATE varchar(36),
  OPERATER varchar(36),
  MAINTENANCE_COSTS varchar(36),
  AC_RV_RENT_MONEY varchar(36) ,
  AC_DISCOUNT_MONEY varchar(36),
  AC_RENT_REVENUE varchar(36),
  AC_DRIVE_RV_MONEY varchar(36),
  AC_SEND_RV_MONEY varchar(36),
  AC_TAKE_RV_MONEY varchar(36),
  AC_SERVICE_FEE varchar(36),
  AC_GOODS_RENT_MONEY varchar(36),
  AC_GOODS_SALE_MONEY varchar(36),
  AC_OTHER_REVENUE_MONEY varchar(36),
  REFUND_DATE varchar(36),
  REFUND_MONEY varchar(36),
  REFUND_REASON varchar(36), 
  primary key (id)
  )
GO

Truncate Table [07reports].dbo.dq_sent_detail --清空该表 id从1开始，而用delete id顺序继续之前的添加

insert into [07reports].dbo.dq_sent_detail
(BOOK_RV_NO,
  RENT_START_TIME,
  RENT_END_TIME,
  ac_get_rv,
  ac_send_rv,
  BOOK_NOTE,
  CUSTOMER_NAME,
  CUSTOMER_TYPE,
  CUSTOMER_PHONE,
  RV_MODELS_ID,
  DICTIONARYNAME,
  rent_days,
  RV_CHECK_NOTES,
  MAINTAIN_STATE,
  VIOLATION_DESCRIPTION,
  VIOLATION_STATE,
  SETTLEMENT_DATE,
  OPERATER,
  MAINTENANCE_COSTS,
  AC_RV_RENT_MONEY,
  AC_DISCOUNT_MONEY,
  AC_RENT_REVENUE,
  AC_DRIVE_RV_MONEY,
  AC_SEND_RV_MONEY,
  AC_TAKE_RV_MONEY,
  AC_SERVICE_FEE,
  AC_GOODS_RENT_MONEY,
  AC_GOODS_SALE_MONEY,
  AC_OTHER_REVENUE_MONEY,
  REFUND_DATE,
  REFUND_MONEY,
  REFUND_REASON)
SELECT
  a.BOOK_RV_NO,
  CONVERT (CHAR (30),a.RENT_START_TIME,121) as RENT_START_TIME,
  CONVERT (CHAR (30),a.RENT_END_TIME,121) as RENT_END_TIME,
  CONVERT (CHAR (30),d.ac_get_rv,121) as ac_get_rv,
  CONVERT (CHAR (30),d.ac_send_rv,121) as ac_send_rv,
  a.BOOK_NOTE,
  b.CUSTOMER_NAME,
  b.CUSTOMER_TYPE,
  b.CUSTOMER_PHONE,
  a.RV_MODELS_ID,
  c.DICTIONARYNAME,
  d.rent_days,
  d.RV_CHECK_NOTES, --还车后车况
  e.MAINTAIN_STATE,
  f.VIOLATION_DESCRIPTION,
  f.VIOLATION_STATE,
  CONVERT (CHAR (30),g.SETTLEMENT_DATE,121) as SETTLEMENT_DATE,
  g.OPERATER,
  g.MAINTENANCE_COSTS,
  g.AC_RV_RENT_MONEY,
  g.AC_DISCOUNT_MONEY,
  (g.AC_RV_RENT_MONEY-g.AC_DISCOUNT_MONEY) as AC_RENT_REVENUE,
  g.AC_DRIVE_RV_MONEY,
  g.AC_SEND_RV_MONEY,
  g.AC_TAKE_RV_MONEY,
  g.AC_SERVICE_FEE,
  g.AC_GOODS_RENT_MONEY,
  g.AC_GOODS_SALE_MONEY,
  g.AC_OTHER_REVENUE_MONEY,
  CONVERT (CHAR (30),h.REFUND_DATE,121) as REFUND_DATE,
  h.REFUND_MONEY, --as '退款金额',
  h.REFUND_REASON --as '退款原因'
FROM  bs07.dbo.R_RV_BOOK_INFORMATION as a 
LEFT join(
SELECT * FROM bs07.dbo.C_CUSTOMER_INFORMATION ) as b
on a.CUSTOMER_ID = b.CUSTOMER_ID
LEFT JOIN (
SELECT DICTIONARYVALUE,DICTIONARYNAME 
from bs07.dbo.SYS_DICTIONARY where CATALOGID = '03') as c 
on a.STATE = c.DICTIONARYVALUE
LEFT join (
SELECT m.rent_rv_id,m.rv_check_time AS ac_get_rv,n.rv_check_time AS ac_send_rv,
datediff(DAY,m.RV_CHECK_TIME,n.RV_CHECK_TIME) AS rent_days,n.RV_CHECK_NOTES
FROM
 (SELECT RENT_RV_ID,RV_CHECK_TIME  FROM
      bs07.dbo.R_RV_BACK_INFORMATION where RV_IS_BACK = '还车前') AS m 
JOIN (SELECT RENT_RV_ID, RV_CHECK_TIME,RV_CHECK_NOTES FROM bs07.dbo.R_RV_BACK_INFORMATION
  WHERE RV_IS_BACK = '还车后') AS n  
ON m.RENT_RV_ID = n.RENT_RV_ID) as d
on a.BOOK_RV_NO = d.rent_rv_id
LEFT JOIN (
SELECT * FROM bs07.dbo.M_RV_MAINTAIN_MANAGEMENT) as e
on a.BOOK_RV_NO = e.BOOK_RV_ID
LEFT JOIN(
SELECT * from bs07.dbo.R_VIOLATION_CHECK) as f
on a.BOOK_RV_NO = f.BOOK_RV_NO
LEFT JOIN (
SELECT * FROM bs07.dbo.F_SETTLEMENT_MANAGEMENT)as g
ON a.BOOK_RV_NO = g.BOOK_RV_NO
LEFT JOIN (
SELECT RENT_RV_ID,REFUND_DATE,REFUND_MONEY,REFUND_REASON
FROM  bs07.dbo.F_REFUND_MANAGEMENT) as h 
on a.BOOK_RV_NO = h.RENT_RV_ID
where a.STATE in (0,3,4,5,6,7,8)
ORDER BY a.BOOK_RV_NO DESC 








--按照省份创建日新增表
CREATE TABLE car_province_daily_qty (
id int identity(1,1) not null,
date varchar(36) NOT NULL,
City varchar(36) NOT NULL,
Qty varchar(36) NOT NULL,
times_tamp datetime default (getdate()),
primary key (id)
)
--插入当天的日新增数据
INSERT INTO [07Reports].dbo.car_province_daily_qty (DATE, City, Qty)
SELECT
  CONVERT (CHAR(10), getdate() - 1, 120) AS DATE,
  b.lbname AS City,
  COUNT (*) AS Qty
FROM
  CarReg.dbo.Main AS a
JOIN (
  SELECT
    *
  FROM
    CarReg.dbo.CityTable
) AS b ON a.m_LicNum = b.lbcode
GROUP BY
  b.lbname

--插入夸服务器的日新增数据
INSERT INTO [07Reports].dbo.car_province_daily_qty (DATE, City, Qty)
select date,City,Qty from OPENDATASOURCE( 
'SQLOLEDB', 
'Data Source=10.10.1.19;User ID=user01;Password=123456' 
).[07reports].dbo.carreg_province_daily_qty 

-----

Truncate Table [07reports].dbo.car_province_daily_qty 
INSERT INTO [07Reports].dbo.car_province_daily_qty (DATE, City, Qty)
select date,City,Qty from OPENDATASOURCE( 
'SQLOLEDB', 
'Data Source=10.10.1.19;User ID=user01;Password=123456' 
).[07reports].dbo.carreg_province_daily_qty 

--给已有字段添加主键
Alter table ChangeMemo Add  Constraint  PrimaryKey  Primary  Key (CM_ID)



########################################################################################
-- 触发器练习 ：test1 表 、 test2 表

CREATE TABLE [07Reports].dbo.test1(
id int identity(1,1) not null,--自增
date varchar(36) NOT NULL,
number decimal NOT NULL,
times_tamp datetime default (getdate()),--自增
primary key (id))

insert into [07Reports].dbo.test1(date,number) 
SELECT CONVERT(char(19),GETDATE(),120)as date ,count(*) as number FROM CarReg.dbo.Main 
--创建测试表2
CREATE TABLE [07Reports].dbo.test2(
id int identity(1,1) not null,--自增
n decimal NOT NULL,
times_tamp datetime default (getdate()),--自增
primary key (id))
#######################################################################################
#
--触发器  当test1 插入数据 test2 即开始统计test1 总数
CREATE TRIGGER trigger_sum
ON test1
FOR INSERT
AS
declare @n int --声明变量n 是int型
select @n = (SELECT count(*) as n FROM test1) from inserted --inserted临时表，这里是赋值给n
insert INTO test2(n) VALUES(@n) --其中id和times_stamp是自增数据 在test2中无需体现
GO

--询该表table已有触发器的表
select name 表格名称 from sysobjects where xtype='TR' 
select name 表格名称 from sysobjects where xtype='U'  AND id in(select parent_obj from sysobjects where xtype='TR')------查询有触发器的表

select name 表格名称 from sysobjects where xtype='U'  AND id NOT in(select parent_obj from sysobjects where xtype='TR')------查询没有触发器的表



#################################################################################

/*   添加注释
EXECUTE sp_addextendedproperty 
N'id自增',
N'精确到秒',
N'float:浮点型，含字节数为4，32bit，数值范围为-3.4E38~3.4E38（7个有效位）
double:双精度实型，含字节数为8，64bit数值范围-1.7E308~1.7E308（15个有效位）
decimal:数字型，128bit，不存在精度损失，常用于银行帐目计算。（28个有效位）',
N'时间戳'


EXECUTE sp_addextendedproperty 
N'id自增',
N'精确到秒',
N'float:浮点型，含字节数为4，32bit，数值范围为-3.4E38~3.4E38（7个有效位）
double:双精度实型，含字节数为8，64bit数值范围-1.7E308~1.7E308（15个有效位）
decimal:数字型，128bit，不存在精度损失，常用于银行帐目计算。（28个有效位）',
N'时间戳'

EXEC sys.sp_addextendedproperty 
 @id = N'id自增',
 @date = N'精确到秒',
 @number = N'float:浮点型，含字节数为4，32bit，数值范围为-3.4E38~3.4E38（7个有效位）
double:双精度实型，含字节数为8，64bit数值范围-1.7E308~1.7E308（15个有效位）
decimal:数字型，128bit，不存在精度损失，常用于银行帐目计算。（28个有效位）' ,
 @times_tamp= N'时间戳'
go


comment on table date  is '精确到秒';
comment on table date  is 'float:浮点型，含字节数为4，32bit，数值范围为-3.4E38~3.4E38（7个有效位）
double:双精度实型，含字节数为8，64bit数值范围-1.7E308~1.7E308（15个有效位）
decimal:数字型，128bit，不存在精度损失，常用于银行帐目计算。（28个有效位）';
*/



#################################################################################

CREATE TABLE [07reports].dbo.car_main_new (
m_id varchar(255) NOT NULL,
m_Company varchar(255),
TIMESTAMP datetime default (getdate()),
primary key (m_id))

CREATE TRIGGER main_newuser
ON CarReg.dbo.Main
FOR INSERT
AS
declare @m_id varchar(255)
declare @m_Company  varchar(255)
select @m_id=m_id,@m_Company=m_Company from inserted--inserted临时表，这里是赋值给n
insert INTO [07reports].dbo.car_main_new(m_id,m_Company) VALUES(@m_id,@m_Company) --其中id和times_stamp是自增数据 在test2中无需体现
GO


#
#
DROP TABLE [07reports].dbo.car_main_new
CREATE TABLE [07reports].dbo.car_main_new (
id int identity(1,1) not null
m_id varchar(255) NOT NULL,
m_Company varchar(255),
m_LicNum  varchar(255),
m_RegNum  varchar(255),
m_Date  varchar(255),
m_JZ  varchar(255),
m_YL  varchar(255),
m_CH  varchar(255),
m_CJH varchar(255),
m_StartTime varchar(255),
m_EndTime varchar(255),
m_Flag  int,
m_CompanyCode varchar(255),
m_Checker varchar(255),
m_IsPrint varchar(255),
m_YS  int,
m_CompanyNum  varchar(255),
m_PrintFlag int,
M_Reg varchar(255),
m_linkman varchar(255),
m_linktel varchar(255),
m_bottleID  varchar(255),
m_makecompany varchar(255),
m_installCompany  varchar(255),
m_checkDate varchar(255),
m_newData int,
m_ifflag  int,
m_PrintDate varchar(255),
m_media varchar(255),
m_checkCode varchar(255),
m_ReportCode varchar(255),  
m_ifupload  int,
m_state int,
m_CardFlag  int,
m_RegAdd  varchar(255),
m_ReportCompany varchar(255),
TIMESTAMP datetime default (getdate()),
primary key (m_id)
)

use CarReg
go
CREATE TRIGGER main_newuser_t
ON CarReg.dbo.Main
FOR INSERT
AS
declare @m_id varchar(255)
declare @m_Company  varchar(255)
declare @m_LicNum varchar(255)
declare @m_RegNum varchar(255)
declare @m_Date varchar(255)
declare @m_JZ varchar(255)
declare @m_YL varchar(255)
declare @m_CH varchar(255)
declare @m_CJH  varchar(255)
declare @m_StartTime  varchar(255)
declare @m_EndTime  varchar(255)
declare @m_Flag int
declare @m_CompanyCode  varchar(255)
declare @m_Checker  varchar(255)
declare @m_IsPrint  varchar(255)
declare @m_YS int
declare @m_CompanyNum varchar(255)
declare @m_PrintFlag  int
declare @M_Reg  varchar(255)
declare @m_linkman  varchar(255)
declare @m_linktel  varchar(255)
declare @m_bottleID varchar(255)
declare @m_makecompany  varchar(255)
declare @m_installCompany varchar(255)
declare @m_checkDate  varchar(255)
declare @m_newData  int
declare @m_ifflag int
declare @m_PrintDate  varchar(255)
declare @m_media  varchar(255)
declare @m_checkCode  varchar(255)
declare @m_ReportCode varchar(255)
declare @m_ifupload int
declare @m_state  int
declare @m_CardFlag int
declare @m_RegAdd varchar(255)
declare @m_ReportCompany varchar(255)

select  
@m_id=m_id,
@m_Company=m_Company,
@m_LicNum=m_LicNum,
@m_RegNum=m_RegNum,
@m_Date=(SELECT convert(char(10),m_Date,120) as m_Date  from CarReg.dbo.Main),
@m_JZ =m_JZ,
@m_YL=m_YL,
@m_CH=m_CH,
@m_CJH=m_CJH,
@m_StartTime=(SELECT convert(char(10),m_StartTime,120) as m_StartTime from CarReg.dbo.Main),
@m_EndTime=m_EndTime,
@m_Flag=m_Flag,
@m_CompanyCode=m_CompanyCode,
@m_Checker=m_Checker,
@m_IsPrint=m_IsPrint,
@m_YS=m_YS,
@m_CompanyNum=m_CompanyNum,
@m_PrintFlag=m_PrintFlag,
@M_Reg=M_Reg,
@m_linkman=m_linkman,
@m_linktel=m_linktel,
@m_bottleID=m_bottleID,
@m_makecompany=m_makecompany,
@m_installCompany=m_installCompany,
@m_checkDate=m_checkDate,
@m_newData=m_newData,
@m_ifflag=m_ifflag,
@m_PrintDate=(SELECT convert(char(10),m_PrintDate,120) as m_PrintDate from CarReg.dbo.Main),
@m_media=m_media,
@m_checkCode=m_checkCode,
@m_ReportCode=m_ReportCode,
@m_ifupload=m_ifupload,
@m_state=m_state,
@m_CardFlag=m_CardFlag,
@m_RegAdd=m_RegAdd,
@m_ReportCompany=m_ReportCompany
from inserted
insert INTO [07reports].dbo.car_main_new_t(
m_id,
m_Company,
m_LicNum,
m_RegNum,
m_Date,
m_JZ,
m_YL,
m_CH,
m_CJH,
m_StartTime,
m_EndTime,
m_Flag,
m_CompanyCode,
m_Checker,
m_IsPrint,
m_YS,
m_CompanyNum,
m_PrintFlag,
M_Reg,
m_linkman,
m_linktel,
m_bottleID,
m_makecompany,
m_installCompany,
m_checkDate,
m_newData,
m_ifflag,
m_PrintDate,
m_media,
m_checkCode,
m_ReportCode,
m_ifupload,
m_state,
m_CardFlag,
m_RegAdd,
m_ReportCompany
) VALUES(
@m_id,
@m_Company,
@m_LicNum,
@m_RegNum,
@m_Date,
@m_JZ,
@m_YL,
@m_CH,
@m_CJH,
@m_StartTime,
@m_EndTime,
@m_Flag,
@m_CompanyCode,
@m_Checker,
@m_IsPrint,
@m_YS,
@m_CompanyNum,
@m_PrintFlag,
@M_Reg,
@m_linkman,
@m_linktel,
@m_bottleID,
@m_makecompany,
@m_installCompany,
@m_checkDate,
@m_newData,
@m_ifflag,
@m_PrintDate,
@m_media,
@m_checkCode,
@m_ReportCode,
@m_ifupload,
@m_state,
@m_CardFlag,
@m_RegAdd,
@m_ReportCompany
) 
GO


--去重ID
select * from  CarReg.dbo.SubMain 
where m_id in (select   m_id from    CarReg.dbo.SubMain  
group by   m_id having count (m_id) > 1)   --去重m_id，当大于1时
order by m_id


/*
主键的最大值问题 练习
SELECT count(*) FROM CarReg.dbo.main
SELECT COUNT(DISTINCT(m_id)) FROM CarReg.dbo.SubMain



SELECT a.* FROM  CarReg.dbo.SubMain as a 
INNER JOIN (SELECT m_id,max(sub_checkdate) as sub_checkdate FROM CarReg.dbo.SubMain
GROUP BY m_id) as b
on a.m_id = b.m_id and a.sub_checkdate = b.sub_checkdate

SELECT * FROM CarReg.dbo.SubMain where sub_checkdate in (
SELECT max(sub_checkdate) as sub_checkdate FROM CarReg.dbo.SubMain
GROUP BY m_id) and m_id in(SELECT a.m_id FROM (SELECT m_id,max(sub_checkdate) as sub_checkdate FROM CarReg.dbo.SubMain
GROUP BY m_id) as a )

SELECT b.Sub_ID from (
SELECT m_id,max(sub_checkdate) as sub_checkdate FROM CarReg.dbo.SubMain
GROUP BY m_id) as a 
LEFT JOIN (
SELECT * FROM CarReg.dbo.SubMain ) as b
on a.m_id = b.m_id and a.sub_checkdate = b.sub_checkdate
 */

UPDATE DQ001TEST.dbo.C_CUSTOMER_INFORMATION  
SET CUSTOMER_id_card  = a.CUSTOMER_id_card
FROM bs07.dbo.C_CUSTOMER_INFORMATION as a
WHERE [DQ001TEST].dbo.C_CUSTOMER_INFORMATION.CUSTOMER_id = a.CUSTOMER_id


























































































