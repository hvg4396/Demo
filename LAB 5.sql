--CREATION OF TABLES AND INSERT INTO THE TABLES
CREATE TABLE CUSTOMER_MASTERS
    (
        CUST_ID NUMBER(6) NOT NULL,
        CUST_NAME VARCHAR2(20) NOT NULL,
        ADDRESS VARCHAR2(50),
        DATE_OF_ACC_CREATION DATE,
        CUSTOMER_TYPE VARCHAR2(3)
    );
    
alter table customer_masters
add constraint chk_ct check(CUSTOMER_TYPE IN ('IND' , 'NRI'));
    
CREATE TABLE ACCOUNT_MASTERS
    (
        ACCOUNT_NUMBER NUMBER(6) NOT NULL,
        CUST_ID NUMBER(6),
        ACCOUNT_TYPE VARCHAR2(3),
        LEDGER_BALANCE NUMBER(10)
    );
    
ALTER TABLE ACCOUNT_MASTERS ADD CONSTRAINT CHK_AT CHECK(ACCOUNT_TYPE IN ('SAV','SAL'));

ALTER TABLE ACCOUNT_MASTERS ADD CONSTRAINT CHK_SAV CHECK(LEDGER_BALANCE>=CASE
                                                            WHEN ACCOUNT_TYPE = 'SAV' THEN 5000
                                                            ELSE 0
                                                            END
                                                        );

CREATE TABLE TRANSACTION_MASTERS
    (
        TRANSACTION_ID NUMBER(6) NOT NULL,
        ACCOUNT_NUMBER NUMBER(6),
        DATE_OF_TRANSACTION DATE,
        FROM_ACCOUNT_NUMBER NUMBER(6) NOT NULL,
        TO_ACCOUNT_NUMBER NUMBER(6) NOT NULL,
        AMOUNT NUMBER(10) NOT NULL,
        TRANSACTION_TYPE VARCHAR2(2) NOT NULL
    );                
    
ALTER TABLE TRANSACTION_MASTERS ADD CONSTRAINT CHK_TRTY CHECK(TRANSACTION_TYPE IN ('CR','DB'));
--UPTO HERE CREATION AND INSERTING OF VALUES INTO TABLES

--LAB QUESTION 5.2
CREATE TABLE Customer_Masters
(
Cust_Id Number(6) PRIMARY KEY,
Cust_Name  Varchar2(20) Not Null,
Address Varchar2(50),
Date_of_acc_creation Date,
Customer_Type Char(3),  CONSTRAINT C_CTYPE check(Customer_Type='IND' OR Customer_Type='NRI')
); 
DROP TABLE CUSTOMER_MASTERS

CREATE TABLE Account_Masters 
(
Account_Number Number(6) PRIMARY KEY,
Cust_ID Number(6),CONSTRAINT FK_CUSTACCOUNT FOREIGN KEY (CUST_ID) REFERENCES CUSTOMER_MASTERS(CUST_ID),
Account_Type Char(3) CONSTRAINT C_ATYPE CHECK (ACCOUNT_TYPE IN ('SAV','SAL')),
Ledger_Balance Number(10), CONSTRAINT C_MINBALANCE CHECK(LEDGER_BALANCE >= CASE 
                                                                              WHEN account_type='SAV' THEN 5000
                                                                              ELSE 0
                                                                            END)
);
DROP TABLE ACCOUNT_MASTERS;

TRUNCATE TABLE TRANSACTION_MASTERS;

CREATE TABLE Transaction_Masters
(
Transaction_Id  Number(6) PRIMARY KEY,
Account_Number Number(6) ,CONSTRAINT FK_ACCTRANS FOREIGN KEY (ACCOUNT_NUMBER) REFERENCES ACCOUNT_MASTERS(ACCOUNT_NUMBER),
Date_of_Transaction Date,
From_Account_Number  Number(6) Not Null,
To_Account_Number Number(6) Not Null,
Amount Number(10) Not Null,
Transaction_Type Char(2) Not Null CONSTRAINT C_TTYPE CHECK(TRANSACTION_TYPE IN ('CR','DB'))
);
DROP TABLE TRANSACTION_MASTERS;

create sequence TRANSID 
  start with 1 
  increment by 1 
  nocycle;
DROP SEQUENCE TRANSID; 

CREATE OR REPLACE PACKAGE INSERT_INTO AS
PROCEDURE INSERT_DATA_CUSTOMER
(
  CustId IN Customer_Masters.Cust_Id%Type,
  CustName IN Customer_Masters.Cust_Name%type,
  Addr IN Customer_Masters.Address%type,
  DateAccCreation Customer_Masters.Date_of_acc_creation%type,
  CustomerType Customer_Masters.Customer_Type%type
);

