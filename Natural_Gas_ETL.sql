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
--全市含气站的增量数据
SELECT
	distinct(xian. DATE) as '日期',
	summ.n as '全省累计用户',
	(xian.xian + xianyang.xianyang + baoji.baoji + ankang.ankang +
 hanzhong.hanzhong + shangluo.shangluo + tongchuan.tongchuan + weinan.weinan
 + yanan.yanan + yangling.yangling + yulin.yulin) AS '全省合计新增用户',
	xian.xian as '西安',
	xianyang.xianyang  as '咸阳',
	baoji.baoji  as '宝鸡',
	ankang.ankang  as '安康',
	hanzhong.hanzhong  as '汉中',
	shangluo.shangluo  as '商洛',
	tongchuan.tongchuan  as '铜川',
	weinan.weinan  as '渭南',
	yanan.yanan  as '延安',
	yangling.yangling  as '杨凌',
	yulin.yulin  as '榆林',
	SHD.SHD  as '三环（东站）',
	SHX.SHX as '三环（西站）',
	XLB.XLB as '新力（北站）',
	HRN.HRN as '弘瑞（南站）',
	GJBF.GJBF as '北方（公交）'
FROM
(SELECT a.date,(a.qty-b.qty) as xian from
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-1,120) and city = '西安') as a 
LEFT JOIN 
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-2,120) and city = '西安') as b
on a.City = b.City) as xian
LEFT JOIN
(SELECT a.date,(a.qty-b.qty) as xianyang from
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-1,120) and city = '咸阳') as a 
LEFT JOIN 
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-2,120) and city = '咸阳') as b
on a.City = b.City) as xianyang
on xian.date = xianyang.date
LEFT JOIN
(SELECT a.date,(a.qty-b.qty) as baoji from
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-1,120) and city = '宝鸡') as a 
LEFT JOIN 
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-2,120) and city = '宝鸡') as b
on a.City = b.City) as baoji
on xian.date = baoji.date
LEFT JOIN
(SELECT a.date,(a.qty-b.qty) as ankang from
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-1,120) and city = '安康') as a 
LEFT JOIN 
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-2,120) and city = '安康') as b
on a.City = b.City) as ankang
on xian.date = ankang.date
LEFT JOIN
(SELECT a.date,(a.qty-b.qty) as hanzhong from
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-1,120) and city = '汉中') as a 
LEFT JOIN 
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-2,120) and city = '汉中') as b
on a.City = b.City) as hanzhong
on xian.date = hanzhong.date
LEFT JOIN
(SELECT a.date,(a.qty-b.qty) as shangluo from
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-1,120) and city = '商洛') as a 
LEFT JOIN 
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-2,120) and city = '商洛') as b
on a.City = b.City) as shangluo
on xian.date = shangluo.date
LEFT JOIN
(SELECT a.date,(a.qty-b.qty) as tongchuan from
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-1,120) and city = '铜川') as a 
LEFT JOIN 
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-2,120) and city = '铜川') as b
on a.City = b.City) as tongchuan
on xian.date = tongchuan.date
LEFT JOIN
(SELECT a.date,(a.qty-b.qty) as weinan from
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-1,120) and city = '渭南') as a 
LEFT JOIN 
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-2,120) and city = '渭南') as b
on a.City = b.City) as weinan
on xian.date = weinan.date
LEFT JOIN
(SELECT a.date,(a.qty-b.qty) as yanan from
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-1,120) and city = '延安') as a 
LEFT JOIN 
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-2,120) and city = '延安') as b
on a.City = b.City) as yanan
on xian.date = yanan.date
LEFT JOIN
(SELECT a.date,(a.qty-b.qty) as yangling from
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-1,120) and city = '杨凌') as a 
LEFT JOIN 
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-2,120) and city = '杨凌') as b
on a.City = b.City) as yangling
on xian.date = yangling.date
LEFT JOIN
(SELECT a.date,(a.qty-b.qty) as yulin from
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-1,120) and city = '榆林') as a 
LEFT JOIN 
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-2,120) and city = '榆林') as b
on a.City = b.City) as yulin
on xian.date = yulin.date
LEFT JOIN
(SELECT a.date,(a.qty-b.qty) as SHD from
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-1,120) and city = '三环（东站）') as a 
LEFT JOIN 
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-2,120) and city = '三环（东站）') as b
on a.City = b.City) as SHD
on xian.date = SHD.date
LEFT JOIN
(SELECT a.date,(a.qty-b.qty) as SHX from
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-1,120) and city = '三环（西站）') as a 
LEFT JOIN 
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-2,120) and city = '三环（西站）') as b
on a.City = b.City) as SHX
on xian.date = SHX.date
LEFT JOIN
(SELECT a.date,(a.qty-b.qty) as XLB from
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-1,120) and city = '新力（北站）') as a 
LEFT JOIN 
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-2,120) and city = '新力（北站）') as b
on a.City = b.City) as XLB
on xian.date = XLB.date
LEFT JOIN
(SELECT a.date,(a.qty-b.qty) as HRN from
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-1,120) and city = '弘瑞（南站）') as a 
LEFT JOIN 
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-2,120) and city = '弘瑞（南站）') as b
on a.City = b.City) as HRN
on xian.date = HRN.date
LEFT JOIN
(SELECT a.date,(a.qty-b.qty) as GJBF from
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-1,120) and city = '北方(公交)') as a 
LEFT JOIN 
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-2,120) and city = '北方(公交)') as b
on a.City = b.City) as GJBF
on xian.date = GJBF.date
LEFT JOIN ( 
SELECT CONVERT(char(10),GETDATE()-1,120) as date,count(*) as n FROM [carreg].dbo.Main) as summ
ON  xian.date = summ.date









