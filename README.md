# Godot Peer Example Project

This project uses "index.custom.html" as a custom html template for a Godot web export. The custom html includes PeerJS (https://peerjs.com/) which enables P2P connections. In "main.gd", JavaScriptBridge is used to connect PeerJS with Godot, so that one can create, connect, and send data between conencted Peers.

## Local Server

The root of this project contains index.js and package.json which will run a local server at "http://localhost:3000" with the following commands: "npm install" and "npm start".

## Todo

- [x] Host should list known Peers in UI once they join
  - [x] Peers should do the same

- [ ] Host should add self to knownPeers when sending out gamestate
- [ ] All Peers should remove self from the UI list of knownPeers

- [ ] Host should send "start" event to Peers
- [ ] Non-host Peers should report position to host
- [ ] All Peers should render the positions of other Peers
