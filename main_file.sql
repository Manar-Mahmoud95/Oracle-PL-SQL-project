----------- Tables Creation -----------
Clients table 
CREATE TABLE HR.CLIENTS
(
  CLIENT_ID       NUMBER(4),
  CLIENT_NAME     VARCHAR2(100 BYTE) CONSTRAINT CLIENT_NAME_NN NOT NULL,
  CLIENT_ADDRESS  VARCHAR2(100 BYTE),
  CLIENT_NOTES    VARCHAR2(400 BYTE)
)

insert into clients (client_id, client_name, client_address) values ( 1, 'Ibrahim Mohamed', 'Minya'); 
insert into clients (client_id, client_name, client_address) values ( 2, 'Mohamed Omar', 'Assuit');
insert into clients (client_id, client_name, client_address) values ( 3, 'Helmy Hisham', 'Cairo');
insert into clients (client_id, client_name, client_address) values ( 4, 'Mahmoud Bakr', 'Alex'); 

Contracts table 
create table contracts
(
contract_id number(4) constraint contr_id_pk primary key,
contract_startdate date,
contract_enddate date,
payment_installment_no number(4),
contract_total_fees number(10,2),
contract_deposit_fees number(10,2),
client_id number(4) constraint client_fk_id references clients(client_id),
contract_payment_type varchar2(100),
notes varchar2(400)
);
       
insert into Contracts (CONTRACT_ID,  CONTRACT_STARTDATE, CONTRACT_ENDDATE, CONTRACT_TOTAL_FEES, CONTRACT_DEPOSIT_FEES, CLIENT_ID, CONTRACT_PAYMENT_TYPE) 
values (101, TO_DATE('01.03.2021', 'DD.MM.YYYY') , TO_DATE('01.03.2024', 'DD.MM.YYYY'), 600000, null, 1, 'Annual'); 

insert into Contracts (CONTRACT_ID,  CONTRACT_STARTDATE, CONTRACT_ENDDATE, CONTRACT_TOTAL_FEES, CONTRACT_DEPOSIT_FEES, CLIENT_ID, CONTRACT_PAYMENT_TYPE) 
values (102, TO_DATE('01.03.2021', 'DD.MM.YYYY') , TO_DATE('01.03.2024', 'DD.MM.YYYY'), 600000, 10000, 2, 'Quarter'); 

insert into Contracts (CONTRACT_ID,  CONTRACT_STARTDATE, CONTRACT_ENDDATE, CONTRACT_TOTAL_FEES, CONTRACT_DEPOSIT_FEES, CLIENT_ID, CONTRACT_PAYMENT_TYPE) 
values (103, TO_DATE('01.05.2021', 'DD.MM.YYYY') , TO_DATE('01.03.2023', 'DD.MM.YYYY'), 400000, 50000, 3, 'Quarter'); 

insert into Contracts (CONTRACT_ID,  CONTRACT_STARTDATE, CONTRACT_ENDDATE, CONTRACT_TOTAL_FEES, CONTRACT_DEPOSIT_FEES, CLIENT_ID, CONTRACT_PAYMENT_TYPE) 
values (104, TO_DATE('01.03.2021', 'DD.MM.YYYY') , TO_DATE('01.03.2024', 'DD.MM.YYYY'), 700000, null, 4, 'Monthly');

insert into Contracts (CONTRACT_ID,  CONTRACT_STARTDATE, CONTRACT_ENDDATE, CONTRACT_TOTAL_FEES, CONTRACT_DEPOSIT_FEES, CLIENT_ID, CONTRACT_PAYMENT_TYPE) 
values (105, TO_DATE('01.04.2021', 'DD.MM.YYYY') , TO_DATE('01.03.2026', 'DD.MM.YYYY'), 900000, 300000, 1, 'Annual');

create table installments_paid
(
installment_id number(4) constraint installment_id_pk primary key,
contract_id number(4) constraint contr_id_fk references contracts(contract_id),
installment_date date,
installment_amount number(10,2),
piad number(10,2)
);


