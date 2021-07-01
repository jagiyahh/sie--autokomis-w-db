--USE master;
--DROP DATABASE Siec_Autokomisow;
--GO

--CREATE DATABASE Siec_Autokomisow;
--GO

--USE Siec_Autokomisow;
--GO

------------ USUÑ TABELE - WIDOKI - PROCEDURY - FUNKCJE - WYZWALACZE ------------

DROP TABLE IF EXISTS Sprzedaz;
DROP TABLE IF EXISTS Samochod_Dealera;
DROP TABLE IF EXISTS Samochod_Wyposazenie;
DROP TABLE IF EXISTS Dodatkowe_Wyposazenie;
DROP TABLE IF EXISTS Samochod_Osobowy;
DROP TABLE IF EXISTS Samochod_Ciezarowy;
DROP TABLE IF EXISTS Specjalizacja_Dealera;
DROP TABLE IF EXISTS Silnik_Modelu;
DROP TABLE IF EXISTS Klient;
DROP TABLE IF EXISTS Samochod;
DROP TABLE IF EXISTS Dealer;
DROP TABLE IF EXISTS Model;
DROP TABLE IF EXISTS Typ_Silnika;
DROP TABLE IF EXISTS Marka;

DROP VIEW IF EXISTS Najchetniej_kupowane_marki;

DROP PROCEDURE IF EXISTS Samochody_marki;
DROP PROCEDURE IF EXISTS Nowy_dealer;
DROP PROCEDURE IF EXISTS Usun_samochod_ciezarowy;
DROP PROCEDURE IF EXISTS Nowy_adres;
DROP PROCEDURE IF EXISTS Sprzedano_auto;

DROP FUNCTION IF EXISTS Koszt_Raty;
DROP FUNCTION IF EXISTS Modele_Starsze_Niz;

DROP TRIGGER IF EXISTS Sprawdz_Silnik;

GO

------------ CREATE - UTWÓRZ TABELE I POWI¥ZANIA ------------

CREATE TABLE Marka
(
    nazwa           VARCHAR(20) NOT NULL PRIMARY KEY,
    rok_zalozenia   VARCHAR(19)
);

CREATE TABLE Model
(
    id                              INTEGER NOT NULL IDENTITY(1, 1) PRIMARY KEY,
	nazwa                           VARCHAR(20) UNIQUE,
	rok_wprowadzenia_na_rynek       INTEGER,
	marka                           VARCHAR(20) REFERENCES Marka(nazwa),
	poprzedn_generacja              INTEGER
);

CREATE TABLE Typ_Silnika
(
    id                  INTEGER NOT NULL IDENTITY(1, 1) PRIMARY KEY,
    rodzaj_paliwa       VARCHAR(20),
	opis                VARCHAR(300) UNIQUE
);

CREATE TABLE Dealer
(
    nazwa       VARCHAR(30) NOT NULL PRIMARY KEY,
	adres       VARCHAR(40) UNIQUE
);

CREATE TABLE Samochod
(
    vin                 VARCHAR(17) NOT NULL PRIMARY KEY,
	przebieg            INTEGER DEFAULT 0,
	skrzynia_biegow     VARCHAR(30) CHECK ( skrzynia_biegow IN ('manualna','automatyczna','pó³automatyczna','bezstopniowa')) DEFAULT 'manualna',
	rok_produkcji       INTEGER CHECK( rok_produkcji>1890 ),
	kraj_pochodzenia    VARCHAR(30),
	model            INTEGER NOT NULL REFERENCES Model(id),
	typ_silnika_id      INTEGER NOT NULL REFERENCES Typ_Silnika(id)
);

CREATE TABLE Dodatkowe_Wyposazenie
(
    nazwa VARCHAR(40) NOT NULL PRIMARY KEY
);

CREATE TABLE Klient
(
    id INTEGER NOT NULL IDENTITY(1, 1) PRIMARY KEY,
	imiê VARCHAR(30),
	nazwisko VARCHAR(30),
	numer_telefonu INTEGER UNIQUE
);

