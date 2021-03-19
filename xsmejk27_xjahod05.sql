/*
IDS project 2nd, 3rd, 4th part
task n.50: Klub anonymnich alkoholiku:
@date: 03/2020
@authors: xsmejk27 Jan Smejkal,
          xjahod05 David Jahoda
*/
DROP SEQUENCE Kontrola_seq;
DROP SEQUENCE Poziti_seq;
DROP SEQUENCE Sezeni_seq;
DROP SEQUENCE Mistokonani_seq;
DROP SEQUENCE Upominka_seq;
DROP SEQUENCE Alkoholik_seq;
DROP SEQUENCE Pracovnik_seq;

DROP TABLE Kontrola;
DROP TABLE Poziti;
DROP TABLE Alkoholik_se_ucastni_sezeni;
DROP TABLE Pracovnik_se_ucastni_sezeni;
DROP TABLE Sezeni;
DROP TABLE Misto_konani;
DROP TABLE Upominka;
DROP TABLE Opatrovavani;
DROP TABLE Alkoholik;
DROP TABLE Odbornik;
DROP TABLE Patron;
DROP TABLE Pracovnik;


CREATE SEQUENCE Pracovnik_seq
    START WITH 1
    INCREMENT BY 1;
CREATE SEQUENCE Alkoholik_seq
    START WITH 1
    INCREMENT BY 1;
CREATE SEQUENCE Upominka_seq
    START WITH 1
    INCREMENT BY 1;
CREATE SEQUENCE Mistokonani_seq
    START WITH 1
    INCREMENT BY 1;
CREATE SEQUENCE Sezeni_seq
    START WITH 1
    INCREMENT BY 1;
CREATE SEQUENCE Poziti_seq
    START WITH 1
    INCREMENT BY 1;
CREATE SEQUENCE Kontrola_seq
    START WITH 1
    INCREMENT BY 1;

CREATE TABLE Pracovnik (
    pracovnikID integer DEFAULT Pracovnik_seq.NEXTVAL,
    jmeno varchar(64) NOT NULL,
    prijmeni varchar(64) NOT NULL,
    datum_narozeni date NOT NULL,
    CONSTRAINT pk_pracovnikID PRIMARY KEY (pracovnikID)
);

CREATE TABLE Odbornik
(
    odbornikID integer,
    FOREIGN KEY(odbornikID) REFERENCES Pracovnik(pracovnikID),
    kvalifikace varchar(128) NOT NULL,
    delka_praxe date NOT NULL,
    CONSTRAINT pk_odbornikID PRIMARY KEY (odbornikID)
);

CREATE TABLE Patron
(
    pracovnikID integer,
    FOREIGN KEY(pracovnikID) REFERENCES Pracovnik,
    CONSTRAINT pk_pracovnikID_patron PRIMARY KEY (pracovnikID)
);


CREATE TABLE Alkoholik (
    alkoholikID integer DEFAULT Alkoholik_seq.NEXTVAL,
    pohlavi varchar(64) NOT NULL,
    vek integer NOT NULL,
    CONSTRAINT vek_uint CHECK (vek >= 0),
    CONSTRAINT pk_alkoholikID PRIMARY KEY (alkoholikID)
);

CREATE TABLE Opatrovavani (
    pracovnikID integer NOT NULL,
    FOREIGN KEY(pracovnikID) REFERENCES Pracovnik,
    alkoholikID integer NOT NULL,
    FOREIGN KEY(alkoholikID) REFERENCES Alkoholik,
    CONSTRAINT pk_opatrovavani PRIMARY KEY (alkoholikID, pracovnikID)
);

CREATE TABLE Upominka (
    upominkaID integer DEFAULT Upominka_seq.NEXTVAL,
    alkoholikID integer NOT NULL,
    FOREIGN KEY (alkoholikID) REFERENCES Alkoholik,
    datum date NOT NULL,
    text varchar(512) NOT NULL,
    CONSTRAINT pk_upominkaID PRIMARY KEY (upominkaID)
);

CREATE TABLE Misto_konani (
    mistokonaniID integer DEFAULT Mistokonani_seq.NEXTVAL,
    ulice varchar(64),
    cislo_popisne integer NOT NULL,--napr. 13b
    cislo_orientacni varchar(16),--napr. 13b
    mesto varchar(64) NOT NULL,
    psc integer NOT NULL,
    oficialni char(1) NOT NULL, --A/N
    CONSTRAINT pk_mistokonaniID PRIMARY KEY (mistokonaniID),
    CONSTRAINT psc_validni CHECK((psc >=10000) AND (psc < 80000))
);