-----------------1st Procedure ----------
create or replace procedure Upddte_pro is 

 CURSOR installment_cursor
   IS
      SELECT contract_id,
             client_id,
             MONTHS_BETWEEN (contract_enddate, contract_startdate) AS months,
             contract_payment_type
        FROM contracts;
        
           v_install_no   contracts.PAYMENT_INSTALLMENT_NO%TYPE;
BEGIN
   FOR contract_record IN installment_cursor
   LOOP
      IF contract_record.contract_payment_type = 'Annual'
      THEN
         v_install_no := contract_record.months / 12;

      ELSIF contract_record.contract_payment_type = 'Quarter'
      THEN
         v_install_no := contract_record.months / 3;

      ELSIF contract_record.contract_payment_type = 'Monthly'
      THEN
         v_install_no := contract_record.months;

     
      ELSE
         v_install_no := contract_record.months / 6;


      END IF;
      
               UPDATE contracts
            SET payment_installment_no = v_install_no
          WHERE contract_id = contract_record.contract_id;
   END LOOP;
END;


------------- 2nd Procedure ----------------
CREATE OR REPLACE PROCEDURE installments_paid_proc
IS
   CURSOR installemt_cursor
   IS
      SELECT * FROM contracts;
      v_months   DATE;
       v_amount   NUMBER (10, 2); 
BEGIN
   FOR inst_record IN installemt_cursor
   LOOP
   v_months := inst_record.CONTRACT_STARTDATE;
      v_amount :=
         (inst_record.CONTRACT_TOTAL_FEES
          - (NVL (inst_record.CONTRACT_DEPOSIT_FEES, 0)))
         / inst_record.PAYMENT_INSTALLMENT_NO;

   for i in 1 .. inst_record.PAYMENT_INSTALLMENT_NO loop 

    IF inst_record.CONTRACT_PAYMENT_TYPE = 'Annual'
      THEN
      INSERT INTO installments_paid (INSTALLMENT_ID,
                                        CONTRACT_ID,
                                        INSTALLMENT_DATE,
                                        INSTALLMENT_AMOUNT,
                                       PIAD)
              VALUES (installments_paid_seq.NEXTVAL,
                      inst_record.CONTRACT_ID,
                      v_months,
                      v_amount,
                      0);
            v_months := ADD_MONTHS (v_months, 12);
            
                Elsif inst_record.CONTRACT_PAYMENT_TYPE = 'Quarter'
      THEN
      INSERT INTO installments_paid (INSTALLMENT_ID,
                                        CONTRACT_ID,
                                        INSTALLMENT_DATE,
                                        INSTALLMENT_AMOUNT,
                                       PIAD)
              VALUES (installments_paid_seq.NEXTVAL,
                      inst_record.CONTRACT_ID,
                      v_months,
                      v_amount,
                      0);
            v_months := ADD_MONTHS (v_months, 3);
            
            Elsif inst_record.CONTRACT_PAYMENT_TYPE = 'Monthly'
      THEN
      INSERT INTO installments_paid (INSTALLMENT_ID,
                                        CONTRACT_ID,
                                        INSTALLMENT_DATE,
                                        INSTALLMENT_AMOUNT,
                                       PIAD)
              VALUES (installments_paid_seq.NEXTVAL,
                      inst_record.CONTRACT_ID,
                      v_months,
                      v_amount,
                      0);
            v_months := ADD_MONTHS (v_months, 1);
            
                     Else 
 
      INSERT INTO installments_paid (INSTALLMENT_ID,
                                        CONTRACT_ID,
                                        INSTALLMENT_DATE,
                                        INSTALLMENT_AMOUNT,
                                       PIAD)
              VALUES (installments_paid_seq.NEXTVAL,
                      inst_record.CONTRACT_ID,
                      v_months,
                      v_amount,
                      0);
            v_months := ADD_MONTHS (v_months, 6);

      END IF;
   END LOOP;
   end loop;
