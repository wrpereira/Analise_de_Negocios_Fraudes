SELECT*
FROM dbo.Fraud_Data

UPDATE dbo.Fraud_Data
SET 
device_id = REPLACE (device_id,'"',''),
source = REPLACE (source,'"',''),
browser = REPLACE (browser,'"',''),
sex = REPLACE (sex,'"','');

--Qual o total de fraudes que tivemos no período?
-- PORTANTO, TEMOS 14.151 COMPRAS FRAUDULENTAS PARA 136.961 COMPRAS NÃO FRAUDULENTAS
SELECT class, COUNT(*)
FROM dbo.Fraud_Data
GROUP BY class 

-- QUAL A PORCENTAGEM DE  VENDAS FRAUDADAS?
-- CERCA DE 9,36%
SELECT class,
COUNT (class) AS Contagem_Class,
COUNT (class)*100.0 /

(SELECT COUNT(class) FROM  dbo.Fraud_Data) AS Porcentagem

FROM dbo.Fraud_Data
GROUP BY class 


-- Qual o total de faturamento do ano e qual o valor de fraudes?
-- 1 - 523.488
-- 0 - 5.057.890	
-- TOTAL DE 5.581.378
select class, 
SUM ( CAST (purchase_value AS INT))
from dbo.Fraud_Data
GROUP BY class 

-- Qual a % do valor de fraudes sobre o valor total?
-- 1= 9,37% e 0=90,62%
SELECT class, 
SUM ( CAST (purchase_value AS INT)) AS Valor_Vendas,
SUM ( CAST (purchase_value AS INT)) *100.0 / SUM (SUM ( CAST (purchase_value AS INT))) OVER () AS Porcentagem
FROM DBO.Fraud_Data
GROUP BY class

//* VeriFicação se o mesmo user_id , device_id se repete, ou seja, para ver anormalidades!
 Nessa primeira query, podemos verificar que houveram quantidade de compras maiores de um mesmo 
dispositivo, quando as compras são fraudulentas se comparadas com a segunda query, quando a 
class=0 

primeira query - compras fraudulentas*//

SELECT class, device_id, COUNT(*) AS Contagem
FROM dbo.Fraud_Data
GROUP BY class, device_id
HAVING COUNT(*) > 1 AND class = 1
ORDER BY Contagem desc

//*Segunda query - compras não fraudulentas*//
SELECT class, device_id, COUNT(*) AS Contagem
FROM dbo.Fraud_Data
GROUP BY class, device_id
HAVING COUNT(*) > 1 AND class = 0
ORDER BY Contagem desc

//*Qual intervalo normal entre cadastro e compra no site?*//
//* nessa primeira query, checamos class =1 e verificamos que existem um comportamento de fraude 
que é fraudar em 1s a partir da criação doc aadstro, possivelmente um boot ou algo do tipo
e já quando a chass=0 o comportamento de compra passa a ser no minimo 137s*//

//* primeira query class=1*//
SELECT class, signup_time, purchase_time,
DATEDIFF(second, signup_time,purchase_time) AS Dif_Data
FROM dbo.Fraud_Data
WHERE class = 1
ORDER BY Dif_Data asc

//* segunda query class=0*//
SELECT class, signup_time, purchase_time,
DATEDIFF(second, signup_time,purchase_time) AS Dif_Data
FROM dbo.Fraud_Data
WHERE class = 0
ORDER BY Dif_Data asc