CREATE TABLE Sezeni (
    sezeniID integer DEFAULT Sezeni_seq.NEXTVAL,
    datum date NOT NULL,
    cas date NOT NULL,
    vedouciID integer NOT NULL,
    FOREIGN KEY (vedouciID) REFERENCES Pracovnik(pracovnikID),
    oficialni char(1) NOT NULL,
    mistokonaniID integer NOT NULL,
    FOREIGN KEY (mistokonaniID) REFERENCES  Misto_konani,
    CONSTRAINT pk_sezeniID PRIMARY KEY (sezeniID)
);

--(SELECT oficialni FROM Misto_konani M WHERE mistokonaniID = M.mistokonaniID) = 'A')
CREATE TABLE Pracovnik_se_ucastni_sezeni (
    sezeniID integer NOT NULL,
    FOREIGN KEY (sezeniID) REFERENCES Sezeni,
    pracovnikID integer NOT NULL,
    FOREIGN KEY (pracovnikID) REFERENCES Pracovnik,
    CONSTRAINT pk_sezeniID_prac PRIMARY KEY (sezeniID, pracovnikID)
);

CREATE TABLE  Alkoholik_se_ucastni_sezeni (
    sezeniID integer NOT NULL,
    FOREIGN KEY (sezeniID) REFERENCES Sezeni,
    alkoholikID integer NOT NULL,
    FOREIGN KEY (alkoholikID) REFERENCES Alkoholik,
    CONSTRAINT pk_sezeniID_alk PRIMARY KEY (sezeniID, alkoholikID)
);

CREATE TABLE Poziti (
    pozitiID integer DEFAULT Poziti_seq.NEXTVAL,
    alkoholikID integer NOT NULL,
    FOREIGN KEY (alkoholikID) REFERENCES Alkoholik,
    datum date NOT NULL,
    cas date NOT NULL,
    puvod varchar(255) NOT NULL,
    typ varchar(128) NOT NULL,
    CONSTRAINT pk_poziti PRIMARY KEY (pozitiID)
);

CREATE TABLE Kontrola(
    kontrolaID integer DEFAULT Kontrola_seq.NEXTVAL,
    alkoholikID integer NOT NULL,
    FOREIGN KEY (alkoholikID) REFERENCES Alkoholik,
    odbornikID integer NOT NULL,
    FOREIGN KEY (odbornikID) REFERENCES Odbornik,
    pozitiID integer,--muze byt NULL: cisty
    FOREIGN KEY (pozitiID) REFERENCES Poziti,
    datum date NOT NULL,
    cas date NOT NULL,
    promile float NOT NULL,
    CONSTRAINT promile_uint CHECK(promile >=0.0),
    CONSTRAINT poziti_ke_kontrole CHECK((promile >0.2 AND pozitiID IS NOT NULL)
        OR (promile <=0.2 AND pozitiID IS NULL)),
    CONSTRAINT pk_kontrolaID PRIMARY KEY (kontrolaID)
);


INSERT INTO Pracovnik (jmeno, prijmeni, datum_narozeni)
 VALUES ('Jan', 'Novak', TO_DATE( '2018/03/11', 'yy/mm/dd' ));
INSERT INTO Pracovnik (jmeno, prijmeni, datum_narozeni)
 VALUES ('Jakub', 'Bolín', TO_DATE('1988-4-4', 'yy-mm-dd'));
INSERT INTO Pracovnik (jmeno, prijmeni, datum_narozeni)--osoba se stejnymi udaji, presto vsak rozlisitelna diky pracovnikID
 VALUES ('Jakub', 'Bolín', TO_DATE('1988-4-4', 'yy-mm-dd'));

INSERT INTO Patron (pracovnikID)
VALUES (2);

INSERT INTO Odbornik (odbornikID, kvalifikace, delka_praxe)
VALUES (1, 'doktorat MUNI', TO_DATE( '2018/03/11', 'yy/mm/dd' ) );
INSERT INTO Odbornik (odbornikID, kvalifikace, delka_praxe)
VALUES (3, 'doktorat MUNI', TO_DATE( '2019/06/12', 'yy/mm/dd' ) );

INSERT INTO Alkoholik (pohlavi, vek)    -- 1.
 VALUES ('muz', 54);
INSERT INTO Alkoholik (pohlavi, vek)    -- 2.
 VALUES ('zena', 18);
INSERT INTO Alkoholik (pohlavi, vek)    -- 3.
 VALUES ('muz', 40);
