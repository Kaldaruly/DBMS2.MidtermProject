- Procedure which does group by information 


CREATE OR REPLACE PROCEDURE proc_group
IS
BEGIN
  FOR i IN (
    SELECT Supp_ID, COUNT(*) AS Sup_count
    FROM Product
    GROUP BY Supp_ID
  )
  LOOP
    DBMS_OUTPUT.PUT_LINE(i.Supp_ID || ': ' ||  i.Sup_count);
  END LOOP;
END;

begin
proc_group;
end;

--------------------------------------------------------------------------------------
- Function which counts the number of records 

create or replace function get_cnt_of_customer
return number
as number_of_table number := 0;
begin
   select count(*) into number_of_table from customer;
   return number_of_table;
end;

create or replace function get_cnt_of_supplier
return number
as number_of_table number := 0;
begin
   select count(*) into number_of_table from supplier;
   return number_of_table;
end;

create or replace function get_cnt_of_product
return number
as number_of_table number := 0;
begin
   select count(*) into number_of_table from product;
   return number_of_table;
end;

create or replace function get_cnt_of_reviews
return number
as number_of_table number := 0;
begin
   select count(*) into number_of_table from reviews;
   return number_of_table;
end;

create or replace function get_cnt_of_orderr
return number
as number_of_table number := 0;
begin
   select count(*) into number_of_table from orderr;
   return number_of_table;
end;

create or replace function get_cnt_of_delivery
return number
as number_of_table number := 0;
begin
   select count(*) into number_of_table from delivery;
   return number_of_table;
end;

create or replace function get_cnt_of_card_item
return number
as number_of_table number := 0;
begin
   select count(*) into number_of_table from card_item;
   return number_of_table;
end;

create or replace function get_cnt_of_basket
return number
as number_of_table number := 0;
begin
   select count(*) into number_of_table from basket;
   return number_of_table;
end;

create or replace function get_cnt_of_driver
return number
as number_of_table number := 0;
begin
   select count(*) into number_of_table from driver;
   return number_of_table;
end;

--------------------------------------------------------------------------------------
- Procedure which uses SQL%ROWCOUNT to determine the number of rows affected


CREATE OR REPLACE PROCEDURE row_count(
    c_expired_date IN DATE
)
IS
BEGIN
    UPDATE CARD_ITEM
    SET Expired_date = c_expired_date
    WHERE Expired_date < SYSDATE;
    
    DBMS_OUTPUT.PUT_LINE('Number of rows updated: ' || SQL%ROWCOUNT);
END;

begin
DECLARE
    c_expired_date DATE := add_months(SYSDATE, 24);
BEGIN
row_count(c_expired_date);
END;
end;

select *from CARD_ITEM
--------------------------------------------------------------------------------------
- Add user-defined exception which disallows to enter title of item (e.g. book) to be less than 5 characters

create or replace trigger check_bank_id_length 
before insert on card_item 
for each row 
declare 
  bank_id_length_by_user integer; 
  invalid_data exception; 
begin 
  bank_id_length_by_user := length(:new.bank_id); 
  if bank_id_length_by_user <> 16 then 
    raise invalid_data; 
  end if; 
exception 
  when invalid_data then 
  raise_application_error(-20001, 'the length of the bank_id must not exceed or be less than 16 characters :)'); 
end;

--------------------------------------------------------------------------------------
- Create a trigger before insert on any entity which will show the current number of rows in the table

create or replace trigger write_before_insert_on_customer
before insert on customer
for each row
declare 
number_of_table number;
begin
   select count(*) into number_of_table from customer;
   DBMS_OUTPUT.PUT_LINE('current number of rows in the table: ' || number_of_table);
end;   

create or replace trigger write_before_insert_on_supplier
before insert on supplier
for each row
declare 
number_of_table number;
begin
   select count(*) into number_of_table from supplier;
   DBMS_OUTPUT.PUT_LINE('current number of rows in the table: ' || number_of_table);
end;   

create or replace trigger write_before_insert_on_product
before insert on product
for each row
declare 
number_of_table number;
begin
   select count(*) into number_of_table from product;
   DBMS_OUTPUT.PUT_LINE('current number of rows in the table: ' || number_of_table);
end;   

create or replace trigger write_before_insert_on_reviews
before insert on reviews
for each row
declare 
number_of_table number;
begin
   select count(*) into number_of_table from reviews;
   DBMS_OUTPUT.PUT_LINE('current number of rows in the table: ' || number_of_table);
