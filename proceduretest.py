# -*- coding:utf-8 -*-

from InfraDatabase import InfraDatabase

if __name__ == '__main__':
  infra = InfraDatabase('root', 'root', '127.0.0.1')
  
  ids = "李四"
  vals = "006225588123"
  result = infra.ReturnPersonByIdentity(vals)
  print result
  