INSERT INTO Alkoholik (pohlavi, vek)    -- 4.
 VALUES ('muz', 41);
INSERT INTO Alkoholik (pohlavi, vek)    -- 5.
 VALUES ('zena', 42);
INSERT INTO Alkoholik (pohlavi, vek)    -- 6.
 VALUES ('muz', 43);
INSERT INTO Alkoholik (pohlavi, vek)    -- 7.
 VALUES ('zena', 44);
INSERT INTO Alkoholik (pohlavi, vek)    -- 8.
 VALUES ('muz', 45); 
INSERT INTO Alkoholik (pohlavi, vek)    -- 9.
 VALUES ('muz', 46);
INSERT INTO Alkoholik (pohlavi, vek)    -- 10.
 VALUES ('muz', 47);
INSERT INTO Alkoholik (pohlavi, vek)    -- 11.
 VALUES ('zena', 48);
INSERT INTO Alkoholik (pohlavi, vek)    -- 12,
 VALUES ('muz', 49);
INSERT INTO Alkoholik (pohlavi, vek)    -- 13.
 VALUES ('zena', 20);
 

INSERT INTO Opatrovavani (pracovnikID, alkoholikID)
VALUES (2, 1);
INSERT INTO Opatrovavani (pracovnikID, alkoholikID)
VALUES (2, 2);
INSERT INTO Opatrovavani (pracovnikID, alkoholikID)
VALUES (1, 2);

INSERT INTO Upominka(alkoholikID, datum, text)
 VALUES (1, TO_DATE('2020-03-23', 'yy-mm-dd'), 'Vynechal jste sezeni v poslednich trech mesicich :(');
INSERT INTO Upominka(alkoholikID, datum, text)
 VALUES (1, TO_DATE('2020-03-26', 'yy-mm-dd'), 'Vynechal jste sezeni v poslednich trech mesicich, druhe upozorneni :(');

INSERT INTO  Misto_konani(ulice, cislo_popisne, cislo_orientacni, mesto, psc, oficialni)
 VALUES ('Bratri Capku', 129, 26, 'Brno', '32166', 'A');
INSERT INTO  Misto_konani(ulice, cislo_popisne, cislo_orientacni, mesto, psc, oficialni)
 VALUES ('Sester Nejedlych', 67, 66, 'Brno', '66623', 'N');
INSERT INTO  Misto_konani(ulice, cislo_popisne, cislo_orientacni, mesto, psc, oficialni)
 VALUES ('Konecna ulice', 6, 666, 'Praha', '10100', 'A');

INSERT INTO  Sezeni (datum, cas, vedouciID, oficialni, mistokonaniID)
 VALUES (TO_DATE('2019-08-20', 'yy-mm-dd'), TO_DATE( '08:00', 'hh24:mi' ), 1, 'A', 1);
INSERT INTO  Sezeni (datum, cas, vedouciID, oficialni, mistokonaniID)
 VALUES (TO_DATE('2019-12-20', 'yy-mm-dd'), TO_DATE( '12:00', 'hh24:mi' ), 1, 'N', 1);
INSERT INTO  Sezeni (datum, cas, vedouciID, oficialni, mistokonaniID)
 VALUES (TO_DATE('2019-12-20', 'yy-mm-dd'), TO_DATE( '22:00', 'hh24:mi' ), 2, 'N', 2);
INSERT INTO  Sezeni (datum, cas, vedouciID, oficialni, mistokonaniID)
 VALUES (TO_DATE('2019-02-03', 'yy-mm-dd'), TO_DATE( '12:00', 'hh24:mi' ), 2, 'N', 3);
INSERT INTO  Sezeni (datum, cas, vedouciID, oficialni, mistokonaniID)
 VALUES (TO_DATE('2019-02-04', 'yy-mm-dd'), TO_DATE( '14:00', 'hh24:mi' ), 2, 'N', 3);
INSERT INTO  Sezeni (datum, cas, vedouciID, oficialni, mistokonaniID)
 VALUES (TO_DATE('2019-02-10', 'yy-mm-dd'), TO_DATE( '10:00', 'hh24:mi' ), 2, 'N', 3);


INSERT INTO Pracovnik_se_ucastni_sezeni(sezeniID, pracovnikID)
 VALUES (1, 2);
INSERT INTO Pracovnik_se_ucastni_sezeni(sezeniID, pracovnikID)
 VALUES (3, 1);

INSERT INTO Alkoholik_se_ucastni_sezeni(sezeniID, alkoholikID)
 VALUES (1, 1);
