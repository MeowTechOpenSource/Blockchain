import hashlib
import re
import requests
import json
SERVER_URL = "http://localhost:8000/"
response = requests.get(SERVER_URL+"unmined_chain")
unmined_blocks = response.json()['unmined blocks']
response = requests.get(SERVER_URL+"chain")
chain = response.json()['chain']
desired_order_list = ["transaction","nonce","timestamp","prev_hash","hash"]
desired_order_list2 = ["from","to","amount"]
def compute_hash(block):
    block_bytes = str(block).encode()
    block_hash = hashlib.sha256(block_bytes).hexdigest()
    return block_hash
for b in unmined_blocks:
    org = b
    b["prev_hash"] = chain[-1]["hash"]
    b = {k: b[k] for k in desired_order_list}
    b["transaction"] = {k: b["transaction"][k] for k in desired_order_list2}
    while True:
        # response = requests.get(SERVER_URL+"chain")
        # chain = response.json()['chain']
        tmp = org
        tmp['nonce'] = chain[-1]["nonce"]
        tmp["prev_hash"] = chain[-1]["hash"]
        # if chain[-1] == tmp:
        #     print("Doing Next Job.")
        #     break
        b["nonce"] +=1
        c = compute_hash(b)
        if c.startswith("0000"):
            b["hash"] = c
            break
    unmined_blocks.remove(org)
    print(org)
    print(b)
    resp = requests.post(SERVER_URL+"completemined",json={
        "from":"test",
        "data":b,
        "index":0
    })
    print(resp.content)
    chain.append(b)

