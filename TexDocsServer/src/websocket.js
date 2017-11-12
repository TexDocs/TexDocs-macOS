const WebSocket = require('ws');
const uuidv4 = require('uuid/v4');
const fs = require("fs-extra");
const { spawn } = require('child_process');
const config = require('../config/config');
const path = require("path");

const NOT_FOUND = {
    status: 404
};

const projects = {
    "110ec58a-a0f2-4ac4-8393-c866d813b8d1": {
        repoURL: "git@gitlab.com:TheMegaTB/testLatex.git",
        serverChanges: [],
        gitLog: [],
    }
};

function heartbeat() {
    this.isAlive = true;
}

async function getProject(projectID) {
    return new Promise((resolve, reject) => {
        if (projects.hasOwnProperty(projectID))
            resolve(projects[projectID]);
        else
            reject();
    })
}

async function updateProject(projectID) {
    return new Promise((resolve, reject) => {
        getProject(projectID).then((project) => {
            const projectDir = path.join(config.storageFolder, projectID);

            fs.ensureDirSync(config.storageFolder);
            let gitShell;
            if (fs.existsSync(projectDir)) {
                console.log("executing pull");
                // TODO Check for local, uncommited changes
                gitShell = spawn('git', ['pull'], { cwd: projectDir });
            } else {
                console.log("executing clone");
                gitShell = spawn('git', ['clone', project.repoURL, projectDir]);
            }

            gitShell.stdout.setEncoding('utf8');
            gitShell.stderr.setEncoding('utf8');

            gitShell.stdout.on('data', (chunk) => {
                project.gitLog.push([Date.now().toString(), 'stdout', chunk]);
            });

            gitShell.stderr.on('data', (chunk) => {
                project.gitLog.push([Date.now().toString(), 'stderr', chunk]);
            });

            gitShell.on('close', (code) => {
                console.log(`child process exited with code ${code}`);
                if (code === 0) resolve();
                else reject(code);
            });
        }).catch((err) => reject(err));
    });
}

// updateProject("110ec58a-a0f2-4ac4-8393-c866d813b8d1").then(() => console.log("updated!"));

function joinProject(projectID, userID) {
    if (projects.hasOwnProperty(projectID)) {
        const project = projects[projectID];
        return {
            status: 200,
            type: "project-open",
            userID,
            repoURL: project.repoURL,
            changes: project.serverChanges
        };
    } else {
        return NOT_FOUND;
    }
}

function handshake(ws, req, userID) {
    const url = req.url.split('/').slice(1);
    let msg = {};
    if (url[0] === "project") {
        if (url[1] === 'join') {
            msg = joinProject(url[2], userID);
        } else if (url[1] === 'create') {
            msg = {
                status: 501
            };
        }
    } else {
        msg = NOT_FOUND;
    }

    ws.send(JSON.stringify(msg));
}

export function setupWebsocket(server) {
    const wss = new WebSocket.Server({server});
    wss.on('connection', (ws, req) => {
        ws.userID = uuidv4();
        console.log(req.url);
        // TODO Map to project invite link

        ws.isAlive = true;
        ws.on('pong', heartbeat);

        ws.on('message', (message) => {
            console.log('received: %s', message);
            let data;
            try {
                data = JSON.parse(message);
            } catch (e) {
                console.warn("Received bogus message", data);
                return;
            }

            // TODO Interpret data

            switch (data.type) {
                case 'cursor':
                    wss.clients.forEach((client) => {
                        if (ws.userID === client.userID) return;
                        data.userID = ws.userID;
                        client.send(JSON.stringify(data));
                    });
                    break;
                case 'edit':
                    wss.clients.forEach((client) => {
                        if (ws.userID === client.userID) return;
                        client.send(JSON.stringify(data));
                    });
                    break;
            }
        });


        handshake(ws, req, ws.userID);

    });

    const interval = setInterval(function ping() {
        wss.clients.forEach(function each(ws) {
            if (ws.isAlive === false) {
                // TODO Notify others about this state
                return ws.terminate();
            }

            ws.isAlive = false;
            ws.ping('', false, true);
        });
    }, 30000);
}