INSERT INTO Alkoholik_se_ucastni_sezeni(sezeniID, alkoholikID)
 VALUES (2, 1);
INSERT INTO Alkoholik_se_ucastni_sezeni(sezeniID, alkoholikID)
 VALUES (3, 1);
INSERT INTO Alkoholik_se_ucastni_sezeni(sezeniID, alkoholikID)
 VALUES (3, 2);
 INSERT INTO Alkoholik_se_ucastni_sezeni(sezeniID, alkoholikID)
 VALUES (3, 3);
INSERT INTO Alkoholik_se_ucastni_sezeni(sezeniID, alkoholikID)
 VALUES (3, 4); 
INSERT INTO Alkoholik_se_ucastni_sezeni(sezeniID, alkoholikID)
 VALUES (3, 5); 
INSERT INTO Alkoholik_se_ucastni_sezeni(sezeniID, alkoholikID)
 VALUES (3, 6);
INSERT INTO Alkoholik_se_ucastni_sezeni(sezeniID, alkoholikID)
 VALUES (3, 7);
INSERT INTO Alkoholik_se_ucastni_sezeni(sezeniID, alkoholikID)
 VALUES (3, 8);
INSERT INTO Alkoholik_se_ucastni_sezeni(sezeniID, alkoholikID)
 VALUES (3, 9);
INSERT INTO Alkoholik_se_ucastni_sezeni(sezeniID, alkoholikID)
 VALUES (3, 10);
INSERT INTO Alkoholik_se_ucastni_sezeni(sezeniID, alkoholikID)
 VALUES (3, 11);
INSERT INTO Alkoholik_se_ucastni_sezeni(sezeniID, alkoholikID)
 VALUES (3, 12);
INSERT INTO Alkoholik_se_ucastni_sezeni(sezeniID, alkoholikID)
 VALUES (4, 2);
INSERT INTO Alkoholik_se_ucastni_sezeni(sezeniID, alkoholikID)
 VALUES (4, 1);
INSERT INTO Alkoholik_se_ucastni_sezeni(sezeniID, alkoholikID)
 VALUES (5, 2);
INSERT INTO Alkoholik_se_ucastni_sezeni(sezeniID, alkoholikID)
 VALUES (5, 3);


INSERT INTO Poziti(alkoholikID, datum, cas, puvod, typ)
 VALUES (1, TO_DATE('2020-03-02', 'yy-mm-dd'), TO_DATE( '13:00', 'hh24:mi' ), 'Hospoda', 'rum, vodka, becherovka');
INSERT INTO Poziti(alkoholikID, datum, cas, puvod, typ)
 VALUES (1, TO_DATE('2020-03-12', 'yy-mm-dd'), TO_DATE( '15:00', 'hh24:mi' ), 'Hospoda', 'rum, vodka');
INSERT INTO Poziti(alkoholikID, datum, cas, puvod, typ)
 VALUES (2, TO_DATE('2014-03-05', 'yy-mm-dd'), TO_DATE( '11:00', 'hh24:mi' ), 'doma', 'vodka');
INSERT INTO Poziti(alkoholikID, datum, cas, puvod, typ)
 VALUES (10, TO_DATE('2020-04-25', 'yy-mm-dd'), TO_DATE( '20:00', 'hh24:mi' ), 'Hospoda', 'pivo');

INSERT INTO Kontrola(alkoholikID, odbornikID, pozitiID, datum, cas, promile)
 VALUES (1, 1, 1, TO_DATE('2020-06-02', 'yy-mm-dd'), TO_DATE( '12:00', 'hh24:mi' ), 1.5);--testuje pripad pritomnosti alkoholu v krvi, kde musi byt zaznamenano poziti !NULL
INSERT INTO Kontrola(alkoholikID, odbornikID, datum, cas, promile)
 VALUES (1, 1, TO_DATE('2020-06-02', 'yy-mm-dd'), TO_DATE( '12:00', 'hh24:mi' ), 0.0);
INSERT INTO Kontrola(alkoholikID, odbornikID, pozitiID, datum, cas, promile)
 VALUES (1, 1, 2, TO_DATE('2020-06-12', 'yy-mm-dd'), TO_DATE( '11:00', 'hh24:mi' ), 1.0);


INSERT INTO Kontrola(alkoholikID, odbornikID, pozitiID, datum, cas, promile)
 VALUES (10, 1, 3, TO_DATE('2014-03-05', 'yy-mm-dd'), TO_DATE( '02:00', 'hh24:mi' ), 0.6);
