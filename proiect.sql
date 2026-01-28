set serveroutput on;

--0. Stergerea tabelelor 
declare
toate_tabelele_sterse BOOLEAN := TRUE;
begin
begin
    execute immediate 'drop table hoteluri cascade constraints';
    exception when others then dbms_output.put_line('Nu exista tabela hoteluri'); toate_tabelele_sterse:=false;
end;
begin
    execute immediate 'drop table camere cascade constraints';
    exception when others then dbms_output.put_line('Nu exista tabela camere'); toate_tabelele_sterse:=false;
end;
begin
    execute immediate 'drop table clienti_hotel cascade constraints';
    exception when others then dbms_output.put_line('Nu exista tabela clienti_hotel'); toate_tabelele_sterse:=false;
end;
begin
    execute immediate 'drop table rezervari cascade constraints';
    exception when others then dbms_output.put_line('Nu exista tabela rezervari'); toate_tabelele_sterse:=false;
end;
begin
    execute immediate 'drop table plati cascade constraints';
    exception when others then dbms_output.put_line('Nu exista tabela plati'); toate_tabelele_sterse:=false;
end;
begin
    execute immediate 'drop table recenzii cascade constraints';
    exception when others then dbms_output.put_line('Nu exista tabela recenzii'); toate_tabelele_sterse:=false;
end;
begin
    execute immediate 'drop table angajati_hotel cascade constraints';
    exception when others then dbms_output.put_line('Nu exista tabela angajati_hotel'); toate_tabelele_sterse:=false;
end;
begin
    execute immediate 'drop table istoric_rezervari cascade constraints';
    exception when others then dbms_output.put_line('Nu exista tabela istoric_rezervari'); toate_tabelele_sterse:=false;
end;
if toate_tabelele_sterse = true then
dbms_output.put_line('S-au sters toate tabelele');
end if;
end;
/



--1.Crearea tabelelor
begin
execute immediate 'create table hoteluri
(id_hotel number(5) constraint id_hotel_pk primary key,
nume varchar(50) not null,
adresa varchar(100) not null,
oras varchar(50) not null,
stele number(1),
constraint stele_ch check (stele between 1 and 5))';

execute immediate 'create table camere
( nr_camera varchar(3) constraint nr_camera_pk primary key,
tip varchar(40),
pret_noapte number(3) not null,
id_hotel number(5) references hoteluri(id_hotel),
constraint pret_ch check (pret_noapte>0)
)';


execute immediate 'create table clienti_hotel
( id_client number(5) constraint id_client_pk primary key,
nume varchar(20) not null,
prenume varchar(20) not null,
email varchar(40)
)';

execute immediate 'create table rezervari
( id_rezervare number(5) constraint id_rezervare_pk primary key,
id_client number(5) constraint id_client_fk references clienti_hotel(id_client),
id_hotel number(5) references hoteluri(id_hotel),
nr_camera varchar(3) constraint nr_camera_fk references camere(nr_camera), 
data_checkin date not null,
data_checkout date not null,
status varchar(20) default ''activa'' not null,
constraint data_ch check (data_checkout>data_checkin)
)';

execute immediate 'create table plati
(
id_plata NUMBER(5) CONSTRAINT id_plata_pk PRIMARY KEY,
id_rezervare NUMBER(5) CONSTRAINT id_rezervare_fk REFERENCES rezervari(id_rezervare),
suma NUMBER(8,2) NOT NULL,
data_plata DATE NOT NULL,
metoda_plata VARCHAR2(50),
CONSTRAINT metode_plata_ch CHECK (metoda_plata IN (''card'', ''cash'', ''transfer bancar'', ''bonuri de vacanta''))
)';

execute immediate 'create table recenzii 
(
id_recenzie NUMBER(5) CONSTRAINT id_recenzie_pk PRIMARY KEY,
id_client NUMBER(5) CONSTRAINT id_client_fk2 REFERENCES clienti_hotel(id_client),
id_rezervare NUMBER(5) CONSTRAINT id_rezervare_fk2 REFERENCES rezervari(id_rezervare),
rating NUMBER(1),
comentariu varchar(200)
)';

