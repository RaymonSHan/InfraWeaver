# -*- coding:utf-8 -*-

import mysql.connector
from InfraCommon import *

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

  def ExecuteAdd(self, addproc, addpara):
    resultset =  self.Execute(addproc, addpara)
    if resultset == None:
      return (1, 0)  # first 1 for error in add
    else:
      return resultset
  def ExecuteGet(self, getproc, getpara):
    resultset = self.Execute(getproc, getpara)
    if resultset == None:
      return (0, 0)  # first 0 for success, second 0 for not found
    else:
      return resultset
  def ExecuteReturn(self, getproc, getpara, addproc, addpara):
    (result, personid) = self.ExecuteGet(getproc, getpara)
    if result == 0 and personid == 0:
      return self.ExecuteAdd(addproc, addpara)
    else:
      return (result, personid)

  def AddPersonByIdentity(self, valcert, valname):
    (valsex, valbirth) = AnalyzePersonIdentity(valcert, valname)
    addset = (200001, valcert, valname, valsex, valbirth)
    return self.ExecuteAdd("AddNaturalPerson", addset)
  def GetPersonByIdentity(self, valcert, valname):
    getset = (200001, valcert, valname)
    return self.ExecuteGet("GetPerson", getset)
  def ReturnPersonByIdentity(self, valcert, valname):
    (valsex, valbirth) = AnalyzePersonIdentity(valcert, valname)
    getset = (200001, valcert, valname)
    addset = (200001, valcert, valname, valsex, valbirth)
    return self.ExecuteReturn("GetPerson", getset, "AddNaturalPerson", addset)
# ABOVE FINISHED in Jan. 27 '15

class InfraDatabase_old(object):
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
