import json
import threading
from urllib import response
from flask import Flask, jsonify, request, abort
import os
import requests
from block import Block
from nodes import Nodes
from typing import List
from block import Block

USERDATADIR = "users"


class FlaskServer:
    def __init__(self, chain, users, port=8000, debug=False, host="0.0.0.0"):
        self.chain = chain
        self.users = users
        self.port = port
        self.debug = debug
        self.host = host
        self.nodes = Nodes()
        self.inited = False
        if not os.path.exists(USERDATADIR):
            os.mkdir(USERDATADIR)
        usersa = os.listdir(USERDATADIR)
        for user in usersa:
            with open(USERDATADIR+os.sep+user, 'r') as f:
                d = json.load(f)
                self.users[d["username"]] = d["password"]

    def announce(self):
        for node in self.nodes.peers:
            if node == self.nodes.root_url:
                continue
            try:
                response = request.post(node + '/update_chain')
            except Exception:
                self.nodes.failed_peers.add(node)

    def run(self):
        app = Flask("API")

        @app.before_first_request
        def init():
            self.nodes.root_url = request.root_url
            self.nodes.knock_peers()
            self.consensus()

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

        @app.route('/get_balance', methods=['POST'])
        def get_balance():
            required_fields = ['username', 'password']
            for r in required_fields:
                if r not in request.get_json():
                    return {"value": f"Missing field {r}"}, 400
            data = request.get_json()
            if data['username'] in self.users:
                if data['password'] != self.users[data['username']]:
                    return {"value": "The password is incorrect."}, 400
                balance = 0
                for block in self.chain.chain:
                    tx = block.transaction
                    if tx["from"] == data['username']:
                        balance -= tx['amount']
                    elif tx["to"] == data['username']:
                        balance += tx['amount']
                return {'balance': balance}, 200
            else:
                return {'value': "User does not exist."}, 400

        @app.route('/unmined_blocks')
        def get_unmined_chain():
            return json.dumps({"unmined blocks" : self.chain.unmined_chain, "length": len(self.chain.unmined_chain)},default=lambda obj: obj.__dict__)

        @app.route('/new_transaction', methods=['POST'])
        def add_transaction():
            self.consensus()
            tx_data = request.get_json()
            req = ["from", "to", "amount", "password"]
            for r in req:
                if r not in tx_data:
                    return {'value': f'Missing field {r}'}, 400
            try:
                float(tx_data["amount"])
                pass
            except Exception as e:
                print('add_transaction', e)
                return {'value': "amount not valid"}, 400
            # tx = f"{tx_data['from']}, {tx_data['to']}, {tx_data['amount']}"

            if tx_data["from"] != '_':
                response = requests.post(f"http://localhost:{self.port}/get_balance", json={
                                         'username': tx_data["from"], 'password': tx_data["password"]})
                if response.status_code == 200:
                    balance = response.json()["balance"]
                    balance -= tx_data["amount"]
                    if balance < 0:
                        return jsonify({"value": "Failed:Not enough balance."}), 400
                    for ub in self.chain.unmined_chain:
                        tx = ub.transaction
                        if tx_data["from"] == tx["from"]:
                            if balance >= tx_data["amount"]:
                                balance -= tx_data["amount"]
                            else:
                                return jsonify({"value": "Failed:Not enough balance."}), 400
                        # Check To
                else:
                    return jsonify({"value": "Failed:Could not get balance."}), 400
            print(self.users)
            if tx_data["to"] in self.users:
                if not self.users[tx_data["from"]] == tx_data["password"]:
                    return jsonify({"value": "Password incorrect"}), 400
            else:
                return jsonify({"value": "User does not exists"}), 400
            del tx_data["password"]

            self.chain.add_transaction(tx_data)
            self.announce()
            return {"value": "OK"}

        @app.route('/completemined', methods=['POST'])
        def completemine():
            tx_data = request.get_json()
            req = ["from", "data"]
            for r in req:
                if r not in tx_data:
                    return {'value': f'Missing field {r}'}, 400
            if tx_data["from"] not in self.users:
                return jsonify({"value": "User does not exists"}), 400
            else:
                a = self.chain.checkmine(tx_data["data"]["nonce"])
                if a:
                    self.announce()
                    return {"value": "Mined Successful"}, 200
                else:
                    return {"value": "Mined Unsuccessful"}, 400
        # @app.route('/mine')
        # def mine():
        #     um = self.chain.unmined_chain
        #     if not um:
        #         return {"value":"No unmined transactions"},200
        #     else:
        #         a = self.chain.mine()
        #         if a:
        #             self.announce()
        #         return {"value":"Ran","success":a}

        @app.route('/create_user', methods=['POST'])
        def create_user():
            data = request.get_json()
            req = ["username", "password"]
            for r in req:
                if r not in data:
                    return {'value': f'Missing field {r}'}, 400
            if data['username'] in self.users:
                return {"value": 'User already exists'}, 400
            else:
                self.users[data['username']] = data['password']
                with open(f"users{os.sep}{data['username']}.json", "w") as f:
                    f.write(json.dumps(
                        {"username": data["username"], "password": data["password"]}))
                return {'value': "User created."}

        @app.route('/login', methods=['POST'])
        def login():
            data = request.get_json()
            req = ["username", "password"]
            for r in req:
                if r not in data:
                    return {'value': f'Missing field {r}'}, 400
            if data['username'] in self.users:
                a = self.users[data['username']] == data['password']
                if not a:
                    code = 400
                else:
                    code = 200
                return {'correct': a}, code
            else:
                return {'value': "User does not exist."}, 400

        @app.route('/peers')
        def peers():
            return jsonify({"peers": self.nodes.get_peers()})

        @app.route('/register_node', methods=['POST'])
        def regnode():
            if not request.get_json().get('node_address'):
                return jsonify({'value': 'Missing node address', 'success': False})
            node_address = request.get_json().get('node_address')
            # TODO: Ping the node address.
            try:
                response = requests.get(node_address+"isblockchain")
            except Exception:
                response = "a"
            a = False
            if response != "a":
                if response.status_code == 200:
                    if response.text == jsonify({"isitblockchain": "yesitis", "root_url": node_address}):
                        a = True
            if a:
                self.nodes.add_node(node_address)
            else:
                return jsonify({'value': 'Node address not reachable', 'success': False})
            return jsonify({'success': True})

        @app.route('/isblockchain')
        def isblockchain():
            return jsonify({"isitblockchain": "yesitis", "root_url": self.nodes.root_url})

        app.run(host=self.host, port=self.port, debug=self.debug)

    def consensus(self):
        for node in self.nodes.peers:
            if node == self.nodes.root_url:
                continue
            if True:
                try:
                    response = requests.get(node + 'chain', timeout=5)
                    if response.status_code == 200:
                        peer_json = response.json()

                        if peer_json['length'] >= len(self.chain.chain):
                            dicts = peer_json['chain']
                            new_blocks: List[Block] = []
                            new_hashes: List[str] = []

                            prev_hash = '0'
                            valid_chain = True

                            for dict in dicts:
                                block = Block(transaction=dict['transaction'], nonce=dict['nonce'],
                                              prev_hash=dict['prev_hash'])
                                block.timestamp = dict['timestamp']

                                # check validity of the chain:
                                if prev_hash != block.prev_hash and dict['hash'] != block.compute_hash():
                                    valid_chain = False
                                    break

                                new_blocks.append(block)
                                new_hashes.append(dict['hash'])
                                prev_hash = dict['hash']

                            if valid_chain:
                                self.chain.replace_chain(
                                    new_blocks, new_hashes)
                                response = requests.get(
                                    node + 'unmined_blocks')
                                if response.status_code == 200:
                                    ub_json = response.json()
                                    ub = ub_json['unmined blocks']
                                if len(self.chain.chain) < peer_json['length']:
                                    self.chain.replace_unmined_chain(ub)
                                else:
                                    if len(self.chain.unmined_chain) < len(ub):
                                        self.chain.replace_unmined_chain(ub)
                                break
                        else:
                            # TODO: Check if both chains are identical
                            pass
                except Exception as e:
                    print("Exception", e)

                # except Exception as e:
            #     print("Exception: ", e)
            #     self.nodes.failed_peers.add(node)
            self.inited = True
