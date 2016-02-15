
CREATE SCHEMA `InfraWeaver` DEFAULT CHARACTER SET utf8 COLLATE utf8_bin;

DROP TABLE IF EXISTS `SystemClass`;
CREATE TABLE `SystemClass` (
  `idClass` INT(11) NOT NULL,
  `valueClass` VARCHAR(256) NULL,
  `startClass` INT(11) NOT NULL,
  PRIMARY KEY (`idClass`))
COMMENT='类别信息表';

DROP TABLE IF EXISTS `SystemField`;
CREATE TABLE `SystemField` (
  `idField` INT(11) NOT NULL,
  `descField` VARCHAR(32) NOT NULL,
  `valueField` VARCHAR(256) NOT NULL,
  PRIMARY KEY (`idField`))
COMMENT='属性信息表';

DROP TABLE IF EXISTS `BasePerson`;
CREATE TABLE `BasePerson` (
  `sequPerson` BIGINT  NOT NULL,
  `idClass` INT(11) NOT NULL,
  PRIMARY KEY (`sequPerson`))
COMMENT='人信息基本表';

DROP TABLE IF EXISTS `BaseAccount`;
CREATE TABLE `BaseAccount` (
  `sequAccount` BIGINT NOT NULL,
  `idClass` INT(11) NOT NULL,
  PRIMARY KEY (`sequAccount`))
COMMENT='帐号基本表';

DROP TABLE IF EXISTS `BaseCertificate`;
CREATE TABLE `BaseCertificate` (
  `sequCertificate` BIGINT NOT NULL,
  `idCertificate` INT(11) NOT NULL,
  `valueCertificate` VARCHAR(32) NOT NULL,
  `valueName` VARCHAR(256) NOT NULL,
  PRIMARY KEY (`sequCertificate`),
  UNIQUE `baseCertificate_INDEX` (`valueCertificate` ASC, `idCertificate` ASC))
COMMENT='证件信息基本表';

INSERT INTO `SystemClass` 
  (`idClass`, `valueClass`, `startClass`) 
VALUES
  (0x0001, '自然人类别', 0),
  (0x0002, '法人类别', 0),
  (0x0003, '产品持有类别', 0),
  (0x1001, '证券帐户', 0),
  (0x1002, '资金帐户', 0),
  (0x1003, '银行帐户', 0);

INSERT INTO `SystemField` 
  (`idField`, `descField`, `valueField`) 
VALUES
  (0x100001, 'idSex', '男'),
  (0x100002, 'idSex', '女'),
  (0x200001, 'idCertificate', '身份证'),
  (0x200002, 'idCertificate', '护照'),
  (0x200101, 'idCertificate', '机构代码证'),
  (0x200102, 'idCertificate', '税务登记号'),
  (0x200103, 'idCertificate', '工商注册号'),
  (0x300001, 'idMarket', '报价系统'),
  (0x300002, 'idMarket', '场外一卡通'),
  (0x400001, 'idAccountType', '个人主帐号'),
  (0x400002, 'idAccountType', '个人附加帐号'),
  (0x401003, 'idAccountType', '名义持有帐号');
-- STEP 01, create base table, Feb. 02 '16

DELIMITER $
DROP PROCEDURE IF EXISTS `__AddBasePerson`; $
CREATE PROCEDURE `__AddBasePerson` (
  IN idclass INT(11), OUT sequper BIGINT)
BEGIN
  SET @sequ = uuid_short();
  SET sequper = 0;
  INSERT INTO `BasePerson` (`sequPerson`, `idClass`) 
    VALUES (@sequ, idclass);
  SET sequper = @sequ;
END; $

DELIMITER $
DROP PROCEDURE IF EXISTS `__AddBaseAccount`; $
CREATE PROCEDURE `__AddBaseAccount` (
  IN idclass INT(11), OUT sequacc BIGINT)
BEGIN
  SET @sequ = uuid_short();
  SET sequacc = 0;
  INSERT INTO `BaseAccount` (`sequAccount`, `idClass`) 
    VALUES (@sequ, idclass);
  SET sequacc = @sequ;
END; $