END;



begin 
    installments_paid_proc;
end;----------- Tables Creation -----------
Clients table 
CREATE TABLE HR.CLIENTS
(
  CLIENT_ID       NUMBER(4),
  CLIENT_NAME     VARCHAR2(100 BYTE) CONSTRAINT CLIENT_NAME_NN NOT NULL,
  CLIENT_ADDRESS  VARCHAR2(100 BYTE),
  CLIENT_NOTES    VARCHAR2(400 BYTE)
)

insert into clients (client_id, client_name, client_address) values ( 1, 'Ibrahim Mohamed', 'Minya'); 
insert into clients (client_id, client_name, client_address) values ( 2, 'Mohamed Omar', 'Assuit');
insert into clients (client_id, client_name, client_address) values ( 3, 'Helmy Hisham', 'Cairo');
insert into clients (client_id, client_name, client_address) values ( 4, 'Mahmoud Bakr', 'Alex'); 

Contracts table 
create table contracts
(
contract_id number(4) constraint contr_id_pk primary key,
contract_startdate date,
contract_enddate date,
payment_installment_no number(4),
contract_total_fees number(10,2),
contract_deposit_fees number(10,2),
client_id number(4) constraint client_fk_id references clients(client_id),
contract_payment_type varchar2(100),
notes varchar2(400)
);
       
insert into Contracts (CONTRACT_ID,  CONTRACT_STARTDATE, CONTRACT_ENDDATE, CONTRACT_TOTAL_FEES, CONTRACT_DEPOSIT_FEES, CLIENT_ID, CONTRACT_PAYMENT_TYPE) 
values (101, TO_DATE('01.03.2021', 'DD.MM.YYYY') , TO_DATE('01.03.2024', 'DD.MM.YYYY'), 600000, null, 1, 'Annual'); 

insert into Contracts (CONTRACT_ID,  CONTRACT_STARTDATE, CONTRACT_ENDDATE, CONTRACT_TOTAL_FEES, CONTRACT_DEPOSIT_FEES, CLIENT_ID, CONTRACT_PAYMENT_TYPE) 
values (102, TO_DATE('01.03.2021', 'DD.MM.YYYY') , TO_DATE('01.03.2024', 'DD.MM.YYYY'), 600000, 10000, 2, 'Quarter'); 

insert into Contracts (CONTRACT_ID,  CONTRACT_STARTDATE, CONTRACT_ENDDATE, CONTRACT_TOTAL_FEES, CONTRACT_DEPOSIT_FEES, CLIENT_ID, CONTRACT_PAYMENT_TYPE) 
values (103, TO_DATE('01.05.2021', 'DD.MM.YYYY') , TO_DATE('01.03.2023', 'DD.MM.YYYY'), 400000, 50000, 3, 'Quarter'); 

insert into Contracts (CONTRACT_ID,  CONTRACT_STARTDATE, CONTRACT_ENDDATE, CONTRACT_TOTAL_FEES, CONTRACT_DEPOSIT_FEES, CLIENT_ID, CONTRACT_PAYMENT_TYPE) 
values (104, TO_DATE('01.03.2021', 'DD.MM.YYYY') , TO_DATE('01.03.2024', 'DD.MM.YYYY'), 700000, null, 4, 'Monthly');

insert into Contracts (CONTRACT_ID,  CONTRACT_STARTDATE, CONTRACT_ENDDATE, CONTRACT_TOTAL_FEES, CONTRACT_DEPOSIT_FEES, CLIENT_ID, CONTRACT_PAYMENT_TYPE) 
values (105, TO_DATE('01.04.2021', 'DD.MM.YYYY') , TO_DATE('01.03.2026', 'DD.MM.YYYY'), 900000, 300000, 1, 'Annual');

create table installments_paid
(
installment_id number(4) constraint installment_id_pk primary key,
contract_id number(4) constraint contr_id_fk references contracts(contract_id),
installment_date date,
installment_amount number(10,2),
piad number(10,2)
);