end;   

create or replace trigger write_before_insert_on_orderr
before insert on orderr
for each row
declare 
number_of_table number;
begin
   select count(*) into number_of_table from orderr;
   DBMS_OUTPUT.PUT_LINE('current number of rows in the table: ' || number_of_table);
end;   

create or replace trigger write_before_insert_on_delivery
before insert on delivery
for each row
declare 
number_of_table number;
begin
   select count(*) into number_of_table from delivery;
   DBMS_OUTPUT.PUT_LINE('current number of rows in the table: ' || number_of_table);
end;   

create or replace trigger write_before_insert_on_card_item
before insert on card_item
for each row
declare 
number_of_table number;
begin
   select count(*) into number_of_table from card_item;
   DBMS_OUTPUT.PUT_LINE('current number of rows in the table: ' || number_of_table);
end;   

create or replace trigger write_before_insert_on_basket
before insert on basket
for each row
declare 
number_of_table number;
begin
   select count(*) into number_of_table from basket;
   DBMS_OUTPUT.PUT_LINE('current number of rows in the table: ' || number_of_table);
end;   

create or replace trigger write_before_insert_on_driver
before insert on driver
for each row
declare 
number_of_table number;
begin
   select count(*) into number_of_table from driver;
   DBMS_OUTPUT.PUT_LINE('current number of rows in the table: ' || number_of_table);
end;   

--------------------------------------------------------------------------------------


//function that return product id which customer order

create or replace function get_prod(b_cust_id number)
return number is
    b_prod_id number;
    cursor prodd is
      select distinct prod_id
      from basket
      where cust_id=b_cust_id;
begin
   open prodd;
   loop
    fetch prodd into b_prod_id;
    exit when prodd%NOTFOUND;
   end loop;
   close prodd;
   return b_prod_id;
end;


//function to get expiration date of product which customer order from product table by using customer id

create or replace function get_expired_date(n_cust_id number)
return date is 
  p_expired_date date;
begin 
  select expired_date into p_expired_date  
  from product
  where   get_prod(n_cust_id)=prod_id;  
  return p_expired_date;
end;


// a trigger that check if the products are expired when ordering,if the product expired then trigger update amount to 0 and raise application

create or replace trigger check_expired_date
before insert on orderr
for each row
declare 
  current_date date;
  expired_date date;
begin
  current_date:=SYSDATE;
  expired_date:=get_expired_date(:new.cust_id);
  if current_date > expired_date then 
    raise_application_error(-20001,'Sorry, but your ordered product is expired. Please,retry.');
  end if;
end;

insert into orderr
values (3,3,3,'4400 4300 5500 8902',4875,'04-20-2023');

--------------------------------------------------------------------------------------


вернет количество этого продукта в складе:
create or replace function get_product_amount(b_prod_id number)
return number is
    r_amount number;
begin 
    select amount into r_amount 
    from product
    where prod_id = b_prod_id;
    return r_amount;
end;

проверяет, есть ли этот продукт в складе:
create or replace trigger check_exist_product 
before insert on basket
for each row
declare 
amount number;
begin
    amount := get_product_amount(:new.prod_id);
    if amount = 0 then 
        raise_application_error(-20002, 'Product not exist');
    end if;
end;

проверяет, есть ли достаточно денег на заказ у пользователя: 
CREATE OR REPLACE TRIGGER check_balance_before_order 
BEFORE INSERT ON orderr
FOR EACH ROW 
DECLARE
    amount NUMBER;
BEGIN
    amount := get_customer_balance(:NEW.bank_id);
    
    IF amount < :NEW.total_cost THEN
        RAISE_APPLICATION_ERROR(-20000, 'Not enough money for the order!');
    ELSE
        update_customer_balance(:NEW.bank_id, :NEW.total_cost);
    END IF;
END;

Снимает деньги со счета пользователя:
CREATE OR REPLACE PROCEDURE update_customer_balance(p_bank_id varchar, p_balance NUMBER) IS 
BEGIN
    UPDATE card_item
    SET balance = balance - p_balance
    WHERE bank_id = p_bank_id;
END;


Вернет баланс пользователя:
CREATE OR REPLACE FUNCTION get_customer_balance(p_bank_id varchar) 
RETURN NUMBER IS 
    amount NUMBER;
BEGIN
    SELECT balance INTO amount
    FROM card_item
    WHERE bank_id = p_bank_id;
    RETURN amount;
END;

--------------------------------------------------------------------------------------
