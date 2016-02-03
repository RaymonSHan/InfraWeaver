
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
  (1, '自然人类别', 0),
  (2, '法人类别', 0),
  (3, '产品持有类别', 0),
  (1001, '证券帐户', 0),
  (1002, '资金帐户', 0),
  (1003, '银行帐户', 0);

INSERT INTO `SystemField` 
  (`idField`, `descField`, `valueField`) 
VALUES
  (100001, 'idSex', '男'),
  (100002, 'idSex', '女'),
  (200001, 'idCertificate', '身份证'),
  (200002, 'idCertificate', '护照'),
  (200101, 'idCertificate', '机构代码证'),
  (200102, 'idCertificate', '税务登记号'),
  (200103, 'idCertificate', '工商注册号'),
  (300001, 'idMarket', '报价系统'),
  (300002, 'idMarket', '场外一卡通'),
  (400001, 'idAccountType', '个人主帐号'),
  (400002, 'idAccountType', '个人附加帐号'),
  (400003, 'idAccountType', '名义持有帐号');
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
  CALL __AddBasePerson(1, @sequ);
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
  CALL __AddBasePerson(2, @sequ);
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
  CALL __AddBaseCertificate(200001, valcert, valname, @sequ);
  SELECT 0, @sequ;  -- 0 for success
  COMMIT;
END; $

DELIMITER $
DROP PROCEDURE IF EXISTS `AddSecurityAccount`; $
CREATE PROCEDURE `AddSecurityAccount` (
  IN idmarket INT(11), IN valaccount VARCHAR(32), IN idtype INT(11))
BEGIN
  SET @sequ = 0;
  CALL __AddBaseAccount(1001, @sequ);
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

DROP VIEW IF EXISTS `SecurityHolderView`;
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

CREATE TABLE IF NOT EXISTS `BaseProdure` (
  `idProdure` BIGINT NOT NULL,
  `idClass` INT(11) NOT NULL,
  `valueName` VARCHAR(256) NOT NULL,
  `valueShortname` VARCHAR(32) NULL,
  `valueCode` VARCHAR(32) NULL,
  `idConsignee` BIGINT NULL COMMENT '承销人，应在ParticipantPerson中',
  `valueNumberLimit` INT(11) UNSIGNED NULL,
  `valueNumberNow` INT(11) UNSIGNED NULL,
  PRIMARY KEY (`idProdure`))
COMMENT = '产品信息基本表';

INSERT INTO 
  `SystemClass` (`idClass`, `valueClass`, `startClass`)
VALUES
  (5100, '资产管理类', 0),
  (5101, '集合计划', 0),
  (5103, '定向计划', 0),
  (5104, '专项计划', 0),
  (5200, '债务融资工具类', 0),
  (5201, '中小企业私募债', 0),
  (5202, '次级债', 0),
  (5203, '非公开发行公司债', 0),
  (5300, '私募股权类', 0),
  (5400, '衍生品类', 0),
  (5402, '期权', 0),
  (5403, '互换', 0),
  (5406, '远期', 0),
  (5407, '结构化衍生品', 0),
  (5500, '资产支持证券类', 0),
  (5501, '资产支持证券', 0),
  (5600, '私募基金类', 0),
  (5601, '私募股权投资基金', 0),
  (5602, '私募证券投资基金', 0),
  (5700, '收益凭证类', 0),
  (5800, '其他类型', 0);

