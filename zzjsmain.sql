
CREATE SCHEMA `InfraWeaver` DEFAULT CHARACTER SET utf8 COLLATE utf8_bin ;

CREATE TABLE IF NOT EXISTS `SystemClass` (
  `idClass` INT(11) UNSIGNED NOT NULL,
  `valueClass` VARCHAR(256) NULL,
  `startClass` INT(11) UNSIGNED NOT NULL,
  PRIMARY KEY (`idClass`))
COMMENT='类别信息表';

CREATE TABLE IF NOT EXISTS `SystemField` (
  `idField` INT(11) UNSIGNED NOT NULL,
  `descField` VARCHAR(32) NOT NULL,
  `valueField` VARCHAR(256) NOT NULL,
  PRIMARY KEY (`idField`))
COMMENT='属性信息表';

INSERT INTO `SystemClass` 
  (`idClass`, `valueClass`, `startClass`) 
VALUES
  (1, '自然人类别', 0),
  (2, '法人类别', 0),
  (3, '产品持有类别', 0);

INSERT INTO `SystemField` 
  (`idField`, `descField`, `valueField`) 
VALUES
  (100001, 'idSex', '男'),
  (100002, 'idSex', '女'),
  (200001, 'idCertificate', '身份证'),
  (200002, 'idCertificate', '护照');

CREATE TABLE IF NOT EXISTS `BasePerson` (
  `sequPerson` BIGINT  UNSIGNED NOT NULL,
  `idClass` INT(11) UNSIGNED NOT NULL,
  PRIMARY KEY (`sequPerson`))
COMMENT='人信息基本表';

CREATE TABLE IF NOT EXISTS `NaturalPerson` (
  `sequPerson` BIGINT UNSIGNED NOT NULL,
  `valueName` VARCHAR(256) NOT NULL,
  `idSex` INT(11) UNSIGNED NOT NULL,
  `valueBirthday` VARCHAR(32) NOT NULL,
  PRIMARY KEY (`sequPerson`),
  CONSTRAINT `fk_NaturalPerson` 
    FOREIGN KEY (`sequPerson`)
    REFERENCES `BasePerson` (`sequPerson`)
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION)
COMMENT='自然人信息表';

CREATE TABLE IF NOT EXISTS `BaseCertificate` (
  `idCertificate` INT(11) UNSIGNED NOT NULL,
  `valueCertificate` VARCHAR(32) NOT NULL,
  `valueName` VARCHAR(256) NOT NULL,
  `sequPerson` BIGINT UNSIGNED NOT NULL,
  UNIQUE `baseCertificate_INDEX` (`valueCertificate` ASC, `idCertificate` ASC))
COMMENT='证件信息基本表';

CREATE VIEW `NaturalPersonView` AS
  SELECT
    BP.idClass,
    NP.sequPerson, NP.valueName, NP.idSex, NP.valueBirthday
  FROM
    NaturalPerson NP, BasePerson BP
  WHERE
    NP.sequPerson = BP.sequPerson;

DELIMITER $
CREATE PROCEDURE `__AddBasePerson` (
  IN idclass INT(11),
  IN idcert INT(11), IN valcert VARCHAR(32), IN valname VARCHAR(256), 
  INOUT sequperson BIGINT )
BEGIN
  IF sequperson = 0 THEN
    SET @sequ = uuid_short();
    INSERT INTO `BasePerson` (`sequPerson`, `idClass`) 
      VALUES (@sequ, idclass);
  ELSE
    -- should check whether sequperson is valid
    SET @sequ = sequperson;
  END IF;
  SET sequperson = 0;
  INSERT INTO `BaseCertificate` (`idCertificate`, `valueCertificate`, `valueName`, `sequPerson`)
    VALUES (idcert, valcert, valname, @sequ);
  SET sequperson = @sequ;
END; $

DELIMITER $
CREATE PROCEDURE `GetPerson` (
  IN idcert INT(11), IN valcert VARCHAR(32), IN valname VARCHAR(256) )
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

DELIMITER $
CREATE PROCEDURE `AddNaturalPerson` ( 
  IN idcert INT(11), IN valcert VARCHAR(32), IN valname VARCHAR(256), 
  IN valsex INT(11), IN valbirth VARCHAR(32) )
BEGIN
  SET @sequ = 0;
  CALL __AddBasePerson(1, idcert, valcert, valname, @sequ);
  INSERT INTO `NaturalPerson` (`sequPerson`, `valueName`, `idSex`, `valueBirthday`)
    VALUES (@sequ, valname, valsex, valbirth);
  SELECT 0, @sequ;  -- 0 for success
  COMMIT;
END; $
-- ABOVE FINISHED in Jan. 27 '16, for NaturalPerson

INSERT INTO `SystemField` 
  (`idField`, `descField`, `valueField`) 
