# -*- coding:utf-8 -*-

import string
from InfraDatabase import InfraDatabase

if __name__ == '__main__':
#  infra = InfraDatabase('root', 'root', '127.0.0.1')
  infra = InfraDatabase('root', '', '192.168.206.139')

  vcert = "006225588135"
  vname = "中证技术"


  print result, sequ

#### OKED
'''
  vcert = "113322200011223255"
  vname = "王五"
  result = infra.Execute("AddNaturalPerson", (200001, vcert, vname, 100001, "1999-11-22"))
  result = infra.AddPersonByIdentity( vcert, vname )
  result = infra.ReturnPersonByIdentity( vcert, vname )
# ABOVE FINISHED in Jan. 27 '15, for NaturalPerson

  vcert = "113322200011223255"
  vname = "王五"
  (result, sequ) = infra.GetPersonByIdentity( vcert, vname )
  print result, sequ
  vcert = "006225588135"
  vname = "中证技术"
  (result, sequ) = infra.AddLegalByCommerce(vcert, vname, sequ, 100000)
  (result, sequ) = infra.GetLegalByCommerce(vcert, vname)
# ABOVE FINISHED in Jan. 27 '15, for LegalPerson
'''
 

#  print resultv
