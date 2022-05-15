import sqlite3
import json, os, random, string
import ast
class AccountService:
    def __init__(self):
        self.conn =sqlite3.connect('database\\database.sql', check_same_thread=False)
        self.cursor = self.conn.cursor()
        with open("permission.json") as f:
            self.apis=json.loads(f.read())
    def checkuser(self,username,password):
        hasher=Hashing()
        sqlstr='select * from users'
        self.cur=self.conn.execute(sqlstr)
        rows=self.cur.fetchall()
        cor=False
        for row in rows:
            if hasher.check(password,row[1]) and username == row[0]:
                cor=True
                return [True,row]
            if hasher.check(password,row[1]) and username == row[2]:
                cor=True
                return [True,row]
        if not cor:
            return [False]
    def checkuserexists(self,username):
        hasher=Hashing()
        sqlstr='select * from users'
        self.cur=self.conn.execute(sqlstr)
        rows=self.cur.fetchall()
        cor=False
        for row in rows:
            if username == row[0]:
                cor=True
                return True
        if not cor:
            return False
    def adduser(self,username,password):
        hasher=Hashing()
        sqlstr='select * from users'
        self.cur=self.conn.execute(sqlstr)
        rows=self.cur.fetchall()
        for row in rows:
            if username == row[0]:
                exist=True
                return "Exist"
        sqlstr=f'insert into users values ("{username}","{password}",)'
        #print(sqlstr)
        self.conn.execute(sqlstr)
        self.conn.commit()
        return "OK"
    