CREATE TABLE Samochod_Osobowy
(
    model INTEGER NOT NULL PRIMARY KEY REFERENCES Model(id),
	liczba_pasazerow INTEGER DEFAULT 0,
	pojemnosc_bagaznika INTEGER DEFAULT 0
);

CREATE TABLE Samochod_Ciezarowy
(
    model INTEGER NOT NULL PRIMARY KEY REFERENCES Model(id),
	ladownosc INTEGER DEFAULT 0
);

CREATE TABLE Specjalizacja_Dealera
(
    dealer VARCHAR(30) NOT NULL REFERENCES Dealer(nazwa),
	model INTEGER NOT NULL REFERENCES Model(id),
	PRIMARY KEY (dealer, model)
);

CREATE TABLE Silnik_Modelu
(
	model INTEGER NOT NULL REFERENCES Model(id),
	typ_silnika_id INTEGER NOT NULL REFERENCES Typ_Silnika(id),
	PRIMARY KEY (model, typ_silnika_id)
);

CREATE TABLE Samochod_Dealera
(
	dealer VARCHAR(30) NOT NULL REFERENCES Dealer(nazwa),
	samochod_vin VARCHAR(17) NOT NULL REFERENCES Samochod(vin),
	PRIMARY KEY (samochod_vin)
);

CREATE TABLE Samochod_Wyposazenie
(
	samochod_vin VARCHAR(17) NOT NULL REFERENCES Samochod(vin),
	wyposazenie VARCHAR(40) NOT NULL REFERENCES Dodatkowe_Wyposazenie(nazwa),
	PRIMARY KEY (samochod_vin, wyposazenie)
);

CREATE TABLE Sprzedaz
(
    klient_id INTEGER NOT NULL REFERENCES Klient(id),
	dealer VARCHAR(30) NOT NULL REFERENCES Dealer(nazwa),
	samochod_vin VARCHAR(17) NOT NULL REFERENCES Samochod(vin),
	data_sprzedazy VARCHAR(19) NOT NULL,
	cena DECIMAL(11,2) NOT NULL CHECK ( cena > 0.00 ),
	PRIMARY KEY (klient_id, samochod_vin, dealer, data_sprzedazy)
);

GO

------------ INSERT - WSTAW DANE ------------

INSERT INTO Marka VALUES
('Volkswagen', 				'1909-07-16 00:00:00'),
('Škoda',					'1916-03-07 00:00:00'),
('SEAT', 			'1902-08-22 00:00:00'),
('BMW', 			'1911-11-03 00:00:00'),
('Ferrari', 			'1919-01-01 00:00:00'),
('Bentley', 				'1914-01-01 00:00:00'),
('Jaguar', 			'1938-09-13 00:00:00'),
('Fiat', 				'1899-07-11 00:00:00'),
('Ford Motor Company', 				'1906-11-29 00:00:00'),
('Audi', 	'1908-01-01 00:00:00');

INSERT INTO Model VALUES
('Polo V', 			'2009', 'Volkswagen',		NULL	),
('Polo VI',	 		'2017', 'Volkswagen',		1		),
('Kinga', 			'1996', 'Volkswagen',		NULL	),
('Kinga II', 		'2003', 'Volkswagen',		3		),
('Kinga III', 		'2012', 'Volkswagen',		4		),
('Octavia I',	    '1996', 'Škoda',		    NULL	),
('Octavia II',	    '2003', 'Škoda',		    6		),
('Octavia III',	        '2012', 'Škoda',		7	    ),
('S31',			    '1998', 'Škoda',		    NULL	),
('S32',			    '2002', 'Škoda',	 	    9		),
('Jumper I',		'1994', 'Ferrari',	        NULL	),
('Jumper II',		'2006', 'Ferrari',	        11		),
('Tristen I',		'1981', 'Fiat',		        NULL	),
('Tristen II',		'1994', 'Fiat',		        13		),
('Norv ',		    '2006', 'Fiat',		        NULL		),
('Diablo I',		'2000', 'Fiat',		        NULL	),
('Diablo II',		'2010', 'Fiat',		        16		),
('Fundo I',			'1996', 'Fiat',		        NULL	),
('Fundo II',		'2006', 'Fiat',		        18		),
('Sat I',		    '1998', 'Fiat',		        NULL	);