INSERT INTO Kontrola(alkoholikID, odbornikID, datum, cas, promile)
 VALUES (10, 1, TO_DATE('2016-04-05', 'yy-mm-dd'), TO_DATE( '22:00', 'hh24:mi' ), 0.1);
--Dotazy:

--1)Kteří alkoholici se účastnili sezení dne 2019-12-20 a kterých?
SELECT Alkoholik_se_ucastni_sezeni.alkoholikID, Sezeni.sezeniID FROM Alkoholik_se_ucastni_sezeni inner join Sezeni
    ON Alkoholik_se_ucastni_sezeni.sezeniID = Sezeni.sezeniID
WHERE
    Sezeni.datum = TO_DATE('2019-12-20', 'yy-mm-dd');

--2)Kteří pracovníci(ID, jmeno, prijmeni, dat.narozeni) vedou která sezení?
SELECT Pracovnik.pracovnikID, Pracovnik.jmeno, Pracovnik.prijmeni, Sezeni.sezeniID, Sezeni.datum
FROM Pracovnik INNER JOIN Sezeni ON
    Sezeni.vedouciID = Pracovnik.pracovnikID
WHERE
      Sezeni.vedouciID = Pracovnik.pracovnikID;

--3)Kteří alkoholici  podstoupili kontrolu dne xy a
--  měli zaznamenanou hodnotu vyšší než 0.5 po požití vodky
SELECT * --Alkoholik.alkoholikID
FROM Kontrola JOIN Poziti ON Kontrola.pozitiID = Poziti.pozitiID
              JOIN Alkoholik ON Kontrola.alkoholikID = Alkoholik.alkoholikID
WHERE Kontrola.promile >= 0.5 AND Poziti.typ = 'vodka';

--dva dotazy s klauzulí GROUP BY a agregační funkcí
--4)Kolik míst konání se nachází v jednotlivých městech?
-- (2 v Brně, 5 v Praze, 1 v Jáchymově,..)
SELECT mesto, COUNT(mistokonaniID)
FROM Misto_konani
GROUP BY mesto
ORDER BY mesto;

--5)
-- Jaké je nejvyšší naměřené promile při kontrole
-- u jednotlivých alkoholiků
SELECT alkoholikID, MAX(promile)
FROM Kontrola
GROUP BY alkoholikID
ORDER BY alkoholikID;

--6)Vypiš ID alkoholiků,
--  kteří nikdy nedostali upomínku (NOT EXISTS)
SELECT alkoholikID
FROM Alkoholik
WHERE NOT EXISTS
(SELECT Upominka.alkoholikID FROM Upominka
WHERE Alkoholik.alkoholikID = Upominka.alkoholikID);

--s predikátem IN s vnořeným selectem (nikoliv IN s množinou konstantních dat)
--7)Která sezení proběhla v Brně?
SELECT sezeniID, mistokonaniID
FROM Sezeni
WHERE mistokonaniID
IN(SELECT mistokonaniID FROM Misto_konani WHERE mesto = 'Brno');

/************* PROCEDURY *****************************************************/
SET SERVEROUTPUT ON;
/*
Procedura 1:
    Vypiš, kolik procent ze všech provedených kontrol bylo s nálezem alkoholu v krvi u alkoholika zdaného parametrem
    Pozn: vyuziva pomocnou proceduru Podil_Nalezu_Alkoholu_Vypocet
 */
CREATE OR REPLACE PROCEDURE Podil_Nalezu_Alkoholu_Vypocet(AlkoholikID IN integer)
IS
    CURSOR kontrola IS
        SELECT * FROM Kontrola WHERE Kontrola.alkoholikID = Podil_Nalezu_Alkoholu_Vypocet.AlkoholikID;
    pom Kontrola%ROWTYPE;
    pocitadlo_bez_nalezu integer;
    pocitadlo_nalez integer;
    vysledek integer;
BEGIN
    pocitadlo_bez_nalezu := 0;
    pocitadlo_nalez := 0;
    vysledek := 0;
    
    OPEN kontrola;
    LOOP
        FETCH kontrola into pom;        
        EXIT WHEN kontrola%NOTFOUND;

        IF (pom.promile >= 0.2) THEN
            pocitadlo_nalez := pocitadlo_nalez + 1;
        ELSE
            pocitadlo_bez_nalezu := pocitadlo_bez_nalezu + 1;
        END IF;
    END LOOP;
    CLOSE kontrola;
    vysledek := pocitadlo_nalez/(pocitadlo_nalez+pocitadlo_bez_nalezu)*100;
    dbms_output.put_line('Alkoholik č. '||Podil_Nalezu_Alkoholu_Vypocet.AlkoholikID||' měl u '||vysledek||'% kontrol nález alkoholu');