-------------------------------------------
--截止当前为止，五个站点的累计用户数（车辆数）
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
WHEN m_Checker = 'SHD00' THEN '三环（东站）' 
WHEN m_Checker = 'SHD01' THEN '三环（东站）' 
WHEN m_Checker = 'SHD02' THEN '三环（东站）' 
WHEN m_Checker = 'SHD03' THEN '三环（东站）' 
WHEN m_Checker = 'SHD04' THEN '三环（东站）' 
WHEN m_Checker = 'SHD05' THEN '三环（东站）' 
WHEN m_Checker = '白宝丽' THEN '三环（东站）' 
WHEN m_Checker = '陈娟' THEN '三环（东站）' 
WHEN m_Checker = '崔文娟' THEN '三环（东站）' 
WHEN m_Checker = '关飞' THEN '三环（东站）' 
WHEN m_Checker = '郭严' THEN '三环（东站）' 
WHEN m_Checker = '刘芳' THEN '三环（东站）' 
WHEN m_Checker = '陆秦' THEN '三环（东站）' 
WHEN m_Checker = '潘迎丽' THEN '三环（东站）' 
WHEN m_Checker = '裴荣荣' THEN '三环（东站）' 
WHEN m_Checker = '乔秀霞' THEN '三环（东站）' 
WHEN m_Checker = '三环燃气汽车中心4' THEN '三环（东站）' 
WHEN m_Checker = '试用1' THEN '三环（东站）' 
WHEN m_Checker = '孙建茹' THEN '三环（东站）' 
WHEN m_Checker = '王祎' THEN '三环（东站）' 
WHEN m_Checker = '西安东录入' THEN '三环（东站）' 
WHEN m_Checker = '西安东注册' THEN '三环（东站）' 
WHEN m_Checker = '薛丹' THEN '三环（东站）' 
WHEN m_Checker = '姚娟' THEN '三环（东站）' 
WHEN m_Checker = '叶飞' THEN '三环（东站）' 
WHEN m_Checker = '叶至柔' THEN '三环（东站）' 
WHEN m_Checker = '张萍' THEN '三环（东站）' 
WHEN m_Checker = '张晓红' THEN '三环（东站）' 
WHEN m_Checker = '张引弟' THEN '三环（东站）' 
WHEN m_Checker = '张颖' THEN '三环（东站）' 
WHEN m_Checker = 'HR001' THEN '弘瑞（南站）' 
WHEN m_Checker = 'HR002' THEN '弘瑞（南站）' 
WHEN m_Checker = '弘瑞注册' THEN '弘瑞（南站）' 
WHEN m_Checker = '徐晶' THEN '弘瑞（南站）' 
WHEN m_Checker = 'SHX00' THEN '三环（西站）' 
WHEN m_Checker = 'SHX01' THEN '三环（西站）' 
WHEN m_Checker = 'SHX02' THEN '三环（西站）' 
WHEN m_Checker = 'SHX03' THEN '三环（西站）' 
WHEN m_Checker = 'SHX04' THEN '三环（西站）' 
WHEN m_Checker = 'SHX05' THEN '三环（西站）' 
WHEN m_Checker = '贺海莹' THEN '三环（西站）' 
WHEN m_Checker = '刘盈' THEN '三环（西站）' 
WHEN m_Checker = '孙凤' THEN '三环（西站）' 
WHEN m_Checker = '汪孟君' THEN '三环（西站）' 
WHEN m_Checker = '王贝贝' THEN '三环（西站）' 
WHEN m_Checker = '王思同' THEN '三环（西站）' 
WHEN m_Checker = '王晓荣' THEN '三环（西站）'
WHEN m_Checker = '西安西注册' THEN '三环（西站）'
WHEN m_Checker = '张双娟' THEN '三环（西站）'
WHEN m_Checker = '张娱' THEN '三环（西站）'
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
WHEN m_Checker = 'SHD00' THEN '三环（东站）' 
WHEN m_Checker = 'SHD01' THEN '三环（东站）' 
WHEN m_Checker = 'SHD02' THEN '三环（东站）' 
WHEN m_Checker = 'SHD03' THEN '三环（东站）' 
WHEN m_Checker = 'SHD04' THEN '三环（东站）' 
WHEN m_Checker = 'SHD05' THEN '三环（东站）' 
WHEN m_Checker = '白宝丽' THEN '三环（东站）' 
WHEN m_Checker = '陈娟' THEN '三环（东站）' 
WHEN m_Checker = '崔文娟' THEN '三环（东站）' 
WHEN m_Checker = '关飞' THEN '三环（东站）' 
WHEN m_Checker = '郭严' THEN '三环（东站）' 
WHEN m_Checker = '刘芳' THEN '三环（东站）' 
WHEN m_Checker = '陆秦' THEN '三环（东站）' 
WHEN m_Checker = '潘迎丽' THEN '三环（东站）' 
WHEN m_Checker = '裴荣荣' THEN '三环（东站）' 
WHEN m_Checker = '乔秀霞' THEN '三环（东站）' 
WHEN m_Checker = '三环燃气汽车中心4' THEN '三环（东站）' 
WHEN m_Checker = '试用1' THEN '三环（东站）' 
WHEN m_Checker = '孙建茹' THEN '三环（东站）' 
WHEN m_Checker = '王祎' THEN '三环（东站）' 
WHEN m_Checker = '西安东录入' THEN '三环（东站）' 
WHEN m_Checker = '西安东注册' THEN '三环（东站）' 
WHEN m_Checker = '薛丹' THEN '三环（东站）' 
WHEN m_Checker = '姚娟' THEN '三环（东站）' 
WHEN m_Checker = '叶飞' THEN '三环（东站）' 
WHEN m_Checker = '叶至柔' THEN '三环（东站）' 
WHEN m_Checker = '张萍' THEN '三环（东站）' 
WHEN m_Checker = '张晓红' THEN '三环（东站）' 
WHEN m_Checker = '张引弟' THEN '三环（东站）' 
WHEN m_Checker = '张颖' THEN '三环（东站）' 
WHEN m_Checker = 'HR001' THEN '弘瑞（南站）' 
WHEN m_Checker = 'HR002' THEN '弘瑞（南站）' 
WHEN m_Checker = '弘瑞注册' THEN '弘瑞（南站）' 
WHEN m_Checker = '徐晶' THEN '弘瑞（南站）' 
WHEN m_Checker = 'SHX00' THEN '三环（西站）' 
WHEN m_Checker = 'SHX01' THEN '三环（西站）' 
WHEN m_Checker = 'SHX02' THEN '三环（西站）' 
WHEN m_Checker = 'SHX03' THEN '三环（西站）' 
WHEN m_Checker = 'SHX04' THEN '三环（西站）' 
WHEN m_Checker = 'SHX05' THEN '三环（西站）' 
WHEN m_Checker = '贺海莹' THEN '三环（西站）' 
WHEN m_Checker = '刘盈' THEN '三环（西站）' 
WHEN m_Checker = '孙凤' THEN '三环（西站）' 
WHEN m_Checker = '汪孟君' THEN '三环（西站）' 
WHEN m_Checker = '王贝贝' THEN '三环（西站）' 
WHEN m_Checker = '王思同' THEN '三环（西站）' 
WHEN m_Checker = '王晓荣' THEN '三环（西站）'
WHEN m_Checker = '西安西注册' THEN '三环（西站）'
WHEN m_Checker = '张双娟' THEN '三环（西站）'
WHEN m_Checker = '张娱' THEN '三环（西站）'
WHEN m_Checker = 'XIN001' THEN '新奥'
WHEN m_Checker = 'XIN002' THEN '新奥'
WHEN m_Checker = 'XL001' THEN '新力（北站）'
WHEN m_Checker = 'XL002' THEN '新力（北站）'
WHEN m_Checker = '陈捷' THEN '新力（北站）'
WHEN m_Checker = '陈婕' THEN '新力（北站）'
WHEN m_Checker = '新力注册' THEN '新力（北站）'
ELSE m_Checker END)


--当天瓶检数量
SELECT
	CONVERT(char(10),GETDATE()-1,120) as date,
	(case WHEN m_Checker = 'BF001' THEN '北方(公交)' 
WHEN m_Checker = 'BF002' THEN '北方(公交)' 
WHEN m_Checker = '冯静' THEN '北方(公交)' 
WHEN m_Checker = '李文昊' THEN '北方(公交)' 
WHEN m_Checker = 'SHD00' THEN '三环（东站）' 
WHEN m_Checker = 'SHD01' THEN '三环（东站）' 
WHEN m_Checker = 'SHD02' THEN '三环（东站）' 
WHEN m_Checker = 'SHD03' THEN '三环（东站）' 
WHEN m_Checker = 'SHD04' THEN '三环（东站）' 
WHEN m_Checker = 'SHD05' THEN '三环（东站）' 
WHEN m_Checker = '白宝丽' THEN '三环（东站）' 
WHEN m_Checker = '陈娟' THEN '三环（东站）' 
WHEN m_Checker = '崔文娟' THEN '三环（东站）' 
WHEN m_Checker = '关飞' THEN '三环（东站）' 
WHEN m_Checker = '郭严' THEN '三环（东站）' 
WHEN m_Checker = '刘芳' THEN '三环（东站）' 
WHEN m_Checker = '陆秦' THEN '三环（东站）' 
WHEN m_Checker = '潘迎丽' THEN '三环（东站）' 
WHEN m_Checker = '裴荣荣' THEN '三环（东站）' 
WHEN m_Checker = '乔秀霞' THEN '三环（东站）' 
WHEN m_Checker = '三环燃气汽车中心4' THEN '三环（东站）' 
WHEN m_Checker = '试用1' THEN '三环（东站）' 
WHEN m_Checker = '孙建茹' THEN '三环（东站）' 
WHEN m_Checker = '王祎' THEN '三环（东站）' 
WHEN m_Checker = '西安东录入' THEN '三环（东站）' 
WHEN m_Checker = '西安东注册' THEN '三环（东站）' 
WHEN m_Checker = '薛丹' THEN '三环（东站）' 
WHEN m_Checker = '姚娟' THEN '三环（东站）' 
WHEN m_Checker = '叶飞' THEN '三环（东站）' 
WHEN m_Checker = '叶至柔' THEN '三环（东站）' 
WHEN m_Checker = '张萍' THEN '三环（东站）' 
WHEN m_Checker = '张晓红' THEN '三环（东站）' 
WHEN m_Checker = '张引弟' THEN '三环（东站）' 
WHEN m_Checker = '张颖' THEN '三环（东站）' 
WHEN m_Checker = 'HR001' THEN '弘瑞（南站）' 
WHEN m_Checker = 'HR002' THEN '弘瑞（南站）' 
WHEN m_Checker = '弘瑞注册' THEN '弘瑞（南站）' 
WHEN m_Checker = '徐晶' THEN '弘瑞（南站）' 
WHEN m_Checker = 'SHX00' THEN '三环（西站）' 
WHEN m_Checker = 'SHX01' THEN '三环（西站）' 
WHEN m_Checker = 'SHX02' THEN '三环（西站）' 
WHEN m_Checker = 'SHX03' THEN '三环（西站）' 
WHEN m_Checker = 'SHX04' THEN '三环（西站）' 
WHEN m_Checker = 'SHX05' THEN '三环（西站）' 
WHEN m_Checker = '贺海莹' THEN '三环（西站）' 
WHEN m_Checker = '刘盈' THEN '三环（西站）' 
WHEN m_Checker = '孙凤' THEN '三环（西站）' 
WHEN m_Checker = '汪孟君' THEN '三环（西站）' 
WHEN m_Checker = '王贝贝' THEN '三环（西站）' 
WHEN m_Checker = '王思同' THEN '三环（西站）' 
WHEN m_Checker = '王晓荣' THEN '三环（西站）'
WHEN m_Checker = '西安西注册' THEN '三环（西站）'
WHEN m_Checker = '张双娟' THEN '三环（西站）'
WHEN m_Checker = '张娱' THEN '三环（西站）'
WHEN m_Checker = 'XIN001' THEN '新奥'
WHEN m_Checker = 'XIN002' THEN '新奥'
WHEN m_Checker = 'XL001' THEN '新力（北站）'
WHEN m_Checker = 'XL002' THEN '新力（北站）'
WHEN m_Checker = '陈捷' THEN '新力（北站）'
WHEN m_Checker = '陈婕' THEN '新力（北站）'
WHEN m_Checker = '新力注册' THEN '新力（北站）'
ELSE m_Checker END) as station,
	COUNT (*) AS number
