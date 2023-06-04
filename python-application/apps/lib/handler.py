from config.config import DBNAME, DBUSER, DBPASS, DBHOST
from flask import jsonify
import psycopg2
import logging.config
from config.logs import logging_config
import random


logging.config.dictConfig(logging_config)

###CREATE TABLE IF NOT EXISTS users( id TEXT PRIMARY KEY     NOT NULL, name  TEXT  NOT NULL, email  TEXT  NOT NULL, dob  TIMESTAMP  NOT NULL);

def createuser(payload):
    log = logging.getLogger(__name__)
    data = payload.json
    try:
        _name = data['username']
        _email = data['email']
        _dob = data['dob']
        _id = str(random.getrandbits(32))
        if _name and _email and _dob and payload.method == "POST":
            conn = psycopg2.connect(database= DBNAME, user= DBUSER, password= DBPASS, host= DBHOST, port='5432')
            cursor = conn.cursor()
            sqlQuery = "INSERT into users(id,name, email, dob) VALUES(%s, %s, %s, %s)"
            bindData = (_id, _name, _email, _dob)            
            cursor.execute(sqlQuery, bindData)
            conn.commit()
            respone = jsonify('User added successfully!')
            respone.status_code = 200
            return respone
    except Exception as e:
        print(e)
    finally:
        if conn:
            cursor.close()
            conn.close()
            log.info("PostgreSQL connection is closed")
        
def deleteUser(id):
    log = logging.getLogger(__name__)
    try:
        conn = psycopg2.connect(database= DBNAME, user= DBUSER, password= DBPASS, host= DBHOST, port='5432')
        cursor = conn.cursor()
        sqlQuery = "DELETE FROM users WHERE id =%s"    
        cursor.execute(sqlQuery, (id,))
        conn.commit()
        respone = jsonify('User Deleted successfully!')
        respone.status_code = 200
        return respone
    except Exception as e:
        print(e)
    finally:
        if conn:
            cursor.close()
            conn.close()
            log.info("PostgreSQL connection is closed")

def updateUserInfo(payload):
    log = logging.getLogger(__name__)
    data = payload.json
    try:
        _id = data["id"]
        _name = data['username']
        _email = data['email']
        _dob = data['dob']
        if _id and _name and _email and _dob and payload.method == "PUT":
            conn = psycopg2.connect(database= DBNAME, user= DBUSER, password= DBPASS, host= DBHOST, port='5432')
            cursor = conn.cursor()
            sqlQuery = "UPDATE users SET name=%s, email=%s, dob=%s WHERE id=%s)"
            bindData = (_name, _email, _dob,_id)            
            cursor.execute(sqlQuery, bindData)
            conn.commit()
            respone = jsonify('User updated successfully!')
            respone.status_code = 200
            return respone
    except Exception as e:
        print(e)
    finally:
        if conn:
            cursor.close()
            conn.close()
            log.info("PostgreSQL connection is closed")

def getUser(payload):
    log = logging.getLogger(__name__)
    data = payload.json
    try:
        _name = data['username']
        _email = data['email']
        _dob = data['dob']
        if _name and _email and _dob and payload.method == "GET":
            conn = psycopg2.connect(database= DBNAME, user= DBUSER, password= DBPASS, host= DBHOST, port='5432')
            cursor = conn.cursor()
            sqlQuery = "INSERT INTO emp(name, email, phone, address) VALUES(%s, %s, %s, %s)"
            bindData = (_name, _email, _dob)            
            cursor.execute(sqlQuery, bindData)
            conn.commit()
            respone = jsonify('User added successfully!')
            respone.status_code = 200
            return respone
    except Exception as e:
        print(e)
    finally:
        if conn:
            cursor.close()
            conn.close()
            log.info("PostgreSQL connection is closed")

def getAllUserDetails():
    log = logging.getLogger(__name__)
    try:
        conn = psycopg2.connect(database= DBNAME, user= DBUSER, password= DBPASS, host= DBHOST, port='5432')
        cursor = conn.cursor()
        sqlQuery = "SELECT id, name, email , dob FROM users"         
        cursor.execute(sqlQuery)
        usersRows = cursor.fetchall()
        respone = jsonify(usersRows)
        respone.status_code = 200
        return respone
    except Exception as e:
        print(e)
    finally:
        if conn:
            cursor.close()
            conn.close()
            log.info("PostgreSQL connection is closed")

def getUserDetails(id):
    log = logging.getLogger(__name__)
    try:
        conn = psycopg2.connect(database= DBNAME, user= DBUSER, password= DBPASS, host= DBHOST, port='5432')
        cursor = conn.cursor()
        sqlQuery = "SELECT id, name, email , dob FROM users WHERE id =%s"         
        cursor.execute(sqlQuery,(id,))
        userRows = cursor.fetchone()
        respone = jsonify(userRows)
        respone.status_code = 200
        return respone
    except Exception as e:
        print(e)
    finally:
        if conn:
            cursor.close()
            conn.close()
            log.info("PostgreSQL connection is closed")