EXCEPTION
    WHEN ZERO_DIVIDE THEN
            BEGIN
                DBMS_OUTPUT.put_line('U alkoholika č. '||Podil_Nalezu_Alkoholu_Vypocet.AlkoholikID||' nebyla dosud provedena žádná kontrola.' );
            END;
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'Chyba v procedure Podil_Nalezu_Alkoholu_Vypocet!');
END;
/

CREATE OR REPLACE PROCEDURE Podil_Nalezu_Alkoholu (AlkoholikID IN integer)
IS
vysledek integer;
neexistuji_zaznamy exception;
BEGIN
    vysledek := 0;
    SELECT COUNT(*) INTO vysledek FROM Kontrola WHERE Kontrola.alkoholikID = Podil_Nalezu_Alkoholu.AlkoholikID;
    IF vysledek = 0 THEN
        RAISE neexistuji_zaznamy;
    END IF;
    Podil_Nalezu_Alkoholu_Vypocet(Podil_Nalezu_Alkoholu.AlkoholikID);
    
EXCEPTION
    WHEN neexistuji_zaznamy THEN
        RAISE_APPLICATION_ERROR(-20002, 'U alkoholika č. '||Podil_Nalezu_Alkoholu.AlkoholikID||' nebyla dosud provedena žádná kontrola.');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20003, 'Chyba v procedure Podil_Nalezu_Alkoholu!');
END;
/
-- ukazkove prikladu procedury Podil_Nalezu_Alkoholu
/* 1. priklad
- uspech
vypis: Alkoholik č. 1 měl u 67% kontrol nález alkoholu */
EXECUTE Podil_Nalezu_Alkoholu(1);
/* 2. priklad
- ma vychodit chybu neexistujici_zaznamy
vypis: U alkoholika č. 2 nebyla dosud provedena žádná kontrola.*/
EXECUTE Podil_Nalezu_Alkoholu(2);
/* 3. priklad
- uspech
vypis: Alkoholik č. 10 měl u 50% kontrol nález alkoholu */
EXECUTE Podil_Nalezu_Alkoholu(10);


/*Procedura 2:
    Vypiš obsazenost na sezeních vedených pracovníkem zadaným v argumentu
*/
CREATE OR REPLACE PROCEDURE Obsazenost_sezeni(PracovnikID IN integer)
IS
    CURSOR obsazenost IS
    SELECT Sezeni.sezeniID, Sezeni.vedouciID, Alkoholik_se_ucastni_sezeni.alkoholikID FROM Sezeni FULL OUTER JOIN Alkoholik_se_ucastni_sezeni ON Sezeni.sezeniID = Alkoholik_se_ucastni_sezeni.sezeniID
        WHERE Sezeni.vedouciID = Obsazenost_sezeni.PracovnikID
        ORDER BY Sezeni.sezeniID ASC;

    pom obsazenost%ROWTYPE;
    pocitadlo integer;
    akt_sezeni integer;
BEGIN
    pocitadlo :=0;
    akt_sezeni :=0;
    dbms_output.put_line('Obsazenost na sezenich vedených pracovníkem c.'||Obsazenost_sezeni.PracovnikID||':');
    OPEN obsazenost;
    LOOP
        FETCH obsazenost into pom;
        EXIT WHEN obsazenost%NOTFOUND;
        IF (akt_sezeni = 0) THEN--pro pripad zacatku iterovani nastavim na pom
            akt_sezeni := pom.sezeniID;
        END IF;
        IF(pom.sezeniID = akt_sezeni) THEN--iteruji v sezeni, prictu pocet, netreba nic overovat
            IF(pom.alkoholikID IS NOT NULL) THEN--na novem sezeni je alkoholik
                pocitadlo := pocitadlo+ 1;
            END IF;
        ELSIF(pom.sezeniID != akt_sezeni) THEN --pokud se meni sezeni
            IF (akt_sezeni != 0) THEN--pokud nezacinam, zpracuju pocet minulych a resetuji
                dbms_output.put_line('Obsazenost na sezeni c. '|| akt_sezeni ||': '||pocitadlo|| ' z 12');
                pocitadlo := 0;
                akt_sezeni := pom.sezeniID;
                IF(pom.alkoholikID IS NOT NULL) THEN--na novem sezeni je alkoholik
                    pocitadlo := 1;
                END IF;
            END IF;
        END IF;
    END LOOP;
    IF (akt_sezeni != 0) THEN
        dbms_output.put_line('Obsazenost na sezeni c. '|| akt_sezeni ||': '||pocitadlo|| ' z 12');
    ELSIF (akt_sezeni = 0) THEN
        dbms_output.put_line('Nebylo zadne sezeni.');
    END IF;
    CLOSE obsazenost;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20004, 'Chyba v procedure Obsazenost_sezeni!');
