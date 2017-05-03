--将C_CUSTOMER_INFORMATION用户表所需字段存储到 etl库中



--创建表和相应的字段和主键
drop table dbo.c_customer_information
create table dbo.c_customer_information(
	id int identity(1,1) not null,
customer_id varchar(36) NOT NULL,
	customer_name varchar(36),
	customer_type varchar(36),
	customer_certificate_tpye varchar(36),
	customer_id_card varchar(36),
	customer_phone varchar(36) ,
	company_address varchar(36) ,
	customer_regist_time varchar(36),
	times_tamp datetime default (getdate()),
	primary key (id)
	)
GO
--插入记录
insert into dbo.c_customer_information(CUSTOMER_ID,CUSTOMER_NAME,CUSTOMER_TYPE,
	CUSTOMER_CERTIFICATE_TYPE,
	CUSTOMER_ID_CARD,
	CUSTOMER_PHONE,
	COMPANY_ADDRESS,
	customer_regist_time)

select CUSTOMER_ID,
	CUSTOMER_NAME,
	CUSTOMER_TYPE,
	CUSTOMER_CERTIFICATE_TYPE,
	CUSTOMER_ID_CARD,
	CUSTOMER_PHONE,
	COMPANY_ADDRESS,
	CONVERT(char(30), OPERATE_TIME, 121) AS customer_regist_time
FROM bs07.dbo.C_CUSTOMER_INFORMATION
order by customer_regist_time DESC

--自动递增的两种方法：auto_increment，identity(1,1) 
DROP TABLE daily_new_user
create table dbo.daily_new_user(
id int identity(1,1) not null,
date varchar(36) NOT NULL,
new_add_user varchar(36) NOT NULL,
rent_user varchar(36) NOT NULL,
--TIMESTAMP,
times_tamp datetime default (getdate()),
primary key (id)
)
-------------------------------------------------------------------------
--昨日新增用户数
insert into [07Reports].dbo.daily_new_user(date,number) 
SELECT
	CONVERT (CHAR (10),getdate()-1,120) AS date,
	COUNT (*) AS number
FROM bs07.dbo.C_CUSTOMER_INFORMATION
WHERE OPERATE_TIME BETWEEN CONVERT (CHAR (10),getdate()-1,120)
AND CONVERT (CHAR (10),getdate(),120)


--一个月新增用户数
insert into [07Reports].dbo.daily_new_user(date,number) 
SELECT
	CONVERT (CHAR (10),OPERATE_TIME,120) AS date,
	COUNT (*) AS number
FROM
	[bs07].dbo.c_customer_information
WHERE
	OPERATE_TIME BETWEEN getdate() -30
AND getdate()
GROUP BY
	CONVERT (CHAR (10),OPERATE_TIME,120)
--------------------------------------------------------------------------------------------------------------
########################
#daily_report
--清空该表
Truncate Table dq_daily_new_user  --清空后编号默认从 1 开始记录
Delete dq_daily_new_user          --清空后编号默认之前的数值继续记录

--删除该表前 5行以后的数据
Delete From dq_daily_new_user Where id Not In
(Select Top 5 id From dq_daily_new_user Order By id)
--删除该表个
DROP TABLE dq_daily_new_user

create table [07reports].dbo.dq_daily_new_user(
id int identity(1,1) not null,
Date varchar(36) NOT NULL,
New_add_User varchar(36) NOT NULL,
Personal_NO varchar(36) NOT NULL,
Business_NO varchar(36) NOT NULL,
Rent_User varchar(36) NOT NULL,
times_tamp datetime default (getdate()),
primary key (id)
)


insert into [07Reports].dbo.dq_daily_new_user(Date,New_add_User,Personal_NO,Business_NO,Rent_User) 
SELECT
a.Date,
a.New_add_User,
c.Personal_NO,
d.Business_NO,
b.Rent_User
FROM 
(SELECT
	CONVERT (CHAR (10),getdate()-1,120) AS Date,
	COUNT (*) AS New_add_User from bs07.dbo.C_CUSTOMER_INFORMATION
WHERE OPERATE_TIME BETWEEN CONVERT (CHAR (10),getdate()-1,120)
AND CONVERT (CHAR (10),getdate(),120)) as a
LEFT JOIN 
(SELECT
CONVERT (CHAR (10),getdate()-1,120) AS Date,
		COUNT (DISTINCT(CUSTOMER_ID)) AS Rent_User
	FROM
		bs07.dbo.R_RV_BOOK_INFORMATION where STATE > 3
	AND STATE <> 9
	AND RENT_START_TIME BETWEEN CONVERT (CHAR (10),getdate()-1,120)
	AND CONVERT (CHAR (10),getdate(),120)) as b
on a.Date = b.Date
JOIN (
SELECT CONVERT (CHAR (10),getdate()-1,120) AS Date,
count(customer_type) as Personal_NO FROM bs07.dbo.C_CUSTOMER_INFORMATION 
where customer_type = '个人会员'
and  OPERATE_TIME BETWEEN CONVERT (CHAR (10),getdate()-1,120)
AND CONVERT (CHAR (10),getdate(),120)) as c 
on a.Date = c.Date
JOIN (
SELECT CONVERT (CHAR (10),getdate()-1,120) AS Date,
count(customer_type) as Business_NO FROM bs07.dbo.C_CUSTOMER_INFORMATION 
where customer_type = '企业会员'
and  OPERATE_TIME BETWEEN CONVERT (CHAR (10),getdate()-1,120)
AND CONVERT (CHAR (10),getdate(),120)) as d 
on a.Date = d.Date













