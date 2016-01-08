# -*- coding:utf-8 -*-

import mysql.connector

if __name__ == '__main__':
    try:
	print "BEGIN"
        connectsql = mysql.connector.connect( user='root',password='',host='192.168.206.139',database='zzjs_main')    
        cursorsql = connectsql.cursor()
	ids = 1
	vals = 2

	print "START"
	cursorsql.callproc('getvalueinto3', (ids, vals))

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


