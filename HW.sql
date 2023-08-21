SELECT *
FROM store;

CREATE OR REPLACE PROCEDURE addCity(
	_city VARCHAR, 
	_country VARCHAR)
LANGUAGE plpgsql AS $$
BEGIN
	INSERT INTO city (city, country_id, last_update)
	VALUES (
	INITCAP(_city),
	(SELECT country_id
		FROM country
		WHERE country.country = INITCAP(_country)),
	NOW());
	COMMIT;
END
$$;

CALL addCity('davis','United States');

SELECT * 
FROM city
WHERE city.city = 'Davis';

--601	Davis	103	2023-07-13 19:04:10.182


CREATE OR REPLACE FUNCTION  addAddress(
	_address VARCHAR,
	_address2 VARCHAR,
	 _district VARCHAR,
 	_city_id INTEGER,
 	postalCode VARCHAR,
 	phone_num VARCHAR)
RETURNS VOID
LANGUAGE plpgsql AS $$
BEGIN 
	INSERT INTO address(
	address,
	address2,
	district,
	city_id,
	postal_code,
	phone,
	last_update)
	VALUES(
	_address,
	_address2,
	_district,
	_city_id,
	postalCode,
	phone_num,
	NOW());
END
$$;


SELECT  addAddress(
	'1615, Anderson rd',
	'',
	'California',
	601,
	'95624',
	'8172401959');

SELECT * FROM address
WHERE postal_code = '95624';

-- 606	1615, Anderson rd	California	601	95624	8172401959	2023-07-13 19:51:54.160

-- I tried really hard to get this working 
CREATE OR REPLACE FUNCTION  addAddress(
	_address VARCHAR,
	_address2 VARCHAR,
	 _district VARCHAR,
 	_city VARCHAR,
 	_country VARCHAR,
 	postalCode VARCHAR,
 	phone_num VARCHAR)
RETURNS VOID
LANGUAGE plpgsql AS $$
DECLARE
		new_city VARCHAR := INITCAP(_city);
		new_country VARCHAR := INITCAP(_country);
BEGIN 
	INSERT INTO address(
	address,
	address2,
	district,
	city_id,
	postal_code,
	phone,
	last_update)
	VALUES(
	_address,
	_address2,
	_district,
	(IF new_city IN (SELECT city FROM city) THEN
			RETURNING (
				SELECT city_id
				FROM city
				WHERE new_city = city.city);
	ELSE
		CALL addCity(new_city ,new_country)
		RETURNING (
			SELECT city_id
			FROM city
			WHERE new_city = city.city);
	END IF;),
	postalCode,
	phone_num,
	NOW());
END
$$;