###########################################################################################
--财务数据（存储过程）
--清除表格
DROP TABLE quarter_settlement_detail
--创建表格
create table dbo.quarter_settlement_detail(
id int identity(1,1) not null,
SETTLEMENT_DATE varchar(36)not null,
BOOK_RV_NO varchar(36)not null,
ac_get_rv varchar(36)not null,
ac_send_rv varchar(36)not null,
rent_days varchar(36)not null,
CUSTOMER_NAME varchar(36),
AC_RV_RENT_MONEY varchar(36)not null,
MAINTENANCE_COSTS varchar(36)not null,
AC_DRIVE_RV_MONEY varchar(36)not null,
AC_SEND_RV_MONEY varchar(36)not null,
AC_TAKE_RV_MONEY varchar(36)not null,
AC_SERVICE_FEE varchar(36)not null,
AC_GOODS_RENT_MONEY varchar(36)not null,
AC_GOODS_SALE_MONEY varchar(36)not null,
AC_OTHER_REVENUE_MONEY varchar(36)not null,
AC_DISCOUNT_MONEY varchar(36)not null,
REFUND_DATE varchar(36)not null,
REFUND_MONEY varchar(36)not null,
REFUND_REASON varchar(36) ,
times_tamp datetime default (getdate()),
primary key (id)
)
--插入表格数据
insert into [07Reports].dbo.quarter_settlement_detail(
SETTLEMENT_DATE,BOOK_RV_NO,
ac_get_rv,
ac_send_rv,rent_days,
CUSTOMER_NAME,
AC_RV_RENT_MONEY,
MAINTENANCE_COSTS,
AC_DRIVE_RV_MONEY,
AC_SEND_RV_MONEY,
AC_TAKE_RV_MONEY,
AC_SERVICE_FEE,
AC_GOODS_RENT_MONEY,
AC_GOODS_SALE_MONEY,
AC_OTHER_REVENUE_MONEY,
AC_DISCOUNT_MONEY,
REFUND_DATE,
REFUND_MONEY,
REFUND_REASON
) 
SELECT
	CONVERT (CHAR (10),a.SETTLEMENT_DATE,120) AS SETTLEMENT_DATE,
	a.BOOK_RV_NO ,-- AS '订单号',
	CONVERT (CHAR (30),c.ac_get_rv,121) as ac_get_rv,-- as '实际取车日期',
	CONVERT (CHAR (30),c.ac_send_rv,121) as ac_send_rv ,-- as '实际还车日期',
  c.rent_days,-- as '租车天数',
	a.CUSTOMER_NAME ,-- AS '用户姓名',
	ISNULL(a.AC_RV_RENT_MONEY,0) as AC_RV_RENT_MONEY,-- AS '应收租金',
	ISNULL(a.MAINTENANCE_COSTS,0) as MAINTENANCE_COSTS,--  AS '维修费用' ,
	ISNULL(a.AC_DRIVE_RV_MONEY,0) as AC_DRIVE_RV_MONEY,-- AS '代驾费用',
	ISNULL(a.AC_SEND_RV_MONEY,0) as AC_SEND_RV_MONEY,-- AS '还车节假日费用',
	ISNULL(a.AC_TAKE_RV_MONEY,0) as AC_TAKE_RV_MONEY,-- AS '取车节假日费用',
	ISNULL(a.AC_SERVICE_FEE,0) as AC_SERVICE_FEE,--  AS '服务费' ,
	ISNULL(a.AC_GOODS_RENT_MONEY,0) as AC_GOODS_RENT_MONEY,-- AS '租赁物品费用',
	ISNULL(a.AC_GOODS_SALE_MONEY,0) as AC_GOODS_SALE_MONEY,--  AS '购买物品费用',
	ISNULL(a.AC_OTHER_REVENUE_MONEY,0) as AC_OTHER_REVENUE_MONEY,-- AS '其他收入' ,
  ISNULL(a.AC_DISCOUNT_MONEY,0) as AC_DISCOUNT_MONEY,-- AS '折扣金',
	CONVERT (CHAR (10),b.REFUND_DATE,120) as REFUND_DATE,
	ISNULL(b.REFUND_MONEY,0) as REFUND_MONEY,--as '退款金额',
	b.REFUND_REASON --as '退款原因'
FROM
	bs07.dbo.F_SETTLEMENT_MANAGEMENT as a 
LEFT JOIN (
SELECT 
	CONVERT(CHAR (10),REFUND_DATE,120) as REFUND_DATE ,
	RENT_RV_ID,
	REFUND_MONEY,
	REFUND_REASON
FROM
	bs07.dbo.F_REFUND_MANAGEMENT) as b 
on 
a.BOOK_RV_NO = b.RENT_RV_ID
inner join (
SELECT
	d.rent_rv_id, --AS '租赁单号' ,
d.rv_check_time AS ac_get_rv,
f.rv_check_time AS ac_send_rv,
datediff(DAY,d.RV_CHECK_TIME,f.RV_CHECK_TIME) AS rent_days
FROM
 (
		SELECT
			RENT_RV_ID,
			RV_CHECK_TIME
		FROM
			bs07.dbo.R_RV_BACK_INFORMATION where RV_IS_BACK = '还车前'
	) AS d 
JOIN (
	SELECT
		RENT_RV_ID,
		RV_CHECK_TIME
	FROM
		bs07.dbo.R_RV_BACK_INFORMATION
	WHERE
		RV_IS_BACK = '还车后'
) AS f  
ON d.RENT_RV_ID = f.RENT_RV_ID 
WHERE
	d.RV_CHECK_TIME BETWEEN CONVERT (CHAR (10),getdate()-90,120)
AND CONVERT (CHAR (10),getdate(),120)) as c 
on a.BOOK_RV_NO = c.rent_rv_id
WHERE
	a.SETTLEMENT_DATE BETWEEN CONVERT (CHAR (10),getdate()-90,120)
AND 
CONVERT (CHAR (10),getdate(),120)
AND a.OPERATER IS NOT NULL
ORDER BY
	CONVERT (CHAR (10),a.SETTLEMENT_DATE,120) DESC


-------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------
--结算订单相关信息
SELECT
a.BOOK_RV_NO,
a.RENT_START_TIME,
a.RENT_END_TIME,
a.RV_MODELS_ID,
b.CUSTOMER_NAME,
b.CUSTOMER_PHONE,
c.DICTIONARYNAME,
d.RV_CHECK_TIME,
d.RV_CHECK_NOTES,
f.START_TIME,
f.MAINTAIN_STATE,
g.SETTLEMENT_DATE,
g.OPERATER
FROM
	bs07.dbo.R_RV_BOOK_INFORMATION AS a
JOIN (

SELECT * FROM bs07.dbo.C_CUSTOMER_INFORMATION ) as b
on a.CUSTOMER_ID = b.CUSTOMER_ID
JOIN (
SELECT DICTIONARYVALUE,DICTIONARYNAME from bs07.dbo.SYS_DICTIONARY where CATALOGID = '03') as c 
on a.STATE = c.DICTIONARYVALUE
JOIN (
SELECT * from bs07.dbo.R_RV_BACK_INFORMATION) as d
ON a.BOOK_RV_NO =d.RENT_RV_ID
JOIN (
SELECT * FROM bs07.dbo.M_RV_MAINTAIN_MANAGEMENT) as f
on a.BOOK_RV_NO = f.BOOK_RV_ID
JOIN (
SELECT * FROM bs07.dbo.F_SETTLEMENT_MANAGEMENT) as g
on a.BOOK_RV_NO = g.BOOK_RV_NO
where a.STATE in (0,3,4,5,6,7,8)





