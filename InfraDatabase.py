# -*- coding:utf-8 -*-

import mysql.connector

class InfraDatabase(object): 
  """This is Database connect and query"""
  
  def __init__(self, username, password, hostip):
    try:
      self.ConnectSQL = mysql.connector.connect(user=username, password=password, host=hostip, database='InfraWeaver')
    except Exception as e:  
      print(e)

  def __del__(self):
    try:
      self.ConnectSQL.close()
    except Exception as e:
      print(e)

  def GetCursor(self):
    return self.ConnectSQL.cursor()

  def Execute(self, procedure, parameter):
    try:
      executecursor = self.GetCursor()
      executecursor.callproc(procedure, parameter)
      for executeresult in executecursor.stored_results():
        result = executeresult.fetchone()
      executecursor.close()
      return result
    except Exception as e:
      print(e)
  def Query(self, procedure, parameter):
    try:
      executecursor = self.GetCursor()
      executecursor.callproc("Query"+procedure, parameter)
      result = []
      for executeresult in executecursor.stored_results():
        result.append( executeresult.fetchall() )
      executecursor.close()
      return result
    except Exception as e:
      print(e)

class InfraDatabase_old(object):
  def ExecuteAdd(self, procedure, parameter):
    return self.Execute("Add"+procedure, parameter)
  def ExecuteGet(self, procedure, parameter):
    resultset = self.Execute("Get"+procedure, parameter)
    if resultset == None:
      return (0, 0)
    else:
      return resultset
  def ExecuteReturn(self, procedure, parameter):
    (result, personid) = self.ExecuteGet(procedure, parameter)
    if result == 0 and personid == 0:
      return self.ExecuteAdd(procedure, parameter)
    else:
      return (result, personid)

  def AddPersonByIdentity(self, personname, personid):
    return self.ExecuteAdd("PersonByIdentity", (personname, personid))
  def GetPersonByIdentity(self, personname, personid):
    return self.ExecuteGet("PersonByIdentity", (personname, personid))
  def ReturnPersonByIdentity(self, personname, personid):
    return self.ExecuteReturn("PersonByIdentity", (personname, personid))

  def AddLegalByCommerce(self, legalname, legalid, represenid, capital):
    return self.ExecuteAdd("LegalByCommerce", (legalname, legalid, represenid, capital))
  def GetLegalByCommerce(self, legalname, legalid, represenid = 0, capital = 0):
    return self.ExecuteGet("LegalByCommerce", (legalname, legalid, represenid, capital))
  def ReturnLegalByCommerce(self, legalname, legalid, represenid, capital):
    return self.ExecuteReturn("LegalByCommerce", (legalname, legalid, represenid, capital))

  def AddAccountByOTC(self, accountid):
    return self.ExecuteAdd("AccountByOTC", (accountid,))
  def GetAccountByOTC(self, accountid):
    return self.ExecuteGet("AccountByOTC", (accountid,))
  def ReturnAccountByOTC(self, accountid):
    return self.ExecuteReturn("AccountByOTC", (accountid,))

  def AddRelationPersonAccount(self, personsequ, accountsequ):
    return self.ExecuteAdd("RelationPersonAccount", (personsequ, accountsequ))
  def GetRelationPersonAccount(self, personsequ, accountsequ):
    return self.ExecuteGet("RelationPersonAccount", (personsequ, accountsequ))
  def ReturnRelationPersonAccount(self, personsequ, accountsequ):
    return self.ExecuteReturn("RelationPersonAccount", (personsequ, accountsequ))

  def QueryAccountByIdentiry(self, personid):
    return self.Query("AccountByIdentiry", (personid,))

  def AddPersonAccountByIdentity(self, personname, personid, accountid):
    (result, personsequ) = self.ReturnPersonByIdentity(personname, personid)
    (result, accountsequ) = self.ReturnAccountByOTC(accountid)
    return self.ReturnRelationPersonAccount(personsequ, accountsequ)
