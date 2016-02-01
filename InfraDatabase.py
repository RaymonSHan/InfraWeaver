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
      executecursor.callproc(procedure, parameter)
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
# ABOVE FINISHED in Jan. 27 '16, for NaturalPerson

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
# ABOVE FINISHED in Jan. 27 '16, for LegalPerson

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
# ABOVE FINISHED in Jan. 29 '16, for SecurityAccount

  def AddPersonAccount(self, sequper, sequacc, idtype):
    addset = (sequper, sequacc, idtype)
    return self.ExecuteAdd("AddPersonAccount", addset)
  def GetPersonAccount(self, sequper, sequacc, idtype):
    getset = (sequper, sequacc, idtype)
    return self.ExecuteGet("GetPersonAccount", getset)
  def ReturnPersonAccount(self, sequper, sequacc, idtype):
    addset = (sequper, sequacc, idtype)
    getset = (sequper, sequacc, idtype)
    return self.ExecuteReturn("GetPersonAccount", getset, "AddPersonAccount", addset)

  def AddPersonPrimaryAccount(self, valcert, valname, valaccount): # by Identiry and OTC account
    (result, sequper) = self.ReturnPersonByIdentity(valcert, valname)
    if result == 1:
      return (1, 0)
    (result, sequacc) = self.ReturnSecurityAccountOTC(valaccount)
    if result == 1:
      return (1, 0)
    return self.ReturnPersonAccount(sequper, sequacc, 400001)
  def AddPersonSecondaryAccount(self, valcert, valname, valaccount): # by Identiry and OTC account
    (result, sequper) = self.GetPersonByIdentity(valcert, valname)
    if result != 0 or sequper == 0:
      return (1, 0)
    (result, sequacc) = self.ReturnSecurityAccountOTC(valaccount)
    if result == 1:
      return (1, 0)
    return self.ReturnPersonAccount(sequper, sequacc, 400002)
  def AddNominalPersonAccount(self, valcert, valname, valaccount):
    (result, sequper) = self.ReturnPersonByIdentity(valcert, valname)
    if result == 1:
      return (1, 0)
    (result, sequacc) = self.GetSecurityAccountOTC(valaccount)
    if result == 1:
      return (1, 0)
    return self.ReturnPersonAccount(sequper, sequacc, 400003)

  def QueryPersonAccount(self, valcert): # by Identiry and OTC account
    queryset = (200001, valcert)
    result = self.Query("QueryAccountByIdentiry", queryset)
    return result[0]
# ABOVE FINISHED in Feb. 01 '16, for SecurityAccount




class InfraDatabase_old(object):
  def QueryAccountByIdentiry(self, personid):
    return self.Query("AccountByIdentiry", (personid,))