######################################################################################################
#气瓶日新增用户
DROP table [07Reports].dbo.CarReg_daily_newuser

create table [07Reports].dbo.CarReg_daily_newuser(
id int identity(1,1) not null,
date varchar(36) NOT NULL,
company varchar(36) NOT NULL,
new_car_number varchar(36) NOT NULL,
times_tamp datetime default (getdate()),
primary key (id)
)

insert into [07Reports].dbo.carreg_daily_newuser(date,company,new_car_number) 
SELECT CONVERT (CHAR (10),GETDATE()-1,120) as date,m_RegAdd as company,count(m_StartTime) as new_car_number 
FROM CarReg.dbo.Main 
where m_RegAdd <> '' and 
m_StartTime BETWEEN CONVERT (CHAR (10),GETDATE()-1,120) and 
CONVERT (CHAR (10),GETDATE()-1,120)
GROUP BY m_RegAdd



--详情注册用户信息
SELECT m_RegAdd as company,m_StartTime,m_ch FROM CarReg.dbo.Main where m_RegAdd <> '' and 
m_StartTime BETWEEN CONVERT (CHAR (10),GETDATE()-2,120) and 
CONVERT (CHAR (10),GETDATE(),120)
ORDER BY company,m_starttime

#周新增全省用户注册量

SELECT DATENAME(WEEK,m_StartTime) AS WeekName,
(CASE WHEN m_LicNum = 'S' THEN '陕西省' 
WHEN m_LicNum = 'SA' THEN '西安'
WHEN m_LicNum = 'SB' THEN '铜川'
WHEN m_LicNum = 'SC' THEN '宝鸡'
WHEN m_LicNum = 'SD' THEN '咸阳'
WHEN m_LicNum = 'SK' THEN '榆林'
WHEN m_LicNum = 'SJ' THEN '延安'
WHEN m_LicNum = 'SH' THEN '商洛'
WHEN m_LicNum = 'SE' THEN '渭南'
WHEN m_LicNum = 'SG' THEN '安康'
WHEN m_LicNum = 'SF' THEN '汉中'
WHEN m_LicNum = 'SV' THEN '杨凌'
ELSE 'null' END) as City , ISNULL(COUNT(*), 0) as Quantity from CarReg.dbo.Main
where m_StartTime 
BETWEEN '2016-01-01' 
and CONVERT(char(10), GETDATE(), 120) 
GROUP BY m_LicNum ,m_StartTime
ORDER BY m_StartTime

#月新增全省用户注册量





SELECT b.lbname,count(*) as Sum_Qty from CarReg.dbo.Main as a
JOIN (
SELECT * FROM CarReg.dbo.CityTable) as b 
on a.m_LicNum = b.lbcode
GROUP BY b.lbname




SELECT b.lbname,count(*) as Sum_Qty from CarReg.dbo.Main as a
JOIN (
SELECT * FROM CarReg.dbo.CityTable) as b 
on a.m_LicNum = b.lbcode
GROUP BY b.lbname




启用Ad Hoc Distributed Queries： 
exec sp_configure 'show advanced options',1 
reconfigure 
exec sp_configure 'Ad Hoc Distributed Queries',1 
reconfigure 
   

关闭Ad Hoc Distributed Queries： 
exec sp_configure 'Ad Hoc Distributed Queries',0 
reconfigure 
exec sp_configure 'show advanced options',0 
reconfigure

select * from OPENDATASOURCE( 
'SQLOLEDB', 
'Data Source=10.10.1.19;User ID=user01;Password=123456' 
).[CarReg].dbo.Main 


select * from 
OPENDATASOURCE('SQLOLEDB','Data Source=10.10.1.19;DBN=CARMANAGE1;UID=user01;PWD=123456').[CarReg].dbo.Main 

---
--陕西省各城市累计用户数（day）
create table [07Reports].dbo.CarReg_province_daily_qty(
id int identity(1,1) not null,
date varchar(36) NOT NULL,
City varchar(36) NOT NULL,
Qty varchar(36) NOT NULL,
times_tamp datetime default (getdate()),
primary key (id)
)

INSERT INTO [07Reports].dbo.CarReg_province_daily_qty (DATE, City, Qty)
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
--12-03新加站点信息
INSERT INTO [07Reports].dbo.CarReg_province_daily_qty (DATE, City, Qty)
SELECT  CONVERT (CHAR(10), getdate() - 1, 120) AS DATE,
  b.lbname AS City,
  COUNT (*) AS Qty
FROM
  CarReg.dbo.Main AS a
JOIN (  SELECT    *  FROM    CarReg.dbo.CityTable
) AS b 
ON a.m_LicNum = b.lbcode
GROUP BY
  b.lbname
UNION 
SELECT CONVERT (CHAR(10),GETDATE()-1,120) as date ,station as city,count(*) AS Qty FROM car_xa_daily_detail
where station in ('东站','西站','新力（北站）','北方(公交)','弘瑞（南站）')
GROUP BY station

----------------------------------------------------------------------
DROP TABLE [07reports].dbo.car_xa_daily_detail

CREATE TABLE [07reports].dbo.car_xa_daily_detail(
id int identity(1,1) not null,
times_tamp datetime default (getdate()),
lbname varchar(100) ,
m_StartTime varchar(100),
m_linkman varchar(100),
m_linktel varchar(100),
m_ReportCode varchar(100),
station varchar(100),
Sub_ZZDate varchar(100),
Sub_InstallDate varchar(100),
Sub_CheckDate varchar(100),
Sub_FirstDate varchar(100),
cm_changedate varchar(100),
cm_memo varchar(100),
cm_changecontent varchar(500),
primary key (id)
)

--清空该表
Truncate Table [07reports].dbo.car_xa_daily_detail
--插入气瓶检验信息
INSERT INTO [07Reports].dbo.car_xa_daily_detail(
lbname,
m_StartTime,
m_linkman,
m_linktel,
m_ReportCode,
station,
Sub_ZZDate,
Sub_InstallDate,
Sub_CheckDate,
Sub_FirstDate,
cm_changedate,
cm_memo,
cm_changecontent
)
SELECT
	b.lbname,
	CONVERT (CHAR(10),m_StartTime,120) as m_StartTime,
	m_linkman,
	m_linktel,
	m_ReportCode,