FROM
	CarReg.dbo.Main
WHERE
	m_ReportCode <> '' AND
m_printdate <> ''
AND m_LicNum = 'SA'
AND m_StartTime BETWEEN '2016-12-9'--CONVERT (CHAR(10), GETDATE() - 2, 121)
AND '2016-12-10'--CONVERT (CHAR(10), GETDATE() - 1, 121)
GROUP BY 
	(case WHEN m_Checker = 'BF001' THEN '北方(公交)' 
WHEN m_Checker = 'BF002' THEN '北方(公交)' 
WHEN m_Checker = '冯静' THEN '北方(公交)' 
WHEN m_Checker = '李文昊' THEN '北方(公交)' 
WHEN m_Checker = 'SHD00' THEN '三环（东站）' 
WHEN m_Checker = 'SHD01' THEN '三环（东站）' 
WHEN m_Checker = 'SHD02' THEN '三环（东站）' 
WHEN m_Checker = 'SHD03' THEN '三环（东站）' 
WHEN m_Checker = 'SHD04' THEN '三环（东站）' 
WHEN m_Checker = 'SHD05' THEN '三环（东站）' 
WHEN m_Checker = '白宝丽' THEN '三环（东站）' 
WHEN m_Checker = '陈娟' THEN '三环（东站）' 
WHEN m_Checker = '崔文娟' THEN '三环（东站）' 
WHEN m_Checker = '关飞' THEN '三环（东站）' 
WHEN m_Checker = '郭严' THEN '三环（东站）' 
WHEN m_Checker = '刘芳' THEN '三环（东站）' 
WHEN m_Checker = '陆秦' THEN '三环（东站）' 
WHEN m_Checker = '潘迎丽' THEN '三环（东站）' 
WHEN m_Checker = '裴荣荣' THEN '三环（东站）' 
WHEN m_Checker = '乔秀霞' THEN '三环（东站）' 
WHEN m_Checker = '三环燃气汽车中心4' THEN '三环（东站）' 
WHEN m_Checker = '试用1' THEN '三环（东站）' 
WHEN m_Checker = '孙建茹' THEN '三环（东站）' 
WHEN m_Checker = '王祎' THEN '三环（东站）' 
WHEN m_Checker = '西安东录入' THEN '三环（东站）' 
WHEN m_Checker = '西安东注册' THEN '三环（东站）' 
WHEN m_Checker = '薛丹' THEN '三环（东站）' 
WHEN m_Checker = '姚娟' THEN '三环（东站）' 
WHEN m_Checker = '叶飞' THEN '三环（东站）' 
WHEN m_Checker = '叶至柔' THEN '三环（东站）' 
WHEN m_Checker = '张萍' THEN '三环（东站）' 
WHEN m_Checker = '张晓红' THEN '三环（东站）' 
WHEN m_Checker = '张引弟' THEN '三环（东站）' 
WHEN m_Checker = '张颖' THEN '三环（东站）' 
WHEN m_Checker = 'HR001' THEN '弘瑞（南站）' 
WHEN m_Checker = 'HR002' THEN '弘瑞（南站）' 
WHEN m_Checker = '弘瑞注册' THEN '弘瑞（南站）' 
WHEN m_Checker = '徐晶' THEN '弘瑞（南站）' 
WHEN m_Checker = 'SHX00' THEN '三环（西站）' 
WHEN m_Checker = 'SHX01' THEN '三环（西站）' 
WHEN m_Checker = 'SHX02' THEN '三环（西站）' 
WHEN m_Checker = 'SHX03' THEN '三环（西站）' 
WHEN m_Checker = 'SHX04' THEN '三环（西站）' 
WHEN m_Checker = 'SHX05' THEN '三环（西站）' 
WHEN m_Checker = '贺海莹' THEN '三环（西站）' 
WHEN m_Checker = '刘盈' THEN '三环（西站）' 
WHEN m_Checker = '孙凤' THEN '三环（西站）' 
WHEN m_Checker = '汪孟君' THEN '三环（西站）' 
WHEN m_Checker = '王贝贝' THEN '三环（西站）' 
WHEN m_Checker = '王思同' THEN '三环（西站）' 
WHEN m_Checker = '王晓荣' THEN '三环（西站）'
WHEN m_Checker = '西安西注册' THEN '三环（西站）'
WHEN m_Checker = '张双娟' THEN '三环（西站）'
WHEN m_Checker = '张娱' THEN '三环（西站）'
WHEN m_Checker = 'XIN001' THEN '新奥'
WHEN m_Checker = 'XIN002' THEN '新奥'
WHEN m_Checker = 'XL001' THEN '新力（北站）'
WHEN m_Checker = 'XL002' THEN '新力（北站）'
WHEN m_Checker = '陈捷' THEN '新力（北站）'
WHEN m_Checker = '陈婕' THEN '新力（北站）'
WHEN m_Checker = '新力注册' THEN '新力（北站）'
ELSE m_Checker END) 


------------------------------------------------------------------------------------------------------
--Car_daily_qty
create table [07Reports].dbo.Car_daily_qty(
id int identity(1,1) not null,
date varchar(36) NOT NULL,
City varchar(36) NOT NULL,
Sum int NOT NULL,
Increment int NOT NULL,
check_number int NOT NULL,
times_tamp datetime default (getdate()),
primary key (id)
)

INSERT INTO [07Reports].dbo.Car_daily_qty (DATE, City,Sum, Increment,check_number)

