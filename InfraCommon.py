# -*- coding:utf-8 -*-

import string

CLASS_NATURAL_PERSON            = 1
CLASS_LEGAL_PERSON              = 2
CLASS_PROCEDURE_PERSON          = 3

CLASS_SECURITY_ACCOUNT          = 1001
CLASS_FONDING_ACCOUNT           = 1002
CLASS_BANK_ACCOUNT              = 1003

ID_SEX_MALE                     = 100001
ID_SEX_FEMALE                   = 100002

ID_CERTIFICATE_CARD             = 200001
ID_CERTIFICATE_PASSPORT         = 200002
ID_CERTIFICATE_ORGANIZATION     = 200101
ID_CERTIFICATE_TAX              = 200102
ID_CERTIFICATE_COMMERCIAL       = 200103

ID_MARKET_INTEROTC              = 300001
ID_MARKET_OTCCOMMON             = 300002

def AnalyzePersonIdentity(valcert, valname):
  if string.atoi(valcert[16:17]) % 2 == 0:
    valsex = 100002
  else:
    valsex = 100001
  valbirth = '-'.join((valcert[6:10], valcert[10:12], valcert[12:14]))
  return (valsex, valbirth)