(case WHEN m_Checker = 'BF001' THEN '北方(公交)' 
WHEN m_Checker = 'BF002' THEN '北方(公交)' 
WHEN m_Checker = '冯静' THEN '北方(公交)' 
WHEN m_Checker = '李文昊' THEN '北方(公交)' 
WHEN m_Checker = 'SHD00' THEN '东站' 
WHEN m_Checker = 'SHD02' THEN '东站' 
WHEN m_Checker = 'SHD03' THEN '东站' 
WHEN m_Checker = 'SHD04' THEN '东站' 
WHEN m_Checker = 'SHD05' THEN '东站' 
WHEN m_Checker = '白宝丽' THEN '东站' 
WHEN m_Checker = '陈娟' THEN '东站' 
WHEN m_Checker = '崔文娟' THEN '东站' 
WHEN m_Checker = '关飞' THEN '东站' 
WHEN m_Checker = '郭严' THEN '东站' 
WHEN m_Checker = '刘芳' THEN '东站' 
WHEN m_Checker = '陆秦' THEN '东站' 
WHEN m_Checker = '潘迎丽' THEN '东站' 
WHEN m_Checker = '裴荣荣' THEN '东站' 
WHEN m_Checker = '乔秀霞' THEN '东站' 
WHEN m_Checker = '三环燃气汽车中心4' THEN '东站' 
WHEN m_Checker = '试用1' THEN '东站' 
WHEN m_Checker = '孙建茹' THEN '东站' 
WHEN m_Checker = '王祎' THEN '东站' 
WHEN m_Checker = '西安东录入' THEN '东站' 
WHEN m_Checker = '西安东注册' THEN '东站' 
WHEN m_Checker = '薛丹' THEN '东站' 
WHEN m_Checker = '姚娟' THEN '东站' 
WHEN m_Checker = '叶飞' THEN '东站' 
WHEN m_Checker = '叶至柔' THEN '东站' 
WHEN m_Checker = '张萍' THEN '东站' 
WHEN m_Checker = '张晓红' THEN '东站' 
WHEN m_Checker = '张引弟' THEN '东站' 
WHEN m_Checker = '张颖' THEN '东站' 
WHEN m_Checker = 'HR001' THEN '弘瑞（南站）' 
WHEN m_Checker = 'HR002' THEN '弘瑞（南站）' 
WHEN m_Checker = '弘瑞注册' THEN '弘瑞（南站）' 
WHEN m_Checker = '徐晶' THEN '弘瑞（南站）' 
WHEN m_Checker = 'SHX00' THEN '西站' 
WHEN m_Checker = 'SHX01' THEN '西站' 
WHEN m_Checker = 'SHX02' THEN '西站' 
WHEN m_Checker = 'SHX03' THEN '西站' 
WHEN m_Checker = 'SHX04' THEN '西站' 
WHEN m_Checker = 'SHX05' THEN '西站' 
WHEN m_Checker = '贺海莹' THEN '西站' 
WHEN m_Checker = '刘盈' THEN '西站' 
WHEN m_Checker = '孙凤' THEN '西站' 
WHEN m_Checker = '汪孟君' THEN '西站' 
WHEN m_Checker = '王贝贝' THEN '西站' 
WHEN m_Checker = '王思同' THEN '西站' 
WHEN m_Checker = '王晓荣' THEN '西站'
WHEN m_Checker = '西安西注册' THEN '西站'
WHEN m_Checker = '张双娟' THEN '西站'
WHEN m_Checker = '张娱' THEN '西站'
WHEN m_Checker = 'XIN001' THEN '新奥'
WHEN m_Checker = 'XIN002' THEN '新奥'
WHEN m_Checker = 'XL001' THEN '新力（北站）'
WHEN m_Checker = 'XL002' THEN '新力（北站）'
WHEN m_Checker = '陈捷' THEN '新力（北站）'
WHEN m_Checker = '陈婕' THEN '新力（北站）'
WHEN m_Checker = '新力注册' THEN '新力（北站）'
ELSE m_Checker END) as station,
CONVERT (CHAR(10),c.Sub_ZZDate,120) as Sub_ZZDate,
CONVERT (CHAR(10),c.Sub_InstallDate,120) as Sub_InstallDate,
CONVERT (CHAR(10),c.Sub_CheckDate,120) as Sub_CheckDate,
CONVERT (CHAR(10),c.Sub_FirstDate,120) as Sub_FirstDate,
CONVERT (CHAR(30),d.cm_changedate,121) as cm_changedate,--最后一次检验记录时间
d.cm_memo,
d.cm_changecontent
from CarReg.dbo.Main as a 
LEFT JOIN (
SELECT * from CarReg.dbo.CityTable) as b
on a.m_LicNum = b.lbcode
LEFT JOIN (
SELECT
	m_ID,
	Sub_ZZDate,
	Sub_InstallDate,
	Sub_CheckDate,
	Sub_FirstDate
FROM
	CarReg.dbo.SubMain) as c
on a.m_ID = c.m_ID
LEFT JOIN (
SELECT * from CarReg.dbo.ChangeMemo where cm_changedate in (
SELECT max(cm_changedate) as cm_changedate FROM CarReg.dbo.ChangeMemo
GROUP BY m_id)
) as d
on a.m_ID = d.m_ID
where b.lbname = '西安'


---气瓶日新增数据数据量
SELECT a.date,a.city,(convert(int,a.qty)-convert(int,b.qty)) as add_qty from
(SELECT * FROM car_province_daily_qty where date = CONVERT (CHAR(10),GETDATE()-1,120)) as a 
LEFT JOIN  
(SELECT * FROM car_province_daily_qty where date = CONVERT (CHAR(10),GETDATE()-2,120)) as b
on a.City = b.City
ORDER BY a.city


---------------------------------------------------------------------
SELECT
	xian.DATE,
	xian.xian,
	xianyang.xianyang,
	baoji.baoji,
	ankang.ankang,
	hanzhong.hanzhong,
	shangluo.shangluo,
	tongchuan.tongchuan,
	weinan.weinan,
	yanan.yanan,
	yangling.yangling,
	yulin.yulin