END;
/
-- testovaci priklady procedury Obsazenost_sezeni
/* 
1. priklad - uspech
vypis:
Obsazenost na sezenich vedených pracovníkem c.1:
Obsazenost na sezeni c. 1: 1 z 12
Obsazenost na sezeni c. 2: 1 z 12
*/
EXECUTE Obsazenost_sezeni(1);
/*
2. priklad - uspech vcetne prazdneho sezeni
vypis:
Obsazenost na sezenich vedených pracovníkem c.2:
Obsazenost na sezeni c. 3: 12 z 12
Obsazenost na sezeni c. 4: 2 z 12
Obsazenost na sezeni c. 5: 2 z 12
Obsazenost na sezeni c. 6: 0 z 12
*/
EXECUTE Obsazenost_sezeni(2);

/***************** TRIGERY ***********************/
-- 1. triger - pro zajisteni kardinality 12 u ucasti alkoholiku na sezeni
CREATE OR REPLACE TRIGGER max_12
    BEFORE INSERT ON Alkoholik_se_ucastni_sezeni
    FOR EACH ROW

DECLARE
    pocitadlo integer;   
    kapacita_chyba exception;
BEGIN
    pocitadlo := 0;    
    SELECT COUNT(*) INTO pocitadlo FROM Alkoholik_se_ucastni_sezeni
        WHERE Alkoholik_se_ucastni_sezeni.sezeniID = :new.sezeniID;
    IF (pocitadlo >= 12) THEN
       RAISE kapacita_chyba;        
    END IF;
EXCEPTION
    WHEN kapacita_chyba THEN
        raise_application_error(-20005, 'Chyba - Kapacita sezeni jiz byla naplnena.');        
END;
/
-- testovaci priklad triggeru max_12
/*
1. priklad - uspesne pridani
*/
INSERT INTO Alkoholik_se_ucastni_sezeni(sezeniID, alkoholikID)
 VALUES (2, 13);

 /*
2. příklad - pokus o pridani do jiz zaplneneho sezeni, melo by vyvolat chybu 
vypis:
Chyba - Kapacita sezeni jiz byla naplnena.
 */
INSERT INTO Alkoholik_se_ucastni_sezeni(sezeniID, alkoholikID)
 VALUES (3, 13);
 

-- 2. trigger - zajisteni ze datum kontroly neni budouci
CREATE OR REPLACE TRIGGER neni_budouci
    BEFORE INSERT ON Kontrola
    FOR EACH ROW
DECLARE
    datum_chyba exception;
BEGIN
    IF (:new.datum > CURRENT_DATE) THEN
        RAISE datum_chyba; 
    END IF;
EXCEPTION
    WHEN datum_chyba THEN
        raise_application_error(-20006, 'Chyba - Zadano budouci datum u probehle kontroly');
    WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-1, 'Chyba v triggeru neni_budouci!');        
END;
/

-- Příklad trigeru s budoucim datem
/* Pokus o zadani budouciho data
vypis: ORA-20006: Chyba - Zadano budouci datum u probehle kontroly
*/
INSERT INTO Kontrola(alkoholikID, odbornikID, pozitiID, datum, cas, promile)
 VALUES (10, 3, 2, TO_DATE('2022-03-05', 'yy-mm-dd'), TO_DATE( '08:00', 'hh24:mi' ), 2.0);

/**************** Udeleni prav*************************/
GRANT ALL ON  Kontrola TO xsmejk27;
GRANT ALL ON  Poziti TO xsmejk27;
GRANT ALL ON  Alkoholik_se_ucastni_sezeni TO xsmejk27;
GRANT ALL ON  Pracovnik_se_ucastni_sezeni TO xsmejk27;
GRANT ALL ON  Sezeni TO xsmejk27;
GRANT ALL ON  Misto_konani TO xsmejk27;
GRANT ALL ON  Upominka TO xsmejk27;
GRANT ALL ON  Opatrovavani TO xsmejk27;
GRANT ALL ON  Alkoholik TO xsmejk27;
GRANT ALL ON  Odbornik TO xsmejk27;
GRANT ALL ON  Patron TO xsmejk27;
GRANT ALL ON  Pracovnik TO xsmejk27;

