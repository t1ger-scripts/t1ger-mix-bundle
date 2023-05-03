INSERT IGNORE INTO `addon_account` (name, label, shared) VALUES
	('society_delivery1','Delivery', 1),
	('society_delivery2','Delivery', 1)
;

INSERT IGNORE INTO `addon_account_data` (account_name, money) VALUES
	('society_delivery1', 0),
	('society_delivery2', 0)
;

INSERT IGNORE INTO `jobs` (name, label) VALUES
	('delivery1','Delivery'),
	('delivery2','Delivery')
;

INSERT IGNORE INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('delivery1',0,'employee','Employee',100,'{}','{}'),
	('delivery1',1,'boss','Boss',250,'{}','{}'),
	('delivery2',0,'employee','Employee',100,'{}','{}'),
	('delivery2',1,'boss','Boss',250,'{}','{}')
;

DROP TABLE IF EXISTS `t1ger_deliveries`;
CREATE TABLE `t1ger_deliveries` (
	`id` INT(11),
	`identifier` VARCHAR(100) NOT NULL,
	`name` VARCHAR(100) NOT NULL,
	`level` TINYINT(11) NOT NULL DEFAULT 0,
	`certificate` TINYINT(1) NOT NULL DEFAULT 0,
	PRIMARY KEY (`id`)
);