VALUES
  (200101, 'idCertificate', '机构代码证'),
  (200102, 'idCertificate', '税务登记号'),
  (200103, 'idCertificate', '工商注册号');

CREATE TABLE IF NOT EXISTS `LegalPerson` (
  `sequPerson` BIGINT UNSIGNED NOT NULL,
  `valueName` VARCHAR(256) NOT NULL,
  `sequRepresentative` BIGINT UNSIGNED NOT NULL COMMENT '法人代表id，此id应在NaturalPerson中',
  `valueCapital` VARCHAR(32) NULL COMMENT '注册资本，仅供显示',
  PRIMARY KEY (`sequPerson`),
  INDEX `indexRepresentative` (`sequRepresentative` ASC),
  CONSTRAINT `fk_LegalPerson`
    FOREIGN KEY (`sequPerson`)
    REFERENCES `BasePerson` (`sequPerson`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
COMMENT='法人信息表';

CREATE VIEW `LegalPersonView` AS
  SELECT
    BP.idClass,
    LP.sequPerson, LP.valueName, LP.sequRepresentative, LP.valueCapital
  FROM
    LegalPerson LP,
    BasePerson BP
  WHERE
    LP.sequPerson = BP.sequPerson;

DELIMITER $
CREATE PROCEDURE `AddLegalPerson` (
  IN idcert INT(11), IN valcert VARCHAR(32), IN valname VARCHAR(256), 
  IN sequrepr BIGINT, IN valcapital VARCHAR(32) )
BEGIN
  SET @sequ = 0;
  CALL __AddBasePerson(1, idcert, valcert, valname, @sequ);
  INSERT INTO `LegalPerson` (`sequPerson`, `valueName`, `sequRepresentative`, `valueCapital`)
    VALUES (@sequ, valname, sequrepr, valcapital);
  SELECT 0, @sequ;  -- 0 for success
  COMMIT;
END $
-- ABOVE FINISHED in Jan. 27 '16, for LegalPerson

INSERT INTO `SystemClass` 
  (`idClass`, `valueClass`, `startClass`) 
VALUES
  (1001, '证券帐户', 0),
  (1002, '资金帐户', 0),
  (1003, '银行帐户', 0);

INSERT INTO `SystemField` 
  (`idField`, `descField`, `valueField`)
VALUES
  (300001, 'idMarket', '报价系统'),
  (300002, 'idMarket', '场外一卡通');

CREATE TABLE IF NOT EXISTS `BaseAccount` (
  `sequAccount` BIGINT UNSIGNED NOT NULL,
  `idClass` INT(11) UNSIGNED NOT NULL,
  PRIMARY KEY (`sequAccount`))
COMMENT='帐号基本表';

CREATE TABLE IF NOT EXISTS `SecurityAccount` (
  `sequAccount` BIGINT UNSIGNED NOT NULL,
  `idMarket` INT(11) UNSIGNED NOT NULL,
  `valueAccount` VARCHAR(32) NOT NULL,
  PRIMARY KEY (`sequAccount`),
  UNIQUE `indexvalAccount` (`valueAccount` ASC, `idMarket` ASC),
  CONSTRAINT `fk_SecurityAccount`
    FOREIGN KEY (`sequAccount`)
    REFERENCES `BaseAccount` (`sequAccount`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
COMMENT='证券账户表';

CREATE VIEW `SecurityAccountView` AS
  SELECT
    BA.idClass,
    SA.sequAccount, SA.idMarket, SA.valueAccount
  FROM
    SecurityAccount SA,
    BaseAccount BA
  WHERE
    SA.sequAccount = BA.sequAccount;

DELIMITER $
CREATE PROCEDURE `__AddBaseAccount` (
  IN idclass INT(11), OUT sequacc BIGINT )
BEGIN
  SET @sequ = uuid_short();
  SET sequacc = 0;
  INSERT INTO `BaseAccount` (`sequAccount`, `idClass`) 
    VALUES (@sequ, idclass);
  SET sequacc = @sequ;
END; $

DELIMITER $
CREATE PROCEDURE `AddSecurityAccount` (
  IN idmarket INT(11), IN valaccount VARCHAR(32))
BEGIN
  SET @sequ = 0;
  CALL __AddBaseAccount(1001, @sequ);
  INSERT INTO `SecurityAccount` (`sequAccount`, `idMarket`, `valueAccount`)
    VALUES (@sequ, idmarket, valaccount);
  SELECT 0, @sequ;  -- 0 for success
  COMMIT;
END; $

DELIMITER $
CREATE PROCEDURE `GetSecurityAccount` (
  IN idmarket INT(11), IN valaccount VARCHAR(32))
BEGIN
  SELECT
    0, BA.sequAccount
  FROM
    BaseAccount BA,
    SecurityAccount SA
  WHERE
    SA.idMarket = idmarket AND
    SA.valueAccount = valaccount AND
    BA.sequAccount = SA.sequAccount;
END; $
-- ABOVE FINISHED in Jan. 29 '16, for SecurityAccount

INSERT INTO `SystemField` 
  (`idField`, `descField`, `valueField`)
VALUES
  (400001, 'idAccountType', '个人主帐号'),
  (400002, 'idAccountType', '个人附加帐号'),
  (400003, 'idAccountType', '实际持有人');

CREATE TABLE IF NOT EXISTS `BasePersonAccount` (
  `sequPersonAccount` BIGINT UNSIGNED NOT NULL,
  `sequPerson` BIGINT UNSIGNED NOT NULL,
  `sequAccount` BIGINT UNSIGNED NOT NULL,
  `idAccountType` INT(11) UNSIGNED NOT NULL,
  PRIMARY KEY (`sequPersonAccount`),
  INDEX `indexPerson` (`sequPerson` ASC),
  INDEX `indexAccount` (`sequAccount` ASC),
  UNIQUE `indexPersonAccount` (`sequPerson` ASC, `sequAccount` ASC))
COMMENT='人员帐户关系表';

DELIMITER $
CREATE PROCEDURE `AddPersonAccount` (
  IN sequper BIGINT, IN sequacc BIGINT, IN idtype INT(11))
BEGIN
  SET @sequ = uuid_short();
  INSERT INTO `BasePersonAccount` (`sequPersonAccount`, `sequPerson`, `sequAccount`, `idAccountType`)
    VALUES (@sequ, sequper, sequacc, idtype);
  SELECT 0, @sequ;  -- 0 for success
  COMMIT;
END; $

DELIMITER $
CREATE PROCEDURE `GetPersonAccount` (
  IN sequper BIGINT, IN sequacc BIGINT, IN idtype INT(11))
BEGIN
  SELECT
    IF (idtype = BPA.idAccountType, 0, 1) AS result,
    BPA.sequPersonAccount
  FROM
    BasePersonAccount BPA
  WHERE
    BPA.sequPerson = sequper AND
    BPA.sequAccount = sequacc;
END; $

DELIMITER $
CREATE PROCEDURE `QueryAccountByIdentiry`
  (IN idcert INT(11), IN valcert VARCHAR(32))
BEGIN
  SELECT
    BPA.sequPersonAccount, BPA.sequPerson, BPA.sequAccount, BPA.idAccountType
  FROM
    BasePersonAccount BPA, BaseCertificate BC
  WHERE
    BPA.sequPerson = BC.sequPerson AND
    BC.idCertificate = idcert AND
    BC.valueCertificate = vercert
END $
-- ABOVE FINISHED in Feb. 01 '16, for SecurityAccount



CREATE TABLE IF NOT EXISTS `BaseProdure` (
  `idProdure` BIGINT UNSIGNED NOT NULL,
  `idClass` INT(11) UNSIGNED NOT NULL,
  `valueName` VARCHAR(256) NOT NULL,
  `valueShortname` VARCHAR(32) NULL,
  `valueCode` VARCHAR(32) NULL,
  `idConsignee` BIGINT UNSIGNED NOT NULL COMMENT '承销人，应在ParticipantPerson中',
  `valueOthers` VARCHAR(32) NULL,
  `valueNumberLimit` INT(11) NULL,
  `valueNumberNow` INT(11) NULL,
  PRIMARY KEY (`idProdure`))
COMMENT = '产品信息基本表';

INSERT INTO `SystemClass` (`idClass`, `valueClass`, `startClass`) VALUES
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

DELIMITER $
CREATE PROCEDURE `AddRelationPersonAccount` -- 增加人员帐户关系
  (IN personsequ BIGINT, IN accountsequ BIGINT)
BEGIN
  SET @sequ = uuid_short();
  INSERT INTO `RelationPersonAccount` (`RePersonAccount`, `idPerson`, `idAccount`)
    VALUES (@sequ, personsequ, accountsequ);
  SELECT 0, @sequ;  -- 0 for success
  COMMIT;
END $

DELIMITER $
CREATE PROCEDURE `GetRelationPersonAccount`
  (IN personsequ BIGINT, IN accountsequ BIGINT)
BEGIN
  SELECT 0, RePersonAccount
  FROM RelationPersonAccount
  WHERE idPerson = personsequ AND idAccount = accountsequ;
END $































DELIMITER $ -- NOT FINISH
CREATE FUNCTION `IsValidIdentity` 
  (personid VARCHAR(45))
RETURNS INT
BEGIN
  IF LENGTH(personid) != 18 THEN
    RETURN 1;
  END IF;
  SET @ofday = MONTH(SUBSTRING(personid, 7, 8) );
  IF @ofday = NULL THEN
    RETURN 2;
  END IF;
  RETURN 0;
END $ -- NOT FINISH
