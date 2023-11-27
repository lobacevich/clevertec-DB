/*1. Вывести к каждому самолету класс обслуживания и количество мест этого класса*/
SELECT aircrafts.*, fare_conditions, seats_count
FROM aircrafts
INNER JOIN (
    SELECT aircraft_code, fare_conditions, COUNT(seat_no) AS seats_count
    FROM seats
    GROUP BY aircraft_code, fare_conditions
) AS ms
USING(aircraft_code);

/*2. Найти 3 самых вместительных самолета (модель + кол-во мест)*/
SELECT model, seats_count
FROM aircrafts
INNER JOIN (
    SELECT aircraft_code, COUNT(seat_no) AS seats_count
    FROM seats
    GROUP BY aircraft_code
) AS ms
USING(aircraft_code)
ORDER BY seats_count DESC
LIMIT 3;

/*3. Найти все рейсы, которые задерживались более 2 часов*/
SELECT *
FROM flights
WHERE actual_departure - scheduled_departure > INTERVAL '2 hours'
OR actual_arrival - scheduled_arrival > INTERVAL '2 hours';

/*4. Найти последние 10 билетов, купленные в бизнес-классе 
(fare_conditions = 'Business'), с указанием имени пассажира и контактных данных*/
SELECT ticket_no, book_date, passenger_name, contact_data
FROM bookings
INNER JOIN (
    SELECT *
    FROM tickets
    INNER JOIN ticket_flights
    USING(ticket_no)
    WHERE fare_conditions = 'Business'
) AS tf
USING(book_ref)
ORDER BY book_date DESC
LIMIT 10;

/*5. Найти все рейсы, у которых нет забронированных мест в бизнес-классе 
(fare_conditions = 'Business')*/
SELECT flights.*, fare_conditions
FROM flights
INNER JOIN ticket_flights
USING(flight_id)
WHERE NOT fare_conditions = 'Business';

/*6. Получить список аэропортов (airport_name) и городов (city), в которых есть рейсы
с задержкой*/
SELECT DISTINCT airport_name, city
FROM flights
INNER JOIN airports
ON flights.departure_airport = airports.airport_code
WHERE status = 'Delayed';

/*7. Получить список аэропортов (airport_name) и количество рейсов, вылетающих из 
каждого аэропорта, отсортированный по убыванию количества рейсов*/
SELECT airport_name, flights_count
FROM airports
INNER JOIN (
    SELECT departure_airport, count(departure_airport) AS flights_count
    FROM flights
    GROUP BY departure_airport
) AS fc
ON airports.airport_code = fc.departure_airport
ORDER BY flights_count DESC;

/*8. Найти все рейсы, у которых запланированное время прибытия (scheduled_arrival) 
было изменено и новое время прибытия (actual_arrival) не совпадает с запланированным*/
SELECT * 
FROM flights
WHERE NOT scheduled_arrival = actual_arrival;

/*9. Вывести код, модель самолета и места не эконом класса для самолета 
"Аэробус A321-200" с сортировкой по местам*/
SELECT aircraft_code, model, seat_no
FROM aircrafts
INNER JOIN (
    SELECT *
    FROM seats
    WHERE NOT fare_conditions = 'Economy'
) as s
USING(aircraft_code)
WHERE model = 'Аэробус A321-200'
ORDER BY seat_no;

/*10. Вывести города, в которых больше 1 аэропорта (код аэропорта, аэропорт, город)*/
SELECT airport_code, airport_name, city
FROM airports
INNER JOIN (
    SELECT city, COUNT(city) AS airport_count
    FROM airports
    GROUP BY city
) AS ac
USING(city)
WHERE airport_count > 1;

/*11. Найти пассажиров, у которых суммарная стоимость бронирований превышает 
среднюю сумму всех бронирований*/
SELECT passenger_id, passenger_name, SUM(amount) as total_sum
FROM tickets
INNER JOIN ticket_flights
USING(ticket_no)
GROUP BY passenger_id, passenger_name
HAVING SUM(amount) > (
    SELECT AVG(amount)
    FROM ticket_flights
);

/*12. Найти ближайший вылетающий рейс из Екатеринбурга в Москву, на который еще 
не завершилась регистрация*/
SELECT *
FROM (
    SELECT flights.*, city as departure_city
    FROM flights
    INNER JOIN airports
    ON airport_code = departure_airport
    WHERE city = 'Екатеринбург'
) AS ef
INNER JOIN (
    SELECT flight_id, city as arrival_city
    FROM flights
    INNER JOIN airports
    ON airport_code = arrival_airport
    WHERE city = 'Москва'
) AS mf
USING(flight_id)
WHERE status IN ('On Time', 'Delayed')
ORDER BY scheduled_departure DESC
LIMIT 1;

/*13. Вывести самый дешевый и дорогой билет и стоимость 
(в одном результирующем ответе)*/
WITH cheapest_ticket AS (
    SELECT *
    FROM ticket_flights
    ORDER BY amount
    LIMIT 1
),
most_expensive_ticket AS (
    SELECT *
    FROM ticket_flights
    ORDER BY amount DESC
    LIMIT 1
)
SELECT *
FROM cheapest_ticket
UNION ALL
SELECT *
FROM most_expensive_ticket;

/*14. Написать DDL таблицы Customers, должны быть поля id, firstName, LastName, 
email, phone. Добавить ограничения на поля (constraints)*/
CREATE TABLE Customers
(
    id SERIAL,
    firstName CHARACTER VARYING(20) NOT NULL,
    lastName CHARACTER VARYING(20) NOT NULL,
    email CHARACTER VARYING(30),
    Phone CHARACTER VARYING(20),
    CONSTRAINT customers_id PRIMARY KEY(id),
    CONSTRAINT customers_email UNIQUE(email),
    CONSTRAINT customers_phone UNIQUE(phone)
);

/*15. Написать DDL таблицы Orders, должен быть id, customerId, quantity. Должен быть
внешний ключ на таблицу customers + constraints*/
CREATE TABLE Orders
(
    id SERIAL,
    customerId INTEGER,
	quantity INTEGER,
    CONSTRAINT orders_id PRIMARY KEY(id),
    FOREIGN KEY (customerId)
    REFERENCES Customers(id)
);

/*16. Написать 5 insert в эти таблицы*/
INSERT INTO Customers (firstName, lastName, email, phone)
VALUES ('John', 'Doe', 'johndoe@gmail.com', '1234567890');

INSERT INTO Customers (firstName, lastName, email, phone)
VALUES ('Jane', 'Smith', 'janesmith@gmail.com', '9876543210');

INSERT INTO Orders (customerId, quantity)
VALUES (1, 5);

INSERT INTO Orders (customerId, quantity)
VALUES (2, 10);

INSERT INTO Orders (customerId, quantity)
VALUES (1, 3);

/*17. Удалить таблицы*/
DROP TABLE Orders;
DROP TABLE Customers;