FROM
(SELECT a.date,(convert(int,a.qty)-convert(int,b.qty)) as xian from
(SELECT * FROM car_province_daily_qty where date = CONVERT (CHAR(10),GETDATE()-1,120) and city = '西安') as a 
LEFT JOIN 
(SELECT * FROM car_province_daily_qty where date = CONVERT (CHAR(10),GETDATE()-2,120) and city = '西安') as b
on a.City = b.City) as xian
LEFT JOIN
(SELECT a.date,(convert(int,a.qty)-convert(int,b.qty)) as xianyang from
(SELECT * FROM car_province_daily_qty where date = CONVERT (CHAR(10),GETDATE()-1,120) and city = '咸阳') as a 
LEFT JOIN 
(SELECT * FROM car_province_daily_qty where date = CONVERT (CHAR(10),GETDATE()-2,120) and city = '咸阳') as b
on a.City = b.City) as xianyang
on xian.date = xianyang.date
LEFT JOIN
(SELECT a.date,(convert(int,a.qty)-convert(int,b.qty)) as baoji from
(SELECT * FROM car_province_daily_qty where date = CONVERT (CHAR(10),GETDATE()-1,120) and city = '宝鸡') as a 
LEFT JOIN 
(SELECT * FROM car_province_daily_qty where date = CONVERT (CHAR(10),GETDATE()-2,120) and city = '宝鸡') as b
on a.City = b.City) as baoji
on xian.date = baoji.date
LEFT JOIN
(SELECT a.date,(convert(int,a.qty)-convert(int,b.qty)) as ankang from
(SELECT * FROM car_province_daily_qty where date = CONVERT (CHAR(10),GETDATE()-1,120) and city = '安康') as a 
LEFT JOIN 
(SELECT * FROM car_province_daily_qty where date = CONVERT (CHAR(10),GETDATE()-2,120) and city = '安康') as b
on a.City = b.City) as ankang
on xian.date = ankang.date
LEFT JOIN
(SELECT a.date,(convert(int,a.qty)-convert(int,b.qty)) as hanzhong from
(SELECT * FROM car_province_daily_qty where date = CONVERT (CHAR(10),GETDATE()-1,120) and city = '汉中') as a 
LEFT JOIN 
(SELECT * FROM car_province_daily_qty where date = CONVERT (CHAR(10),GETDATE()-2,120) and city = '汉中') as b
on a.City = b.City) as hanzhong
on xian.date = hanzhong.date
LEFT JOIN
(SELECT a.date,(convert(int,a.qty)-convert(int,b.qty)) as shangluo from
(SELECT * FROM car_province_daily_qty where date = CONVERT (CHAR(10),GETDATE()-1,120) and city = '商洛') as a 
LEFT JOIN 
(SELECT * FROM car_province_daily_qty where date = CONVERT (CHAR(10),GETDATE()-2,120) and city = '商洛') as b
on a.City = b.City) as shangluo
on xian.date = shangluo.date
LEFT JOIN
(SELECT a.date,(convert(int,a.qty)-convert(int,b.qty)) as tongchuan from
(SELECT * FROM car_province_daily_qty where date = CONVERT (CHAR(10),GETDATE()-1,120) and city = '铜川') as a 
LEFT JOIN 
(SELECT * FROM car_province_daily_qty where date = CONVERT (CHAR(10),GETDATE()-2,120) and city = '铜川') as b
on a.City = b.City) as tongchuan
on xian.date = tongchuan.date
LEFT JOIN
(SELECT a.date,(convert(int,a.qty)-convert(int,b.qty)) as weinan from
(SELECT * FROM car_province_daily_qty where date = CONVERT (CHAR(10),GETDATE()-1,120) and city = '渭南') as a 
LEFT JOIN 
(SELECT * FROM car_province_daily_qty where date = CONVERT (CHAR(10),GETDATE()-2,120) and city = '渭南') as b
on a.City = b.City) as weinan
on xian.date = weinan.date
LEFT JOIN
(SELECT a.date,(convert(int,a.qty)-convert(int,b.qty)) as yanan from
(SELECT * FROM car_province_daily_qty where date = CONVERT (CHAR(10),GETDATE()-1,120) and city = '延安') as a 
LEFT JOIN 
(SELECT * FROM car_province_daily_qty where date = CONVERT (CHAR(10),GETDATE()-2,120) and city = '延安') as b
on a.City = b.City) as yanan
on xian.date = yanan.date
LEFT JOIN
(SELECT a.date,(convert(int,a.qty)-convert(int,b.qty)) as yangling from
(SELECT * FROM car_province_daily_qty where date = CONVERT (CHAR(10),GETDATE()-1,120) and city = '杨凌') as a 
LEFT JOIN 
(SELECT * FROM car_province_daily_qty where date = CONVERT (CHAR(10),GETDATE()-2,120) and city = '杨凌') as b
on a.City = b.City) as yangling
on xian.date = yangling.date
LEFT JOIN
(SELECT a.date,(convert(int,a.qty)-convert(int,b.qty)) as yulin from
(SELECT * FROM car_province_daily_qty where date = CONVERT (CHAR(10),GETDATE()-1,120) and city = '榆林') as a 
LEFT JOIN 
(SELECT * FROM car_province_daily_qty where date = CONVERT (CHAR(10),GETDATE()-2,120) and city = '榆林') as b
on a.City = b.City) as yulin
on xian.date = yulin.date


-------------------------------------------
SELECT
	dz. DATE,
	dz.Qty_dongzhan,
	xz.Qty_xizhan,
	bz.Qty_beizhan,
	bf.Qty_beifang,
	nz.Qty_nanzhan
FROM
(SELECT CONVERT (CHAR(10), getdate() - 1, 120) AS DATE,
COUNT (station) AS Qty_dongzhan
FROM car_xa_daily_detail
where station = '东站') as dz
LEFT JOIN (
SELECT CONVERT (CHAR(10), getdate() - 1, 120) AS DATE,
COUNT (station) AS Qty_xizhan
FROM car_xa_daily_detail
where station = '西站') as xz
ON dz.date = xz.date
LEFT JOIN (
SELECT CONVERT (CHAR(10), getdate() - 1, 120) AS DATE,
COUNT (station) AS Qty_beizhan
FROM car_xa_daily_detail
where station = '新力（北站）') as bz
ON dz.date = bz.date
LEFT JOIN (
SELECT CONVERT (CHAR(10), getdate() - 1, 120) AS DATE,
COUNT (station) AS Qty_beifang
FROM car_xa_daily_detail
where station = '北方(公交)') as bf
ON dz.date = bf.date
LEFT JOIN (
SELECT CONVERT (CHAR(10), getdate() - 1, 120) AS DATE,
COUNT (station) AS Qty_nanzhan
FROM car_xa_daily_detail
where station = '弘瑞（南站）') as nz
ON dz.date = nz.date