PROCEDURE INSERT_DATA_ACCOUNT
(ACCNO IN Account_Masters.Cust_Id%Type,
 CUSTID IN Account_Masters.Cust_Id%type,
 ACCTYPE IN Account_Masters.Account_type%type,
 LEDGER IN Account_Masters.ledger_balance%type
);

PROCEDURE INSERT_DATA_TRANSACTION
(
  CustId IN Customer_Masters.Cust_Id%Type,
  from_account_no IN TRANSACTION_MASTERS.FROM_ACCOUNT_NUMBER%type,
  to_account_no IN TRANSACTION_MASTERS.TO_ACCOUNT_NUMBER%type,
  amt IN transaction_masters.amount%type, 
  transtype IN transaction_masters.transaction_type%type
);
END INSERT_INTO; 


CREATE OR REPLACE PACKAGE BODY INSERT_INTO AS
  PROCEDURE INSERT_DATA_CUSTOMER
  (
    CustId IN Customer_Masters.Cust_Id%Type,
    CustName IN Customer_Masters.Cust_Name%type,
    Addr IN Customer_Masters.Address%type,
    DateAccCreation Customer_Masters.Date_of_acc_creation%type,
    CustomerType Customer_Masters.Customer_Type%type
  )
  as BEGIN
    insert into customer_masters 
    values (CustId,CustName,Addr,DateAccCreation,CustomerType);
  end INSERT_DATA_CUSTOMER; 
  
  PROCEDURE INSERT_DATA_ACCOUNT
  (
   ACCNO IN Account_Masters.Cust_Id%Type,
   CUSTID IN Account_Masters.Cust_Id%type,
   ACCTYPE IN Account_Masters.Account_type%type,
   LEDGER IN Account_Masters.ledger_balance%type
  )
  as BEGIN
    insert into account_masters 
    values(accno, custid, acctype, ledger);
  end INSERT_DATA_ACCOUNT; 
  
  PROCEDURE INSERT_DATA_TRANSACTION
  (
    CustId IN Customer_Masters.Cust_Id%Type,
    from_account_no IN TRANSACTION_MASTERS.FROM_ACCOUNT_NUMBER%type,
    to_account_no IN TRANSACTION_MASTERS.TO_ACCOUNT_NUMBER%type,
    amt IN transaction_masters.amount%type, 
    transtype IN transaction_masters.transaction_type%type
  )
  as 
    AccNo Transaction_Masters.ACCOUNT_NUMBER%type;
    date_of_trans TRANSACTION_MASTERS.DATE_OF_TRANSACTION%type:=sysdate;
    cursor c_custid is 
      select cust_id 
      from customer_masters 
      where cust_id=custid;
    CURSOR c_faccountno IS 
      SELECT account_number 
      FROM account_MASTERS 
      WHERE account_number=from_account_no;
    CURSOR c_taccountno IS 
      SELECT account_number 
      FROM account_MASTERS 
      WHERE account_number=to_account_no;
  
    customerid customer_masters.cust_id%type;
    faccountno account_masters.account_number%type;
    taccountno account_masters.account_number%type;
    accountno account_masters.account_number%type;
    acctype account_masters.account_type%type;
    ledger account_masters.ledger_balance%type;
  cr_f_acctype account_masters.account_type%type;
  cr_f_ledger account_masters.ledger_balance%type;
  
  no_dbtaccount exception;
  no_dbfaccount exception;
  no_crtaccount exception;
  no_crfaccount exception;
  no_customer exception;
  no_balance exception;
  no_min_balance exception;
  cr_does_not_belong exception;
  db_does_not_belong exception;
  cr_f_no_balance exception; 
  
  BEGIN
