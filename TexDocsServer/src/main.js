import {setupWebsocket} from "./websocket";

const express = require('express');
const http = require('http');
const app = express();

const server = http.createServer(app);

setupWebsocket(server);

server.listen(8080, function listening() {
    console.log('Listening on %d', server.address().port);
});
