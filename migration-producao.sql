-- ============================================================
-- Migration: AddUserIdToIngredienteEGrupo
-- Script seguro para banco de produção (usa IF NOT EXISTS)
-- Execute no banco: pizza_calculator (ou o nome do seu banco)
-- ============================================================

START TRANSACTION;

-- ------------------------------------------------------------
-- 1. Novas colunas em tabelas existentes
-- ------------------------------------------------------------

ALTER TABLE `tbc_receita_item`
  ADD COLUMN IF NOT EXISTS `ing_grupo_id` int NULL,
  ADD COLUMN IF NOT EXISTS `rec_item_obs` longtext CHARACTER SET utf8mb4 NULL;

ALTER TABLE `tbc_receita`
  ADD COLUMN IF NOT EXISTS `rec_user_id` varchar(255) CHARACTER SET utf8mb4 NULL;

ALTER TABLE `tbc_ingrediente`
  ADD COLUMN IF NOT EXISTS `ing_user_id` varchar(255) CHARACTER SET utf8mb4 NULL;

-- ------------------------------------------------------------
-- 2. Tabelas de identidade (ASP.NET Core Identity)
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `AspNetRoles` (
    `Id` varchar(255) CHARACTER SET utf8mb4 NOT NULL,
    `Name` varchar(256) CHARACTER SET utf8mb4 NULL,
    `NormalizedName` varchar(256) CHARACTER SET utf8mb4 NULL,
    `ConcurrencyStamp` longtext CHARACTER SET utf8mb4 NULL,
    CONSTRAINT `PK_AspNetRoles` PRIMARY KEY (`Id`)
) CHARACTER SET=utf8mb4;

CREATE TABLE IF NOT EXISTS `tbc_usuario` (
    `Id` varchar(255) CHARACTER SET utf8mb4 NOT NULL,
    `Status` tinyint(1) NOT NULL,
    `UserName` varchar(256) CHARACTER SET utf8mb4 NULL,
    `NormalizedUserName` varchar(256) CHARACTER SET utf8mb4 NULL,
    `Email` varchar(256) CHARACTER SET utf8mb4 NULL,
    `NormalizedEmail` varchar(256) CHARACTER SET utf8mb4 NULL,
    `EmailConfirmed` tinyint(1) NOT NULL,
    `PasswordHash` longtext CHARACTER SET utf8mb4 NULL,
    `SecurityStamp` longtext CHARACTER SET utf8mb4 NULL,
    `ConcurrencyStamp` longtext CHARACTER SET utf8mb4 NULL,
    `PhoneNumber` longtext CHARACTER SET utf8mb4 NULL,
    `PhoneNumberConfirmed` tinyint(1) NOT NULL,
    `TwoFactorEnabled` tinyint(1) NOT NULL,
    `LockoutEnd` datetime(6) NULL,
    `LockoutEnabled` tinyint(1) NOT NULL,
    `AccessFailedCount` int NOT NULL,
    CONSTRAINT `PK_tbc_usuario` PRIMARY KEY (`Id`)
) CHARACTER SET=utf8mb4;

CREATE TABLE IF NOT EXISTS `AspNetRoleClaims` (
    `Id` int NOT NULL AUTO_INCREMENT,
    `RoleId` varchar(255) CHARACTER SET utf8mb4 NOT NULL,
    `ClaimType` longtext CHARACTER SET utf8mb4 NULL,
    `ClaimValue` longtext CHARACTER SET utf8mb4 NULL,
    CONSTRAINT `PK_AspNetRoleClaims` PRIMARY KEY (`Id`),
    CONSTRAINT `FK_AspNetRoleClaims_AspNetRoles_RoleId`
        FOREIGN KEY (`RoleId`) REFERENCES `AspNetRoles` (`Id`) ON DELETE CASCADE
) CHARACTER SET=utf8mb4;

CREATE TABLE IF NOT EXISTS `AspNetUserClaims` (
    `Id` int NOT NULL AUTO_INCREMENT,
    `UserId` varchar(255) CHARACTER SET utf8mb4 NOT NULL,
    `ClaimType` longtext CHARACTER SET utf8mb4 NULL,
    `ClaimValue` longtext CHARACTER SET utf8mb4 NULL,
    CONSTRAINT `PK_AspNetUserClaims` PRIMARY KEY (`Id`),
    CONSTRAINT `FK_AspNetUserClaims_tbc_usuario_UserId`
        FOREIGN KEY (`UserId`) REFERENCES `tbc_usuario` (`Id`) ON DELETE CASCADE
) CHARACTER SET=utf8mb4;

