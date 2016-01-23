# -*- coding:utf-8 -*-

from InfraDatabase import InfraDatabase

if __name__ == '__main__':
  infra = InfraDatabase('root', 'root', '127.0.0.1')
  
  ids = "李四"
  pid = "443322200011223215"
  vals = "006225588130"
#  result = infra.AddPersonAccountByIdentity(ids, pid, vals)
  
  result = infra.QueryAccountByIdentiry(pid)

  print result
  