-----------------1st Procedure ----------
create or replace procedure Upddte_pro is 

 CURSOR installment_cursor
   IS
      SELECT contract_id,
             client_id,
             MONTHS_BETWEEN (contract_enddate, contract_startdate) AS months,
             contract_payment_type
        FROM contracts;
        
           v_install_no   contracts.PAYMENT_INSTALLMENT_NO%TYPE;
BEGIN
   FOR contract_record IN installment_cursor
   LOOP
      IF contract_record.contract_payment_type = 'Annual'
      THEN
         v_install_no := contract_record.months / 12;

      ELSIF contract_record.contract_payment_type = 'Quarter'
      THEN
         v_install_no := contract_record.months / 3;

      ELSIF contract_record.contract_payment_type = 'Monthly'
      THEN
         v_install_no := contract_record.months;

     
      ELSE
         v_install_no := contract_record.months / 6;


      END IF;
      
               UPDATE contracts
            SET payment_installment_no = v_install_no
          WHERE contract_id = contract_record.contract_id;
   END LOOP;
END;


------------- 2nd Procedure ----------------
CREATE OR REPLACE PROCEDURE installments_paid_proc
IS
   CURSOR installemt_cursor
   IS
      SELECT * FROM contracts;
      v_months   DATE;
       v_amount   NUMBER (10, 2); 
BEGIN
   FOR inst_record IN installemt_cursor
   LOOP
   v_months := inst_record.CONTRACT_STARTDATE;
      v_amount :=
         (inst_record.CONTRACT_TOTAL_FEES
          - (NVL (inst_record.CONTRACT_DEPOSIT_FEES, 0)))
         / inst_record.PAYMENT_INSTALLMENT_NO;

   for i in 1 .. inst_record.PAYMENT_INSTALLMENT_NO loop 

    IF inst_record.CONTRACT_PAYMENT_TYPE = 'Annual'
      THEN
      INSERT INTO installments_paid (INSTALLMENT_ID,
                                        CONTRACT_ID,
                                        INSTALLMENT_DATE,
                                        INSTALLMENT_AMOUNT,
                                       PIAD)
              VALUES (installments_paid_seq.NEXTVAL,
                      inst_record.CONTRACT_ID,
                      v_months,
                      v_amount,
                      0);
            v_months := ADD_MONTHS (v_months, 12);
            
                Elsif inst_record.CONTRACT_PAYMENT_TYPE = 'Quarter'
      THEN
      INSERT INTO installments_paid (INSTALLMENT_ID,
                                        CONTRACT_ID,
                                        INSTALLMENT_DATE,
                                        INSTALLMENT_AMOUNT,
                                       PIAD)
              VALUES (installments_paid_seq.NEXTVAL,
                      inst_record.CONTRACT_ID,
                      v_months,
                      v_amount,
                      0);
            v_months := ADD_MONTHS (v_months, 3);
            
            Elsif inst_record.CONTRACT_PAYMENT_TYPE = 'Monthly'
      THEN
      INSERT INTO installments_paid (INSTALLMENT_ID,
                                        CONTRACT_ID,
                                        INSTALLMENT_DATE,
                                        INSTALLMENT_AMOUNT,
                                       PIAD)
              VALUES (installments_paid_seq.NEXTVAL,
                      inst_record.CONTRACT_ID,
                      v_months,
                      v_amount,
                      0);
            v_months := ADD_MONTHS (v_months, 1);
            
                     Else 
 
      INSERT INTO installments_paid (INSTALLMENT_ID,
                                        CONTRACT_ID,
                                        INSTALLMENT_DATE,
                                        INSTALLMENT_AMOUNT,
                                       PIAD)
              VALUES (installments_paid_seq.NEXTVAL,
                      inst_record.CONTRACT_ID,
                      v_months,
                      v_amount,
                      0);
            v_months := ADD_MONTHS (v_months, 6);

      END IF;
   END LOOP;
   end loop;
END;



begin 
    installments_paid_proc;
end;
