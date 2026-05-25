-- ============================================================
-- MIGRATION: ASP.NET Identity + UserId em tbc_receita
-- Banco: ws_dotrigo (MySQL 8)
-- Executar ANTES de subir a nova versão do backend
-- ============================================================

-- 1. Tabelas do ASP.NET Identity
-- ============================================================

CREATE TABLE IF NOT EXISTS `AspNetRoles` (
    `Id`               varchar(255) NOT NULL,
    `Name`             varchar(256) NULL,
    `NormalizedName`   varchar(256) NULL,
    `ConcurrencyStamp` longtext NULL,
    PRIMARY KEY (`Id`),
    UNIQUE KEY `RoleNameIndex` (`NormalizedName`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `tbc_usuario` (
    `Id`                   varchar(255) NOT NULL,
    `Status`               tinyint(1) NOT NULL DEFAULT 1,
    `UserName`             varchar(256) NULL,
    `NormalizedUserName`   varchar(256) NULL,
    `Email`                varchar(256) NULL,
    `NormalizedEmail`      varchar(256) NULL,
    `EmailConfirmed`       tinyint(1) NOT NULL DEFAULT 0,
    `PasswordHash`         longtext NULL,
    `SecurityStamp`        longtext NULL,
    `ConcurrencyStamp`     longtext NULL,
    `PhoneNumber`          longtext NULL,
    `PhoneNumberConfirmed` tinyint(1) NOT NULL DEFAULT 0,
    `TwoFactorEnabled`     tinyint(1) NOT NULL DEFAULT 0,
    `LockoutEnd`           datetime(6) NULL,
    `LockoutEnabled`       tinyint(1) NOT NULL DEFAULT 1,
    `AccessFailedCount`    int NOT NULL DEFAULT 0,
    PRIMARY KEY (`Id`),
    UNIQUE KEY `UserNameIndex` (`NormalizedUserName`),
    KEY `EmailIndex` (`NormalizedEmail`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `AspNetUserRoles` (
    `UserId` varchar(255) NOT NULL,
    `RoleId` varchar(255) NOT NULL,
    PRIMARY KEY (`UserId`, `RoleId`),
    KEY `IX_AspNetUserRoles_RoleId` (`RoleId`),
    CONSTRAINT `FK_AspNetUserRoles_AspNetRoles_RoleId`
        FOREIGN KEY (`RoleId`) REFERENCES `AspNetRoles` (`Id`) ON DELETE CASCADE,
    CONSTRAINT `FK_AspNetUserRoles_tbc_usuario_UserId`
        FOREIGN KEY (`UserId`) REFERENCES `tbc_usuario` (`Id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `AspNetUserClaims` (
    `Id`         int NOT NULL AUTO_INCREMENT,
    `UserId`     varchar(255) NOT NULL,
    `ClaimType`  longtext NULL,
    `ClaimValue` longtext NULL,
    PRIMARY KEY (`Id`),
    KEY `IX_AspNetUserClaims_UserId` (`UserId`),
    CONSTRAINT `FK_AspNetUserClaims_tbc_usuario_UserId`
        FOREIGN KEY (`UserId`) REFERENCES `tbc_usuario` (`Id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `AspNetUserLogins` (
    `LoginProvider`       varchar(128) NOT NULL,
    `ProviderKey`         varchar(128) NOT NULL,
    `ProviderDisplayName` longtext NULL,
    `UserId`              varchar(255) NOT NULL,
    PRIMARY KEY (`LoginProvider`, `ProviderKey`),
    KEY `IX_AspNetUserLogins_UserId` (`UserId`),
    CONSTRAINT `FK_AspNetUserLogins_tbc_usuario_UserId`
        FOREIGN KEY (`UserId`) REFERENCES `tbc_usuario` (`Id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `AspNetRoleClaims` (
    `Id`         int NOT NULL AUTO_INCREMENT,
    `RoleId`     varchar(255) NOT NULL,
    `ClaimType`  longtext NULL,
    `ClaimValue` longtext NULL,
    PRIMARY KEY (`Id`),
    KEY `IX_AspNetRoleClaims_RoleId` (`RoleId`),
    CONSTRAINT `FK_AspNetRoleClaims_AspNetRoles_RoleId`
        FOREIGN KEY (`RoleId`) REFERENCES `AspNetRoles` (`Id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `AspNetUserTokens` (
    `UserId`        varchar(255) NOT NULL,
    `LoginProvider` varchar(128) NOT NULL,
    `Name`          varchar(128) NOT NULL,
    `Value`         longtext NULL,
    PRIMARY KEY (`UserId`, `LoginProvider`, `Name`),
    CONSTRAINT `FK_AspNetUserTokens_tbc_usuario_UserId`
        FOREIGN KEY (`UserId`) REFERENCES `tbc_usuario` (`Id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. Adicionar UserId na tabela de receitas
-- ============================================================

ALTER TABLE `tbc_receita`
    ADD COLUMN `rec_user_id` varchar(255) NULL AFTER `rec_status`,
    ADD KEY `IX_tbc_receita_rec_user_id` (`rec_user_id`),
    ADD CONSTRAINT `FK_tbc_receita_tbc_usuario_rec_user_id`
        FOREIGN KEY (`rec_user_id`) REFERENCES `tbc_usuario` (`Id`) ON DELETE SET NULL;

-- 3. EF Migrations history (para o EF não tentar re-aplicar)
-- ============================================================

CREATE TABLE IF NOT EXISTS `__EFMigrationsHistory` (
    `MigrationId`    varchar(150) NOT NULL,
    `ProductVersion` varchar(32)  NOT NULL,
    PRIMARY KEY (`MigrationId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Marcar a migration inicial como aplicada (se já existia o banco)
INSERT IGNORE INTO `__EFMigrationsHistory` (`MigrationId`, `ProductVersion`)
VALUES ('20260514172019_InitialCreate', '9.0.3');

-- ============================================================
-- APÓS EXECUTAR ESTE SCRIPT:
-- Suba a nova versão do backend — o DbInitializer criará
-- automaticamente os roles e o usuário rcprieto@gmail.com,
-- associando todas as receitas existentes a ele.
-- ============================================================
