DROP TABLE IF EXISTS `t1ger_anpr`;
CREATE TABLE `t1ger_anpr`  (
	`identifier` varchar(100) NOT NULL,
	`plate` varchar(12) NOT NULL,
	`owner` varchar(255) NOT NULL,
	`stolen` tinyint(1) NOT NULL DEFAULT 0,
	`bolo` tinyint(1) NOT NULL DEFAULT 0,
	PRIMARY KEY (`plate`)
);

DROP TABLE IF EXISTS `t1ger_citations`;
CREATE TABLE `t1ger_citations`  (
	`id` int AUTO_INCREMENT,
	`officer` varchar(100) NOT NULL,
	`offender` varchar(100) NOT NULL,
	`fine` int(12) NOT NULL,
	`offences` LONGTEXT NOT NULL,
	`note` varchar(255) DEFAULT NULL,
	`paid` tinyint(1) NOT NULL DEFAULT 0,
	PRIMARY KEY (`id`)
);
ALTER TABLE `t1ger_citations` AUTO_INCREMENT = 1000;