SELECT 
CONVERT (CHAR(10), getdate() - 1, 120) AS DATE,
a.City,
b.qty as Sum,
(CONVERT(int,b.qty)-CONVERT(int,a.qty)) as Increment,
isnull(c.check_number,0)  as check_number
FROM (
SELECT *  FROM [07reports].dbo.car_province_daily_qty where date = CONVERT (CHAR(10), getdate() - 2, 120)) as a 
LEFT JOIN
(SELECT *  FROM [07reports].dbo.car_province_daily_qty where date = CONVERT (CHAR(10), getdate() - 1, 120)) as b
on a.city = b.city
LEFT JOIN
(SELECT a.cm_changedate,a.type,sum(a.n) as check_number from (
SELECT 
CONVERT(char(10),cm_changedate,120) as cm_changedate,
(case WHEN substring(cm_changeman,1,3) = 'SHD' THEN '三环（东站）' 
WHEN substring(cm_changeman,1,3) = 'SHX' THEN '三环（西站）' 
WHEN substring(cm_changeman,1,2) = 'XL' THEN '新力（北站）' 
WHEN substring(cm_changeman,1,2) = 'HR' THEN '弘瑞（南站）' 
WHEN substring(cm_changeman,1,2) = 'BF' THEN '北方(公交)'
ELSE cm_changeman END ) as type,
count(*) as n
 FROM CarReg.dbo.ChangeMemo as a 
LEFT JOIN(
SELECT * FROM CarReg.dbo.main) as b
on a.m_id = b.m_id
WHERE cm_changedate BETWEEN CONVERT(char(10),GETDATE()-1,120) and CONVERT(char(10),GETDATE(),120)
 and substring(cm_ChangeContent,1,7) = '原定检报告编号'  
GROUP BY 
cm_changedate,
(case WHEN substring(cm_changeman,1,3) = 'SHD' THEN '三环（东站）' 
WHEN substring(cm_changeman,1,3) = 'SHX' THEN '三环（西站）' 
WHEN substring(cm_changeman,1,2) = 'XL' THEN '新力（北站）' 
WHEN substring(cm_changeman,1,2) = 'HR' THEN '弘瑞（南站）' 
WHEN substring(cm_changeman,1,2) = 'BF' THEN '北方(公交)'
ELSE cm_changeman END )
) as a 
GROUP BY a.cm_changedate,a.type ) as c
on a.city = c.type and a.date = c.cm_changedate
GROUP BY a.City,(CONVERT(int,b.qty)-CONVERT(int,a.qty)),b.qty,c.check_number





/*
SELECT 
CONVERT (CHAR(10), getdate() - 1, 120) AS DATE,
a.City,
b.qty as Sum,
(CONVERT(int,b.qty)-CONVERT(int,a.qty)) as Increment,
--(case when c.check_number = null then 0 else c.check_number end ) as check_number
isnull(c.check_number,0)  as check_number
FROM (
SELECT *  FROM [07reports].dbo.car_province_daily_qty where date = CONVERT (CHAR(10), getdate() - 2, 120)) as a 
LEFT JOIN
(SELECT *  FROM [07reports].dbo.car_province_daily_qty where date = CONVERT (CHAR(10), getdate() - 1, 120)) as b
on a.city = b.city
LEFT JOIN
(SELECT
	CONVERT(char(10),GETDATE()-1,120) as date,
(case WHEN m_Checker = 'BF001' THEN '北方(公交)' 
WHEN m_Checker = 'BF002' THEN '北方(公交)' 
WHEN m_Checker = '冯静' THEN '北方(公交)' 
WHEN m_Checker = '李文昊' THEN '北方(公交)' 
WHEN m_Checker = 'SHD00' THEN '三环（东站）' 
WHEN m_Checker = 'SHD01' THEN '三环（东站）' 
WHEN m_Checker = 'SHD02' THEN '三环（东站）' 
WHEN m_Checker = 'SHD03' THEN '三环（东站）' 
WHEN m_Checker = 'SHD04' THEN '三环（东站）' 
WHEN m_Checker = 'SHD05' THEN '三环（东站）' 
WHEN m_Checker = '白宝丽' THEN '三环（东站）' 
WHEN m_Checker = '陈娟' THEN '三环（东站）' 
WHEN m_Checker = '崔文娟' THEN '三环（东站）' 
WHEN m_Checker = '关飞' THEN '三环（东站）' 
WHEN m_Checker = '郭严' THEN '三环（东站）' 
WHEN m_Checker = '刘芳' THEN '三环（东站）' 
WHEN m_Checker = '陆秦' THEN '三环（东站）' 
WHEN m_Checker = '潘迎丽' THEN '三环（东站）' 
WHEN m_Checker = '裴荣荣' THEN '三环（东站）' 
WHEN m_Checker = '乔秀霞' THEN '三环（东站）' 
WHEN m_Checker = '三环燃气汽车中心4' THEN '三环（东站）' 
WHEN m_Checker = '试用1' THEN '三环（东站）' 
WHEN m_Checker = '孙建茹' THEN '三环（东站）' 
WHEN m_Checker = '王祎' THEN '三环（东站）' 
WHEN m_Checker = '西安东录入' THEN '三环（东站）' 
WHEN m_Checker = '西安东注册' THEN '三环（东站）' 
WHEN m_Checker = '薛丹' THEN '三环（东站）' 
WHEN m_Checker = '姚娟' THEN '三环（东站）' 
WHEN m_Checker = '叶飞' THEN '三环（东站）' 
WHEN m_Checker = '叶至柔' THEN '三环（东站）' 
WHEN m_Checker = '张萍' THEN '三环（东站）' 
WHEN m_Checker = '张晓红' THEN '三环（东站）' 
WHEN m_Checker = '张引弟' THEN '三环（东站）' 
WHEN m_Checker = '张颖' THEN '三环（东站）' 
WHEN m_Checker = 'HR001' THEN '弘瑞（南站）' 
WHEN m_Checker = 'HR002' THEN '弘瑞（南站）' 
WHEN m_Checker = '弘瑞注册' THEN '弘瑞（南站）' 
WHEN m_Checker = '徐晶' THEN '弘瑞（南站）' 
WHEN m_Checker = 'SHX00' THEN '三环（西站）' 
WHEN m_Checker = 'SHX01' THEN '三环（西站）' 
WHEN m_Checker = 'SHX02' THEN '三环（西站）' 
WHEN m_Checker = 'SHX03' THEN '三环（西站）' 
WHEN m_Checker = 'SHX04' THEN '三环（西站）' 
WHEN m_Checker = 'SHX05' THEN '三环（西站）' 
WHEN m_Checker = '贺海莹' THEN '三环（西站）' 
WHEN m_Checker = '刘盈' THEN '三环（西站）' 
WHEN m_Checker = '孙凤' THEN '三环（西站）' 
WHEN m_Checker = '汪孟君' THEN '三环（西站）' 
WHEN m_Checker = '王贝贝' THEN '三环（西站）' 
WHEN m_Checker = '王思同' THEN '三环（西站）' 
WHEN m_Checker = '王晓荣' THEN '三环（西站）'
WHEN m_Checker = '西安西注册' THEN '三环（西站）'
WHEN m_Checker = '张双娟' THEN '三环（西站）'
WHEN m_Checker = '张娱' THEN '三环（西站）'
WHEN m_Checker = 'XIN001' THEN '新奥'
WHEN m_Checker = 'XIN002' THEN '新奥'
WHEN m_Checker = 'XL001' THEN '新力（北站）'
WHEN m_Checker = 'XL002' THEN '新力（北站）'
WHEN m_Checker = '陈捷' THEN '新力（北站）'
WHEN m_Checker = '陈婕' THEN '新力（北站）'
WHEN m_Checker = '新力注册' THEN '新力（北站）'
ELSE m_Checker END) as station,
	COUNT (*) AS check_number
FROM
	CarReg.dbo.Main
WHERE
	m_ReportCode <> '' AND
m_printdate <> ''
AND m_LicNum = 'SA'
AND m_StartTime = CONVERT (CHAR(10), GETDATE() - 1, 121)
GROUP BY 
(case WHEN m_Checker = 'BF001' THEN '北方(公交)' 
WHEN m_Checker = 'BF002' THEN '北方(公交)' 
WHEN m_Checker = '冯静' THEN '北方(公交)' 
WHEN m_Checker = '李文昊' THEN '北方(公交)' 
WHEN m_Checker = 'SHD00' THEN '三环（东站）' 
WHEN m_Checker = 'SHD01' THEN '三环（东站）' 
WHEN m_Checker = 'SHD02' THEN '三环（东站）' 
WHEN m_Checker = 'SHD03' THEN '三环（东站）' 
WHEN m_Checker = 'SHD04' THEN '三环（东站）' 
WHEN m_Checker = 'SHD05' THEN '三环（东站）' 
WHEN m_Checker = '白宝丽' THEN '三环（东站）' 
WHEN m_Checker = '陈娟' THEN '三环（东站）' 
WHEN m_Checker = '崔文娟' THEN '三环（东站）' 
WHEN m_Checker = '关飞' THEN '三环（东站）' 
WHEN m_Checker = '郭严' THEN '三环（东站）' 
WHEN m_Checker = '刘芳' THEN '三环（东站）' 
WHEN m_Checker = '陆秦' THEN '三环（东站）' 
WHEN m_Checker = '潘迎丽' THEN '三环（东站）' 
WHEN m_Checker = '裴荣荣' THEN '三环（东站）' 
WHEN m_Checker = '乔秀霞' THEN '三环（东站）' 
WHEN m_Checker = '三环燃气汽车中心4' THEN '三环（东站）' 
WHEN m_Checker = '试用1' THEN '三环（东站）' 
WHEN m_Checker = '孙建茹' THEN '三环（东站）' 
WHEN m_Checker = '王祎' THEN '三环（东站）' 
WHEN m_Checker = '西安东录入' THEN '三环（东站）' 
WHEN m_Checker = '西安东注册' THEN '三环（东站）' 
WHEN m_Checker = '薛丹' THEN '三环（东站）' 
WHEN m_Checker = '姚娟' THEN '三环（东站）' 
WHEN m_Checker = '叶飞' THEN '三环（东站）' 
WHEN m_Checker = '叶至柔' THEN '三环（东站）' 
WHEN m_Checker = '张萍' THEN '三环（东站）' 
WHEN m_Checker = '张晓红' THEN '三环（东站）' 
WHEN m_Checker = '张引弟' THEN '三环（东站）' 
WHEN m_Checker = '张颖' THEN '三环（东站）' 
WHEN m_Checker = 'HR001' THEN '弘瑞（南站）' 
WHEN m_Checker = 'HR002' THEN '弘瑞（南站）' 
WHEN m_Checker = '弘瑞注册' THEN '弘瑞（南站）' 
WHEN m_Checker = '徐晶' THEN '弘瑞（南站）' 
WHEN m_Checker = 'SHX00' THEN '三环（西站）' 
WHEN m_Checker = 'SHX01' THEN '三环（西站）' 
WHEN m_Checker = 'SHX02' THEN '三环（西站）' 
WHEN m_Checker = 'SHX03' THEN '三环（西站）' 
WHEN m_Checker = 'SHX04' THEN '三环（西站）' 
WHEN m_Checker = 'SHX05' THEN '三环（西站）' 
WHEN m_Checker = '贺海莹' THEN '三环（西站）' 
WHEN m_Checker = '刘盈' THEN '三环（西站）' 
WHEN m_Checker = '孙凤' THEN '三环（西站）' 
WHEN m_Checker = '汪孟君' THEN '三环（西站）' 
WHEN m_Checker = '王贝贝' THEN '三环（西站）' 
WHEN m_Checker = '王思同' THEN '三环（西站）' 
WHEN m_Checker = '王晓荣' THEN '三环（西站）'
WHEN m_Checker = '西安西注册' THEN '三环（西站）'
WHEN m_Checker = '张双娟' THEN '三环（西站）'
WHEN m_Checker = '张娱' THEN '三环（西站）'
WHEN m_Checker = 'XIN001' THEN '新奥'
WHEN m_Checker = 'XIN002' THEN '新奥'
WHEN m_Checker = 'XL001' THEN '新力（北站）'
WHEN m_Checker = 'XL002' THEN '新力（北站）'
WHEN m_Checker = '陈捷' THEN '新力（北站）'
WHEN m_Checker = '陈婕' THEN '新力（北站）'
WHEN m_Checker = '新力注册' THEN '新力（北站）'
ELSE m_Checker END) ) as c
on a.city = c.station
GROUP BY a.City,(CONVERT(int,b.qty)-CONVERT(int,a.qty)),b.qty,c.check_number
*/
----------------------------------------
--距今为止2年内未到检车辆信息详情：
create table [07Reports].dbo.car_Expiration_check_daily(
id int identity(1,1) not null,
car_id varchar(255),
user_name varchar(255),
user_phone varchar(36) NOT NULL,
check_date varchar(36) NOT NULL,
minus_days INT,
car_type varchar(36) NOT NULL,
times_tamp datetime default (getdate()),
primary key (id)
)

