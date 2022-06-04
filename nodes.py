import json
import os
from time import time
import requests
NODES_FILENAME = "nodes.json"
MASTER_NODE = ''


class Nodes:
    def __init__(self):
        self.peers = set()
        self.failed_peers = set()
        self.root_url = ""
        if not os.path.exists(NODES_FILENAME):
            self.add_node(MASTER_NODE)
        else:
            self.load_nodes()

    def add_node(self, address: str):
        self.peers.add(address)
        with open(NODES_FILENAME, "w") as f:
            json.dump(list(self.peers), f)

    def load_nodes(self):
        with open(NODES_FILENAME, "r") as f:
            self.peers = set(json.load(f))

    def get_peers(self):
        return list(self.peers)

    def knock_peers(self):
        for peer in self.peers:
            try:
                response = requests.get(peer + 'peers', timeout=5)
                if response.status_code == 200:
                    ps = response.json()['peers']
                    for n in ps:
                        self.add_node(n)
                    break
            except Exception as e:
                print(e)
        for p in self.peers:
            print('post', p)
            try:
                response = requests.post(p+'register_node', {
                    'node_address': self.root_url
                }, timeout=5)
            except Exception:
                pass