CREATE TABLE IF NOT EXISTS `AspNetUserLogins` (
    `LoginProvider` varchar(255) CHARACTER SET utf8mb4 NOT NULL,
    `ProviderKey` varchar(255) CHARACTER SET utf8mb4 NOT NULL,
    `ProviderDisplayName` longtext CHARACTER SET utf8mb4 NULL,
    `UserId` varchar(255) CHARACTER SET utf8mb4 NOT NULL,
    CONSTRAINT `PK_AspNetUserLogins` PRIMARY KEY (`LoginProvider`, `ProviderKey`),
    CONSTRAINT `FK_AspNetUserLogins_tbc_usuario_UserId`
        FOREIGN KEY (`UserId`) REFERENCES `tbc_usuario` (`Id`) ON DELETE CASCADE
) CHARACTER SET=utf8mb4;

CREATE TABLE IF NOT EXISTS `AspNetUserRoles` (
    `UserId` varchar(255) CHARACTER SET utf8mb4 NOT NULL,
    `RoleId` varchar(255) CHARACTER SET utf8mb4 NOT NULL,
    CONSTRAINT `PK_AspNetUserRoles` PRIMARY KEY (`UserId`, `RoleId`),
    CONSTRAINT `FK_AspNetUserRoles_AspNetRoles_RoleId`
        FOREIGN KEY (`RoleId`) REFERENCES `AspNetRoles` (`Id`) ON DELETE CASCADE,
    CONSTRAINT `FK_AspNetUserRoles_tbc_usuario_UserId`
        FOREIGN KEY (`UserId`) REFERENCES `tbc_usuario` (`Id`) ON DELETE CASCADE
) CHARACTER SET=utf8mb4;

CREATE TABLE IF NOT EXISTS `AspNetUserTokens` (
    `UserId` varchar(255) CHARACTER SET utf8mb4 NOT NULL,
    `LoginProvider` varchar(255) CHARACTER SET utf8mb4 NOT NULL,
    `Name` varchar(255) CHARACTER SET utf8mb4 NOT NULL,
    `Value` longtext CHARACTER SET utf8mb4 NULL,
    CONSTRAINT `PK_AspNetUserTokens` PRIMARY KEY (`UserId`, `LoginProvider`, `Name`),
    CONSTRAINT `FK_AspNetUserTokens_tbc_usuario_UserId`
        FOREIGN KEY (`UserId`) REFERENCES `tbc_usuario` (`Id`) ON DELETE CASCADE
) CHARACTER SET=utf8mb4;

-- ------------------------------------------------------------
-- 3. Tabela de grupos (caso não exista — cria com a nova coluna)
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `tbc_ingrediente_grupo` (
    `ing_grupo_id` int NOT NULL AUTO_INCREMENT,
    `ing_grupo_nome` varchar(200) CHARACTER SET utf8mb4 NULL,
    `ing_grupo_ordem` int NOT NULL,
    `ing_grupo_status` tinyint(1) NOT NULL,
    `ing_grupo_user_id` varchar(255) CHARACTER SET utf8mb4 NULL,
    CONSTRAINT `PK_tbc_ingrediente_grupo` PRIMARY KEY (`ing_grupo_id`),
    CONSTRAINT `FK_tbc_ingrediente_grupo_tbc_usuario_ing_grupo_user_id`
        FOREIGN KEY (`ing_grupo_user_id`) REFERENCES `tbc_usuario` (`Id`) ON DELETE SET NULL
) CHARACTER SET=utf8mb4;

-- Se a tabela já existia, garante que a coluna nova existe
ALTER TABLE `tbc_ingrediente_grupo`
  ADD COLUMN IF NOT EXISTS `ing_grupo_user_id` varchar(255) CHARACTER SET utf8mb4 NULL;

-- ------------------------------------------------------------
-- 4. Índices (ignora erro se já existirem)
-- ------------------------------------------------------------

CREATE INDEX IF NOT EXISTS `IX_tbc_receita_item_ing_grupo_id`
  ON `tbc_receita_item` (`ing_grupo_id`);

CREATE INDEX IF NOT EXISTS `IX_tbc_receita_rec_user_id`
  ON `tbc_receita` (`rec_user_id`);

CREATE INDEX IF NOT EXISTS `IX_tbc_ingrediente_ing_user_id`
  ON `tbc_ingrediente` (`ing_user_id`);

