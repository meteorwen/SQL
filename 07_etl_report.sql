daily_report
--用户基本信息 
#######################################################################################################################
create table [07_ETL].dbo.dq_daily_user(
id int identity(1,1) not null primary key,
Dates varchar(10) NOT NULL,
total INT NOT NULL,
Personal INT NOT NULL,
Business INT NOT NULL,
new_user INT NOT NULL,
availability_user INT NOT NULL,
man INT NOT NULL,
female INT NOT NULL,
age20to24 INT NOT NULL,
age25to29 INT NOT NULL,
age30to34 INT NOT NULL,
age35to39 INT NOT NULL,
age40to44 INT NOT NULL,
age45to49 INT NOT NULL,
age50to54 INT NOT NULL,
age55to59 INT NOT NULL,
age60plus INT NOT NULL,
times_tamp datetime default (getdate())
)

TRUNCATE TABLE [07_ETL].dbo.dq_daily_user


INSERT INTO [07_ETL].dbo.dq_daily_user(Dates,total,personal,business,
new_user,availability_user,man,female,age20to24,
age25to29,age30to34,age35to39,age40to44,age45to49,age50to54,age55to59,age60plus) 

SELECT a.Dates,a.total,d.personal,e.business,
b.new_user,c.availability_user,f.man,g.female,h.age20to24,
i.age25to29,j.age30to34,k.age35to39,l.age40to44,m.age45to49,n.age50to54,o.age55to59,p.age60plus
 FROM
