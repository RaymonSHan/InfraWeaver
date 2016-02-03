# -*- coding:utf-8 -*-

import string
from InfraCommon import *
from InfraDatabase import InfraDatabase

if __name__ == '__main__':
#  infra = InfraDatabase('root', 'root', '127.0.0.1')
  infra = InfraDatabase('root', '', '192.168.206.139')

  print result, sequ

#### OKED
'''
  ## Feb. 02 `16
  vcert = "133322200011223299"
  vname = "王五"
  vacc = "006225588149"
  (result, sequ) = infra.AddAccountByIdentity(vcert, vname, vacc, ID_MARKET_INTEROTC, ID_TYPE_PRIMARY)
'''

#### REWRITE ONCE, STOPPED Feb. 02 `16
'''
  vcert = "113322200011223255"
  vname = "王五"
  result = infra.Execute("AddNaturalPerson", (200001, vcert, vname, 100001, "1999-11-22"))
  result = infra.AddPersonByIdentity( vcert, vname )
  result = infra.ReturnPersonByIdentity( vcert, vname )
# ABOVE FINISHED in Jan. 27 '16, for NaturalPerson

  vcert = "113322200011223255"
  vname = "王五"
  (result, sequ) = infra.GetPersonByIdentity( vcert, vname )
  vcert = "006225588135"
  vname = "中证技术"
  (result, sequ) = infra.AddLegalByCommerce(vcert, vname, sequ, 100000)
  (result, sequ) = infra.GetLegalByCommerce(vcert, vname)
# ABOVE FINISHED in Jan. 27 '16, for LegalPerson

  vacc = "008123456789"
  (result, sequ) = infra.AddSecurityAccountOTC(vacc)
  (result, sequ) = infra.ReturnSecurityAccountOTC(vacc)
# ABOVE FINISHED in Jan. 29 '16, for SecurityAccount

  vcert = "213322200011223255"
  vname = "赵六"
  vacc = "1008123456789"
  (result, sequ) = infra.AddPersonPrimaryAccount(vcert, vname, vacc)
  vacc = "1018123456789"
  (result, sequ) = infra.AddPersonSecondaryAccount(vcert, vname, vacc)
  vcert = "313322200011223255"
  vname = "牛七"
  (result, sequ) = infra.AddNominalPersonAccount(vcert, vname, vacc)
# ABOVE FINISHED in Feb. 01 '16, for SecurityAccount
'''

