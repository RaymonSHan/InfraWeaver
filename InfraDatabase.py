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
      result = None
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
    resultset = self.Execute(addproc, addpara)
    if resultset == None:
      return RESULT_ERR  # first 1 for error in add
    else:
      return resultset
  def ExecuteGet(self, getproc, getpara):
    resultset = self.Execute(getproc, getpara)
    if resultset == None:
      return RESULT_NOTFOUND  # first 0 for success, second 0 for not found
    else:
      return resultset
  def ExecuteReturn(self, getproc, getpara, addproc, addpara):
    (result, returnid) = self.ExecuteGet(getproc, getpara)
    if result == 0 and returnid == 0:
      (result, returnid) = self.ExecuteAdd(addproc, addpara)
    return (result, returnid)

  def AddHolder(self, procper, paraper, proccert, paracert, procacc, paraacc):
    (resultc, sequcert) = self.ExecuteGet("GetBaseCertificate", paracert)
    if sequcert == 0:
      (resultc, sequcert) = self.ExecuteAdd(proccert, paracert)
      if resultc != 0:
        return RESULT_ERR
      (resultp, sequper) = self.ExecuteAdd(procper, paraper)
      if resultp != 0:
        return RESULT_ERR
    else:
      (resultp, sequper) = self.ExecuteGet("GetPersonBySequcert", (sequcert,))
      if resultp != 0 or sequper == 0:
        return RESULT_ERR
      print "sequper", sequper
    (resulta, sequacc) = self.ExecuteAdd(procacc, paraacc)
    if resulta != 0:
      return RESULT_ERR
    return self.ExecuteAdd("AddBaseHolder", (sequper, sequcert, sequacc))

  def AddAccountByIdentity(self, valcert, valname, valaccount, idmarket, idtype):
    paraper = AnalyzePersonIdentity(valcert, valname)
    paracert = (ID_CERTIFICATE_CARD, valcert, valname)
    paraacc = (idmarket, valaccount, idtype)
    return self.AddHolder("AddNaturalPerson", paraper, "AddIdentityCard", paracert, "AddSecurityAccount", paraacc)

  def AddPrivateProdureSimple(self, valname, valcode, idmarket, vallimit):
    addpara = (CLASS_PRIVATE_STOCK, valname, "", valcode, idmarket, 0, vallimit)
    return self.ExecuteAdd("AddPrivateProdure", addpara)

  def GetPrimaryHolderByIdentity(self, valcert, idmarket):
    getpara = (ID_CERTIFICATE_CARD, valcert, idmarket, "")
    return self.ExecuteGet("GetPrimaryHolderByCert", getpara)


  def AddOneDocument(self, sequuser, descdoc, signdoc, docdetails):
    addpara = (sequuser, descdoc, signdoc)
    (result, sequdoc) = self.ExecuteAdd("AddDocumentMain", addpara)
    if sequdoc == 0:
      return RESULT_ERR
    orderdoc = 0
    for onedetail in docdetails:
      (sequhold, sequprod, tabname, fiename, deltabal) = onedetail
      getpara = (sequhold, sequprod, tabname, fiename)
      (result, bal) = self.ExecuteGet("GetBalance", getpara)
      detailpara = (sequdoc, orderdoc, sequhold, sequprod, tabname, fiename, deltabal, bal)
      resultdetail = self.Execute("ReplaceDocumentDetail", detailpara)
      if resultdetail == None:
        return RESULT_ERR
      orderdoc += 1
