# -*- coding:utf-8 -*-

class InfraDatabase(object): 
  """This is Database connect and query"""
  ConnectString = ( user='root',password='',host='192.168.206.139',database='InfraWeaver')
  def __init__(self):
    self.ConnectSQL = mysql.connector.connect(self.ConnectString)
    print "aa"




  try:
    print "BEGIN"
    connectsql = mysql.connector.connect( user='root',password='',host='192.168.206.139',database='InfraWeaver')    
    cursorsql = connectsql.cursor()
    ids = "张三"
    vals = "123456201112312212"

    print "START"
    cursorsql.callproc('AddPersonByIdentity', (ids, vals))

    for cursorresult in cursorsql.stored_results():
      allresult = cursorresult.fetchall()
      for oneresult in allresult:
        for onefield in oneresult:
          print onefield

  except Exception as e:  
    print(e)
  finally:
    cursorsql.close()
    connectsql.close()
    print "END"

