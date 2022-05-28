import json
from flask import Flask, jsonify,request,abort
import os
USERDATADIR = "users"
class FlaskServer:
    def __init__(self,chain,users,port=8000,debug=False,host="0.0.0.0"):
        self.chain = chain
        self.users = users
        self.port = port
        self.debug = debug
        self.host = host
        if not os.path.exists(USERDATADIR):
            os.mkdir(USERDATADIR)
        usersa = os.listdir(USERDATADIR)
        for user in usersa:
            with open(USERDATADIR+os.sep+user,'r') as f:
                d=json.load(f)
                self.users[d["username"]]=d["password"]
    def run(self):
        app = Flask("API")
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
                return {'value':"User not exists"}

        app.run(host=self.host, port=self.port,debug = self.debug)
