INSERT IGNORE INTO `addon_account` (name, label, shared) VALUES
	('society_towtrucker1','Tow Trucker', 1),
	('society_towtrucker2','Tow Trucker', 1)
;

INSERT IGNORE INTO `addon_account_data` (account_name, money) VALUES
	('society_towtrucker1', 0),
	('society_towtrucker2', 0)
;

INSERT IGNORE INTO `jobs` (name, label) VALUES
	('towtrucker1','Tow Trucker'),
	('towtrucker2','Tow Trucker')
;

INSERT IGNORE INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('towtrucker1',0,'apprentice','Apprentice',100,'{}','{}'),
	('towtrucker1',1,'employee','Employee',200,'{}','{}'),
	('towtrucker1',2,'boss','Boss',300,'{}','{}'),
	('towtrucker2',0,'apprentice','Apprentice',100,'{}','{}'),
	('towtrucker2',1,'employee','Employee',200,'{}','{}'),
	('towtrucker2',2,'boss','Boss',300,'{}','{}')
;

DROP TABLE IF EXISTS `t1ger_towtrucker`;
CREATE TABLE `t1ger_towtrucker` (
	`id` INT(11) NOT NULL,
	`identifier` VARCHAR(100) NOT NULL,
	`name` varchar(100) NOT NULL,
	`impound` LONGTEXT DEFAULT NULL,
	PRIMARY KEY (`id`)
);

ALTER TABLE `owned_vehicles`
ADD `tow_impound` INT(11) NOT NULL DEFAULT 0;
