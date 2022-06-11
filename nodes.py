import json
import os
from time import time
import requests
import _thread
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
                    new_ps = set()
                    for p in ps:
                        new_ps.add(p)
                    self.peers = self.peers.union(new_ps)
                    break
            except Exception as e:
                print(e)
                self.failed_peers.add(peer)

        for p in self.peers:
            print('post', p)
            def knock_peer(addr):
                try:
                    response = requests.post(addr+'register_node', json={
                        'node_address': self.root_url
                    }, timeout=5)
                    if response.status_code != 200:
                        self.failed_peers.add(peer)
                except Exception:
                    self.failed_peers.add(peer)
            _thread.start_new_thread(knock_peer,(peer,))
                
            