TRUNCATE TABLE [07Reports].dbo.car_Expiration_check_daily
INSERT INTO [07Reports].dbo.car_Expiration_check_daily (car_id, user_name, user_phone,check_date,minus_days,car_type)
SELECT DISTINCT
	(d.m_CH) AS car_id,
	d.m_linkman AS user_name,
	d.m_linktel AS user_phone,
	CONVERT(char(10),d.sub_checkdate,120) AS check_date,
	datediff(
		DAY,
		getdate(),
		sub_checkdate
	) AS minus_days,
	d.aaa AS car_type
FROM
	(	SELECT
			a.m_LicNum,
			a.m_CH,
			b.Sub_Installdate,
			b.sub_firstdate,
			b.sub_checkdate,
			a.m_CompanyNum,
			a.m_linkman,
			a.m_linktel,
(	CASE
	WHEN a.m_JZ = 'A' THEN
		'私家车'
	WHEN a.m_JZ = 'B' THEN
		'公交车'
	WHEN a.m_JZ = 'C' THEN
		'快倢货运'
	WHEN a.m_JZ = 'D' THEN
		'D'
	WHEN a.m_JZ = 'H' THEN
		'营运车'
	WHEN a.m_JZ = 'P' THEN
		'公务车'
	WHEN a.m_JZ = 'V' THEN
		'微型货运车'
	WHEN a.m_JZ = 'X' THEN
		'其他'
	WHEN a.m_JZ = 'T' THEN
		'出租车'
	WHEN a.m_JZ = 'J' THEN
		'教练车'
	ELSE
		'm'
	END
) AS aaa  FROM CarReg.dbo.Main  as a 
JOIN (SELECT * from CarReg.dbo.SubMain) as b 
ON a.m_id = b.m_id
where a.m_JZ <> '' and a.m_LicNum = 'SA') as d
where datediff(DAY,getdate(),d.sub_checkdate) > -730 
and  datediff(DAY,getdate(),d.sub_checkdate) < 0
ORDER BY datediff(DAY,getdate(),sub_checkdate) DESC

----------------------------------------

--每年第几周增量统计
--统计5天内注册新增用户量
SELECT datepart(week,getdate()) as week,b.city,(b.sum-a.sum) as register,c.Increment FROM (
SELECT city,sum,Increment FROM car_increment_daily where date = CONVERT(char(10),GETDATE()-6,120)) as a
LEFT JOIN(
SELECT city,sum,Increment FROM car_increment_daily where date = CONVERT(char(10),GETDATE()-1,120)) as b
on a.city = b.city
LEFT JOIN(
SELECT city,sum(Increment) as Increment  FROM car_increment_daily where date BETWEEN CONVERT(char(10),GETDATE()-5,120)--每日净增加天数与累计天数差一天
and CONVERT(char(10),GETDATE()-1,120)
GROUP BY city) as c 
on b.city = c.city
----------------------------------------


--瓶检用户数（老用户）
SELECT 
(case WHEN substring(cm_changeman,1,3) = 'SHD' THEN '东站' 
WHEN substring(cm_changeman,1,3) = 'SHX' THEN '西站' 
WHEN substring(cm_changeman,1,2) = 'XL' THEN '北站' 
WHEN substring(cm_changeman,1,2) = 'HR' THEN '南站' 
WHEN substring(cm_changeman,1,2) = 'BF' THEN '公交'
ELSE cm_changeman END ) as type,
count(*) as num
 FROM CarReg.dbo.ChangeMemo as a 
LEFT JOIN(
SELECT * FROM CarReg.dbo.main) as b
on a.m_id = b.m_id
WHERE cm_changedate BETWEEN CONVERT(char(10),GETDATE(),120) and CONVERT(char(10),GETDATE()+1,120)
 and substring(cm_ChangeContent,1,7) = '原定检报告编号'  
