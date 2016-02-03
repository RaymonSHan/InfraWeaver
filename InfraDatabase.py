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
    except Exception as e:
      print(e)
    finally:
      executecursor.close()
    return result
  def Query(self, procedure, parameter):
    try:
      executecursor = self.GetCursor()
      executecursor.callproc(procedure, parameter)
      result = []
      for executeresult in executecursor.stored_results():
        result.append( executeresult.fetchall() )
    except Exception as e:
      print(e)
    finally:
      executecursor.close()
    return result

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

  def AddHolder(self, procper, paraper, proccert, paracert, procacc, paraacc):
    (resultp, sequper) = self.ExecuteAdd(procper, paraper)
    (resultc, sequcert) = self.ExecuteAdd(proccert, paracert)
    (resulta, sequacc) = self.ExecuteAdd(procacc, paraacc)
    if resultp + resultc + resulta == 0:
      return self.ExecuteAdd("AddBaseHolder", (sequper, sequcert, sequacc))
    else:
      return (1, 0)

  def AddAccountByIdentity(self, valcert, valname, valaccount, idmarket, idtype):
    paraper = AnalyzePersonIdentity(valcert, valname)
    paracert = (valcert, valname)
    paraacc = (idmarket, valaccount, idtype)
    return self.AddHolder("AddNaturalPerson", paraper, "AddIdentityCard", paracert, "AddSecurityAccount", paraacc)
# STEP 04, first python procedure, Feb. 03 '16