(SELECT CONVERT(char(10),GETDATE(),120) as Dates,count(*) as total 
FROM bs07.dbo.C_CUSTOMER_INFORMATION) as a--总人数
LEFT JOIN(
SELECT CONVERT(char(10),GETDATE(),120) as Dates,count(*) as new_user
FROM  bs07.dbo.C_CUSTOMER_INFORMATION 
where CONVERT(char(10),operate_time,120) = CONVERT(char(10),GETDATE(),120)) as b--新增用户
on a.Dates = b.Dates
LEFT JOIN(
SELECT CONVERT(char(10),GETDATE(),120) as Dates,count(*) as availability_user
FROM  bs07.dbo.C_CUSTOMER_INFORMATION 
where len(customer_id_card) = 18) as c--有效用户（填写身份证用户）
on a.Dates = c.Dates
LEFT JOIN(
SELECT CONVERT(char(10),GETDATE(),120) as Dates,count(*) as personal
FROM  bs07.dbo.C_CUSTOMER_INFORMATION 
where customer_type = '个人会员') as d--个人用户
on a.Dates = d.Dates
LEFT JOIN(
SELECT CONVERT(char(10),GETDATE(),120) as Dates,count(*) as business
FROM  bs07.dbo.C_CUSTOMER_INFORMATION 
where customer_type = '企业会员') as e--企业用户
on a.Dates = e.Dates
LEFT JOIN(
SELECT CONVERT(char(10),GETDATE(),120) as Dates,count(*) as man
FROM  bs07.dbo.C_CUSTOMER_INFORMATION 
where len(CUSTOMER_ID_CARD) = 18 and cast(substring(CUSTOMER_ID_CARD,17,1) as int) % 2 = 1) as f--男用户数（填写身份证）
on a.Dates = f.Dates
LEFT JOIN(
SELECT CONVERT(char(10),GETDATE(),120) as Dates,count(*) as female
FROM  bs07.dbo.C_CUSTOMER_INFORMATION 
where len(CUSTOMER_ID_CARD) = 18 and cast(substring(CUSTOMER_ID_CARD,17,1) as int) % 2 = 0) as g--女用户数（填写身份证）
on a.Dates = g.Dates
LEFT JOIN(
SELECT CONVERT(char(10),GETDATE(),120) as Dates,count(a.age) as age20to24 FROM (
SELECT datediff(year,convert(datetime,substring(CUSTOMER_ID_CARD,7,8),120),getdate()) as age
FROM  bs07.dbo.C_CUSTOMER_INFORMATION 
where len(CUSTOMER_ID_CARD) = 18 ) as a
where a.age BETWEEN 20 and 24) as h
on a.Dates = h.Dates
LEFT JOIN(
SELECT CONVERT(char(10),GETDATE(),120) as Dates,count(a.age) as age25to29 FROM (
SELECT datediff(year,convert(datetime,substring(CUSTOMER_ID_CARD,7,8),120),getdate()) as age
FROM  bs07.dbo.C_CUSTOMER_INFORMATION 
where len(CUSTOMER_ID_CARD) = 18 ) as a
where a.age BETWEEN 25 and 29) as i
on a.Dates = i.Dates
LEFT JOIN(
SELECT CONVERT(char(10),GETDATE(),120) as Dates,count(a.age) as age30to34 FROM (
SELECT datediff(year,convert(datetime,substring(CUSTOMER_ID_CARD,7,8),120),getdate()) as age
FROM  bs07.dbo.C_CUSTOMER_INFORMATION 
where len(CUSTOMER_ID_CARD) = 18 ) as a
where a.age BETWEEN 30 and 34) as j
on a.Dates = j.Dates
LEFT JOIN(
SELECT CONVERT(char(10),GETDATE(),120) as Dates,count(a.age) as age35to39 FROM (
SELECT datediff(year,convert(datetime,substring(CUSTOMER_ID_CARD,7,8),120),getdate()) as age
FROM  bs07.dbo.C_CUSTOMER_INFORMATION 
where len(CUSTOMER_ID_CARD) = 18 ) as a
where a.age BETWEEN 35 and 39) as k
on a.Dates = k.Dates
LEFT JOIN(
SELECT CONVERT(char(10),GETDATE(),120) as Dates,count(a.age) as age40to44 FROM (
SELECT datediff(year,convert(datetime,substring(CUSTOMER_ID_CARD,7,8),120),getdate()) as age
FROM  bs07.dbo.C_CUSTOMER_INFORMATION 
where len(CUSTOMER_ID_CARD) = 18 ) as a
where a.age BETWEEN 40 and 44) as l
on a.Dates = l.Dates
LEFT JOIN(
SELECT CONVERT(char(10),GETDATE(),120) as Dates,count(a.age) as age45to49 FROM (
SELECT datediff(year,convert(datetime,substring(CUSTOMER_ID_CARD,7,8),120),getdate()) as age
FROM  bs07.dbo.C_CUSTOMER_INFORMATION 
where len(CUSTOMER_ID_CARD) = 18 ) as a
where a.age BETWEEN 45 and 49) as m
on a.Dates = m.Dates
LEFT JOIN(
SELECT CONVERT(char(10),GETDATE(),120) as Dates,count(a.age) as age50to54 FROM (
SELECT datediff(year,convert(datetime,substring(CUSTOMER_ID_CARD,7,8),120),getdate()) as age
FROM  bs07.dbo.C_CUSTOMER_INFORMATION 
where len(CUSTOMER_ID_CARD) = 18 ) as a
where a.age BETWEEN 50 and 54) as n
on a.Dates = n.Dates
LEFT JOIN(
SELECT CONVERT(char(10),GETDATE(),120) as Dates,count(a.age) as age55to59 FROM (
SELECT datediff(year,convert(datetime,substring(CUSTOMER_ID_CARD,7,8),120),getdate()) as age
FROM  bs07.dbo.C_CUSTOMER_INFORMATION 
where len(CUSTOMER_ID_CARD) = 18 ) as a
where a.age BETWEEN 55 and 59) as o
on a.Dates = o.Dates
LEFT JOIN(
SELECT CONVERT(char(10),GETDATE(),120) as Dates,count(a.age) as age60plus FROM (
SELECT datediff(year,convert(datetime,substring(CUSTOMER_ID_CARD,7,8),120),getdate()) as age
FROM  bs07.dbo.C_CUSTOMER_INFORMATION 
where len(CUSTOMER_ID_CARD) = 18 ) as a
where a.age > 60) as p
on a.Dates = p.Dates

----------------------------------------------------------------------------------------------------------------------------------
--07日增量用户数及其类型
create table [07_ETL].dbo.dq_daily_increment(
	id int identity(1,1) not null PRIMARY KEY,
	Dates varchar(10) NOT NULL,
	increment INT NOT NULL,
	Personal INT NOT NULL,
	Business INT NOT NULL,
	times_tamp datetime default(getdate())
)

