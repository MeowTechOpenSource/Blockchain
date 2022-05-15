from typing import List
from block import Block
import os
import json
class Blockchain:
    def __init__(self):
        self.chain: List[Block] = []
        self.unmined_chain: List[Block] = [] 
        # self.create_genesis_block()
        if not os.path.exists("mined") and not os.path.exists("unmined"):
            os.mkdir("mined")
            os.mkdir("unmined")
            self.create_genesis_block()
        mined = os.listdir("mined")
        unmined = os.listdir("unmined")
        for m in mined:
            with open("mined/"+m,"r") as f:
                data = json.load(f)
            self.chain.append(Block(data["transaction"],data["nonce"],data["prev_hash"]))
        for m in unmined:
            with open("unmined/"+m,"r") as f:
                data = json.load(f)
            self.unmined_chain.append(Block(data["transaction"],data["nonce"],data["prev_hash"]))
        self.show()
    def create_genesis_block(self):
        self.add_transaction("genesis block")
        self.mine(genesis_block=True)
    
    def add_block(self, block: Block, proof: str) -> bool:
        if self.verify_proof(block, proof):
            block.hash = proof
            self.chain.append(block)
            with open(f"mined/0000{str(len(self.chain))}.json","w") as f:
                f.write(json.dumps(block.__dict__))
            self.unmined_chain.remove(block)
            os.remove(f"unmined/{str(len(self.chain))}.json")
            print(f'Block #{len(self.chain)} added.')
            return True
        else:
            print('Incorrect proof.')
            return False

    
    
    def verify_proof(self, block: Block, proof: str) -> bool:
        return proof == block.compute_hash() and proof.startswith('0000')


    def add_transaction(self, tx: str):
        b = Block(tx, 0)
        self.unmined_chain.append(b)
        with open(f"unmined/{str(len(self.chain)+len(self.unmined_chain))}.json","w") as f:
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
