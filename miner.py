import requests

from block import Block
SERVER_URL = "http://localhost:8000/"
response = requests.get(SERVER_URL+"unmined_blocks")

unmined_blocks = response.json()['unmined blocks']
response = requests.get(SERVER_URL+"chain")
chain = response.json()['chain']

for i in range(len(unmined_blocks)):
    b = unmined_blocks[i]
    block = Block(b["transaction"], b["nonce"], b["prev_hash"])
    block.timestamp =  b["timestamp"]
    block.prev_hash = chain[-1]['hash']

    while not block.compute_hash().startswith('0000'):
        block.nonce += 1
    
    block.hash = ''

    resp = requests.post(SERVER_URL+"completemined", json={
        "from": "test",
        "data": block.__dict__
    })
    print(resp.content)
    chain.append(block.__dict__)