INSERT INTO [07_ETL].dbo.dq_daily_increment(
Dates,
increment,
Personal,
Business)
SELECT b.Dates,
isnull((b.total-a.total),0) as increment,
isnull((b.Personal-a.Personal),0) as Personal,
isnull((b.Business-a.Business),0) as Business
FROM (SELECT * FROM [07_ETL].dbo.dq_daily_user 
where dates = CONVERT(char(10),GETDATE()-2,120)) as a
LEFT JOIN(SELECT * FROM [07_ETL].dbo.dq_daily_user 
where dates = CONVERT(char(10),GETDATE()-1,120)) as b 
ON a.id = (b.id-1)



--物品信息 
#######################################################################################################################
create table [07_ETL].dbo.dq_daily_goods(
id int identity(1,1) not null primary key,
Dates varchar(10) NOT NULL,
goods_total INT NOT NULL,
car_type INT NOT NULL,
Traveling INT NOT NULL,
food INT NOT NULL,
maintain INT NOT NULL,
Drink INT NOT NULL,
products INT NOT NULL,
online_no INT NOT NULL,
offline_no INT NOT NULL,
in_no INT NOT NULL,
in_money INT NOT NULL,
out_no INT NOT NULL,
out_money INT NOT NULL,
times_tamp datetime default (getdate())
)

INSERT INTO [07_ETL].dbo.dq_daily_goods( Dates,goods_total,car_type,Traveling,food,maintain,Drink,products,
online_no,offline_no,in_no,in_money,out_no,out_money)
SELECT a.Dates,a.goods_total,b.car_type,c.Traveling,d.food,e.maintain,f.Drink,g.products,
h.online_no,i.offline_no,j.in_no,m.in_money,k.out_no,l.out_money
FROM (
SELECT CONVERT(char(10),GETDATE()-1,120) as Dates,
count(*) as goods_total
FROM bs07.dbo.G_GOODS_INFO) as a 
LEFT JOIN(                                            --物品分类情况
SELECT CONVERT(char(10),GETDATE()-1,120) as Dates,
count(*) as car_type 
FROM bs07.dbo.G_GOODS_INFO
WHERE substring(goods_type,1,2) = '车辆') as b 
on a.Dates=b.Dates
LEFT JOIN(
SELECT CONVERT(char(10),GETDATE()-1,120) as Dates,
count(*) as Traveling 
FROM bs07.dbo.G_GOODS_INFO
WHERE substring(goods_type,1,2) = '旅游') as c 
on a.Dates = c.Dates
LEFT JOIN(
SELECT CONVERT(char(10),GETDATE()-1,120) as Dates,
count(*) as food 
FROM bs07.dbo.G_GOODS_INFO
WHERE substring(goods_type,1,2) = '食品') as d 
on a.Dates = d.Dates
LEFT JOIN(
SELECT CONVERT(char(10),GETDATE()-1,120) as Dates,
count(*) as maintain 
FROM bs07.dbo.G_GOODS_INFO
WHERE substring(goods_type,1,2) = '维养') as e 
on a.Dates = e.Dates
LEFT JOIN(
SELECT CONVERT(char(10),GETDATE()-1,120) as Dates,
count(*) as Drink 
FROM bs07.dbo.G_GOODS_INFO
WHERE substring(goods_type,1,2) = '饮品') as f 
on a.Dates = f.Dates
LEFT JOIN(
SELECT CONVERT(char(10),GETDATE()-1,120) as Dates,
count(*) as products 
FROM bs07.dbo.G_GOODS_INFO
WHERE substring(goods_type,1,2) = '用品') as g 
on a.Dates = g.Dates
LEFT JOIN(                                        --物品上下架情况
SELECT CONVERT(char(10),GETDATE()-1,120) as Dates,
count(*) as online_no 
FROM bs07.dbo.G_GOODS_INFO
WHERE IS_SHELVE = '上架') as h
on a.Dates = h.Dates
LEFT JOIN(
SELECT CONVERT(char(10),GETDATE()-1,120) as Dates,
count(*) as offline_no 
FROM bs07.dbo.G_GOODS_INFO
WHERE IS_SHELVE = '下架') as i
on a.Dates = i.Dates
LEFT JOIN(
SELECT CONVERT(char(10),GETDATE()-1,120) as Dates,isnull(SUM(IN_NUMBER),0) AS in_no
FROM bs07.dbo.G_IN_GOODS_INFO
where operate_time BETWEEN CONVERT(char(10),GETDATE()-1,120) 
and CONVERT(char(10),GETDATE(),120)) AS j
on a.Dates = j.Dates
LEFT JOIN(
SELECT CONVERT(char(10),GETDATE()-1,120) as Dates, isnull(sum(b.GOODS_NUMBER),0) as out_no 
FROM bs07.dbo.G_GOODS_OUT_MANAGEMENT as a
LEFT JOIN (SELECT * FROM bs07.dbo.G_OUT_GOODS_INFO ) as b
on a.GOODS_OUT_NO = b.GOODS_OUT_ID
where HANDLER_NAME <> '' and TICKET_MAKER_DATE BETWEEN CONVERT(char(10),GETDATE()-1,120) 
and CONVERT(char(10),GETDATE(),120))as k
on a.Dates = k.Dates
LEFT JOIN(
SELECT CONVERT(char(10),GETDATE()-1,120) as Dates, isnull(sum(b.TAX_TOTAL_MONEY),0) as out_money 
FROM bs07.dbo.G_GOODS_OUT_MANAGEMENT as a
LEFT JOIN (SELECT * FROM bs07.dbo.G_OUT_GOODS_INFO ) as b
on a.GOODS_OUT_NO = b.GOODS_OUT_ID
where HANDLER_NAME <> '' and TICKET_MAKER_DATE BETWEEN CONVERT(char(10),GETDATE()-1,120) 
and CONVERT(char(10),GETDATE(),120)) as l
on a.Dates = l.Dates
LEFT JOIN(
SELECT CONVERT(char(10),GETDATE()-1,120) as Dates, isnull(sum(TOTAL_PRICE),0) as in_money 
FROM bs07.dbo.G_GOODS_IN_MANAGEMENT
where OPERATION_USER <> '' and OPERATE_TIME  BETWEEN CONVERT(char(10),GETDATE()-1,120) 
and CONVERT(char(10),GETDATE(),120))as m
on a.Dates = m.Dates

