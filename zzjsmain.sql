
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

CREATE TABLE IF NOT EXISTS `BasePerson` (
  `idPerson` BIGINT  UNSIGNED NOT NULL,
  `idClass` INT(11) UNSIGNED NOT NULL,
  PRIMARY KEY (`idPerson`))
COMMENT='人信息基本表';

CREATE TABLE IF NOT EXISTS `NaturalPerson` (
  `idPerson` BIGINT UNSIGNED NOT NULL,
  `valueName` VARCHAR(256) NOT NULL,
  `idSex` INT(11) UNSIGNED NOT NULL,
  `valueBirthday` VARCHAR(32) NOT NULL,
  PRIMARY KEY (`idPerson`),
  CONSTRAINT `fk_NaturalPerson` 
    FOREIGN KEY (`idPerson`)
    REFERENCES `BasePerson` (`idPerson`)
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION)
COMMENT='自然人信息表';

CREATE TABLE IF NOT EXISTS `LegalPerson` (
  `idPerson` BIGINT UNSIGNED NOT NULL,
  `valueName` VARCHAR(256) NOT NULL,
  `idRepresentative` INT(11) UNSIGNED NOT NULL COMMENT '法人代表id，此id应在NaturalPerson中',
  `valueCapital` VARCHAR(32) NULL COMMENT '注册资本',
  PRIMARY KEY (`idPerson`),
  INDEX `idRepresentative` (`idRepresentative` ASC),
  CONSTRAINT `fk_LegalPerson`
    FOREIGN KEY (`idPerson`)
    REFERENCES `BasePerson` (`idPerson`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
COMMENT='法人信息表';

CREATE TABLE IF NOT EXISTS `BaseCertificate` (
  `idCertificate` INT(11) UNSIGNED NOT NULL,
  `valueCertificate` VARCHAR(32) NOT NULL,
  `valueName` VARCHAR(256) NOT NULL,
  `idPerson` BIGINT UNSIGNED NOT NULL,
  INDEX `baseCertificate_INDEX` (`valueCertificate` ASC, `idCertificate` ASC, `valueName` ASC))
COMMENT='证件信息基本表';

CREATE TABLE IF NOT EXISTS `BaseAccount` (
  `idAccount` BIGINT UNSIGNED NOT NULL,
  `idClass` INT(11) UNSIGNED NOT NULL,
  PRIMARY KEY (`idAccount`))
COMMENT='帐号基本表';

CREATE TABLE IF NOT EXISTS `SecurityAccount` (
  `idAccount` BIGINT UNSIGNED NOT NULL,
  `idMarket` BIGINT UNSIGNED NOT NULL,
  `valueAccount` VARCHAR(32) NOT NULL,
  PRIMARY KEY (`idAccount`))
COMMENT = '证券账户表';

CREATE TABLE IF NOT EXISTS `RelationPersonAccount` (
  `RePersonAccount` BIGINT UNSIGNED NOT NULL,
  `idPerson` BIGINT  UNSIGNED NOT NULL,
  `idAccount` BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (`RePersonAccount`),
  INDEX `ReidPerson` (`idPerson` ASC),
  INDEX `ReidAccount` (`idAccount` ASC))
COMMENT='人员帐户关系表';

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

CREATE VIEW `NaturalPersonView` AS
  SELECT
    BP.idClass,
    NP.idPerson, NP.valueName, NP.idSex, NP.valueBirthday
  FROM
    NaturalPerson NP,
    BasePerson BP
  WHERE
    NP.idPerson = BP.idPerson;

CREATE VIEW `LegalPersonView` AS
  SELECT
    BP.idClass,
    LP.idPerson, LP.valueName, LP.idRepresentative, LP.valueCapital
  FROM
    LegalPerson LP,
    BasePerson BP
  WHERE
    LP.idPerson = BP.idPerson;

CREATE VIEW `SecurityAccountView` AS
  SELECT
    BA.idClass,
    SA.idAccount, SA.idMarket, SA.valueAccount
  FROM
    SecurityAccount SA,
    BaseAccount BA
  WHERE
    SA.idAccount = BA.idAccount;

INSERT INTO `SystemClass` (`idClass`, `valueClass`, `startClass`) VALUES
(1, '自然人类别', 0),
(2, '法人类别', 0),
(3, '产品持有类别', 0),
(1001, '证券帐户', 0),
(1002, '资金帐户', 0),
(1003, '银行帐户', 0),
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

INSERT INTO `SystemField` (`idField`, `descField`, `valueField`) VALUES
(100001, 'idSex', '男'),
(100002, 'idSex', '女'),
(200001, 'idCertificate', '身份证'),
(200002, 'idCertificate', '护照'),
(200101, 'idCertificate', '机构代码证'),
(200102, 'idCertificate', '税务登记号'),
(200103, 'idCertificate', '工商注册号'),
(300001, 'idMarket', '报价系统'),
(300002, 'idMarket', '场外一卡通');

DELIMITER $
CREATE PROCEDURE `AddPersonByIdentity` -- 身份证姓名，身份证号码
  (IN personname VARCHAR(256), IN personid VARCHAR(32))
BEGIN
  SET @sequ = uuid_short();
  INSERT INTO `BasePerson` (`idPerson`, `idClass`) 
    VALUES (@sequ, '1');
  INSERT INTO `BaseCertificate` (`idCertificate`, `valueCertificate`, `valueName`, `idPerson`)
    VALUES ('200001', personid, personname, @sequ);
  SET @sexid = CAST(SUBSTRING(personid, 17, 1) AS UNSIGNED);
  IF MOD(@sexid, 2) = 0 THEN
    SET @sexname = '100002';
  ELSE
    SET @sexname = '100001';
  END IF;
  SET @birth = CONCAT(SUBSTRING(personid, 7, 4), '-', SUBSTRING(personid, 11, 2), '-', SUBSTRING(personid, 13, 2));
  INSERT INTO `NaturalPerson` (`idPerson`, `valueName`, `idSex`, `valueBirthday`)
    VALUES (@sequ, personname, @sexname, @birth);
  SELECT 0, @sequ;  -- 0 for success
  COMMIT;
END $

DELIMITER $
CREATE PROCEDURE `GetPersonByIdentity` -- 身份证姓名，身份证号码
  (IN personname VARCHAR(256), IN personid VARCHAR(32))
BEGIN
  SELECT
    IF (personname = BC.valueName, 0, 1) AS result,
    BC.idPerson
  FROM
    BaseCertificate BC,
    NaturalPerson NP
  WHERE
    BC.idCertificate = '200001' AND
    BC.valueCertificate = personid AND
    BC.idPerson = NP.idPerson;
END $

DELIMITER $
CREATE PROCEDURE `AddLegalByCommerce` -- 法人名称，工商登记号号码, 法人ID, 注册资本
  (IN legalname VARCHAR(256), IN legalid VARCHAR(32), IN represenid BIGINT, IN capital BIGINT)
BEGIN
  SET @sequ = uuid_short();
  INSERT INTO `BasePerson` (`idPerson`, `idClass`) 
    VALUES (@sequ, '2');
  INSERT INTO `BaseCertificate` (`idCertificate`, `valueCertificate`, `valueName`, `idPerson`)
    VALUES ('200103', legalid, legalname, @sequ);
  INSERT INTO `LegalPerson` (`idPerson`, `valueName`, `idRepresentative`, `valueCapital`)
    VALUES (@sequ, legalname, represenid, capital);
  SELECT 0, @sequ;  -- 0 for success
  COMMIT;
END $

DELIMITER $
CREATE PROCEDURE `GetLegalByCommerce` -- 法人名称，工商登记号号码
  (IN personname VARCHAR(256), IN personid VARCHAR(32), IN foo1 BIGINT, IN foo2 BIGINT)
BEGIN
  SELECT
    IF (personname = BC.valueName, 0, 1) AS result,
    BC.idPerson
  FROM
    BaseCertificate BC,
    LegalPerson LP
  WHERE
    BC.idCertificate = '200103' AND
    BC.valueCertificate = personid AND
    BC.idPerson = LP.idPerson;
END $

DELIMITER $
CREATE PROCEDURE `AddAccountByOTC` -- 增加报价系统产品帐户
  (IN accountid VARCHAR(32))
BEGIN
  SET @sequ = uuid_short();
  INSERT INTO `BaseAccount` (`idAccount`, `idClass`) 
    VALUES (@sequ, '1001');
  INSERT INTO `SecurityAccount` (`idAccount`, `idMarket`, `valueAccount`)
    VALUES (@sequ, '300001', accountid);
  SELECT 0, @sequ;  -- 0 for success
  COMMIT;
END $

DELIMITER $
CREATE PROCEDURE `GetAccountByOTC` -- 报价系统产品帐户
  (IN accountid VARCHAR(32))
BEGIN
  SELECT
    0, BA.idAccount
  FROM
    BaseAccount BA,
    SecurityAccount SA
  WHERE
    SA.idMarket = '300001' AND
    BA.idAccount = SA.idAccount AND
    SA.valueAccount = accountid;
END $

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

DELIMITER $
CREATE PROCEDURE `QueryAccountByIdentiry`
  (IN personid VARCHAR(32))
BEGIN
  SELECT SA.idMarket, SA.valueAccount
  FROM `SecurityAccount` SA
  WHERE SA.idAccount IN (
    SELECT RPA.idAccount
    FROM `RelationPersonAccount` RPA, `BaseCertificate` BC
    WHERE RPA.idPerson = BC.idPerson AND BC.valueCertificate = personid );
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
