-- იუზერის შექმნა(იუზერნეიმი(უნიკალური), სახელი, გვარი, დაბ-თარიღი, მეილი(უნიკალური), პაროლი(ჰეშირებული)) ;
-- კატეგორიების მიხედვით პროდუქტების შექმნა, ფასის და მარაგის განსაზღვრა;
-- მარაგის განახლებით შეკვეთის განთავსება, გაუქმება, დარედაქტირება(ახალი პროდუქტით ჩანაცვლება ან ძველის რაოდენობის შეცვლა);
-- შეკვეთის გადახდის მეთოდები (card, apple pay)
-- ვაუჩერის სისტემა (10%, 25%, 50%, 100% სასაჩუქრე)
-- wish list-ში ნივთის დამატება;
-- wish list-ში დამატაებული ნივთების ნახვა;
-- კალათში ნივთ(ებ)ის დამატება, ამოშლა (მარაგის განახლებით);
-- კალათში დამატებული ნივთების ნახვა;
-- კალათში დამატებული ნივთების შეძენა (მარაგის განახლებით);
-- wish list-ში დამატებული ნივთების შეძენა (მარაგის განახლებით);
-- Didect Buy - ის განხორციელება (მარაგის განახლებით);
-- პროდუქტების ძებნა სახელით;
-- პროდუქტების ძებნა კატეგორიებით;
-- იუზერის მიერ ჯამურად დახარჯული თანხის ნახვა Total Spent amount;
-- იუზერის order history-ის წამოღება ფასის დიაპაზონის მითითებით;
-- შეკვეთის განხორციელების დროს ხდება დროის დაფიქსირება;
-- ამ ეტაპზე შემიძლია ვაუჩერით სარგებლობა მხოლოდ ბარათზე დამატებული ნივთის ყიდვის დროს რაც შეიძლება მომავალში სხვა შეძენის ტიპებზეც გავავრცელო ;









-- ცხრილების შექმნა

-- ვქმნი ცხრილს: USER
CREATE TABLE "USER" (
    userName TEXT PRIMARY KEY,
    firstName TEXT NOT NULL,
    lastName TEXT NOT NULL,
    birthDate DATE NOT NULL,
    email TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL DEFAULT crypt('password1', gen_salt('bf'))
);

-- ვქმნი ცხრილს: CATEGORY
CREATE TABLE CATEGORY (
    categoryId SERIAL PRIMARY KEY,
    categoryName TEXT UNIQUE NOT NULL
);



-- კატეგორიების დამატება
INSERT INTO CATEGORY (categoryName) VALUES
('Laptops'), ('Desktops'), ('Phones'), ('Accessories');


-- ვქმნი ცხრილს: PRODUCT
CREATE TABLE PRODUCT (
    prodName TEXT PRIMARY KEY,
    prodPrice NUMERIC NOT NULL CHECK (prodPrice >= 0),
    prodStock INT NOT NULL CHECK (prodStock >= 0),
    categoryId INT REFERENCES CATEGORY(categoryId)
);





-- ვქმნი ცხრილს: PAYMENT_METHOD
CREATE TABLE PAYMENT_METHOD (
    paymentType TEXT PRIMARY KEY
);



-- გადახდის ტიპებს ვამატებ
INSERT INTO PAYMENT_METHOD (paymentType) VALUES ('card'), ('apple pay');



-- ვქმნი ცხრილს: BASKET
CREATE TABLE BASKET (
    userName TEXT REFERENCES "USER"(userName),
    prodName TEXT REFERENCES PRODUCT(prodName),
    prodQntt INT NOT NULL CHECK (prodQntt > 0),
    prodPrice NUMERIC NOT NULL,
    sum NUMERIC GENERATED ALWAYS AS (prodPrice * prodQntt) STORED,
    PRIMARY KEY (userName, prodName)
);