DELIMITER $
DROP PROCEDURE IF EXISTS `__AddBaseCertificate`; $
CREATE PROCEDURE `__AddBaseCertificate` (
  IN idcert INT(11), IN valcert VARCHAR(32), IN valname VARCHAR(256), 
  OUT sequcert BIGINT)
BEGIN
  SET @sequ = uuid_short();
  SET sequcert = 0;
  INSERT INTO `BaseCertificate` 
    (`sequCertificate`, `idCertificate`, `valueCertificate`, `valueName`)
    VALUES (@sequ, idcert, valcert, valname);
  SET sequcert = @sequ;
END; $

DELIMITER $
DROP PROCEDURE IF EXISTS `GetBaseCertificate`; $
CREATE PROCEDURE `GetBaseCertificate` (
  IN idcert INT(11), IN valcert VARCHAR(32), IN valname VARCHAR(256))
BEGIN
  SELECT
    IF (valname = BC.valueName, 0, 1) AS result,
    BC.sequPerson
  FROM
    BaseCertificate BC,
    BasePerson BP
  WHERE
    BC.idCertificate = idcert AND
    BC.valueCertificate = valcert AND
    BC.sequPerson = BP.sequPerson;
END; $
-- STEP 02, create base procedure, Feb. 02 '16

DROP TABLE IF EXISTS `NaturalPerson`;
CREATE TABLE `NaturalPerson` (
  `sequPerson` BIGINT NOT NULL,
  `idSex` INT(11) NOT NULL,
  `valueBirthday` VARCHAR(32) NOT NULL,
  PRIMARY KEY (`sequPerson`),
  CONSTRAINT `fk_NaturalPerson` 
    FOREIGN KEY (`sequPerson`)
    REFERENCES `BasePerson` (`sequPerson`)
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION)
COMMENT='自然人信息表';

