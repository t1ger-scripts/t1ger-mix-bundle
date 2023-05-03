DROP TABLE IF EXISTS `t1ger_shops`;
CREATE TABLE `t1ger_shops` (
	`id` INT(11) PRIMARY KEY,
	`identifier` VARCHAR(100) NOT NULL,
	`stock` longtext DEFAULT NULL,
	`shelves` longtext DEFAULT NULL
);

DROP TABLE IF EXISTS `t1ger_orders`;
CREATE TABLE `t1ger_orders` (
	`id` INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
	`shopID` INT(11),
	`data` longtext DEFAULT NULL,
	`taken` TINYINT(1) NOT NULL DEFAULT 0,
	`cost` INT(11) NOT NULL,
	`pos` longtext DEFAULT NULL
);

INSERT IGNORE INTO `items` (`name`, `label`) VALUES
('water', 'Water'),
('redgull', 'Energy Drink'),
('pisswasser', 'Pisswasser'),
('sandwich', 'Sandwich'),
('bread', 'Bread'),
('donut', 'Donut'),
('tacos', 'Tacos'),
('umbrella', 'Umbrella'),
('lockpick', 'Lockpick'),
('binoculars', 'Binoculars'),
('oxygenmask', 'Oxygen Mask'),
('repairkit', 'Repair Kit')
;