INSERT INTO Typ_Silnika VALUES
('benzyna','R4 1,2 l (1197 cm3), DOHC, turbo'),
('benzyna','R4 2,0 l, DOHC, turbo'),
('benzyna','R4 1,6 l (1595 cm3), SOHC'),
('benzyna','VR6 3,2 l (3189 cm3), DOHC'),
('benzyna','R4 1,9 l (1896 cm3), SOHC'),
('benzyna','R4 1,6 l (1574 cm3), SOHC'),
('benzyna','R6 2,0 l (1991 cm3), SOHC'),
('benzyna','R4 2,0 l (1991 cm3), SOHC'),
('benzyna','R6 2,3 l (2316 cm3), SOHC'),
('benzyna','R4 1,6 l (1766 cm3), SOHC'),
('diesel','PSA DJY (XUD9A)'),
('diesel','PSA T9A (DJ5)'),
('diesel','SOFIM 8140.21'),
('diesel','SOFIM 8140.27'),
('benzyna','R4 OHC/8 102/3500'),
('benzyna','R4 OHC/8 121/3300'),
('benzyna','R4 DOHC/16 145/4000'),
('benzyna','R4 DOHC/16 8,6/6,8/7,5'),
('benzyna','R4 DOHC/16 9,4/6,6/7,6'),
('benzyna','R4 73 (54)/5200 118/2600');

INSERT INTO Dealer VALUES
('Auto Gazda', 	'Koœciuszki 215, Warszawa'),
('Pro-moto', 		'Warszawska 330, Warszawa'),
('Dynamica',	'Jawornik 525, Warszawa'),
('Grupa GEZET', 		'£opuszañska 72, Warszawa'),
('Bednarek', 	'Szczeciñska 36, Warszawa'),
('Autopark',	'Gadowiejska 432, Warszawa'),
('Top Auto', 'Batorego 69, Warszawa'),
('CARSED',	'Opolska 2, Warszawa'),
('LELLEK',	'Budowlanych 7, Warszawa'),
('GAS GAS GAS',	'Kruszyna 12, Warszawa');

INSERT INTO Samochod VALUES
('WPOZZZ99ZTS392124', 212, 'automatyczna', 2000, 'Niemcy', 1, 1),
('WBA5L31080G078897', 0, 'automatyczna', 1998, 'Niemcy', 2, 2),
('WBANU31080B697476', 0, 'manualna', 2002, 'Niemcy', 3, 3),
('WBA1S510805A74005', 2554, 'manualna', 2017, 'W³ochy', 4, 4),
('TNBAB7NE5E0100470', 254257, 'manualna', 2013, 'W³ochy', 5, 5),
('WVWZZZ1JZ1W214431', 6454, 'automatyczna', 1997, 'Niemcy', 6, 6),
('TMBEM25J6D3135222', 34556, 'automatyczna', 2005, 'Niemcy', 7, 7),
('WVWZZZ3CZGP033210', 54348, 'automatyczna', 1996, 'Niemcy', 8, 8),
('VSSZZZ5PZ6R049517', 31245, 'manualna', 2018, 'Niemcy', 9, 9),
('SAJAF51276BE94147', 1324, 'manualna', 2006, 'Francja', 10, 10),
('WF0DXXGBBD7P77169', 3354, 'manualna', 2001, 'W³ochy', 11, 11),
('2FMDK36C78BA90204', 8684, 'pó³automatyczna', 2010, 'W³ochy', 12, 12),
('WVWZZZAUZDP077595', 564868, 'manualna', 1999, 'Niemcy', 13, 13),
('WA1MFCFPXEA018412', 65456, 'manualna', 2016, 'Niemcy', 14, 14),
('TMBAH7NP1G7023039', 31345, 'pó³automatyczna', 2013, 'Niemcy', 15, 15),
('TMBEC25J8D3134639', 349963, 'manualna', 2010, 'Francja', 16, 16),
('WBA5A51030G178312', 0, 'manualna', 1995, 'Francja', 17, 17),
('TMBAE73TXC9065064', 0, 'manualna', 2000, 'Francja', 18, 18),
('WBAPY51010CX14136', 0, 'pó³automatyczna', 2018, 'Niemcy', 19, 19),
('TMBCJ9NP3G7040661', 0, 'pó³automatyczna', 1999, 'Niemcy', 20, 20);

