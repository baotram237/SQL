-- exercise 1
CREATE TABLE songs(
song_id INT PRIMARY KEY,
song_name VARCHAR(30) NOT NULL,
genre VARCHAR(30) DEFAULT 'Not defined',
price NUMERIC(4,2),
release_date DATE
);
ALTER TABLE songs
ADD CONSTRAINT price CHECK (price >= 1.99);
ALTER TABLE songs
ADD CONSTRAINT release_date CHECK (release_date BETWEEN GETDATE() AND '2024-01-01');
INSERT INTO songs
VALUES (4,'SQL song','Not defined', 2.99, '2023-11-11');
-- exercise 2
CREATE TABLE app_user(
user_id INT PRIMARY KEY,
first_name VARCHAR(30),
last_name VARCHAR(30),
signup_date DATE DEFAULT GETDATE(),
birth_date DATE
);
ALTER TABLE app_user
ADD user_name VARCHAR(30);
ALTER TABLE app_user
ADD CONSTRAINT namelength CHECK (LEN(user_name)>2);
INSERT INTO app_user(user_id,first_name,last_name,birth_date)
VALUES (1,'Frank','Smith','1905-01-01');
--Exercise 3
CREATE TABLE user_anonymous (
    user_id INT,
    first_name VARCHAR(30),
    last_name VARCHAR(30)
);
INSERT INTO user_anonymous (user_id, first_name, last_name)
SELECT user_id, first_name, last_name
FROM app_user
WHERE first_name LIKE 'C%';