if not c_custid %isopen then
  OPEN c_custid;
 end if;
 
 fetch c_custid into customerid;
  if c_custid %notfound then
    raise no_customer;
  else
    select account_type, account_number,ledger_balance 
    into acctype,caccountno,ledger 
    from account_masters 
    where cust_id=custid;
    select account_type,ledger_balance 
    into cr_f_acctype, cr_f_ledger 
    from account_masters 
    where account_number= from_account_no;
 
    if (transtype='CR') THEN
      if(caccountno=to_account_no) then
          accno:=to_account_no;
          if not c_taccountno %isopen then
            OPEN c_taccountno;
          end if;
        fetch c_taccountno into taccountno;
          if c_taccountno %notfound then
            raise no_crtaccount;
          else
            if(from_account_no is null) then
              raise no_crfaccount;
          end if; 
          if (cr_f_acctype='SAL') THEN
            if (cr_f_ledger>=amt) then
              insert into transaction_masters 
              values (TRANSID.NEXTVAL, accno, SYSDATE , from_account_no, to_account_no,amt, transtype);
              UPDATE ACCOUNT_MASTERS
                SET LEDGER_BALANCE=LEDGER_BALANCE-AMT WHERE ACCOUNT_NUMBER=from_account_no;
              UPDATE ACCOUNT_MASTERS
                SET LEDGER_BALANCE=LEDGER_BALANCE+AMT WHERE ACCOUNT_NUMBER=to_account_no;
            else
          raise cr_f_no_balance;
          end if;
        ELSE
          IF ((cr_f_ledger-amt)<5000) then
          raise cr_f_no_balance; 
        else
          insert into transaction_masters 
          values(TRANSID.NEXTVAL, accno, SYSDATE, from_account_no, to_account_no,amt, transtype);
          UPDATE ACCOUNT_MASTERS
            SET LEDGER_BALANCE=LEDGER_BALANCE-AMT 
            WHERE ACCOUNT_NUMBER=from_account_no;
          UPDATE ACCOUNT_MASTERS
            SET LEDGER_BALANCE=LEDGER_BALANCE+AMT 
            WHERE ACCOUNT_NUMBER=to_account_no;
       end if;
      END IF;
     --insert into transaction_masters values(TransId.nextval, accno, date_of_trans, from_account_no, to_account_no,amt, transtype);
    end if; 
    else
      raise cr_does_not_belong;
    end if;
  elsif (transtype='DB') THEN
    if(caccountno=from_account_no) then
      ACCNO:= from_account_no;
      if not c_faccountno %isopen then
        OPEN c_faccountno;
      end if;
    fetch c_faccountno into faccountno;
      if c_faccountno %notfound then
          raise no_dbfaccount;
      else
        if(to_account_no is null) then
          raise no_dbtaccount;
        end if;
        if (acctype='SAL') THEN
          if (ledger>=amt) then  
            insert into transaction_masters 
            values (TRANSID.nextval, accno, date_of_trans, from_account_no, to_account_no,amt, transtype);
            UPDATE ACCOUNT_MASTERS
              SET LEDGER_BALANCE=LEDGER_BALANCE-AMT 
              WHERE ACCOUNT_NUMBER=from_account_no;
            UPDATE ACCOUNT_MASTERS
              SET LEDGER_BALANCE=LEDGER_BALANCE+AMT 
              WHERE ACCOUNT_NUMBER=to_account_no;
          else
        raise no_balance;
      end if;
      ELSE
       IF ((ledger-amt)<5000) then
        raise no_balance;
       else
        insert into transaction_masters values(TRANSID.nextval, accno, date_of_trans, from_account_no, to_account_no,amt, transtype); 
          UPDATE ACCOUNT_MASTERS
            SET LEDGER_BALANCE=LEDGER_BALANCE-AMT 
            WHERE ACCOUNT_NUMBER=from_account_no;
          UPDATE ACCOUNT_MASTERS
            SET LEDGER_BALANCE=LEDGER_BALANCE+AMT 
              WHERE ACCOUNT_NUMBER=to_account_no;
        end if;
     END IF;
   end if;
   else
    raise db_does_not_belong;
  end if;
 end if;
end if;

exception
 when no_customer then
  dbms_output.put_line('No such customer!');
 when no_crtaccount then
  dbms_output.put_line('The account to be credited does not exist in accounts table!');
 when no_crfaccount then
  dbms_output.put_line('The account from which credit goes does not exist!');
 when no_dbtaccount then
  dbms_output.put_line('The account debiting the amount does not exist!');
 when no_dbfaccount then
  dbms_output.put_line('The account to be debited from does not exist in the accounts table!');
 when no_balance then
  dbms_output.put_line('There is not enough balance for debit to take place');
 when cr_does_not_belong then
  dbms_output.put_line('The account to be credited does not belong to the given customer id!');
 when db_does_not_belong then
  dbms_output.put_line('The account to be debited from does not belong to the given customer id!');
 when cr_f_no_balance then
  dbms_output.put_line('The account giving credit to another account does not have enough balance!');
end INSERT_DATA_TRANSACTION;
END INSERT_INTO; 

begin
 INSERT_INTO.insert_data_customer(101,'ASHISH','CHENNAI','21-FEB-2000','IND');
 INSERT_INTO.insert_data_customer(102,'ANUPAM','NEW YORK','01-OCT-2001','NRI');
 INSERT_INTO.insert_data_customer(103,'RAJAT','KOLKATA','19-NOV-2000','IND');
 INSERT_INTO.insert_data_ACCOUNT(1001,101,'SAV',5000);
 INSERT_INTO.insert_data_ACCOUNT(1002,102,'SAV',7500);
 INSERT_INTO.insert_data_ACCOUNT(1003,103,'SAL',2345);
end;


--LAB QUESTION 5.3
CREATE OR REPLACE PROCEDURE insert_val
AS
begin
INSERT_INTO.INSERT_DATA_TRANSACTION
 (&Enter_Customer_Id,&Enter_from_account_no,&Enter_to_account_no, &Enter_amount,'&Enter_transaction_type');
end;  


