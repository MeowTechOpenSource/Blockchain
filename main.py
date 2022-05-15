from flask import Flask, jsonify,request,abort
from blockchain import Blockchain
import json
users = {}
blockchain = Blockchain()
blockchain.add_transaction('t1')
blockchain.add_transaction('t2')
blockchain.add_transaction('t3')

blockchain.mine()
blockchain.mine()
blockchain.mine()

app = Flask("app_name")


@app.route("/")
def homepage():
    return "<h1>Hello there~~~</h1>"


app = Flask("app_name")


@app.route("/")
def homepage():
    return "<h1>Hello there~~~</h1>"


@app.route("/chain")
def get_chain():
    chain_dict = {"chain": blockchain.chain}
    value = json.loads(json.dumps(chain_dict,
                                  default=lambda obj: obj.__dict__))
    value["length"] = len(value["chain"])
    return jsonify(value)
@app.route('/unmined_blocks')
@app.route("/unmined_chain")
def get_unmined_chain():
    chain_dict = {"unmined_chain": blockchain.unmined_chain}
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
    blockchain.add_transaction(tx)
    return {"value":"OK"}
@app.route('/mine')
def mine():
    um = blockchain.unmined_chain
    if not um:
        return {"value":"No unmined transactions"},200
    else:
        a = blockchain.mine()
        return {"value":"Ran","success":a}
@app.route('/create_user',methods=['POST'])
def create_user():
    data = request.get_json()
    req = ["username","password"]
    for r in req:
        if r not in data:
            return {'value':f'Missing field {r}'}, 400
    if data['username'] in users:
        return {"value":'User already exists'},400
    else:
        users[data['username']] = data['password']
        return {'value':"User created."}
@app.route('/login',methods=['POST'])
def login():
    data = request.get_json()
    req = ["username","password"]
    for r in req:
        if r not in data:
            return {'value':f'Missing field {r}'}, 400
    if data['username'] in users:
        return {'correct':users[data['username']] == data['password']}
    else:
        return {'value':"User not exists"}

app.run(host="0.0.0.0", port=8000,debug = True)
