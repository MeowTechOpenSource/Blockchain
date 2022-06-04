import json
from flask import Flask, jsonify,request,abort
import os
import requests
from nodes import Nodes
USERDATADIR = "users"
class FlaskServer:
    def __init__(self,chain,users,port=8000,debug=False,host="0.0.0.0"):
        self.chain = chain
        self.users = users
        self.port = port
        self.debug = debug
        self.host = host
        self.nodes = Nodes()
        if not os.path.exists(USERDATADIR):
            os.mkdir(USERDATADIR)
        usersa = os.listdir(USERDATADIR)
        for user in usersa:
            with open(USERDATADIR+os.sep+user,'r') as f:
                d=json.load(f)
                self.users[d["username"]]=d["password"]
    def run(self):
        app = Flask("API")
        @app.before_first_request
        def init():
            self.nodes.root_url = request.root_url
            self.nodes.knock_peers()
        @app.route("/")
        def homepage():
            abort(503)

        @app.route("/chain")
        def get_chain():
            chain_dict = {"chain": self.chain.chain}
            value = json.loads(json.dumps(chain_dict,
                                        default=lambda obj: obj.__dict__))
            value["length"] = len(value["chain"])
            return jsonify(value)
        @app.route('/unmined_blocks')
        @app.route("/unmined_chain")
        def get_unmined_chain():
            chain_dict = {"unmined_chain": self.chain.unmined_chain}
            value = json.loads(json.dumps(chain_dict,
                                        default=lambda obj: obj.__dict__))
            value["length"] = len(value["unmined_chain"])
            return jsonify(value)
        @app.route('/new_transaction',methods=['POST'])
        def add_transaction():
            tx_data = request.get_json()
            req = ["from","to","amount"]#,"password"]
            for r in req:
                if r not in tx_data:
                    return {'value':f'Missing field {r}'}, 400
            # try:
            #     req["amount"] = float(req["amount"])
            # except Exception as e:
            #     print(e)
            #     return {'value':"amount not valid"}, 400
            tx = f"{tx_data['from']}, {tx_data['to']}, {tx_data['amount']}"
            self.chain.add_transaction(tx)
            return {"value":"OK"}
        @app.route('/mine')
        def mine():
            um = self.chain.unmined_chain
            if not um:
                return {"value":"No unmined transactions"},200
            else:
                a = self.chain.mine()
                return {"value":"Ran","success":a}
        @app.route('/create_user',methods=['POST'])
        def create_user():
            data = request.get_json()
            req = ["username","password"]
            for r in req:
                if r not in data:
                    return {'value':f'Missing field {r}'}, 400
            if data['username'] in self.users:
                return {"value":'User already exists'},400
            else:
                self.users[data['username']] = data['password']
                with open(f"users{os.sep}{data['username']}.json","w") as f:
                    f.write(json.dumps({"username":data["username"],"password":data["password"]}))
                return {'value':"User created."}
        @app.route('/login',methods=['POST'])
        def login():
            data = request.get_json()
            req = ["username","password"]
            for r in req:
                if r not in data:
                    return {'value':f'Missing field {r}'}, 400
            if data['username'] in self.users:
                return {'correct':self.users[data['username']] == data['password']}
            else:
                return {'value':"User does not exist."}
        @app.route('/peers')
        def peers():
            return jsonify({"peers":self.nodes.get_peers()})
        @app.route('/register_node',methods=['POST'])
        def regnode():
            if not request.get_json().get('node_address'):
                return jsonify({'value':'Missing node address','success':False})
            node_address = request.get_json().get('node_address')
            # TODO: Ping the node address.
            try:
                response = requests.get(node_address+"isblockchain")
            except Exception:
                response = "a"
            a = False
            if response != "a":
                if response.status_code == 200:
                    if response.text == jsonify({"isitblockchain":"yesitis","root_url":node_address}):
                        a = True
            if a:
                self.nodes.add_node(node_address)
            else:
                return jsonify({'value':'Node address not reachable','success':False})
            return jsonify({'success':True})
        @app.route('/isblockchain')
        def isblockchain():
            return jsonify({"isitblockchain":"yesitis","root_url":self.nodes.root_url})
        app.run(host=self.host, port=self.port,debug = self.debug)
