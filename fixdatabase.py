
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

