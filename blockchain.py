from time import time
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
            with open(UNMINED_DIR+os.sep+m, "r") as f:
                data = json.load(f)
            self.unmined_chain.append(
                Block(data["transaction"], data["nonce"], data["prev_hash"]))
        self.show()

    def create_genesis_block(self):
        self.add_transaction({"from":"_","to":"_","amount":0})
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
                with open(f"{UNMINED_DIR}{os.sep}{files}", "r") as f:
                    data = json.load(f)
                    if data['timestamp'] == block.timestamp:
                        os.remove(f"{UNMINED_DIR}{os.sep}{files}")
                        break
            print(f'Block #{len(self.chain)} added.')
            return True
        else:
            print('Incorrect proof.')
            return False

    def verify_proof(self, block: Block, proof: str) -> bool:
        return proof == block.compute_hash() and proof.startswith('0000')

    def add_transaction(self, tx: str,timestamp:float = 0):
        b = Block(tx, 0)
        b.timestamp = timestamp
        self.unmined_chain.append(b)
        with open(f"{UNMINED_DIR}{os.sep}{str(len(self.chain)+len(self.unmined_chain))}.json", "w") as f:
            f.write(json.dumps(b.__dict__))

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
    def replace_unmined_chain(self, unmined_chain:List[Block]):
        self.unmined_chain.clear()
        for files in os.listdir(UNMINED_DIR):
            os.remove(UNMINED_DIR+os.sep+files)
        for ub in unmined_chain:
            tx_data = ub['transaction']
            timestamp = ub['timestamp']
            self.add_transaction(tx_data,timestamp=timestamp)
            
