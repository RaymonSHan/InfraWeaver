# -*- coding:utf-8 -*-

from InfraDatabase import InfraDatabase

if __name__ == '__main__':
#  infra = InfraDatabase('root', 'root', '127.0.0.1')
  infra = InfraDatabase('root', '', '192.168.206.139')

  vcert = "443322200011223255"
  vname = "李五"
  vals = "006225588135"
  result = infra.Execute("AddPersonByIdentity", (vcert, vname))

  print result

#  '110108019586020'
#  result = infra.QueryAccountByIdentiry(pid)
#  result = infra.AddLegalByCommerce

#  print result, psequ
  
#  resultv = infra.ReturnLegalByCommerce("中证技术", "110108019586020", psequ, 100000)
#  print resultv