GROUP BY 
(case WHEN substring(cm_changeman,1,3) = 'SHD' THEN '东站' 
WHEN substring(cm_changeman,1,3) = 'SHX' THEN '西站' 
WHEN substring(cm_changeman,1,2) = 'XL' THEN '北站' 
WHEN substring(cm_changeman,1,2) = 'HR' THEN '南站' 
WHEN substring(cm_changeman,1,2) = 'BF' THEN '公交'
ELSE cm_changeman END )

---------------------------------------------------------------------------------------------------------------------
##日瓶检用户总量数据
CREATE TABLE	[Car_ETL].dbo.car_inspect_daily(
id int identity(1,1) not null primary key ,
date varchar(10) NOT NULL,
type varchar(36) NOT NULL,
summ int,
times_tamp datetime default (getdate())
)
TRUNCATE TABLE [Car_ETL].dbo.car_inspect_daily

INSERT INTO [Car_ETL].dbo.car_inspect_daily(date,type,summ) 

SELECT a.date,a.type,sum(a.num) as summ FROM (--老用户瓶检数
SELECT CONVERT(char(10),GETDATE()-1,120) as date,
(case WHEN substring(cm_changeman,1,3) = 'SHD' THEN '三环（东站）' 
WHEN substring(cm_changeman,1,3) = 'SHX' THEN '三环（西站）' 
WHEN substring(cm_changeman,1,2) = 'XL' THEN '新力（北站）' 
WHEN substring(cm_changeman,1,2) = 'HR' THEN '弘瑞（南站）' 
WHEN substring(cm_changeman,1,2) = 'BF' THEN '北方(公交)'
ELSE cm_changeman END ) as type,
count(*) as num
 FROM CarReg.dbo.ChangeMemo as a 
LEFT JOIN(
SELECT * FROM CarReg.dbo.main) as b
on a.m_id = b.m_id
WHERE cm_changedate BETWEEN CONVERT(char(10),GETDATE()-1,120) and CONVERT(char(10),GETDATE(),120)
 and substring(cm_ChangeContent,1,7) = '原定检报告编号'  
GROUP BY 
(case WHEN substring(cm_changeman,1,3) = 'SHD' THEN '三环（东站）' 
WHEN substring(cm_changeman,1,3) = 'SHX' THEN '三环（西站）' 
WHEN substring(cm_changeman,1,2) = 'XL' THEN '新力（北站）' 
WHEN substring(cm_changeman,1,2) = 'HR' THEN '弘瑞（南站）' 
WHEN substring(cm_changeman,1,2) = 'BF' THEN '北方(公交)'
ELSE cm_changeman END )
UNION ALL --新注册用户瓶检数
SELECT CONVERT(char(10),GETDATE()-1,120) as date,
(case WHEN substring(m_Checker,1,3) = 'SHD' THEN '三环（东站）' 
WHEN substring(m_Checker,1,3) = 'SHX' THEN '三环（西站）' 
WHEN substring(m_Checker,1,2) = 'XL' THEN '新力（北站）' 
WHEN substring(m_Checker,1,2) = 'HR' THEN '弘瑞（南站）' 
WHEN substring(m_Checker,1,2) = 'BF' THEN '北方(公交)'
ELSE m_Checker END ) as type,
isnull(count(*),0) as num
 FROM  CarReg.dbo.Main
where m_StartTime = CONVERT(char(10),GETDATE()-1,120)
and m_ReportCode <>'' and m_licnum = 'SA'
GROUP BY
(case WHEN substring(m_Checker,1,3) = 'SHD' THEN '三环（东站）' 
WHEN substring(m_Checker,1,3) = 'SHX' THEN '三环（西站）' 
WHEN substring(m_Checker,1,2) = 'XL' THEN '新力（北站）' 
WHEN substring(m_Checker,1,2) = 'HR' THEN '弘瑞（南站）' 
WHEN substring(m_Checker,1,2) = 'BF' THEN '北方(公交)'
ELSE m_Checker END )) as a 
GROUP BY a.type,a.date

---------------------------------------------------------------------------------------------------------------------
SELECT a.m_CH,a.m_linkman,a.m_linktel,c.oxdditemvalue,d.uc_name,
CONVERT(char(10),b.Sub_CheckDate,120) as Sub_CheckDate,
datediff(DAY,getdate(),b.sub_checkdate) AS minus_days,
CONVERT(char(10),b.Sub_FirstDate,120) as Sub_FirstDate,
CONVERT(char(10),b.Sub_InstallDate,120) as Sub_InstallDate,
CONVERT(char(10),b.Sub_ZZDate,120) as Sub_ZZDate
 FROM CarReg.dbo.Main as a 
LEFT JOIN (select * from  CarReg.dbo.SubMain  where Sub_ID in (
select max(Sub_ID) as Sub_ID  from  CarReg.dbo.SubMain 
GROUP BY m_id)) as b 
ON a.m_id = b.m_id
LEFT JOIN (
SELECT DISTINCT oxdditemvalue,oxdditemkeycode from CarReg.dbo.oxdropdownlist) as c --c.oxdditemvalue
ON a.m_LicNum = c.oxdditemkeycode
LEFT JOIN (
SELECT DISTINCT uc_num,uc_name from CarReg.dbo.UseCompany) as d --d.uc_name
ON a.m_JZ = d.uc_num
where c.oxdditemvalue = '西安' and 
datediff(DAY,getdate(),b.sub_checkdate) > -730 
and  datediff(DAY,getdate(),b.sub_checkdate) < 180
ORDER BY datediff(DAY,getdate(),b.sub_checkdate) DESC
/*
1、Left Join（左联接）
以左表为中心，返回左表中符合条件的所有记录以及右表中联结字段相等的记录——当右表中无相应联接记录时，返回空值。
2、Inner Join（等值连接） 
返回两个表中联结字段相等的行。

注意：如出现重复结果列，要从出现重复源头表的列，开始过滤！

先找出重复的列

SELECT name FROM #TEMP2 GROUP BY name  HAVING COUNT(1)>1

再用EXISTS 和NOT IN UNION ALL
 */



SELECT m_id,m_LicNum,m_CH,m_StartTime,m_Checker,m_CompanyNum,m_linkman,m_linktel,m_ReportCode,m_RegAdd FROM [CarReg].dbo.main

##07report ，日注册量和日瓶检量统计
DROP TABLE [07reports].dbo.Car_daily_detail
CREATE TABLE [07reports].dbo.Car_daily_detail(
id int identity(1,1) not null primary key ,
时间戳 datetime default (getdate()),
日期 varchar(10) NOT NULL,
全省累计用户 int,
全省合计新增用户 int,
西安 int,
咸阳 int,
宝鸡 int,
安康 int,
汉中 int,
商洛 int,
铜川 int,
渭南 int,
延安 int,
杨凌 int,
榆林 int,
三环东站 int,
三环西站 int,
新力北站 int,
弘瑞南站 int,
北方公交 int,
瓶检北站 int,
瓶检南站 int,
瓶检公交 int,
瓶检东站 int,
瓶检西站 int
)