CREATE INDEX IF NOT EXISTS `IX_AspNetRoleClaims_RoleId`
  ON `AspNetRoleClaims` (`RoleId`);

CREATE UNIQUE INDEX IF NOT EXISTS `RoleNameIndex`
  ON `AspNetRoles` (`NormalizedName`);

CREATE INDEX IF NOT EXISTS `IX_AspNetUserClaims_UserId`
  ON `AspNetUserClaims` (`UserId`);

CREATE INDEX IF NOT EXISTS `IX_AspNetUserLogins_UserId`
  ON `AspNetUserLogins` (`UserId`);

CREATE INDEX IF NOT EXISTS `IX_AspNetUserRoles_RoleId`
  ON `AspNetUserRoles` (`RoleId`);

CREATE INDEX IF NOT EXISTS `IX_tbc_ingrediente_grupo_ing_grupo_user_id`
  ON `tbc_ingrediente_grupo` (`ing_grupo_user_id`);

CREATE INDEX IF NOT EXISTS `EmailIndex`
  ON `tbc_usuario` (`NormalizedEmail`);

CREATE UNIQUE INDEX IF NOT EXISTS `UserNameIndex`
  ON `tbc_usuario` (`NormalizedUserName`);

-- ------------------------------------------------------------
-- 5. Foreign keys nas tabelas existentes
--    (adiciona só se ainda não existirem)
-- ------------------------------------------------------------

SET @fk1 = (
  SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
  WHERE CONSTRAINT_SCHEMA = DATABASE()
    AND TABLE_NAME = 'tbc_ingrediente'
    AND CONSTRAINT_NAME = 'FK_tbc_ingrediente_tbc_usuario_ing_user_id'
);
SET @sql1 = IF(@fk1 = 0,
  'ALTER TABLE `tbc_ingrediente` ADD CONSTRAINT `FK_tbc_ingrediente_tbc_usuario_ing_user_id`
   FOREIGN KEY (`ing_user_id`) REFERENCES `tbc_usuario` (`Id`) ON DELETE SET NULL',
  'SELECT 1');
PREPARE stmt1 FROM @sql1; EXECUTE stmt1; DEALLOCATE PREPARE stmt1;

SET @fk2 = (
  SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
  WHERE CONSTRAINT_SCHEMA = DATABASE()
    AND TABLE_NAME = 'tbc_receita'
    AND CONSTRAINT_NAME = 'FK_tbc_receita_tbc_usuario_rec_user_id'
);
SET @sql2 = IF(@fk2 = 0,
  'ALTER TABLE `tbc_receita` ADD CONSTRAINT `FK_tbc_receita_tbc_usuario_rec_user_id`
   FOREIGN KEY (`rec_user_id`) REFERENCES `tbc_usuario` (`Id`) ON DELETE SET NULL',
  'SELECT 1');
PREPARE stmt2 FROM @sql2; EXECUTE stmt2; DEALLOCATE PREPARE stmt2;

SET @fk3 = (
  SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
  WHERE CONSTRAINT_SCHEMA = DATABASE()
    AND TABLE_NAME = 'tbc_receita_item'
    AND CONSTRAINT_NAME = 'FK_tbc_receita_item_tbc_ingrediente_grupo_ing_grupo_id'
);
SET @sql3 = IF(@fk3 = 0,
  'ALTER TABLE `tbc_receita_item` ADD CONSTRAINT `FK_tbc_receita_item_tbc_ingrediente_grupo_ing_grupo_id`
   FOREIGN KEY (`ing_grupo_id`) REFERENCES `tbc_ingrediente_grupo` (`ing_grupo_id`) ON DELETE RESTRICT',
  'SELECT 1');
PREPARE stmt3 FROM @sql3; EXECUTE stmt3; DEALLOCATE PREPARE stmt3;

-- ------------------------------------------------------------
-- 6. Registrar migration no histórico do EF Core
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `__EFMigrationsHistory` (
    `MigrationId` varchar(150) CHARACTER SET utf8mb4 NOT NULL,
    `ProductVersion` varchar(32) CHARACTER SET utf8mb4 NOT NULL,
    CONSTRAINT `PK___EFMigrationsHistory` PRIMARY KEY (`MigrationId`)
) CHARACTER SET=utf8mb4;

INSERT IGNORE INTO `__EFMigrationsHistory` (`MigrationId`, `ProductVersion`)
VALUES ('20260601135513_AddUserIdToIngredienteEGrupo', '9.0.3');

COMMIT;