GRANT EXECUTE ON Obsazenost_sezeni TO xsmejk27;
GRANT EXECUTE ON Podil_Nalezu_Alkoholu TO xsmejk27;
GRANT EXECUTE ON Podil_Nalezu_Alkoholu_Vypocet TO xsmejk27;

/**************************EXPLAIN PLAN*************************/

--dotaz na jednotlive alkoholiky, serazene dle maximalnich promile a uved typ alkoholu, z ktereho se opili
--nejdrive bez optimalizaci
EXPLAIN PLAN FOR
    SELECT Kontrola.alkoholikID, MAX(Kontrola.promile), Poziti.typ
    FROM Kontrola JOIN Poziti ON Kontrola.pozitiID = Poziti.pozitiID
    GROUP BY Kontrola.alkoholikID, Kontrola.promile, Poziti.typ
    ORDER BY Kontrola.promile DESC;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

--vytvorim indexy pro Kontrolu pro vsechny atributy, s kterymi budu pracovat
CREATE INDEX Kontrola_index ON Kontrola(alkoholikID, promile, pozitiID);
--stejne tak pro Poziti
CREATE INDEX Poziti_typ ON Poziti(pozitiID, typ);

EXPLAIN PLAN FOR
    SELECT Kontrola.alkoholikID, MAX(Kontrola.promile), Poziti.typ
    FROM Kontrola JOIN Poziti ON Kontrola.pozitiID = Poziti.pozitiID
    GROUP BY Kontrola.alkoholikID, Kontrola.promile, Poziti.typ
    ORDER BY Kontrola.promile DESC;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

DROP INDEX Kontrola_index;
DROP INDEX Poziti_typ;

-----------------------------KONEC EXPLAIN PLANu
/****************************Materializovany pohled*/
/*
Vypis adresy sezeni
*/
DROP MATERIALIZED VIEW sezeni_komplet_adresa;

--DROP MATERIALIZED VIEW LOG ON Sezeni;
--DROP MATERIALIZED VIEW LOG ON Misto_konani;

CREATE MATERIALIZED VIEW LOG ON Sezeni with rowid;
CREATE MATERIALIZED VIEW LOG ON Misto_konani with rowid;

/* EXPLAIN PLAN dotazu pred vytvorenim pohledu*/
EXPLAIN PLAN FOR SELECT sezeniID, Sezeni.mistokonaniID, ulice, cislo_popisne, mesto, psc,
    Sezeni.rowid as sezeni_rowid, Misto_konani.rowid as misto_konanani_rowid
    FROM Sezeni INNER JOIN Misto_konani ON Sezeni.mistokonaniID = Misto_konani.mistokonaniID;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
/* vytvoreni pohledu*/
CREATE MATERIALIZED VIEW sezeni_komplet_adresa
CACHE
BUILD IMMEDIATE
REFRESH FAST ON COMMIT
ENABLE QUERY REWRITE
AS
    SELECT sezeniID, Sezeni.mistokonaniID, ulice, cislo_popisne, mesto, psc,
    Sezeni.rowid as sezeni_rowid, Misto_konani.rowid as misto_konanani_rowid
    FROM Sezeni INNER JOIN Misto_konani ON Sezeni.mistokonaniID = Misto_konani.mistokonaniID;

/* udeleni prav*/
GRANT ALL ON sezeni_komplet_adresa TO xsmejk27;
/* povoleni vyuzivani pohledu optimalizatorem a provedeni EXPLAIN PLAN jenz vyuzije pohled*/
alter session set query_rewrite_enabled = true;
EXPLAIN PLAN FOR SELECT sezeniID, Sezeni.mistokonaniID, ulice, cislo_popisne, mesto, psc,
    Sezeni.rowid as sezeni_rowid, Misto_konani.rowid as misto_konanani_rowid
    FROM Sezeni INNER JOIN Misto_konani ON Sezeni.mistokonaniID = Misto_konani.mistokonaniID;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

/* demonstrace aktualizace pohledu pri commitu */
/* vypis pred upravou*/
SELECT * FROM sezeni_komplet_adresa;
/* vlozeni noveho radku do tabulky sezeni */
INSERT INTO  Sezeni (datum, cas, vedouciID, oficialni, mistokonaniID)
 VALUES (TO_DATE('2020-03-15', 'yy-mm-dd'), TO_DATE( '16:00', 'hh24:mi' ), 2, 'N', 2);
COMMIT;
/* opetovny vypis pohledu s jiz aktualizovanou hodnotou */
SELECT * FROM sezeni_komplet_adresa;



COMMIT;