DROP TABLE IF EXISTS `LegalPerson`;
CREATE TABLE `LegalPerson` (
  `sequPerson` BIGINT NOT NULL,
  `sequRepresentative` BIGINT NOT NULL COMMENT '法人代表id，此id应在NaturalPerson中',
  `valueCapital` VARCHAR(32) NULL COMMENT '注册资本，仅供显示',
  PRIMARY KEY (`sequPerson`),
  INDEX `indexRepresentative` (`sequRepresentative` ASC),
  CONSTRAINT `fk_LegalPerson`
    FOREIGN KEY (`sequPerson`)
    REFERENCES `BasePerson` (`sequPerson`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
COMMENT='法人信息表';

DROP TABLE IF EXISTS `SecurityAccount`;
CREATE TABLE `SecurityAccount` (
  `sequAccount` BIGINT NOT NULL,
  `idMarket` INT(11) NOT NULL,
  `valueAccount` VARCHAR(32) NOT NULL,
  `idAccountType` INT(11) NOT NULL,
  PRIMARY KEY (`sequAccount`),
  UNIQUE `indexvalAccount` (`valueAccount` ASC, `idMarket` ASC),
  CONSTRAINT `fk_SecurityAccount`
    FOREIGN KEY (`sequAccount`)
    REFERENCES `BaseAccount` (`sequAccount`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
COMMENT='证券账户表';

DROP VIEW IF EXISTS `NaturalPersonView`;
CREATE VIEW `NaturalPersonView` AS
  SELECT
    BP.idClass,
    NP.sequPerson, NP.idSex, NP.valueBirthday
  FROM
    NaturalPerson NP, BasePerson BP
  WHERE
    NP.sequPerson = BP.sequPerson;

DROP VIEW IF EXISTS `LegalPersonView`;
CREATE VIEW `LegalPersonView` AS
  SELECT
    BP.idClass,
    LP.sequPerson, LP.sequRepresentative, LP.valueCapital
  FROM
    LegalPerson LP,
    BasePerson BP
  WHERE
    LP.sequPerson = BP.sequPerson;

DROP VIEW IF EXISTS `SecurityAccountView`;
CREATE VIEW `SecurityAccountView` AS
  SELECT
    BA.idClass,
    SA.sequAccount, SA.idMarket, SA.valueAccount, SA.idAccountType
  FROM
    SecurityAccount SA,
    BaseAccount BA
  WHERE
    SA.sequAccount = BA.sequAccount;

DROP TABLE IF EXISTS `BaseHolder`;
CREATE TABLE `BaseHolder` (
  `sequHolder` BIGINT NOT NULL,
  `sequPerson` BIGINT NOT NULL,
  `sequCertificate` BIGINT NOT NULL,
  `sequAccount` BIGINT NOT NULL,
  PRIMARY KEY (`sequHolder`),
  INDEX `indexPerson` (`sequPerson` ASC),
  INDEX `indexCertificate` (`sequCertificate` ASC),
  INDEX `indexAccount` (`sequAccount` ASC),
  UNIQUE `indexPersonAccount` (`sequPerson` ASC, `sequCertificate` ASC, `sequAccount` ASC))
COMMENT='持有关系表';

DELIMITER $
DROP PROCEDURE IF EXISTS `AddNaturalPerson`; $
CREATE PROCEDURE `AddNaturalPerson` ( 
  IN valsex INT(11), IN valbirth VARCHAR(32) )
BEGIN
  SET @sequ = 0;
  CALL __AddBasePerson(0x0001, @sequ);
  INSERT INTO `NaturalPerson` (`sequPerson`, `idSex`, `valueBirthday`)
    VALUES (@sequ, valsex, valbirth);
  SELECT 0, @sequ;  -- 0 for success
  COMMIT;
END; $

DELIMITER $
DROP PROCEDURE IF EXISTS `AddLegalPerson`; $
CREATE PROCEDURE `AddLegalPerson` (
  IN sequrepr BIGINT, IN valcapital VARCHAR(32) )
BEGIN
  SET @sequ = 0;
  CALL __AddBasePerson(0x0002, @sequ);
  INSERT INTO `LegalPerson` (`sequPerson`, `sequRepresentative`, `valueCapital`)
    VALUES (@sequ, sequrepr, valcapital);
  SELECT 0, @sequ;  -- 0 for success
  COMMIT;
END $

DELIMITER $
DROP PROCEDURE IF EXISTS `AddIdentityCard`; $
CREATE PROCEDURE `AddIdentityCard` (
  IN valcert VARCHAR(32), IN valname VARCHAR(256))
BEGIN
  SET @sequ = 0;
  CALL __AddBaseCertificate(0x200001, valcert, valname, @sequ);
  SELECT 0, @sequ;  -- 0 for success
  COMMIT;
END; $

DELIMITER $
DROP PROCEDURE IF EXISTS `AddSecurityAccount`; $
CREATE PROCEDURE `AddSecurityAccount` (
  IN idmarket INT(11), IN valaccount VARCHAR(32), IN idtype INT(11))
BEGIN
  SET @sequ = 0;
  CALL __AddBaseAccount(0x1001, @sequ);
  INSERT INTO `SecurityAccount` (`sequAccount`, `idMarket`, `valueAccount`, `idAccountType`)
    VALUES (@sequ, idmarket, valaccount, idtype);
  SELECT 0, @sequ;  -- 0 for success
  COMMIT;
END; $

DELIMITER $
DROP PROCEDURE IF EXISTS `AddBaseHolder`; $
CREATE PROCEDURE `AddBaseHolder` (
  IN sequper BIGINT, IN sequcert BIGINT, IN sequacc BIGINT)
BEGIN
  SET @sequ = uuid_short();
  INSERT INTO `BaseHolder` (`sequHolder`, `sequPerson`, `sequCertificate`, `sequAccount`)
    VALUES (@sequ, sequper, sequcert, sequacc);
  SELECT 0, @sequ;  -- 0 for success
  COMMIT;
END; $

DROP VIEW IF EXISTS `SecurityHolderView`; $
CREATE VIEW `SecurityHolderView` AS
  SELECT
    BC.idCertificate, BC.valueCertificate, BC.valueName,
    SA.idMarket, SA.valueAccount, SA.idAccountType
  FROM
    BaseHolder BH, BasePerson BP, BaseCertificate BC, BaseAccount BA,
    SecurityAccount SA
  WHERE
    BH.sequPerson = BP.sequPerson AND
    BH.sequCertificate = BC.sequCertificate AND
    BH.sequAccount = BA.sequAccount AND
    BH.sequAccount = SA.sequAccount;
-- STEP 03, create procedure, Feb. 03 '16

DROP TABLE IF EXISTS `BaseProdure`;
CREATE TABLE `BaseProdure` (
  `sequProdure` BIGINT NOT NULL,
  `idClass` INT(11) NOT NULL,
  PRIMARY KEY (`sequProdure`))
COMMENT = '产品信息基本表';

DROP TABLE IF EXISTS `PrivateProdure`;
CREATE TABLE `PrivateProdure` (
  `sequProdure` BIGINT NOT NULL,
  `valueName` VARCHAR(256) NOT NULL,
  `valueShortname` VARCHAR(32) NULL,
  `valueCode` VARCHAR(32) NOT NULL,
  `sequConsignee` BIGINT NULL COMMENT '承销人',
  `valueNumberLimit` INT(11) UNSIGNED NOT NULL,
  PRIMARY KEY (`sequProdure`),
  INDEX `indexCode` (`valueCode` ASC),
  INDEX `indexConsignee` (`sequConsignee` ASC),
  CONSTRAINT `fk_PrivateProdure`
    FOREIGN KEY (`sequProdure`)
    REFERENCES `BaseProdure` (`sequProdure`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
COMMENT = '私募产品信息表';

DROP VIEW IF EXISTS `PrivateProdureView`;
CREATE VIEW `PrivateProdureView` AS
  SELECT
    BP.idClass,
    PP.sequProdure, PP.valueName, PP.valueShortname, PP.valueCode, PP.sequConsignee, PP.valueNumberLimit
  FROM
    PrivateProdure PP, BaseProdure BP
  WHERE
    PP.sequProdure = BP.sequProdure;

INSERT INTO 
  `SystemClass` (`idClass`, `valueClass`, `startClass`)
VALUES
  (0x5100, '资产管理类', 0),
  (0x5101, '集合计划', 0),
  (0x5103, '定向计划', 0),
  (0x5104, '专项计划', 0),
  (0x5200, '债务融资工具类', 0),
  (0x5201, '中小企业私募债', 0),
  (0x5202, '次级债', 0),
  (0x5203, '非公开发行公司债', 0),
  (0x5300, '私募股权类', 0),
  (0x5400, '衍生品类', 0),
  (0x5402, '期权', 0),
  (0x5403, '互换', 0),
  (0x5406, '远期', 0),
  (0x5407, '结构化衍生品', 0),
  (0x5500, '资产支持证券类', 0),
  (0x5501, '资产支持证券', 0),
  (0x5600, '私募基金类', 0),
  (0x5601, '私募股权投资基金', 0),
  (0x5602, '私募证券投资基金', 0),
  (0x5700, '收益凭证类', 0),
  (0x5800, '其他类型', 0);

DELIMITER $
DROP PROCEDURE IF EXISTS `__AddBaseProdure`; $
CREATE PROCEDURE `__AddBaseProdure` (
  IN idclass INT(11),  OUT sequacc BIGINT)
BEGIN
  SET @sequ = uuid_short();
  SET sequacc = 0;
  INSERT INTO `BaseProdure` (`sequProdure`, `idClass`)
    VALUES (@sequ, idclass);
  SET sequacc = @sequ;
END; $

DELIMITER $
DROP PROCEDURE IF EXISTS `AddPrivateProdure`; $
CREATE PROCEDURE `AddPrivateProdure` (
  IN idclass INT(11), IN valname VARCHAR(256), IN valshort VARCHAR(32), 
  IN valcode VARCHAR(32), IN sequconsi BIGINT, IN vallimit INT(11))
BEGIN
  SET @sequ = 0;
  CALL __AddBaseProdure(idclass, @sequ);
  INSERT INTO `PrivateProdure` 
    (`sequProdure`, `valueName`, `valueShortname`, `valueCode`, `sequConsignee`, `valueNumberLimit`)
    VALUES (@sequ, valname, valshort, valcode, sequconsi, vallimit);
  SELECT 0, @sequ;  -- 0 for success
  COMMIT;
END $
-- STEP 04, first Basic Produre, Feb. 04 '16