---------------------------------------------------------------------------------------------------------------------------------
物品类别每日采购 数量和总价
SELECT CONVERT(char(10),GETDATE()-1,120) as dates ,--采购计划(维养)
isnull(sum(a.GOODS_NUMBER),0) AS purchase_no,
isnull(sum(a.SUBTOTAL),0) as purchase_total 
FROM bs07.dbo.G_PURCHASE_GOODS_INFO as a 
LEFT JOIN (
SELECT * from bs07.dbo.G_PURCHASE ) as b 
on a.PURCHASE_PLAN_ID = b.PURCHASE_PLAN_ID
LEFT JOIN(
SELECT * FROM bs07.dbo.G_GOODS_INFO) as c
ON c.GOODS_ID = a.GOODS_ID
where b.state = '已处理' AND
substring(c.GOODS_TYPE,1,2) = '维养' AND
a.OPERATE_TIME BETWEEN CONVERT(char(10),GETDATE()-1,120) and CONVERT(char(10),GETDATE(),120)


---------------------------------------------------------------------------------------------------------------------------------
车辆信息
SELECT RV_MODELS_ID,count(*) as num FROM bs07.dbo.R_RV_BOOK_INFORMATION 
WHERE STATE IN(0,3,4,5,6,7,8) 
AND RENT_START_TIME BETWEEN '2016-11-01' and  '2016-12-01' 
GROUP BY RV_MODELS_ID


SELECT CONVERT(char(10),GETDATE()-1,120) as Dates,
b.RV_MODELS_ID,
isnull(count(*),0) as num FROM bs07.dbo.R_RV_BACK_INFORMATION as a 
LEFT JOIN (
SELECT * FROM bs07.dbo.R_RV_BOOK_INFORMATION  ) as b
ON a.RENT_RV_ID = b.BOOK_RV_NO
where a.RV_IS_BACK = '还车前' AND
a.RV_CHECK_TIME BETWEEN CONVERT(char(10),GETDATE()-1,120) and CONVERT(char(10),GETDATE(),120)
GROUP BY b.RV_MODELS_ID


















































