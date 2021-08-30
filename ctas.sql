-- DROP TABLE [dbo].[ctas_仕入先]
CREATE TABLE [dbo].[ctas_仕入先]
WITH
(
 DISTRIBUTION = REPLICATE
 ,CLUSTERED COLUMNSTORE INDEX
)
AS
SELECT  *
FROM    [dbo].[ext_仕入先]
GO


-- DROP TABLE [dbo].[ctas_運送]
CREATE TABLE [dbo].[ctas_運送]
WITH
(
 DISTRIBUTION = REPLICATE
 ,CLUSTERED COLUMNSTORE INDEX
)
AS
SELECT  *
FROM    [dbo].[ext_運送]
GO

-- DROP TABLE [dbo].[ctas_社員]
CREATE TABLE [dbo].[ctas_社員]
WITH
(
 DISTRIBUTION = REPLICATE
 ,CLUSTERED COLUMNSTORE INDEX
)
AS
SELECT  *
FROM    [dbo].[ext_社員]
GO


-- DROP TABLE [dbo].[ctas_商品]
CREATE TABLE [dbo].[ctas_商品]
WITH
(
 DISTRIBUTION = REPLICATE
 ,CLUSTERED COLUMNSTORE INDEX
)
AS
SELECT  *
FROM    [dbo].[ext_商品]
GO

-- DROP TABLE [dbo].[ctas_商品区分]
CREATE TABLE [dbo].[ctas_商品区分]
WITH
(
 DISTRIBUTION = REPLICATE
 ,CLUSTERED COLUMNSTORE INDEX
)
AS
SELECT  *
FROM    [dbo].[ext_商品区分]
GO


-- DROP TABLE [dbo].[ctas_都道府県]
CREATE TABLE [dbo].[ctas_都道府県]
WITH
(
 DISTRIBUTION = REPLICATE
 ,CLUSTERED COLUMNSTORE INDEX
)
AS
SELECT  *
FROM    [dbo].[ext_都道府県]
GO


-- DROP TABLE [dbo].[ctas_得意先]
CREATE TABLE [dbo].[ctas_得意先]
WITH
(
 DISTRIBUTION = REPLICATE
 ,CLUSTERED COLUMNSTORE INDEX
)
AS
SELECT  *
FROM    [dbo].[ext_得意先]
GO


-- DROP TABLE [dbo].[ctas_受注]
CREATE TABLE [dbo].[ctas_受注]
WITH
(
 DISTRIBUTION = REPLICATE
 ,CLUSTERED COLUMNSTORE INDEX
)
AS
SELECT  *
FROM    [dbo].[ext_受注]
GO


-- DROP TABLE [dbo].[ctas_受注明細]
CREATE TABLE [dbo].[ctas_受注明細]
WITH
(
 DISTRIBUTION = ROUND_ROBIN
 ,CLUSTERED COLUMNSTORE INDEX
)
AS
SELECT  *
FROM    [dbo].[ext_受注明細]
GO