-- ვქმნი ცხრილს: ORDERS
CREATE TABLE ORDERS (
    id SERIAL PRIMARY KEY,
    userName TEXT REFERENCES "USER"(userName),
    purchProdName TEXT NOT NULL,
    purchProdQntt INT NOT NULL CHECK (purchProdQntt > 0),
    purchProdPrice NUMERIC NOT NULL,
    sum NUMERIC GENERATED ALWAYS AS (purchProdPrice * purchProdQntt) STORED,
    orderDate TIMESTAMP DEFAULT NOW(),
    paymentType TEXT REFERENCES PAYMENT_METHOD(paymentType)
);




-- ვქმნი ცხრილს: WISHLIST
CREATE TABLE WISHLIST (
    userName TEXT REFERENCES "USER"(userName),
    prodName TEXT REFERENCES PRODUCT(prodName),
    prodQntt INT NOT NULL CHECK (prodQntt > 0),
    prodPrice NUMERIC NOT NULL,
    sum NUMERIC GENERATED ALWAYS AS (prodPrice * prodQntt) STORED,
    PRIMARY KEY (userName, prodName)
);


-- დავამატე ვაუჩერის ოფშენი, როგორც ფასდაკლება:
CREATE TABLE VOUCHER (
    code TEXT PRIMARY KEY,
    discount_percent INT NOT NULL CHECK (discount_percent BETWEEN 0 AND 100)
);

--დავამატე კონკრეტული პროცენტობის ვაუჩერები:
INSERT INTO VOUCHER (code, discount_percent) VALUES
('sale10', 10),
('sale25', 25),
('sale50', 50),
('sale100', 100);

alter table orders add column voucherCode text references voucher(code);


-- ქუერები: ფუნქციონალი:--------------------------------------------

-- იუზერის შექმნა:

INSERT INTO "USER" (userName, firstName, lastName, birthDate, email, password)
VALUES ('rezot', 'revaz', 'tutarashvili', '1995-05-05', 'rtutarashvili@gmaill.com',crypt('password1', gen_salt('bf')));

--  იუზერის წამოღება:
select * from "USER";



-- პროდუქტის შექმნა კატეგორიის მითითებით:

INSERT INTO PRODUCT (prodName, prodPrice, prodStock, categoryId)
VALUES ('Apple iPhone', 999.99, 10, (SELECT categoryId FROM CATEGORY WHERE categoryName = 'Phones'));

INSERT INTO PRODUCT (prodName, prodPrice, prodStock, categoryId)
VALUES ('Samsung Galaxy s23', 899.99, 10, (SELECT categoryId FROM CATEGORY WHERE categoryName = 'Phones'));

INSERT INTO PRODUCT (prodName, prodPrice, prodStock, categoryId)
VALUES ('Dell i3 Gen12', 540.99, 10, (SELECT categoryId FROM CATEGORY WHERE categoryName = 'Laptops'));

INSERT INTO PRODUCT (prodName, prodPrice, prodStock, categoryId)
VALUES ('Asus', 779.99, 10, (SELECT categoryId FROM CATEGORY WHERE categoryName = 'Laptops'));

INSERT INTO PRODUCT (prodName, prodPrice, prodStock, categoryId)
VALUES ('Acer', 1000, 10, (SELECT categoryId FROM CATEGORY WHERE categoryName = 'Desktops'));

INSERT INTO PRODUCT (prodName, prodPrice, prodStock, categoryId)
VALUES ('Ryzen i9 Gen14', 1000, 10, (SELECT categoryId FROM CATEGORY WHERE categoryName = 'Desktops'));

INSERT INTO PRODUCT (prodName, prodPrice, prodStock, categoryId)
VALUES ('Logitech Mouse', 32, 10, (SELECT categoryId FROM CATEGORY WHERE categoryName = 'Accessories'));

INSERT INTO PRODUCT (prodName, prodPrice, prodStock, categoryId)
VALUES ('Logitech Speakers', 119.99, 10, (SELECT categoryId FROM CATEGORY WHERE categoryName = 'Accessories'));




