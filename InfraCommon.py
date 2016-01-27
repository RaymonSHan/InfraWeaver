# -*- coding:utf-8 -*-

import string

def AnalyzePersonIdentity(valcert, valname):
  if string.atoi(valcert[16:17]) % 2 == 0:
    valsex = 100002
  else:
    valsex = 100001
  valbirth = '-'.join((valcert[6:10], valcert[10:12], valcert[12:14]))
  return (valsex, valbirth)
