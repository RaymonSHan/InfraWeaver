
CREATE TABLE IF NOT EXISTS `zzjs_main`.`SystemClass` (
    `idClass` INT(11) UNSIGNED NOT NULL,
    `valueClass` VARCHAR(256) NULL,
    `startClass` INT(11) UNSIGNED NOT NULL,
    PRIMARY KEY (`idClass`)
)  COMMENT='类别信息表';

CREATE TABLE IF NOT EXISTS `zzjs_main`.`SystemField` (
    `idField` INT(11) UNSIGNED NOT NULL,
    `descField` VARCHAR(32) NOT NULL,
    `valueField` VARCHAR(256) NOT NULL,
    PRIMARY KEY (`idField`)
)  COMMENT='属性信息表';

CREATE TABLE IF NOT EXISTS `zzjs_main`.`BasePerson` (
    `idPerson` INT(11) UNSIGNED NOT NULL,
    `idClass` INT(11) UNSIGNED NOT NULL,
    PRIMARY KEY (`idPerson`)
)  COMMENT='权益人信息基本表';

CREATE TABLE IF NOT EXISTS `zzjs_main`.`NaturalPerson` (
    `idPerson` INT(11) UNSIGNED NOT NULL,
    `idSex` INT(11) UNSIGNED NOT NULL,
    `valueBirthday` VARCHAR(32) NOT NULL,
    PRIMARY KEY (`idPerson`),
    CONSTRAINT `fk_NaturalPerson` FOREIGN KEY (`idPerson`)
        REFERENCES `zzjs_main`.`BasePerson` (`idPerson`)
        ON DELETE NO ACTION ON UPDATE NO ACTION
)  COMMENT='自然人信息表';

CREATE TABLE IF NOT EXISTS `zzjs_main`.`BaseCertificate` (
    `idCertificate` INT(11) UNSIGNED NOT NULL,
    `valueCertificate` VARCHAR(32) NOT NULL,
    `valueName` VARCHAR(256) NOT NULL,
    `idPerson` INT(11) UNSIGNED NOT NULL,
    INDEX `baseCertificate_INDEX` (`valueCertificate` ASC , `idCertificate` ASC , `valueName` ASC)
)  COMMENT='证件信息基本表';

CREATE VIEW `NaturalPersonView` AS
    select 
        BC.idCertificate,
        BC.valueCertificate,
        BC.valueName,
        NP.idSex,
        NP.valueBirthday,
        BP.idClass
    from
        NaturalPerson NP,
        BasePerson BP,
        BaseCertificate BC
    where
        NP.idPerson = BP.idPerson
            and NP.idPerson = BC.idPerson;

INSERT INTO `SystemClass` (`idClass`, `valueClass`, `startClass`) VALUES
(1, '自然人类别', 0),
(2, '法人类别', 0),
(3, '产品持有类别', 0);

INSERT INTO `SystemField` (`idField`, `descField`, `valueField`) VALUES
(100001, 'idSex', '男'),
(100002, 'idSex', '女'),
(200001, 'idCertificate', '身份证'),
(200002, 'idCertificate', '护照'),
(200101, 'idCertificate', '机构代码证'),
(200102, 'idCertificate', '税务登记号');

DELIMITER $
CREATE PROCEDURE `getvalueinto3`(in idc int, out idd int)
BEGIN
set idd = 67;
select idd;
END $