-- პროდუქტის დამატება კალათში (მარაგის შემოწმებით 1)
INSERT INTO basket (userName, prodName, prodQntt, prodPrice)
select 'rezot', 'Asus', 1, prodPrice
from PRODUCT
where prodName = 'Asus' and prodStock >=1;


-- პროდუქტის დამატება კალათში (მარაგის შემოწმებით 2 )
INSERT INTO basket (userName, prodName, prodQntt, prodPrice)
select 'rezot', 'Samsung Galaxy s23', 2, prodPrice
from PRODUCT
where prodName = 'Samsung Galaxy s23' and prodStock >=2;


-- პროდუქტის დამატება კალათში (მარაგის შემოწმებით 3 )
INSERT INTO basket (userName, prodName, prodQntt, prodPrice)
select 'rezot', 'Dell i3 Gen12', 1, prodPrice
from PRODUCT
where prodName = 'Dell i3 Gen12' and prodStock >=1;


--  კალათში დამატებული პროდუქტის ამოშლა
DELETE FROM basket 
WHERE prodName = 'Dell i3 Gen12';


--  კალათში დამატებული პროდუქტის შემოწმება
select * from basket 
where userName ='rezot';


-- კალათიდან პროდუქტების შეძენა ვაუჩერით
WITH all_items AS (
  SELECT * FROM BASKET WHERE userName = 'rezot'
),
stock_check AS (
  SELECT ai.*
  FROM all_items ai
  JOIN PRODUCT p ON ai.prodName = p.prodName
  WHERE p.prodStock >= ai.prodQntt
),
voucher AS (
  SELECT discount_percent FROM VOUCHER WHERE code = 'sale100'
),
insert_orders AS (
  INSERT INTO ORDERS (userName, purchProdName, purchProdQntt, purchProdPrice, paymentType, voucherCode)
  SELECT 
    ai.userName,
    ai.prodName,
    ai.prodQntt,
    ROUND(ai.prodPrice * (1 - (v.discount_percent / 100.0)), 2),
    'card',
    'sale100'
  FROM stock_check ai, voucher v
  RETURNING *
),
update_stock AS (
  UPDATE PRODUCT
  SET prodStock = prodStock - ai.prodQntt
  FROM stock_check ai
  WHERE PRODUCT.prodName = ai.prodName
),
clear_basket AS (
  DELETE FROM BASKET WHERE userName = 'rezot'
)
SELECT * FROM insert_orders;

-- კალათიდან პროდუქტების შეძენა ვაუჩერის გარეშე (გადახდის ტიპის არჩევით)
WITH all_items AS (
  SELECT * FROM BASKET WHERE userName = 'rezot'
),
stock_check AS (
  SELECT COUNT(*) AS valid_items
  FROM all_items ai
  JOIN PRODUCT p ON ai.prodName = p.prodName
  WHERE p.prodStock >= ai.prodQntt
),
insert_orders AS (
  INSERT INTO ORDERS (userName, purchProdName, purchProdQntt, purchProdPrice, paymentType)
  SELECT userName, prodName, prodQntt, prodPrice, 'apple pay' FROM all_items
  RETURNING *
),
update_stock AS (
  UPDATE PRODUCT
  SET prodStock = prodStock - ai.prodQntt
  FROM all_items ai
  WHERE PRODUCT.prodName = ai.prodName
),
clear_basket AS (
  DELETE FROM BASKET WHERE userName = 'rezot'
)
SELECT * FROM insert_orders;



-- ვამატებ პირველ პროდუქტს Wish list-ში
INSERT INTO WISHLIST (userName, prodName, prodQntt, prodPrice)
SELECT 'rezot', 'Apple iPhone', 1, prodPrice
FROM PRODUCT
WHERE prodName = 'Apple iPhone' AND prodStock >= 1;


