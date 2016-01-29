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
# ABOVE FINISHED in Jan. 27 '15, for NaturalPerson

  def AddLegalByCommerce(self, valcert, valname, sequrepr, valcapital):
    addset = (200103, valcert, valname, sequrepr, valcapital)
    return self.ExecuteAdd("AddLegalPerson", addset)
  def GetLegalByCommerce(self, valcert, valname):
    getset = (200103, valcert, valname)
    return self.ExecuteGet("GetPerson", getset)
  def ReturnLegalByCommerce(self, valcert, valname, sequrepr, valcapital):
    getset = (200103, valcert, valname)
    addset = (200103, valcert, valname, sequrepr, valcapital)
    return self.ExecuteReturn("GetPerson", getset, "AddLegalPerson", addset)
# ABOVE FINISHED in Jan. 27 '15, for LegalPerson

  def AddSecurityAccountOTC(self, valaccount):
    addset = (300001, valaccount)
    return self.ExecuteAdd("AddSecurityAccount", addset)
  def GetSecurityAccountOTC(self, valaccount):
    getset = (300001, valaccount)
    return self.ExecuteGet("GetSecurityAccount", getset)
  def ReturnSecurityAccountOTC(self, valaccount):
    getset = (300001, valaccount)
    addset = (300001, valaccount)
    return self.ExecuteReturn("GetSecurityAccount", getset, "AddSecurityAccount", addset)
# ABOVE FINISHED in Jan. 29 '15, for SecurityAccount

class InfraDatabase_old(object):
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
