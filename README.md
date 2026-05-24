# Godot Peer Example Project

This project uses "index.custom.html" as a custom html template for a Godot web export. The custom html includes PeerJS (https://peerjs.com/) which enables P2P connections. In "main.gd", JavaScriptBridge is used to connect PeerJS with Godot, so that one can create, connect, and send data between conencted Peers.

## Local Server

The root of this project contains index.js and package.json which will run a local server at "http://localhost:3000" with the following commands: "npm install" and "npm start".