-- ვამატებ მეორე პროდუქტს Wish list-ში
INSERT INTO WISHLIST (userName, prodName, prodQntt, prodPrice)
SELECT 'rezot', 'Ryzen i9 Gen14', 1, prodPrice
FROM PRODUCT
WHERE prodName = 'Ryzen i9 Gen14' AND prodStock >= 1;

-- wish list-ში დამატებული პროდუქტის შემოწმება
select * from WISHLIST 
where userName ='rezot';



-- Wish list-დან შეძენა (მარაგის შემოწმებით და გადახდის მეთოდის არჩევით "card")
WITH selected AS (
  SELECT * FROM WISHLIST
  WHERE userName = 'rezot' AND prodName = 'Apple iPhone'
),
stock_check AS (
  SELECT * FROM PRODUCT
  WHERE prodName = 'Apple iPhone' AND prodStock >= (SELECT prodQntt FROM selected)
),
insert_order AS (
  INSERT INTO ORDERS (userName, purchProdName, purchProdQntt, purchProdPrice, paymentType)
  SELECT userName, prodName, prodQntt, prodPrice, 'card' FROM selected
  RETURNING *
),
update_stock AS (
  UPDATE PRODUCT
  SET prodStock = prodStock - (SELECT prodQntt FROM selected)
  WHERE prodName = 'Apple iPhone'
),
delete_wishlist AS (
  DELETE FROM WISHLIST
  WHERE userName = 'rezot' AND prodName = 'Apple iPhone'
)
SELECT * FROM insert_order;



-- wish list-ში დამატებული პროდუქტის შემოწმება
select * from WISHLIST 
where userName ='rezot';



-- Wish list-დან შეძენა (მარაგის შემოწმებით და გადახდის მეთოდის არჩევით "apple pay")
WITH selected AS (
  SELECT * FROM WISHLIST
  WHERE userName = 'rezot' AND prodName = 'Ryzen i9 Gen14'
),
stock_check AS (
  SELECT * FROM PRODUCT
  WHERE prodName = 'Ryzen i9 Gen14' AND prodStock >= (SELECT prodQntt FROM selected)
),
insert_order AS (
  INSERT INTO ORDERS (userName, purchProdName, purchProdQntt, purchProdPrice, paymentType)
  SELECT userName, prodName, prodQntt, prodPrice, 'apple pay' FROM selected
  RETURNING *
),
update_stock AS (
  UPDATE PRODUCT
  SET prodStock = prodStock - (SELECT prodQntt FROM selected)
  WHERE prodName = 'Ryzen i9 Gen14'
),
delete_wishlist AS (
  DELETE FROM WISHLIST
  WHERE userName = 'rezot' AND prodName = 'Ryzen i9 Gen14'
)
SELECT * FROM insert_order;



-- wish list-ში დამატებული პროდუქტის შემოწმება
select * from WISHLIST 
where userName ='rezot';





--პროდუქტის პირდაპირ შეძენა Direct_Buy (მარაგის შემოწმება, შეძენა, მარაგის განახლება)
WITH all_items AS (
  SELECT 'rezot' AS userName, 'Logitech Mouse' AS prodName, 9 AS prodQntt, 32 AS prodPrice, 'apple pay' AS paymentType
),
stock_check AS (
  SELECT ai.*
  FROM all_items ai
  JOIN PRODUCT p ON ai.prodName = p.prodName
  WHERE p.prodStock >= ai.prodQntt
),
insert_orders AS (
  INSERT INTO ORDERS (userName, purchProdName, purchProdQntt, purchProdPrice, paymentType)
  SELECT userName, prodName, prodQntt, prodPrice, paymentType
  FROM stock_check
  RETURNING *
),
update_stock AS (
  UPDATE PRODUCT
  SET prodStock = prodStock - sc.prodQntt
  FROM stock_check sc
  WHERE PRODUCT.prodName = sc.prodName
)
SELECT * FROM insert_orders;