INSERT INTO Klient VALUES
('Katarzyna'	,'Na³kowska'	,'265874986'),
('Wojciech'	    ,'Michañski'	,'569321478'),
('Andrzej'	    ,'Kosocki'	    ,'895478658'),
('Aleksandra'	,'Mich'	 	    ,'123654789'),
('Anna'		    ,'Matuszewska'	,'987654321'),
('Zenon'	    ,'Demkowicz'  	,'987321654'),
('Józef'  	    ,'Zarañski'	    ,'321987654'),
('Danuta'   	,'Zaleñska'	    ,'456321987'),
('Martyna'  	,'Pêc'	 	    ,'789654123'),
('Agata'   	    ,'Krisz'	    ,'852963741');

INSERT INTO Dodatkowe_Wyposazenie VALUES
('Czujnik i kamera cofania'),
('Automatyczna klapa baga¿nika'),
('GPS'),
('Podgrzewane fotele'),
('Asystent parkowania'),
('Asystent pasa'),
('Tempomat'),
('Automatyczne swiatla'),
('System bezkluczykowy'),
('Rozpoznawanie znakow');

INSERT INTO Samochod_Osobowy VALUES
(1,  4, 332),
(2,  4, 301),
(3,  4, 214),
(4,  4, 206),
(5,  4, 206),
(6,  4, 206),
(7,  4, 622),
(8,  4, 450),
(9,  4, 246),
(10, 4, 337);

INSERT INTO Samochod_Ciezarowy VALUES
(11, 1500),
(12, 1200),
(13, 2500),
(14, 1300),
(15, 1450),
(16, 1900),
(17, 2000),
(18, 1200),
(19, 1400),
(20, 1700);

INSERT INTO Specjalizacja_Dealera VALUES
('Auto Gazda', 	    1),
('Pro-moto', 		3),
('Dynamica',	    8),
('Grupa GEZET', 	4),
('Bednarek', 	    17),
('Autopark',	    2),
('Top Auto',        3),
('CARSED',	        16),
('LELLEK',	        8),
('GAS GAS GAS',	    12);

INSERT INTO Silnik_Modelu VALUES
(1,1), (2,2),
(3,3), (4,4),
(5,5),(6,6), 
(7,7), (8,8), 
(9,9),(10,10),
(11,11), (12,12),
(13,13), (14,14),
(15,15),(16,16), 
(17,17),(18,18),
(19,19), (20,20);

INSERT INTO Samochod_Dealera VALUES
('Auto Gazda', 	'WPOZZZ99ZTS392124'),
('Pro-moto', 		'WBA1S510805A74005'),
('Dynamica',	'WVWZZZ1JZ1W214431'),
('Dynamica',	'TMBEM25J6D3135222'),
('Grupa GEZET', 		'WVWZZZ3CZGP033210'),
('Bednarek', 	'VSSZZZ5PZ6R049517'),
('Top Auto', 'WVWZZZAUZDP077595'),
('CARSED',	'TMBAH7NP1G7023039'),
('GAS GAS GAS',	'TMBAE73TXC9065064'),
('GAS GAS GAS',	'WBAPY51010CX14136');