-------------------------------------------------------------------

SELECT  CONVERT (CHAR(10), getdate() - 1, 120) AS DATE,
  b.lbname AS City,
  COUNT (*) AS Qty
FROM
  CarReg.dbo.Main AS a
JOIN (  SELECT    *  FROM    CarReg.dbo.CityTable
) AS b 
ON a.m_LicNum = b.lbcode
GROUP BY
  b.lbname
UNION 
SELECT CONVERT (CHAR(10),GETDATE()-1,120) as date ,station as city,count(*) AS Qty FROM car_xa_daily_detail
where station in ('东站','西站','新力（北站）','北方(公交)','弘瑞（南站）')
GROUP BY station



------------------------------------------------------------------------------------------
检车气瓶量
SELECT 
(case WHEN m_Checker = 'BF001' THEN '北方(公交)' 
WHEN m_Checker = 'BF002' THEN '北方(公交)' 
WHEN m_Checker = '冯静' THEN '北方(公交)' 
WHEN m_Checker = '李文昊' THEN '北方(公交)' 
WHEN m_Checker = 'SHD00' THEN '东站' 
WHEN m_Checker = 'SHD02' THEN '东站' 
WHEN m_Checker = 'SHD03' THEN '东站' 
WHEN m_Checker = 'SHD04' THEN '东站' 
WHEN m_Checker = 'SHD05' THEN '东站' 
WHEN m_Checker = '白宝丽' THEN '东站' 
WHEN m_Checker = '陈娟' THEN '东站' 
WHEN m_Checker = '崔文娟' THEN '东站' 
WHEN m_Checker = '关飞' THEN '东站' 
WHEN m_Checker = '郭严' THEN '东站' 
WHEN m_Checker = '刘芳' THEN '东站' 
WHEN m_Checker = '陆秦' THEN '东站' 
WHEN m_Checker = '潘迎丽' THEN '东站' 
WHEN m_Checker = '裴荣荣' THEN '东站' 
WHEN m_Checker = '乔秀霞' THEN '东站' 
WHEN m_Checker = '三环燃气汽车中心4' THEN '东站' 
WHEN m_Checker = '试用1' THEN '东站' 
WHEN m_Checker = '孙建茹' THEN '东站' 
WHEN m_Checker = '王祎' THEN '东站' 
WHEN m_Checker = '西安东录入' THEN '东站' 
WHEN m_Checker = '西安东注册' THEN '东站' 
WHEN m_Checker = '薛丹' THEN '东站' 
WHEN m_Checker = '姚娟' THEN '东站' 
WHEN m_Checker = '叶飞' THEN '东站' 
WHEN m_Checker = '叶至柔' THEN '东站' 
WHEN m_Checker = '张萍' THEN '东站' 
WHEN m_Checker = '张晓红' THEN '东站' 
WHEN m_Checker = '张引弟' THEN '东站' 
WHEN m_Checker = '张颖' THEN '东站' 
WHEN m_Checker = 'HR001' THEN '弘瑞（南站）' 
WHEN m_Checker = 'HR002' THEN '弘瑞（南站）' 
WHEN m_Checker = '弘瑞注册' THEN '弘瑞（南站）' 
WHEN m_Checker = '徐晶' THEN '弘瑞（南站）' 
WHEN m_Checker = 'SHX00' THEN '西站' 
WHEN m_Checker = 'SHX01' THEN '西站' 
WHEN m_Checker = 'SHX02' THEN '西站' 
WHEN m_Checker = 'SHX03' THEN '西站' 
WHEN m_Checker = 'SHX04' THEN '西站' 
WHEN m_Checker = 'SHX05' THEN '西站' 
WHEN m_Checker = '贺海莹' THEN '西站' 
WHEN m_Checker = '刘盈' THEN '西站' 
WHEN m_Checker = '孙凤' THEN '西站' 
WHEN m_Checker = '汪孟君' THEN '西站' 
WHEN m_Checker = '王贝贝' THEN '西站' 
WHEN m_Checker = '王思同' THEN '西站' 
WHEN m_Checker = '王晓荣' THEN '西站'
WHEN m_Checker = '西安西注册' THEN '西站'
WHEN m_Checker = '张双娟' THEN '西站'
WHEN m_Checker = '张娱' THEN '西站'
WHEN m_Checker = 'XIN001' THEN '新奥'
WHEN m_Checker = 'XIN002' THEN '新奥'
WHEN m_Checker = 'XL001' THEN '新力（北站）'
WHEN m_Checker = 'XL002' THEN '新力（北站）'
WHEN m_Checker = '陈捷' THEN '新力（北站）'
WHEN m_Checker = '陈婕' THEN '新力（北站）'
WHEN m_Checker = '新力注册' THEN '新力（北站）'
ELSE m_Checker END) as station,
count(*) as n 
FROM CarReg.dbo.Main 
where m_StartTime BETWEEN '2016-12-04' and '2016-12-05'
and m_LicNum = 'SA' AND m_ReportCode <> ''
GROUP BY 
(case WHEN m_Checker = 'BF001' THEN '北方(公交)' 
WHEN m_Checker = 'BF002' THEN '北方(公交)' 
WHEN m_Checker = '冯静' THEN '北方(公交)' 
WHEN m_Checker = '李文昊' THEN '北方(公交)' 
WHEN m_Checker = 'SHD00' THEN '东站' 
WHEN m_Checker = 'SHD02' THEN '东站' 
WHEN m_Checker = 'SHD03' THEN '东站' 
WHEN m_Checker = 'SHD04' THEN '东站' 
WHEN m_Checker = 'SHD05' THEN '东站' 
WHEN m_Checker = '白宝丽' THEN '东站' 
WHEN m_Checker = '陈娟' THEN '东站' 
WHEN m_Checker = '崔文娟' THEN '东站' 
WHEN m_Checker = '关飞' THEN '东站' 
WHEN m_Checker = '郭严' THEN '东站' 
WHEN m_Checker = '刘芳' THEN '东站' 
WHEN m_Checker = '陆秦' THEN '东站' 
WHEN m_Checker = '潘迎丽' THEN '东站' 
WHEN m_Checker = '裴荣荣' THEN '东站' 
WHEN m_Checker = '乔秀霞' THEN '东站' 
WHEN m_Checker = '三环燃气汽车中心4' THEN '东站' 
WHEN m_Checker = '试用1' THEN '东站' 
WHEN m_Checker = '孙建茹' THEN '东站' 
WHEN m_Checker = '王祎' THEN '东站' 
WHEN m_Checker = '西安东录入' THEN '东站' 
WHEN m_Checker = '西安东注册' THEN '东站' 
WHEN m_Checker = '薛丹' THEN '东站' 
WHEN m_Checker = '姚娟' THEN '东站' 
WHEN m_Checker = '叶飞' THEN '东站' 
WHEN m_Checker = '叶至柔' THEN '东站' 
WHEN m_Checker = '张萍' THEN '东站' 
WHEN m_Checker = '张晓红' THEN '东站' 
WHEN m_Checker = '张引弟' THEN '东站' 
WHEN m_Checker = '张颖' THEN '东站' 
WHEN m_Checker = 'HR001' THEN '弘瑞（南站）' 
WHEN m_Checker = 'HR002' THEN '弘瑞（南站）' 
WHEN m_Checker = '弘瑞注册' THEN '弘瑞（南站）' 
WHEN m_Checker = '徐晶' THEN '弘瑞（南站）' 
WHEN m_Checker = 'SHX00' THEN '西站' 
WHEN m_Checker = 'SHX01' THEN '西站' 
WHEN m_Checker = 'SHX02' THEN '西站' 
WHEN m_Checker = 'SHX03' THEN '西站' 
WHEN m_Checker = 'SHX04' THEN '西站' 
WHEN m_Checker = 'SHX05' THEN '西站' 
WHEN m_Checker = '贺海莹' THEN '西站' 
WHEN m_Checker = '刘盈' THEN '西站' 
WHEN m_Checker = '孙凤' THEN '西站' 
WHEN m_Checker = '汪孟君' THEN '西站' 
WHEN m_Checker = '王贝贝' THEN '西站' 
WHEN m_Checker = '王思同' THEN '西站' 
WHEN m_Checker = '王晓荣' THEN '西站'
WHEN m_Checker = '西安西注册' THEN '西站'
WHEN m_Checker = '张双娟' THEN '西站'
WHEN m_Checker = '张娱' THEN '西站'
WHEN m_Checker = 'XIN001' THEN '新奥'
WHEN m_Checker = 'XIN002' THEN '新奥'
WHEN m_Checker = 'XL001' THEN '新力（北站）'
WHEN m_Checker = 'XL002' THEN '新力（北站）'
WHEN m_Checker = '陈捷' THEN '新力（北站）'
WHEN m_Checker = '陈婕' THEN '新力（北站）'
WHEN m_Checker = '新力注册' THEN '新力（北站）'
ELSE m_Checker END)