INSERT INTO [07reports].dbo.Car_daily_detail(
日期 ,
全省累计用户,
全省合计新增用户,
西安,
咸阳,
宝鸡,
安康,
汉中,
商洛,
铜川,
渭南,
延安,
杨凌,
榆林,
三环东站,
三环西站,
新力北站,
弘瑞南站,
北方公交,
瓶检北站,
瓶检南站,
瓶检公交,
瓶检东站,
瓶检西站
)
SELECT 
	distinct(xian. DATE) as '日期',--当SQL进行表联合的查询，需要查询后的记录主键进行去重处理，否则会有多条重复记录产生
	summ.n as '全省累计用户',
	(xian.xian + xianyang.xianyang + baoji.baoji + ankang.ankang +
 hanzhong.hanzhong + shangluo.shangluo + tongchuan.tongchuan + weinan.weinan
 + yanan.yanan + yangling.yangling + yulin.yulin) AS '全省合计新增用户',
	xian.xian as '西安',
	xianyang.xianyang  as '咸阳',
	baoji.baoji  as '宝鸡',
	ankang.ankang  as '安康',
	hanzhong.hanzhong  as '汉中',
	shangluo.shangluo  as '商洛',
	tongchuan.tongchuan  as '铜川',
	weinan.weinan  as '渭南',
	yanan.yanan  as '延安',
	yangling.yangling  as '杨凌',
	yulin.yulin  as '榆林',
	SHD.SHD  as '三环（东站）',
	SHX.SHX as '三环（西站）',
	XLB.XLB as '新力（北站）',
	HRN.HRN as '弘瑞（南站）',
	GJBF.GJBF as '北方（公交）',
	isnull(bz.summ,0) as '瓶检（北站）',
	isnull(nz.summ,0) as '瓶检（南站）',
	isnull(bf.summ,0) as '瓶检（公交）',
	isnull(dz.summ,0) as '瓶检（东站）',
	isnull(xz.summ,0) as '瓶检（西站）'
FROM
(SELECT a.date,(a.qty-b.qty) as xian from
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-1,120) and city = '西安') as a 
LEFT JOIN 
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-2,120) and city = '西安') as b
on a.City = b.City) as xian
LEFT JOIN
(SELECT a.date,(a.qty-b.qty) as xianyang from
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-1,120) and city = '咸阳') as a 
LEFT JOIN 
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-2,120) and city = '咸阳') as b
on a.City = b.City) as xianyang
on xian.date = xianyang.date
LEFT JOIN
(SELECT a.date,(a.qty-b.qty) as baoji from
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-1,120) and city = '宝鸡') as a 
LEFT JOIN 
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-2,120) and city = '宝鸡') as b
on a.City = b.City) as baoji
on xian.date = baoji.date
LEFT JOIN
(SELECT a.date,(a.qty-b.qty) as ankang from
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-1,120) and city = '安康') as a 
LEFT JOIN 
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-2,120) and city = '安康') as b
on a.City = b.City) as ankang
on xian.date = ankang.date
LEFT JOIN
(SELECT a.date,(a.qty-b.qty) as hanzhong from
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-1,120) and city = '汉中') as a 
LEFT JOIN 
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-2,120) and city = '汉中') as b
on a.City = b.City) as hanzhong
on xian.date = hanzhong.date
LEFT JOIN
(SELECT a.date,(a.qty-b.qty) as shangluo from
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-1,120) and city = '商洛') as a 
LEFT JOIN 
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-2,120) and city = '商洛') as b
on a.City = b.City) as shangluo
on xian.date = shangluo.date
LEFT JOIN
(SELECT a.date,(a.qty-b.qty) as tongchuan from
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-1,120) and city = '铜川') as a 
LEFT JOIN 
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-2,120) and city = '铜川') as b
on a.City = b.City) as tongchuan
on xian.date = tongchuan.date
LEFT JOIN
(SELECT a.date,(a.qty-b.qty) as weinan from
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-1,120) and city = '渭南') as a 
LEFT JOIN 
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-2,120) and city = '渭南') as b
on a.City = b.City) as weinan
on xian.date = weinan.date
LEFT JOIN
(SELECT a.date,(a.qty-b.qty) as yanan from
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-1,120) and city = '延安') as a 
LEFT JOIN 
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-2,120) and city = '延安') as b
on a.City = b.City) as yanan
on xian.date = yanan.date
LEFT JOIN
(SELECT a.date,(a.qty-b.qty) as yangling from
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-1,120) and city = '杨凌') as a 
LEFT JOIN 
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-2,120) and city = '杨凌') as b
on a.City = b.City) as yangling
on xian.date = yangling.date
LEFT JOIN
(SELECT a.date,(a.qty-b.qty) as yulin from
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-1,120) and city = '榆林') as a 
LEFT JOIN 
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-2,120) and city = '榆林') as b
on a.City = b.City) as yulin
on xian.date = yulin.date
LEFT JOIN
(SELECT a.date,(a.qty-b.qty) as SHD from
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-1,120) and city = '三环（东站）') as a 
LEFT JOIN 
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-2,120) and city = '三环（东站）') as b
on a.City = b.City) as SHD
on xian.date = SHD.date
LEFT JOIN
(SELECT a.date,(a.qty-b.qty) as SHX from
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-1,120) and city = '三环（西站）') as a 
LEFT JOIN 
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-2,120) and city = '三环（西站）') as b
on a.City = b.City) as SHX
on xian.date = SHX.date
LEFT JOIN
(SELECT a.date,(a.qty-b.qty) as XLB from
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-1,120) and city = '新力（北站）') as a 
LEFT JOIN 
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-2,120) and city = '新力（北站）') as b
on a.City = b.City) as XLB
on xian.date = XLB.date
LEFT JOIN
(SELECT a.date,(a.qty-b.qty) as HRN from
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-1,120) and city = '弘瑞（南站）') as a 
LEFT JOIN 
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-2,120) and city = '弘瑞（南站）') as b
on a.City = b.City) as HRN
on xian.date = HRN.date
LEFT JOIN
(SELECT a.date,(a.qty-b.qty) as GJBF from
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-1,120) and city = '北方(公交)') as a 
LEFT JOIN 
(SELECT * FROM [Car_ETL].dbo.car_xa_daily where date = CONVERT (CHAR(10),GETDATE()-2,120) and city = '北方(公交)') as b
on a.City = b.City) as GJBF
on xian.date = GJBF.date
LEFT JOIN ( 
SELECT CONVERT(char(10),GETDATE()-1,120) as date,count(*) as n FROM [carreg].dbo.Main) as summ
ON  xian.date = summ.date
LEFT JOIN (
SELECT date,type,summ from Car_ETL.dbo.car_inspect_daily
where date = CONVERT(char(10),GETDATE()-1,120) and type = '新力（北站）')as bz
ON xian.date = bz.date
LEFT JOIN (
SELECT date,type,summ from Car_ETL.dbo.car_inspect_daily
where date = CONVERT(char(10),GETDATE()-1,120) and type = '弘瑞（南站）')as nz
ON xian.date = nz.date
LEFT JOIN (
SELECT date,type,summ from Car_ETL.dbo.car_inspect_daily
where date = CONVERT(char(10),GETDATE()-1,120) and type = '北方(公交)')as bf
ON xian.date = bf.date
LEFT JOIN (
SELECT date,type,summ from Car_ETL.dbo.car_inspect_daily
where date = CONVERT(char(10),GETDATE()-1,120) and type = '三环（东站）')as dz
ON xian.date = dz.date
LEFT JOIN (
SELECT date,type,summ from Car_ETL.dbo.car_inspect_daily
where date = CONVERT(char(10),GETDATE()-1,120) and type = '三环（西站）')as xz
ON xian.date = xz.date

----------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE [07reports].dbo.Car_Weekly_detail(
id int identity(1,1) not null primary key ,
时间戳 datetime default (getdate()),
[周数] varchar(10) NOT NULL,
[全省累计用户]int,
[全省合计新增用户]int,
[西安] int,
[咸阳] int,
[宝鸡] int,
[安康] int,
[汉中] int,
[商洛] int,
[铜川] int,
[渭南] int,
[延安] int,
[杨凌] int,
[榆林] int,
[三环] int,
[新力北站] int,
[弘瑞南站] int,
[北方公交] int,
[瓶检三环] int,
[瓶检北站] int,
[瓶检南站] int,
[瓶检公交] int
)