INSERT INTO Samochod_Wyposazenie VALUES
('WPOZZZ99ZTS392124', 'GPS'),
('WBANU31080B697476', 'Tempomat'),
('WBA1S510805A74005', 'Automatyczna klapa baga¿nika'),
('WVWZZZ3CZGP033210', 'System bezkluczykowy'),
('VSSZZZ5PZ6R049517', 'Asystent parkowania'),
('SAJAF51276BE94147', 'Tempomat'),
('WF0DXXGBBD7P77169', 'Czujnik i kamera cofania'),
('2FMDK36C78BA90204', 'Asystent parkowania'),
('TMBAH7NP1G7023039', 'Automatyczna klapa baga¿nika'),
('TMBAE73TXC9065064', 'Tempomat');

INSERT INTO Sprzedaz VALUES
(1, 'Auto Gazda', 	'WBA5L31080G078897', '2019-03-04 17:02:28', 104700.00),
(2, 'Pro-moto', 		'WBANU31080B697476', '2019-01-04 12:27:55', 5900.00),
(3, 'Dynamica',	'TNBAB7NE5E0100470', '2019-05-09 15:24:05', 125900.00),
(4, 'Bednarek', 	'SAJAF51276BE94147', '2019-06-05 03:16:42', 39999.00),
(5, 'Autopark',	'WF0DXXGBBD7P77169', '2019-01-23 16:39:24', 68300.00),
(6, 'Top Auto',	'2FMDK36C78BA90204', '2019-02-14 23:04:23', 38950.00),
(7, 'CARSED',	'WA1MFCFPXEA018412', '2019-03-31 17:27:47', 69400.00),
(8, 'LELLEK',		'TMBEC25J8D3134639', '2019-04-17 10:03:36', 29500.00),
(9, 'GAS GAS GAS',	'WBA5A51030G178312', '2019-03-07 23:45:06', 60000.00),
(10, 'GAS GAS GAS',	'TMBCJ9NP3G7040661', '2019-05-01 03:56:09', 5000.00);

GO

------------ WIDOK ------------

CREATE VIEW Najchetniej_kupowane_marki(marka, ilosc_sprzedanych_aut)
AS
(
    SELECT  marka, 
            COUNT(*) AS [ilosc_sprzedanych_aut]
	FROM    Model
	WHERE   id IN ( SELECT  model
                    FROM    Samochod
                    WHERE   vin IN ( SELECT  samochod_vin
                                     FROM    Sprzedaz))
    GROUP BY marka
);

GO

----------- PROCEDURY ----------

CREATE PROCEDURE Samochody_marki
    @dealer VARCHAR(30)
AS
BEGIN
    DECLARE @auta VARCHAR(8000);

    SELECT  @auta = COALESCE(@auta + ', ', '') + samochod_vin
    FROM    Samochod_Dealera
    WHERE   dealer = @dealer;

    PRINT @auta;
END;

GO


CREATE PROCEDURE Nowy_dealer
    @nazwa      VARCHAR(30),
	@adres      VARCHAR(40)
AS
BEGIN
    INSERT INTO Dealer VALUES 	
    (@nazwa, @adres);
END;

GO


CREATE PROCEDURE Usun_Samochod_Ciezarowy
    @model VARCHAR(20)
AS
BEGIN
    DELETE FROM	 Samochod_Ciezarowy
	WHERE model = ( SELECT  id
		               FROM 	Model
		               WHERE 	nazwa = @model);
END;

GO


CREATE PROCEDURE Nowy_adres
	@nazwa INTEGER,
    @adres VARCHAR(40)
AS
BEGIN
    UPDATE	Dealer
	SET		adres = @adres
	WHERE 	nazwa = @nazwa;
END;

GO


CREATE PROCEDURE Sprzedano_auto
	@klient_id      INTEGER,
    @vin            VARCHAR(17),
	@cena           DECIMAL(11,2)
