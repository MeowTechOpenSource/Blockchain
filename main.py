from blockchain import Blockchain

from server import FlaskServer
users = {}
blockchain = Blockchain()

server = FlaskServer(blockchain,users,debug=True)
server.run()