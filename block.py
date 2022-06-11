
import hashlib
import time

class Block:
    def __init__(self, transaction: dict, nonce: int, prev_hash: str = "0"):
        self.transaction = transaction
        self.nonce = nonce 
        self.timestamp = time.time()
        self.prev_hash = prev_hash
        self.hash = ""

    def compute_hash(self):
        block_bytes = str(self.__dict__).encode()
        block_hash = hashlib.sha256(block_bytes).hexdigest()
        return block_hash