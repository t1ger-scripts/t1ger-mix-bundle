-- ## USE THIS IF HAVE gotKey AND alarm COLUMNS IN YOU owned_vehicles TABLE ## --

ALTER TABLE owned_vehicles CHANGE COLUMN `gotKey` `t1ger_keys` tinyint(1) NOT NULL DEFAULT 0;
UPDATE owned_vehicles SET alarm = 1 WHERE alarm > 0;
ALTER TABLE owned_vehicles CHANGE COLUMN alarm t1ger_alarm tinyint(1) NOT NULL DEFAULT 0;