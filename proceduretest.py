# -*- coding:utf-8 -*-

import string
from InfraDatabase import InfraDatabase

if __name__ == '__main__':
#  infra = InfraDatabase('root', 'root', '127.0.0.1')
  infra = InfraDatabase('root', '', '192.168.206.139')

  vcert = "113322200011223255"
  vname = "王五"
  vals = "006225588135"

  print result

#### OKED
'''
  result = infra.Execute("AddNaturalPerson", (200001, vcert, vname, 100001, "1999-11-22"))
  result = infra.AddPersonByIdentity( vcert, vname )
  result = infra.ReturnPersonByIdentity( vcert, vname )

# ABOVE FINISHED in Jan. 27 '15
'''
  
#  resultv = infra.ReturnLegalByCommerce("中证技术", "110108019586020", psequ, 100000)
#  print resultv
