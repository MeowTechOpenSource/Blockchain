import time
from typing import List
from block import Block
import os
import json
MINE_DIR = "mined"
UNMINED_DIR = "unmined"


class Blockchain:
    def __init__(self):
        self.chain: List[Block] = []
        self.unmined_chain: List[Block] = []
        self.failed_rm = []
        # self.create_genesis_block()
        if not os.path.exists(MINE_DIR) and not os.path.exists("unmined"):
            os.mkdir(MINE_DIR)
            os.mkdir(UNMINED_DIR)
            self.create_genesis_block()

        def sort_file(s):
            return int(s.split('.')[0])
        mined = sorted(os.listdir(MINE_DIR), key=sort_file)
        unmined = sorted(os.listdir(UNMINED_DIR), key=sort_file)
        for m in mined:
            with open(MINE_DIR+os.sep+m, "r") as f:
                data = json.load(f)
                block = Block(data["transaction"],
                              data["nonce"], data["prev_hash"])
                block.timestamp = data["timestamp"]
                proof = data['hash']
                self.add_block(block, proof)
        for m in unmined:
            try:
                with open(UNMINED_DIR+os.sep+m, "r") as f:
                    data = json.load(f)
                    b = Block(data["transaction"], data["nonce"], data["prev_hash"])
                    b.timestamp = data["timestamp"]
                    self.unmined_chain.append(b)
            except Exception as e:
                print(e)
        # self.show()
        for b in self.unmined_chain:
            print(b.timestamp)
        print("Intialized Blockchain Object.")

    def create_genesis_block(self):
        self.add_transaction({"from": "_", "to": "_", "amount": 0})
        self.mine(genesis_block=True)

    def add_block(self, block: Block, proof: str) -> bool:
        if self.verify_proof(block, proof):
            block.hash = proof
            self.chain.append(block)
            with open(f"{MINE_DIR}{os.sep}0000{str(len(self.chain))}.json", "w") as f:
                f.write(json.dumps(block.__dict__))
            # if block in self.unmined_chain:
            #     self.unmined_chain.remove(block)
            #     os.remove(f"{UNMINED_DIR}{os.sep}{str(len(self.chain))}.json")
            for ub in self.unmined_chain:
                if block.timestamp == ub.timestamp:
                    self.unmined_chain.remove(block)
                    break
            for files in os.listdir(UNMINED_DIR):
                f = open(f"{UNMINED_DIR}{os.sep}{files}", "r")
                data = json.load(f)
                f.close()
                if data['timestamp'] == block.timestamp:
                    try:
                        os.remove(f"{UNMINED_DIR}{os.sep}{files}")
                    except Exception:
                        self.failed_rm.append(
                            f"{UNMINED_DIR}{os.sep}{files}")
                        print("This Failed")
                    break

            # # Try Failed Again
            # for u in self.failed_rm:
            #     try:
            #         os.remove(u)
            #         self.failed_rm.remove(u)
            #     except Exception:
            #         pass
            # print(f'Block #{len(self.chain)} added.')
            return True
        else:
            print('Incorrect proof.')
            return False

    def verify_proof(self, block: Block, proof: str) -> bool:
        return proof == block.compute_hash() and proof.startswith('0000')

    def add_transaction(self, tx: str, timestamp: float = time.time()):
        b = Block(tx, 0)
        b.timestamp = timestamp
        self.unmined_chain.append(b)
        with open(f"{UNMINED_DIR}{os.sep}{str(len(self.chain)+len(self.unmined_chain))}.json", "w") as f:
            f.write(json.dumps(b.__dict__))

    def checkmine(self, nonce):
        b = self.unmined_chain[0]
        b.prev_hash = self.chain[-1].hash

        b.nonce = nonce
        print(b.__dict__)
        proof = b.compute_hash()
        print(proof)
        print('verify: ', self.verify_proof(b, proof))
        if self.verify_proof(b, proof):
            return self.add_block(b, proof)
        else:
            return False

    def mine(self, genesis_block=False):
        if not self.unmined_chain:
            return "No transaction to mine..."

        b = self.unmined_chain[0]
        if not genesis_block:
            b.prev_hash = self.chain[-1].hash

        proof = b.compute_hash()
        while not self.verify_proof(b, proof):
            b.nonce += 1
            proof = b.compute_hash()

        return self.add_block(b, proof)

    def show(self):
        print('+---------------------')
        for b in self.chain:
            print(b.__dict__)
        print('+---------------------')

    def replace_chain(self, chain: List[Block], hashes: List[str]):
        self.chain.clear()
        for i in range(len(chain)):
            self.add_block(chain[i], hashes[i])

    def replace_unmined_chain(self, unmined_chain: List[Block]):
        self.unmined_chain.clear()
        for files in os.listdir(UNMINED_DIR):
            os.remove(UNMINED_DIR+os.sep+files)
        for ub in unmined_chain:
            tx_data = ub['transaction']
            timestamp = ub['timestamp']
            self.add_transaction(tx_data, timestamp=timestamp)



'''miner.py
{'transaction': {'amount': 12300, 'from': '_', 'to': 'a'}, 'nonce': 20241, 'timestamp': 1654913762.0673869, 'prev_hash': '000065e6262a9321dd3bfe2b5c9546bb42208925974fa5751b1a28e0f7c7ba5a', 'hash': ''}
'''


'''blockchain.py
{'transaction': {'from': '_', 'to': 'a', 'amount': 12300}, 'nonce': 6878, 'timestamp': 1654913762.0673869, 'prev_hash': '000065e6262a9321dd3bfe2b5c9546bb42208925974fa5751b1a28e0f7c7ba5a', 'hash': ''}
'''