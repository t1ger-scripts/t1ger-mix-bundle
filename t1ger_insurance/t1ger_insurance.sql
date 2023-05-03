-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 

INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_insurance','Insurance', 1)
;

INSERT INTO `addon_account_data` (account_name, money) VALUES
	('society_insurance', 0)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES
	('society_insurance','Insurance', 1)
;

INSERT INTO `jobs` (name, label) VALUES
	('insurance','Insurance')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('insurance' , 0, 'broker', 'Broker', 100, '{}', '{}'),
	('insurance' , 1, 'boss', 'Boss', 250, '{}', '{}')
;

ALTER TABLE `owned_vehicles` ADD `insurance` tinyint(1) NOT NULL DEFAULT 0;