execute immediate 'create table angajati_hotel (
id_angajat NUMBER(5) CONSTRAINT id_angajat_pk PRIMARY KEY,
nume VARCHAR(30) NOT NULL,
prenume VARCHAR(30) NOT NULL,
functie VARCHAR(30) NOT NULL,
data_angajare DATE NOT NULL,
salariu NUMBER(7,2) NOT NULL,
id_hotel number(5),
CONSTRAINT fk_id_hotel FOREIGN KEY (id_hotel) REFERENCES hoteluri(id_hotel),
constraint salariu_ch CHECK (salariu > 0)
)';

execute immediate 'create table istoric_rezervari (
    id_rezervare number(5) primary key,
    id_client number(5) references clienti_hotel(id_client),
    id_hotel number(5) references hoteluri(id_hotel),
    nr_camera varchar(3) references camere(nr_camera), 
    data_checkin date not null,
    data_checkout date not null,
    nume varchar(20) not null,
    prenume varchar(20) not null,
    rating number(1) not null,
    check (data_checkout > data_checkin))';


dbms_output.put_line('S-au generat toate tabelele');
exception when others then dbms_output.put_line('A aparut o eroare! ' || sqlerrm);
end;
/



--2.Actualizarea structurii tabelelor si modificarea restrictiilor de integritate

--Crearea unui pachet cu proceduri care va face diferite actualizari asupra tabelelor
create or replace package modificari_tabele_hotel is
    procedure adaugare_telefon_clienti;
    procedure stergere_comentariu_recenzii;
    procedure modificare_metoda_plata;
    procedure modificare_constraint_rating_recenzii;
exceptie exception;
end;
/

create or replace package body modificari_tabele_hotel is
procedure adaugare_telefon_clienti --adaugarea coloanei telefon pentru clienti
    is
    begin
    execute immediate 'alter table clienti_hotel add telefon varchar(10)';
    dbms_output.put_line('S-a adaugat coloana telefon in tabela clienti_hotel');
    exception when others then dbms_output.put_line(sqlerrm);
    end;
procedure stergere_comentariu_recenzii --stergerea coloanei de comentariu la recenzii
    is
    begin
    execute immediate 'alter table recenzii drop column comentariu';
    dbms_output.put_line('S-a sters coloana comentariu din tabela recenzii');
    exception when others then dbms_output.put_line(sqlerrm);
    end;
procedure modificare_metoda_plata --modificare tip de date intr-o coloana
    is
    begin
    execute immediate 'alter table plati modify metoda_plata varchar2(20)';
    dbms_output.put_line('S-a modificat tipul coloanei metoda_plata din tabela plati in varchar2(20)');
    exception when others then dbms_output.put_line(sqlerrm);
    end;
procedure modificare_constraint_rating_recenzii --adaugare constraint rating sa fie intre 1 si 5
    is
    begin
        begin
        execute immediate 'alter table recenzii drop constraint check_rating';
        exception when others then null;
        end;
    execute immediate 'alter table recenzii add constraint check_rating check(rating between 1 and 5)';
    dbms_output.put_line('S-a adaugat si modificat un constraint, astfel incat rating-ul sa fie intre 1 si 5');
    exception when others then dbms_output.put_line('Eroare' || sqlerrm);
    end;
end;
/


--Apelarea procedurilor din pachet.
begin
modificari_tabele_hotel.adaugare_telefon_clienti;
modificari_tabele_hotel.stergere_comentariu_recenzii;
modificari_tabele_hotel.modificare_metoda_plata;
modificari_tabele_hotel.modificare_constraint_rating_recenzii;
end;
/