-- შეკვეთის გაუქმება Cancel (პროდუქტის მარაგის აღდგენით)
WITH deleted_order AS (
  DELETE FROM ORDERS
  WHERE id = 10
  RETURNING purchProdName, purchProdQntt
)
UPDATE PRODUCT
SET prodStock = prodStock + delord.purchProdQntt
FROM deleted_order delord
WHERE PRODUCT.prodName = delord.purchProdName;




-- ORDER EDIT რაოდენობის შეცვლა შეკვეთაში 
WITH old_order AS (
  SELECT * FROM ORDERS WHERE id = 8 --ვუთითებ შეკვეთის აიდის
),
product_stock AS (
  SELECT prodStock FROM PRODUCT
  WHERE prodName = (SELECT purchProdName FROM old_order)
),
updated_order AS (
  
  SELECT * FROM old_order, product_stock
  WHERE prodStock + purchProdQntt >= 3  -- ვუთითებ ახალ რაოდენობას
),
update_stock AS (
  -- ძველი რაოდენობა + stock -> შემდეგ - ახალი რაოდენობა
  UPDATE PRODUCT
  SET prodStock = prodStock + (SELECT purchProdQntt FROM old_order) - 3 -- ვაკლებ ახალ რაოდენობას
  WHERE prodName = (SELECT purchProdName FROM old_order)
),
update_order AS (
  UPDATE ORDERS
  SET purchProdQntt = 3, -- ვუსეტავ ახალ რაოდენობას
      purchProdPrice = (SELECT prodPrice FROM PRODUCT WHERE prodName = old_order.purchProdName)
  FROM old_order
  WHERE ORDERS.id = old_order.id
  RETURNING *
)
SELECT * FROM update_order;



--ORDER EDIT შეკვეთაში სხვა ნივთით ჩანაცვლება 
WITH old_order AS (
  SELECT * FROM ORDERS WHERE id = 5 --ვუთითებ შეკვეთის აიდს
),
restore_old_stock AS (
  UPDATE PRODUCT
  SET prodStock = prodStock + (SELECT purchProdQntt FROM old_order)
  WHERE prodName = (SELECT purchProdName FROM old_order)
),
new_product AS (
  SELECT * FROM PRODUCT
  WHERE prodName = 'Apple iPhone' AND prodStock >= 2 -- ვსეტავ პროდუქტს და რაოდენობას
),
update_new_stock AS (
  UPDATE PRODUCT
  SET prodStock = prodStock - 2 --აფდეითისთვის ვაკლებ რაოდენობას
  WHERE prodName = 'Apple iPhone'
),
update_order AS (
  UPDATE ORDERS
  SET purchProdName = 'Apple iPhone', --ვსეტავ სახელს
      purchProdQntt = 2,	  -- ვსეტავ რაოდენობას
      purchProdPrice = (SELECT prodPrice FROM new_product)
  WHERE id = 5 --ვსეტავ აიდის
  RETURNING *
)
SELECT * FROM update_order;



-- იუზერის მიერ ჯამურად დახარჯული თანხა Total Spent amount
SELECT userName, SUM(sum) AS totalSpent
FROM ORDERS
WHERE userName = 'rezot'
GROUP BY userName;


-- იუზერის order history-ის წამოღება ფასის დიაპაზონის მითითებით
SELECT id, userName, purchProdName, purchProdQntt, purchProdPrice, sum, orderDate, paymentType
FROM ORDERS
WHERE userName = 'rezot' AND sum BETWEEN 31 AND 2000;


-- პროდუქტის ძებნა სახელით Search product by name (მაგ. “pl”)
SELECT * FROM PRODUCT
WHERE LOWER(prodName) LIKE '%pl%';

-- კატეგორიით პროდუქტების ძებნა (მაგ. ტელეფონები)
SELECT 
  p.prodName, 
  p.prodPrice, 
  p.prodStock, 
  c.categoryName
FROM PRODUCT AS p
JOIN CATEGORY AS c ON p.categoryId = c.categoryId
WHERE c.categoryName = 'Phones';