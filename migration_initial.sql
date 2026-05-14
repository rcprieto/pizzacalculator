CREATE TABLE IF NOT EXISTS `__EFMigrationsHistory` (
    `MigrationId` varchar(150) CHARACTER SET utf8mb4 NOT NULL,
    `ProductVersion` varchar(32) CHARACTER SET utf8mb4 NOT NULL,
    CONSTRAINT `PK___EFMigrationsHistory` PRIMARY KEY (`MigrationId`)
) CHARACTER SET=utf8mb4;

START TRANSACTION;
DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20260514172019_InitialCreate') THEN

    ALTER DATABASE CHARACTER SET utf8mb4;

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;

DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20260514172019_InitialCreate') THEN

    CREATE TABLE `tbc_ingrediente` (
        `ing_id` int NOT NULL AUTO_INCREMENT,
        `ing_nome` longtext CHARACTER SET utf8mb4 NULL,
        `ing_marca` longtext CHARACTER SET utf8mb4 NULL,
        `ing_preco` decimal(10,4) NOT NULL,
        `ing_status` tinyint(1) NOT NULL,
        CONSTRAINT `PK_tbc_ingrediente` PRIMARY KEY (`ing_id`)
    ) CHARACTER SET=utf8mb4;

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;

DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20260514172019_InitialCreate') THEN

    CREATE TABLE `tbc_receita` (
        `rec_id` int NOT NULL AUTO_INCREMENT,
        `rec_nome` longtext CHARACTER SET utf8mb4 NULL,
        `rec_modo_preparo` longtext CHARACTER SET utf8mb4 NULL,
        `rec_status` tinyint(1) NOT NULL,
        CONSTRAINT `PK_tbc_receita` PRIMARY KEY (`rec_id`)
    ) CHARACTER SET=utf8mb4;

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;

DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20260514172019_InitialCreate') THEN

    CREATE TABLE `tbc_receita_item` (
        `rec_item_id` int NOT NULL AUTO_INCREMENT,
        `rec_id` int NOT NULL,
        `ing_id` int NOT NULL,
        `rec_item_peso_g` decimal(10,3) NOT NULL,
        `percentual` decimal(10,4) NOT NULL,
        CONSTRAINT `PK_tbc_receita_item` PRIMARY KEY (`rec_item_id`),
        CONSTRAINT `FK_tbc_receita_item_tbc_ingrediente_ing_id` FOREIGN KEY (`ing_id`) REFERENCES `tbc_ingrediente` (`ing_id`) ON DELETE RESTRICT,
        CONSTRAINT `FK_tbc_receita_item_tbc_receita_rec_id` FOREIGN KEY (`rec_id`) REFERENCES `tbc_receita` (`rec_id`) ON DELETE CASCADE
    ) CHARACTER SET=utf8mb4;

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;

DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20260514172019_InitialCreate') THEN

    CREATE INDEX `IX_tbc_receita_item_ing_id` ON `tbc_receita_item` (`ing_id`);

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;

DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20260514172019_InitialCreate') THEN

    CREATE INDEX `IX_tbc_receita_item_rec_id` ON `tbc_receita_item` (`rec_id`);

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;

DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20260514172019_InitialCreate') THEN

    INSERT INTO `__EFMigrationsHistory` (`MigrationId`, `ProductVersion`)
    VALUES ('20260514172019_InitialCreate', '9.0.3');

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;

COMMIT;

