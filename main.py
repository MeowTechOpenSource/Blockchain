from itertools import chain
from flask import Flask, jsonify,request,abort
from blockchain import Blockchain
import json

from server import FlaskServer
users = {}
blockchain = Blockchain()

server = FlaskServer(blockchain,users)#,debug=True)
server.run()