--气瓶增量计算（各市与西安5个气站和总量）

CREATE TABLE car_increment_daily (
id int identity(1,1) not null,
date varchar(36) NOT NULL,
City varchar(36) NOT NULL,
Sum int NOT NULL,
Increment int NOT NULL,
times_tamp datetime default (getdate()),
primary key (id)
)

Truncate Table [07reports].dbo.car_increment_daily --清空

INSERT INTO [07Reports].dbo.car_increment_daily (DATE, City,Sum, Increment)
SELECT 
CONVERT (CHAR(10), getdate() - 1, 120) AS DATE,
a.City,
b.qty as Sum,
(CONVERT(int,b.qty)-CONVERT(int,a.qty)) as Increment
FROM (
SELECT *  FROM [07reports].dbo.car_province_daily_qty where date = CONVERT (CHAR(10), getdate() - 2, 120)) as a 
LEFT JOIN
(SELECT *  FROM [07reports].dbo.car_province_daily_qty where date = CONVERT (CHAR(10), getdate() - 1, 120)) as b
on a.city = b.city
GROUP BY a.City,(CONVERT(int,b.qty)-CONVERT(int,a.qty)),b.qty

----------------------------------------------------------------
--气瓶全量统计（各市与西安5个气站）
SELECT  CONVERT (CHAR(10), getdate() - 1, 120) AS DATE,
  b.lbname AS City,
  COUNT (*) AS Qty
FROM
  CarReg.dbo.Main AS a
JOIN (  SELECT    *  FROM    CarReg.dbo.CityTable
) AS b 
ON a.m_LicNum = b.lbcode
GROUP BY
  b.lbname
