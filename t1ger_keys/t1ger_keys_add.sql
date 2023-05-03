-- ## USE THIS TO ADD COLUMNS IN YOUR owned_vehicles TABLE IN DATABASE ## --

ALTER TABLE owned_vehicles
ADD t1ger_keys tinyint(1) NOT NULL DEFAULT 0,
ADD t1ger_alarm tinyint(1) NOT NULL DEFAULT 0;