INSERT INTO [07reports].dbo.Car_Weekly_detail(
[周数],
[全省累计用户],
[全省合计新增用户],
[西安],
[咸阳],
[宝鸡],
[安康],
[汉中],
[商洛],
[铜川],
[渭南],
[延安],
[杨凌],
[榆林],
[三环],
[新力北站],
[弘瑞南站],
[北方公交],
[瓶检三环],
[瓶检北站],
[瓶检南站],
[瓶检公交]
)
--统计周期是每周日为统计的第一天，周六为最后一天的统计方式计算（本年度1月1号礼拜天，即为统计第一天）
SELECT datepart(week,getdate()-2) as '周数',
a.[全省累计用户],
b.[全省合计新增用户],
c.[西安],
d.[咸阳],
e.[宝鸡],
f.[安康],
g.[汉中],
h.[商洛],
i.[铜川],
j.[渭南],
k.[延安],
l.[杨凌],
m.[榆林],
n.[三环],
o.[新力北站],
p.[弘瑞南站],
q.[北方公交],
r.[瓶检三环],
s.[瓶检北站],
t.[瓶检南站],
u.[瓶检公交]
FROM (select datepart(week,getdate()) as 'Weeks',[全省累计用户] 
from [07reports].dbo.Car_daily_detail 
WHERE [日期] = CONVERT(char(10),GETDATE()-1,120)) as a
LEFT JOIN(select datepart(week,getdate()) as 'Weeks',
sum([全省合计新增用户]) as '全省合计新增用户'
from [07reports].dbo.Car_daily_detail 
WHERE [日期] BETWEEN  CONVERT(char(10),GETDATE()-7,120) AND                       
CONVERT(char(10),GETDATE()-1,120)) as b 
ON a.Weeks = b.Weeks
LEFT JOIN(select datepart(week,getdate()) as 'Weeks',
sum([西安]) as '西安'
from [07reports].dbo.Car_daily_detail 
WHERE [日期] BETWEEN  CONVERT(char(10),GETDATE()-7,120) AND
CONVERT(char(10),GETDATE()-1,120)) as c
ON a.Weeks = c.Weeks
LEFT JOIN(select datepart(week,getdate()) as 'Weeks',
sum([咸阳]) as '咸阳'
from [07reports].dbo.Car_daily_detail 
WHERE [日期] BETWEEN  CONVERT(char(10),GETDATE()-7,120) AND
CONVERT(char(10),GETDATE()-1,120)) as d
ON a.Weeks = d.Weeks
LEFT JOIN(select datepart(week,getdate()) as 'Weeks',
sum([宝鸡]) as '宝鸡'
from [07reports].dbo.Car_daily_detail 
WHERE [日期] BETWEEN  CONVERT(char(10),GETDATE()-7,120) AND
CONVERT(char(10),GETDATE()-1,120)) as e
ON a.Weeks = e.Weeks
LEFT JOIN(select datepart(week,getdate()) as 'Weeks',
sum([安康]) as '安康'
from [07reports].dbo.Car_daily_detail 
WHERE [日期] BETWEEN  CONVERT(char(10),GETDATE()-7,120) AND
CONVERT(char(10),GETDATE()-1,120)) as f
ON a.Weeks = f.Weeks
LEFT JOIN(select datepart(week,getdate()) as 'Weeks',
sum([汉中]) as '汉中'
from [07reports].dbo.Car_daily_detail 
WHERE [日期] BETWEEN  CONVERT(char(10),GETDATE()-7,120) AND
CONVERT(char(10),GETDATE()-1,120)) as g
ON a.Weeks = g.Weeks
LEFT JOIN(select datepart(week,getdate()) as 'Weeks',
sum([商洛]) as '商洛'
from [07reports].dbo.Car_daily_detail 
WHERE [日期] BETWEEN  CONVERT(char(10),GETDATE()-7,120) AND
CONVERT(char(10),GETDATE()-1,120)) as h
ON a.Weeks = h.Weeks
LEFT JOIN(select datepart(week,getdate()) as 'Weeks',
sum([铜川]) as '铜川'
from [07reports].dbo.Car_daily_detail 
WHERE [日期] BETWEEN  CONVERT(char(10),GETDATE()-7,120) AND
CONVERT(char(10),GETDATE()-1,120)) as i
ON a.Weeks = i.Weeks
LEFT JOIN(select datepart(week,getdate()) as 'Weeks',
sum([渭南]) as '渭南'
from [07reports].dbo.Car_daily_detail 
WHERE [日期] BETWEEN  CONVERT(char(10),GETDATE()-7,120) AND
CONVERT(char(10),GETDATE()-1,120)) as j
ON a.Weeks = j.Weeks
LEFT JOIN(select datepart(week,getdate()) as 'Weeks',
sum([延安]) as '延安'
from [07reports].dbo.Car_daily_detail 
WHERE [日期] BETWEEN  CONVERT(char(10),GETDATE()-7,120) AND
CONVERT(char(10),GETDATE()-1,120)) as k
ON a.Weeks = k.Weeks
LEFT JOIN(select datepart(week,getdate()) as 'Weeks',
sum([杨凌]) as '杨凌'
from [07reports].dbo.Car_daily_detail 
WHERE [日期] BETWEEN  CONVERT(char(10),GETDATE()-7,120) AND
CONVERT(char(10),GETDATE()-1,120)) as l
ON a.Weeks = l.Weeks
LEFT JOIN(select datepart(week,getdate()) as 'Weeks',
sum([榆林]) as '榆林'
from [07reports].dbo.Car_daily_detail 
WHERE [日期] BETWEEN  CONVERT(char(10),GETDATE()-7,120) AND
CONVERT(char(10),GETDATE()-1,120)) as m
ON a.Weeks = m.Weeks
LEFT JOIN(select datepart(week,getdate()) as 'Weeks',
sum([三环东站])+sum([三环西站]) as '三环'
from [07reports].dbo.Car_daily_detail 
WHERE [日期] BETWEEN  CONVERT(char(10),GETDATE()-7,120) AND
CONVERT(char(10),GETDATE()-1,120)) as n
ON a.Weeks = n.Weeks
LEFT JOIN(select datepart(week,getdate()) as 'Weeks',
sum([新力北站])as '新力北站'
from [07reports].dbo.Car_daily_detail 
WHERE [日期] BETWEEN  CONVERT(char(10),GETDATE()-7,120) AND
CONVERT(char(10),GETDATE()-1,120)) as o
ON a.Weeks = o.Weeks
LEFT JOIN(select datepart(week,getdate()) as 'Weeks',
sum([弘瑞南站])as '弘瑞南站'
from [07reports].dbo.Car_daily_detail 
WHERE [日期] BETWEEN  CONVERT(char(10),GETDATE()-7,120) AND
CONVERT(char(10),GETDATE()-1,120)) as p
ON a.Weeks = p.Weeks
LEFT JOIN(select datepart(week,getdate()) as 'Weeks',
sum([北方公交])as '北方公交'
from [07reports].dbo.Car_daily_detail 
WHERE [日期] BETWEEN  CONVERT(char(10),GETDATE()-7,120) AND
CONVERT(char(10),GETDATE()-1,120)) as q
ON a.Weeks = q.Weeks
LEFT JOIN(select datepart(week,getdate()) as 'Weeks',
sum([瓶检东站])+sum([瓶检西站]) as '瓶检三环'
from [07reports].dbo.Car_daily_detail 
WHERE [日期] BETWEEN  CONVERT(char(10),GETDATE()-7,120) AND
CONVERT(char(10),GETDATE()-1,120)) as r
ON a.Weeks = r.Weeks
LEFT JOIN(select datepart(week,getdate()) as 'Weeks',
sum([瓶检北站]) as '瓶检北站'
from [07reports].dbo.Car_daily_detail 
WHERE [日期] BETWEEN  CONVERT(char(10),GETDATE()-7,120) AND
CONVERT(char(10),GETDATE()-1,120)) as s
ON a.Weeks = s.Weeks
LEFT JOIN(select datepart(week,getdate()) as 'Weeks',
sum([瓶检南站]) as '瓶检南站'
from [07reports].dbo.Car_daily_detail 
WHERE [日期] BETWEEN  CONVERT(char(10),GETDATE()-7,120) AND
CONVERT(char(10),GETDATE()-1,120)) as t
ON a.Weeks = t.Weeks
LEFT JOIN(select datepart(week,getdate()) as 'Weeks',
sum([瓶检公交]) as '瓶检公交'
from [07reports].dbo.Car_daily_detail 
WHERE [日期] BETWEEN  CONVERT(char(10),GETDATE()-7,120) AND
CONVERT(char(10),GETDATE()-1,120)) as u
ON a.Weeks = u.Weeks







