--3.	Adăugarea înregistrărilor în fiecare tabelă (
create or replace package adaugare_date is
procedure insereaza_camere;
procedure insereaza_hoteluri;
procedure insereaza_clienti_hotel;
procedure insereaza_rezervari;
procedure insereaza_plati;
procedure insereaza_recenzii;
procedure insereaza_angajati_hotel;
end;
/
create or replace package body adaugare_date is
procedure insereaza_hoteluri
is
begin
    insert into hoteluri (id_hotel, nume, adresa, oras, stele) values (1, 'Hotel Centru', 'Bulveardul Unirii 28, Bucuresti', 'Bucuresti', 4);
    insert into hoteluri (id_hotel, nume, adresa, oras, stele) values (2, 'Hotel Mare', 'Strada Mircea cel Batran, Constanta', 'Constanta', 5);
    insert into hoteluri (id_hotel, nume, adresa, oras, stele) values (3, 'Hotel Verde', 'Str. Verde 9, Brasov', 'Brasov', 4);
end;
procedure insereaza_camere
is 
begin
    insert into camere (nr_camera, tip, pret_noapte, id_hotel) values ('001', 'single', 150, 1);
insert into camere (nr_camera, tip, pret_noapte, id_hotel) values ('002', 'single', 250, 1);
insert into camere (nr_camera, tip, pret_noapte, id_hotel) values ('003', 'single', 100, 2);
insert into camere (nr_camera, tip, pret_noapte, id_hotel) values ('004', 'single', 120, 2);
insert into camere (nr_camera, tip, pret_noapte, id_hotel) values ('005', 'single', 130, 3);
insert into camere (nr_camera, tip, pret_noapte, id_hotel) values ('006', 'single', 500, 3);
insert into camere (nr_camera, tip, pret_noapte, id_hotel) values ('007', 'single', 80, 1);
insert into camere (nr_camera, tip, pret_noapte, id_hotel) values ('008', 'dubla', 225, 1);
insert into camere (nr_camera, tip, pret_noapte, id_hotel) values ('101', 'apartament', 450, 2);
insert into camere (nr_camera, tip, pret_noapte, id_hotel) values ('102', 'dubla', 180, 3);
insert into camere (nr_camera, tip, pret_noapte, id_hotel) values ('103', 'single', 80, 2);
insert into camere (nr_camera, tip, pret_noapte, id_hotel) values ('104', 'single', 100, 2);
insert into camere (nr_camera, tip, pret_noapte, id_hotel) values ('201', 'single', 120, 1);
insert into camere (nr_camera, tip, pret_noapte, id_hotel) values ('202', 'apartament', 400, 3);
insert into camere (nr_camera, tip, pret_noapte, id_hotel) values ('203', 'apartament', 550, 3);
insert into camere (nr_camera, tip, pret_noapte, id_hotel) values ('204', 'dubla', 200, 2);
insert into camere (nr_camera, tip, pret_noapte, id_hotel) values ('205', 'single', 125, 1);
insert into camere (nr_camera, tip, pret_noapte, id_hotel) values ('206', 'apartament', 450, 1);
insert into camere (nr_camera, tip, pret_noapte, id_hotel) values ('207', 'single', 105, 1);
insert into camere (nr_camera, tip, pret_noapte, id_hotel) values ('208', 'dubla', 250, 2);


end;

procedure insereaza_clienti_hotel 
is
begin
insert into clienti_hotel values(18434, 'Andrei', 'Balitu', 'andreibalitu2001@gmail.com','0727367288');
insert into clienti_hotel values(18435, 'Maria', 'Cicitu', 'mariaaadjawkdd23i9123i19d@gmail.com','0724635261');
insert into clienti_hotel (id_client, nume, prenume, telefon) values (18436, 'Ioana', 'Stanescu','0728374622');
insert into clienti_hotel (id_client, nume, prenume,email ) values (18437, 'Florin', 'Iordache','floriniordache1973@gmail.com');
insert into clienti_hotel (id_client, nume, prenume, email, telefon) values (18438, 'Gheorghe', 'Vasile', 'gheorghevasileetare@yahoo.com', '0722345678');
insert into clienti_hotel (id_client, nume, prenume) values (18439, 'Vasile', 'Radu');
insert into clienti_hotel (id_client, nume, prenume, email, telefon) values (18440, 'Ion', 'Popescu', 'ionpopescu1978@gmail.com', '0721223344');
insert into clienti_hotel (id_client, nume, prenume, telefon) values (18441, 'Valentin', 'Dima', '0729678901');
insert into clienti_hotel (id_client, nume, prenume, telefon)VALUES (18442, 'Teodora', 'Popescu', '0729789012');
insert into clienti_hotel (id_client, nume, prenume, email, telefon) values (18443, 'Andrei', 'Munteanu', 'andreimunteanu728@gmail.com', '0730567890');
insert into clienti_hotel (id_client, nume, prenume, email, telefon) values (18444, 'Alexandru', 'Ionescu', 'alexandru.ionescu@gmail.com', '0745678901');
insert into clienti_hotel (id_client, nume, prenume, email, telefon) values (18445, 'Diana', 'Popa', 'diana.popa@yahoo.com', '0745432109');
insert into clienti_hotel (id_client, nume, prenume, telefon) values (18446, 'Radu', 'Nicolae', '0745123456');
insert into clienti_hotel (id_client, nume, prenume, email, telefon) values (18447, 'Alina', 'Gheorghiu', 'alina.gheorghiu@outlook.com', '0749898765');
insert into clienti_hotel (id_client, nume, prenume, telefon) values (18448, 'Mihai', 'Luca', '0748456123');
insert into clienti_hotel (id_client, nume, prenume, email, telefon) values (18449, 'Laura', 'Costea', 'laura.costea@gmail.com', '0745667788');
insert into clienti_hotel (id_client, nume, prenume, telefon) values (18450, 'Gheorghe', 'Ion', '0741234567');
insert into clienti_hotel (id_client, nume, prenume, email, telefon) values (18451, 'Cristian', 'Marin', 'cristian.marin@yahoo.com', '0745566777');
insert into clienti_hotel (id_client, nume, prenume, email, telefon) values (18452, 'Anca', 'Munteanu', 'anca.munteanu@pgmail.com', '0749998888');
insert into clienti_hotel (id_client, nume, prenume, telefon) values (18453, 'Elena', 'Vlad', '0743322110');

end;

procedure insereaza_rezervari
is
begin
insert into rezervari (id_rezervare, id_client, id_hotel, nr_camera, data_checkin, data_checkout) 
values (1, 18434, 1, '002', TO_DATE('01-05-2025', 'DD-MM-YYYY'), TO_DATE('06-05-2025', 'DD-MM-YYYY'));
insert into rezervari (id_rezervare, id_client, id_hotel, nr_camera, data_checkin, data_checkout) 
values (2, 18435, 1, '003', TO_DATE('07-05-2025', 'DD-MM-YYYY'), TO_DATE('12-05-2025', 'DD-MM-YYYY'));
insert into rezervari (id_rezervare, id_client, id_hotel, nr_camera, data_checkin, data_checkout) 
values (3, 18436, 1, '004', TO_DATE('13-05-2025', 'DD-MM-YYYY'), TO_DATE('18-05-2025', 'DD-MM-YYYY'));
insert into rezervari (id_rezervare, id_client, id_hotel, nr_camera, data_checkin, data_checkout) 
values (4, 18437, 1, '007', TO_DATE('19-05-2025', 'DD-MM-YYYY'), TO_DATE('24-05-2025', 'DD-MM-YYYY'));
insert into rezervari (id_rezervare, id_client, id_hotel, nr_camera, data_checkin, data_checkout) 
values (5, 18438, 2, '103', TO_DATE('01-05-2025', 'DD-MM-YYYY'), TO_DATE('06-05-2025', 'DD-MM-YYYY'));
insert into rezervari (id_rezervare, id_client, id_hotel, nr_camera, data_checkin, data_checkout) 
values (6, 18439, 2, '104', TO_DATE('07-05-2025', 'DD-MM-YYYY'), TO_DATE('12-05-2025', 'DD-MM-YYYY'));
insert into rezervari (id_rezervare, id_client, id_hotel, nr_camera, data_checkin, data_checkout) 
values (7, 18440, 2, '201', TO_DATE('13-05-2025', 'DD-MM-YYYY'), TO_DATE('18-05-2025', 'DD-MM-YYYY'));
insert into rezervari (id_rezervare, id_client, id_hotel, nr_camera, data_checkin, data_checkout) 
values (8, 18441, 2, '203', TO_DATE('19-05-2025', 'DD-MM-YYYY'), TO_DATE('24-05-2025', 'DD-MM-YYYY'));
insert into rezervari (id_rezervare, id_client, id_hotel, nr_camera, data_checkin, data_checkout) 
values (9, 18442, 3, '206', TO_DATE('01-05-2025', 'DD-MM-YYYY'), TO_DATE('06-05-2025', 'DD-MM-YYYY'));
insert into rezervari (id_rezervare, id_client, id_hotel, nr_camera, data_checkin, data_checkout) 
values (10, 18443, 3, '207', TO_DATE('07-05-2025', 'DD-MM-YYYY'), TO_DATE('12-05-2025', 'DD-MM-YYYY'));
insert into rezervari (id_rezervare, id_client, id_hotel, nr_camera, data_checkin, data_checkout) 
values (11, 18444, 1, '004', TO_DATE('13-05-2025', 'DD-MM-YYYY'), TO_DATE('18-05-2025', 'DD-MM-YYYY'));
insert into rezervari (id_rezervare, id_client, id_hotel, nr_camera, data_checkin, data_checkout) 
values (12, 18445, 2, '206', TO_DATE('19-05-2025', 'DD-MM-YYYY'), TO_DATE('24-05-2025', 'DD-MM-YYYY'));
insert into rezervari (id_rezervare, id_client, id_hotel, nr_camera, data_checkin, data_checkout) 
values (13, 18446, 3, '007', TO_DATE('25-05-2025', 'DD-MM-YYYY'), TO_DATE('30-05-2025', 'DD-MM-YYYY'));
insert into rezervari (id_rezervare, id_client, id_hotel, nr_camera, data_checkin, data_checkout) 
values (14, 18447, 2, '103', TO_DATE('31-05-2025', 'DD-MM-YYYY'), TO_DATE('05-06-2025', 'DD-MM-YYYY'));
insert into rezervari (id_rezervare, id_client, id_hotel, nr_camera, data_checkin, data_checkout) 
values (15, 18448, 1, '101', TO_DATE('06-06-2025', 'DD-MM-YYYY'), TO_DATE('11-06-2025', 'DD-MM-YYYY'));
insert into rezervari (id_rezervare, id_client, id_hotel, nr_camera, data_checkin, data_checkout) 
values (16, 18449, 3, '102', TO_DATE('12-06-2025', 'DD-MM-YYYY'), TO_DATE('17-06-2025', 'DD-MM-YYYY'));
insert into rezervari (id_rezervare, id_client, id_hotel, nr_camera, data_checkin, data_checkout) 
values (17, 18450, 2, '205', TO_DATE('13-06-2025', 'DD-MM-YYYY'), TO_DATE('18-06-2025', 'DD-MM-YYYY'));
insert into rezervari (id_rezervare, id_client, id_hotel, nr_camera, data_checkin, data_checkout) 
values (18, 18451, 1, '103', TO_DATE('19-06-2025', 'DD-MM-YYYY'), TO_DATE('24-06-2025', 'DD-MM-YYYY'));
insert into rezervari (id_rezervare, id_client, id_hotel, nr_camera, data_checkin, data_checkout) 
values (19, 18452, 2, '204', TO_DATE('25-06-2025', 'DD-MM-YYYY'), TO_DATE('30-06-2025', 'DD-MM-YYYY'));

end;


procedure insereaza_plati
is
begin
insert into plati (id_plata, id_rezervare, suma, data_plata, metoda_plata) values (1, 1, 1250.00, to_date('10-01-2025', 'DD-MM-YYYY'), 'card');
  insert into plati values (2, 2, 400.00, to_date('12-01-2025', 'DD-MM-YYYY'), 'cash');
  insert into plati values (3, 3, 480.00, to_date('14-01-2025', 'DD-MM-YYYY'), 'card');
  insert into plati values (4, 4, 400.00, to_date('15-01-2025', 'DD-MM-YYYY'), 'cash');
  insert into plati values (5, 5, 480.00, to_date('16-01-2025', 'DD-MM-YYYY'), 'card');
  insert into plati values  (6, 6, 600.00, to_date('17-01-2025', 'DD-MM-YYYY'), 'cash');
  insert into plati values (7, 7, 720.00, to_date('18-01-2025', 'DD-MM-YYYY'), 'card');
  insert into plati values (8, 8, 2700.00, to_date('19-01-2025', 'DD-MM-YYYY'), 'cash');
  insert into plati values (9, 9, 2700.00, to_date('20-01-2025', 'DD-MM-YYYY'), 'card');
  insert into plati values (10, 10, 630.00, to_date('21-01-2025', 'DD-MM-YYYY'), 'card');
  insert into plati (id_plata, id_rezervare, suma, data_plata, metoda_plata) values (11, 11, 1100.00, to_date('22-01-2025', 'DD-MM-YYYY'), 'cash');
  insert into plati (id_plata, id_rezervare, suma, data_plata, metoda_plata) values (12, 12, 250.00, to_date('23-01-2025', 'DD-MM-YYYY'), 'card');
  insert into plati (id_plata, id_rezervare, suma, data_plata, metoda_plata) values (13, 13, 320.00, to_date('24-01-2025', 'DD-MM-YYYY'), 'cash');
  insert into plati (id_plata, id_rezervare, suma, data_plata, metoda_plata) values (14, 14, 560.00, to_date('25-01-2025', 'DD-MM-YYYY'), 'card');
  insert into plati (id_plata, id_rezervare, suma, data_plata, metoda_plata) values (15, 15, 1100.00, to_date('26-01-2025', 'DD-MM-YYYY'), 'cash');
  insert into plati (id_plata, id_rezervare, suma, data_plata, metoda_plata) values (16, 16, 420.00, to_date('27-01-2025', 'DD-MM-YYYY'), 'card');
  insert into plati (id_plata, id_rezervare, suma, data_plata, metoda_plata) values (17, 17, 720.00, to_date('28-01-2025', 'DD-MM-YYYY'), 'cash');
  insert into plati (id_plata, id_rezervare, suma, data_plata, metoda_plata) values (18, 18, 1100.00, to_date('29-01-2025', 'DD-MM-YYYY'), 'card');
  insert into plati (id_plata, id_rezervare, suma, data_plata, metoda_plata) values (19, 19, 350.00, to_date('30-01-2025', 'DD-MM-YYYY'), 'cash');
end;

procedure insereaza_recenzii 
is
begin
insert into recenzii (id_recenzie, id_client, id_rezervare, rating) values (1, 18434, 1, 4);
insert into recenzii (id_recenzie, id_client, id_rezervare, rating) values (2, 18435, 2, 5);
insert into recenzii (id_recenzie, id_client, id_rezervare, rating) values (3, 18436, 3, 3);
insert into recenzii (id_recenzie, id_client, id_rezervare, rating) values (4, 18437, 4, null);
insert into recenzii (id_recenzie, id_client, id_rezervare, rating) values (5, 18438, 5, 4);
insert into recenzii (id_recenzie, id_client, id_rezervare, rating) values (6, 18439, 6, 2);
insert into recenzii (id_recenzie, id_client, id_rezervare, rating) values (7, 18440, 7, null);
insert into recenzii (id_recenzie, id_client, id_rezervare, rating) values (8, 18441, 8, 5);
insert into recenzii (id_recenzie, id_client, id_rezervare, rating) values (9, 18442, 9, null);
insert into recenzii (id_recenzie, id_client, id_rezervare, rating) values (10, 18443, 10, 4);
insert into recenzii (id_recenzie, id_client, id_rezervare, rating) values (11, 18444, 11, 4);
insert into recenzii (id_recenzie, id_client, id_rezervare, rating) values (12, 18445, 12, 3);
insert into recenzii (id_recenzie, id_client, id_rezervare, rating) values (13, 18446, 13, 5);
insert into recenzii (id_recenzie, id_client, id_rezervare, rating) values (14, 18447, 14, null);
insert into recenzii (id_recenzie, id_client, id_rezervare, rating) values (15, 18448, 15, 4);
insert into recenzii (id_recenzie, id_client, id_rezervare, rating) values (16, 18449, 16, 5);
insert into recenzii (id_recenzie, id_client, id_rezervare, rating) values (17, 18450, 17, null);
insert into recenzii (id_recenzie, id_client, id_rezervare, rating) values (18, 18451, 18, 3);
insert into recenzii (id_recenzie, id_client, id_rezervare, rating) values (19, 18452, 19, 4);

end;

procedure insereaza_angajati_hotel
is
begin
  insert into angajati_hotel (id_angajat, nume, prenume, functie, data_angajare, salariu, id_hotel)
  values (1, 'Popescu', 'Ion', 'receptioner', to_date('05-01-2022', 'dd-mm-yyyy'), 3500.00, 1);
  
  insert into angajati_hotel values (2, 'Ionescu', 'Maria', 'manager', to_date('10-02-2021', 'dd-mm-yyyy'), 5000.00, 1);
  insert into angajati_hotel values (3, 'Dumitru', 'Andreea', 'camerista', to_date('15-03-2023', 'dd-mm-yyyy'), 3800.00, 1);
  insert into angajati_hotel values (4, 'Georgescu', 'Mihai', 'bucatar', to_date('20-04-2022', 'dd-mm-yyyy'), 6450.00, 2);
  insert into angajati_hotel values (5, 'Radu', 'Elena', 'receptioner', to_date('01-05-2023', 'dd-mm-yyyy'), 5800.00, 2);
  insert into angajati_hotel values (6, 'Stan', 'Vlad', 'ospatar', to_date('18-06-2022', 'dd-mm-yyyy'), 6200.00, 2); 
  insert into angajati_hotel values (7, 'Tudor', 'Ana', 'menajera', to_date('22-07-2021', 'dd-mm-yyyy'), 3600.00, 3);
  insert into angajati_hotel values (8, 'Marin', 'Stefan', 'manager', to_date('30-08-2020', 'dd-mm-yyyy'), 4800.00, 3);
  insert into angajati_hotel values (9, 'Ilie', 'Carmen', 'receptioner', to_date('10-09-2022', 'dd-mm-yyyy'), 5200.00, 3);
  insert into angajati_hotel values (10, 'Enache', 'George', 'bucatar', to_date('12-10-2021', 'dd-mm-yyyy'), 4600.00, 3);
end;
end adaugare_date;
/

declare
begin
adaugare_date.insereaza_hoteluri;
adaugare_date.insereaza_camere;
adaugare_date.insereaza_clienti_hotel;
adaugare_date.insereaza_rezervari;
adaugare_date.insereaza_plati;
adaugare_date.insereaza_recenzii;
adaugare_date.insereaza_angajati_hotel;
dbms_output.put_line('S-au inserat toate datele in tabele!');
exception 
    when dup_val_on_index then dbms_output.put_line('Datele se afla deja in tabel!');
    when others then dbms_output.put_line('Eroare ' || sqlerrm);
end;
/
select* from hoteluri;
select* from camere;
select* from clienti_hotel;
select* from rezervari;
select* from plati;
select* from recenzii;
select* from angajati_hotel;

--4. Diverse operatiuni pe tabele

--Trigger care adauga in tabela istoric_rezervari toate rezervarile finalizate.

create or replace trigger trg_insert_istoric_rezervari
after update on rezervari
for each row
begin
    if :new.status = 'finalizata' and :old.status != 'finalizata'  then
        insert into istoric_rezervari (id_rezervare, id_client, id_hotel, nr_camera, data_checkin, data_checkout, nume, prenume, rating)
        select :new.id_rezervare,
                :new.id_client,
                :new.id_hotel,
                :new.nr_camera,
               :new.data_checkin, 
               :new.data_checkout,
               ch.nume, 
               ch.prenume, 
               nvl(r.rating,0)
        from clienti_hotel ch, recenzii r where r.id_client=:new.id_client and ch.id_client=:new.id_client and r.id_rezervare=:new.id_rezervare; 
    end if;
end;
/

--Procedura de marcare rezervari ca finalizate la data primita ca parametru

create or replace procedure finalizare_rezervari
(p_data date) 
is
begin
update rezervari
set status = 'finalizata' where data_checkout < p_data;
end;
/

select* from rezervari;
select* from camere;

execute finalizare_rezervari(to_date('15-05-2025','DD-MM-YYYY'));

select* from istoric_rezervari;



--Cursor afisare toti clientii si rezervarile lor

set serveroutput on;
declare
cursor c_rezervari is
    select r.id_rezervare, c.nume, c.prenume, h.nume as nume_hotel, r.nr_camera, r.data_checkin, r.data_checkout
    from rezervari r, clienti_hotel c, hoteluri h where r.id_client = c.id_client and r.id_hotel = h.id_hotel;

begin
    for r_rezervari in c_rezervari loop
        dbms_output.put_line('Rezervare ' || r_rezervari.id_rezervare || ' | Client: ' || 
                             r_rezervari.nume || ' ' || r_rezervari.prenume || 
                             ' | Hotel: ' || r_rezervari.nume_hotel || ' | Camera: ' || r_rezervari.nr_camera || 
                             ' | Check-in: ' || to_char(r_rezervari.data_checkin, 'dd-mm-yyyy') || 
                             ' | Check-out: ' || to_char(r_rezervari.data_checkout, 'dd-mm-yyyy'));
    end loop;
exception
when no_data_found then dbms_output.put_line('Nu exista date!');
when others then dbms_output.put_line('Eroare' || sqlerrm);
end;
/

--Adaugare coloana salariu_min si salariu_max in tabela hotel, in functie de nr de stele.
alter table hoteluri add (salariu_min number(5), salariu_max number(5));
select* from hoteluri;

declare
cursor c_hotel is
select id_hotel, stele from hoteluri
for update of salariu_min, salariu_max;
begin
    for r_hotel in c_hotel loop
    if r_hotel.stele<=2 then update hoteluri 
    set salariu_min=2000, salariu_max=3500 
    where current of c_hotel;
    
    elsif r_hotel.stele=3 then update hoteluri 
    set salariu_min=3000, salariu_max=4500
    where current of c_hotel;
    
    elsif r_hotel.stele=4 then update hoteluri 
    set salariu_min=3500, salariu_max=5500
    where current of c_hotel;
    
    else update hoteluri 
    set salariu_min=4000, salariu_max=7000
    where current of c_hotel;
    end if;
    end loop;
end;
/

-- Creare trigger care sa verifice la inserarea unui angajat nou/ modificarea unui salariu al angajatilor, 
--daca se incadreaza in salariul hotelului respectiv
create or replace trigger salariu_angajati_trigger 
before insert or update on angajati_hotel
for each row
declare
v_salariu_max hoteluri.salariu_max%type;
v_salariu_min hoteluri.salariu_min%type;
exceptie_salariu_invalid exception;
exceptie_salariu_invalid_revenire_valoare_veche exception;
begin
select salariu_max, salariu_min into v_salariu_max, v_salariu_min from hoteluri where id_hotel = :new.id_hotel;

if inserting then if :new.salariu>v_salariu_max or :new.salariu<v_salariu_min
                then raise exceptie_salariu_invalid;
                end if;
elsif updating then if :new.salariu>v_salariu_max or :new.salariu<v_salariu_min
                then raise exceptie_salariu_invalid_revenire_valoare_veche;
                end if;
end if;
exception
when exceptie_salariu_invalid then raise_application_error(-20005,'Salariul angajatului depaseste [salariu_min,salariu_max] pentru hotelul respectiv');
when exceptie_salariu_invalid_revenire_valoare_veche then :new.salariu :=:old.salariu;
dbms_output.put_line('Salariul angajatului depaseste [salariu_min,salariu_max] pentru hotelul respectiv');
when others then dbms_output.put_line('Exceptie ' || sqlerrm);
end;
/

select* from angajati_hotel;
update angajati_hotel set salariu=10000 where id_angajat=1;
insert into angajati_hotel (id_angajat, nume, prenume, functie, data_angajare, salariu, id_hotel)
values (11, 'David', 'Toma', 'receptioner', to_date('06-01-2025', 'dd-mm-yyyy'), 3800, 1); --4 stele [3500,5500]
insert into angajati_hotel (id_angajat, nume, prenume, functie, data_angajare, salariu, id_hotel)
values (12, 'Marin', 'Ioana', 'bucatar', to_date('06-01-2025', 'dd-mm-yyyy'), 3800, 2); --5 stele [4000,7000]









