
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
-- ABOVE FINISHED in Jan. 27 '15, for NaturalPerson

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
-- ABOVE FINISHED in Jan. 27 '15, for LegalPerson

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
  (300002, 'idMarket', '场外一卡通'),
  (400001, 'idAccountType', '个人主帐号'),
  (400002, 'idAccountType', '个人附加帐号');

CREATE TABLE IF NOT EXISTS `BaseAccount` (
  `sequAccount` BIGINT UNSIGNED NOT NULL,
  `idClass` INT(11) UNSIGNED NOT NULL,
  `idMarket` INT(11) UNSIGNED NOT NULL,
  `valueAccount` VARCHAR(32) NOT NULL,
  PRIMARY KEY (`sequAccount`))
COMMENT='帐号基本表';

CREATE TABLE IF NOT EXISTS `SecurityAccount` (
  `sequAccount` BIGINT UNSIGNED NOT NULL,
  `idAccountType` INT(11) UNSIGNED NOT NULL,
  PRIMARY KEY (`sequAccount`))
COMMENT='证券账户表';

CREATE VIEW `SecurityAccountView` AS
  SELECT
    BA.idClass, SA.idAccountType,
    SA.sequAccount, BA.idMarket, BA.valueAccount
  FROM
    SecurityAccount SA,
    BaseAccount BA
  WHERE
    SA.sequAccount = BA.sequAccount;





DELIMITER $
CREATE PROCEDURE `__AddBaseAccount` (
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



'''
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
'''

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