UNION 
SELECT
CONVERT (CHAR(10),GETDATE()-1,120) as date ,
(case WHEN m_Checker = 'BF001' THEN '北方(公交)' 
WHEN m_Checker = 'BF002' THEN '北方(公交)' 
WHEN m_Checker = '冯静' THEN '北方(公交)' 
WHEN m_Checker = '李文昊' THEN '北方(公交)' 
WHEN m_Checker = 'SHD00' THEN '东站' 
WHEN m_Checker = 'SHD01' THEN '东站' 
WHEN m_Checker = 'SHD02' THEN '东站' 
WHEN m_Checker = 'SHD03' THEN '东站' 
WHEN m_Checker = 'SHD04' THEN '东站' 
WHEN m_Checker = 'SHD05' THEN '东站' 
WHEN m_Checker = '白宝丽' THEN '东站' 
WHEN m_Checker = '陈娟' THEN '东站' 
WHEN m_Checker = '崔文娟' THEN '东站' 
WHEN m_Checker = '关飞' THEN '东站' 
WHEN m_Checker = '郭严' THEN '东站' 
WHEN m_Checker = '刘芳' THEN '东站' 
WHEN m_Checker = '陆秦' THEN '东站' 
WHEN m_Checker = '潘迎丽' THEN '东站' 
WHEN m_Checker = '裴荣荣' THEN '东站' 
WHEN m_Checker = '乔秀霞' THEN '东站' 
WHEN m_Checker = '三环燃气汽车中心4' THEN '东站' 
WHEN m_Checker = '试用1' THEN '东站' 
WHEN m_Checker = '孙建茹' THEN '东站' 
WHEN m_Checker = '王祎' THEN '东站' 
WHEN m_Checker = '西安东录入' THEN '东站' 
WHEN m_Checker = '西安东注册' THEN '东站' 
WHEN m_Checker = '薛丹' THEN '东站' 
WHEN m_Checker = '姚娟' THEN '东站' 
WHEN m_Checker = '叶飞' THEN '东站' 
WHEN m_Checker = '叶至柔' THEN '东站' 
WHEN m_Checker = '张萍' THEN '东站' 
WHEN m_Checker = '张晓红' THEN '东站' 
WHEN m_Checker = '张引弟' THEN '东站' 
WHEN m_Checker = '张颖' THEN '东站' 
WHEN m_Checker = 'HR001' THEN '弘瑞（南站）' 
WHEN m_Checker = 'HR002' THEN '弘瑞（南站）' 
WHEN m_Checker = '弘瑞注册' THEN '弘瑞（南站）' 
WHEN m_Checker = '徐晶' THEN '弘瑞（南站）' 
WHEN m_Checker = 'SHX00' THEN '西站' 
WHEN m_Checker = 'SHX01' THEN '西站' 
WHEN m_Checker = 'SHX02' THEN '西站' 
WHEN m_Checker = 'SHX03' THEN '西站' 
WHEN m_Checker = 'SHX04' THEN '西站' 
WHEN m_Checker = 'SHX05' THEN '西站' 
WHEN m_Checker = '贺海莹' THEN '西站' 
WHEN m_Checker = '刘盈' THEN '西站' 
WHEN m_Checker = '孙凤' THEN '西站' 
WHEN m_Checker = '汪孟君' THEN '西站' 
WHEN m_Checker = '王贝贝' THEN '西站' 
WHEN m_Checker = '王思同' THEN '西站' 
WHEN m_Checker = '王晓荣' THEN '西站'
WHEN m_Checker = '西安西注册' THEN '西站'
WHEN m_Checker = '张双娟' THEN '西站'
WHEN m_Checker = '张娱' THEN '西站'
WHEN m_Checker = 'XIN001' THEN '新奥'
WHEN m_Checker = 'XIN002' THEN '新奥'
WHEN m_Checker = 'XL001' THEN '新力（北站）'
WHEN m_Checker = 'XL002' THEN '新力（北站）'
WHEN m_Checker = '陈捷' THEN '新力（北站）'
WHEN m_Checker = '陈婕' THEN '新力（北站）'
WHEN m_Checker = '新力注册' THEN '新力（北站）'
ELSE m_Checker END) as station,
count(*) FROM CarReg.dbo.Main
WHERE m_LicNum = 'SA'
GROUP BY 
(case WHEN m_Checker = 'BF001' THEN '北方(公交)' 
WHEN m_Checker = 'BF002' THEN '北方(公交)' 
WHEN m_Checker = '冯静' THEN '北方(公交)' 
WHEN m_Checker = '李文昊' THEN '北方(公交)' 
WHEN m_Checker = 'SHD00' THEN '东站' 
WHEN m_Checker = 'SHD02' THEN '东站' 
WHEN m_Checker = 'SHD03' THEN '东站' 
WHEN m_Checker = 'SHD04' THEN '东站' 
WHEN m_Checker = 'SHD05' THEN '东站' 
WHEN m_Checker = '白宝丽' THEN '东站' 
WHEN m_Checker = '陈娟' THEN '东站' 
WHEN m_Checker = '崔文娟' THEN '东站' 
WHEN m_Checker = '关飞' THEN '东站' 
WHEN m_Checker = '郭严' THEN '东站' 
WHEN m_Checker = '刘芳' THEN '东站' 
WHEN m_Checker = '陆秦' THEN '东站' 
WHEN m_Checker = '潘迎丽' THEN '东站' 
WHEN m_Checker = '裴荣荣' THEN '东站' 
WHEN m_Checker = '乔秀霞' THEN '东站' 
WHEN m_Checker = '三环燃气汽车中心4' THEN '东站' 
WHEN m_Checker = '试用1' THEN '东站' 
WHEN m_Checker = '孙建茹' THEN '东站' 
WHEN m_Checker = '王祎' THEN '东站' 
WHEN m_Checker = '西安东录入' THEN '东站' 
WHEN m_Checker = '西安东注册' THEN '东站' 
WHEN m_Checker = '薛丹' THEN '东站' 
WHEN m_Checker = '姚娟' THEN '东站' 
WHEN m_Checker = '叶飞' THEN '东站' 
WHEN m_Checker = '叶至柔' THEN '东站' 
WHEN m_Checker = '张萍' THEN '东站' 
WHEN m_Checker = '张晓红' THEN '东站' 
WHEN m_Checker = '张引弟' THEN '东站' 
WHEN m_Checker = '张颖' THEN '东站' 
WHEN m_Checker = 'HR001' THEN '弘瑞（南站）' 
WHEN m_Checker = 'HR002' THEN '弘瑞（南站）' 
WHEN m_Checker = '弘瑞注册' THEN '弘瑞（南站）' 
WHEN m_Checker = '徐晶' THEN '弘瑞（南站）' 
WHEN m_Checker = 'SHX00' THEN '西站' 
WHEN m_Checker = 'SHX01' THEN '西站' 
WHEN m_Checker = 'SHX02' THEN '西站' 
WHEN m_Checker = 'SHX03' THEN '西站' 
WHEN m_Checker = 'SHX04' THEN '西站' 
WHEN m_Checker = 'SHX05' THEN '西站' 
WHEN m_Checker = '贺海莹' THEN '西站' 
WHEN m_Checker = '刘盈' THEN '西站' 
WHEN m_Checker = '孙凤' THEN '西站' 
WHEN m_Checker = '汪孟君' THEN '西站' 
WHEN m_Checker = '王贝贝' THEN '西站' 
WHEN m_Checker = '王思同' THEN '西站' 
WHEN m_Checker = '王晓荣' THEN '西站'
WHEN m_Checker = '西安西注册' THEN '西站'
WHEN m_Checker = '张双娟' THEN '西站'
WHEN m_Checker = '张娱' THEN '西站'
WHEN m_Checker = 'XIN001' THEN '新奥'
WHEN m_Checker = 'XIN002' THEN '新奥'
WHEN m_Checker = 'XL001' THEN '新力（北站）'
WHEN m_Checker = 'XL002' THEN '新力（北站）'
WHEN m_Checker = '陈捷' THEN '新力（北站）'
WHEN m_Checker = '陈婕' THEN '新力（北站）'
WHEN m_Checker = '新力注册' THEN '新力（北站）'
ELSE m_Checker END) 





































































































