AS
BEGIN
    DECLARE @dealer VARCHAR(30);

        IF   @vin IN 	    ( SELECT vin 
                              FROM Samochod )
	         AND  @klient_id IN ( SELECT id 
                                  FROM Klient )
        BEGIN
            SELECT  @dealer = dealer
            FROM 	Samochod_Dealera
	        WHERE	samochod_vin = @vin;
    
            INSERT INTO Sprzedaz VALUES
            (@klient_id, @dealer, @vin, CONVERT(VARCHAR, GETDATE(), 120), @cena);
		
		    DELETE FROM	 Samochod_Dealera
		    WHERE samochod_vin = @vin;
        END
END;

GO

------------- FUNKCJE -------------

CREATE FUNCTION Koszt_Raty
(
    @vin VARCHAR(17),
    @raty DECIMAL(10)
)
    RETURNS DECIMAL(11,2)
AS
BEGIN
    RETURN ( SELECT  cena
             FROM    Sprzedaz
             WHERE   samochod_vin = @vin ) / @raty;
END;

GO


CREATE FUNCTION Modele_Starsze_Niz
(
    @rok INTEGER
)
    RETURNS TABLE
AS
    RETURN SELECT nazwa, rok_wprowadzenia_na_rynek, marka
           FROM   Model
           WHERE  rok_wprowadzenia_na_rynek>@rok;
		   
GO

------------ WYZWALACZ ------------

CREATE TRIGGER Sprawdz_Silnik
ON Samochod
INSTEAD OF INSERT
AS
    IF EXISTS(
        SELECT * FROM inserted i
        WHERE i.model IN (
            SELECT model
            FROM Silnik_Modelu
            WHERE typ_silnika_id = i.typ_silnika_id
        )
    )
    BEGIN
        INSERT INTO Samochod
        SELECT * FROM inserted;
    END;
		
GO

------------ SELECT ------------

SELECT * FROM Samochod;
SELECT * FROM Model;
SELECT * FROM Marka;
SELECT * FROM Typ_Silnika;
SELECT * FROM Dodatkowe_Wyposazenie;
SELECT * FROM Dealer;
SELECT * FROM Klient;
SELECT * FROM Samochod_Osobowy;
SELECT * FROM Samochod_Ciezarowy;
SELECT * FROM Specjalizacja_Dealera;
SELECT * FROM Silnik_Modelu;
SELECT * FROM Samochod_Dealera;
SELECT * FROM Samochod_Wyposazenie;
SELECT * FROM Sprzedaz;

SELECT * FROM Najchetniej_kupowane_marki ORDER BY ilosc_sprzedanych_aut DESC;

GO

------- PRZYK£ADOWE PROCEDURY - FUNKCJE - WYZWALACZE --------

-- EXEC Samochody_marki 'GAS GAS GAS'; -- jakie samochody sprzedaje GASGASGAS

-- EXEC Nowy_dealer 'Satan', 'Warszawska 666, Warszawa';

-- EXEC Usun_samochod_ciezarowy 'Diablo I';

-- EXEC Nowy_adres 'Satan', 'Hell'; 

-- EXEC Sprzedaj 1, 'WBAPY51010CX14136', 300000.00;

-- SELECT dbo.Koszt_Raty('SAJAF51276BE94147', 24);
-- SELECT * FROM dbo.Modele_Starsze_Niz(2000) ORDER BY rok_wprowadzenia_na_rynek;


-- INSERT INTO Samochod VALUES
-- ('BSFDGSRGE45235532', 15850.00, 'pó³automatyczna', 2016, 'Niemcy', 12, 10); 


-- niezgodnosc


-- INSERT INTO Samochod VALUES
-- ('NUAUEHGFU493895FF', 96968.00, 'pó³automatyczna', 2016, 'Niemcy', 8, 8);

 -- zgodnosc silnika z modelem

