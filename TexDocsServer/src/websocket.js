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
        gitLog: [],
        users: {},
        activeSyncClient: undefined,
        unsyncedUsers: [],
        inSync: false
    }
};

async function getProject(projectID) {
    return new Promise((resolve, reject) => {
        if (projects.hasOwnProperty(projectID))
            resolve(projects[projectID]);
        else
            reject();
    })
}

function getProjectDir(projectID) {
    return path.join(config.storageFolder, projectID);
}

async function executeInProject(projectID, spawnClosure) {
    return new Promise((resolve, reject) => {
        getProject(projectID).then((project) => {
            let shellCmd = spawnClosure(project);

            shellCmd.stdout.setEncoding('utf8');
            shellCmd.stderr.setEncoding('utf8');

            shellCmd.stdout.on('data', (chunk) => {
                project.gitLog.push([Date.now().toString(), 'stdout', chunk]);
            });

            shellCmd.stderr.on('data', (chunk) => {
                project.gitLog.push([Date.now().toString(), 'stderr', chunk]);
            });

            shellCmd.on('close', (code) => {
                console.log(`child process exited with code ${code}`);
                if (code === 0) resolve();
                else reject(code);
            });
        }).catch((err) => reject(err));
    });
}

function updateProject(projectID) {
    return executeInProject(projectID, (project) => {
        const projectDir = getProjectDir(projectID);

        fs.ensureDirSync(config.storageFolder);
        if (fs.existsSync(projectDir)) {
            console.log("executing pull");
            // TODO Check for local, uncommited changes
            return spawn('git', ['pull'], { cwd: projectDir });
        } else {
            console.log("executing clone");
            return spawn('git', ['clone', project.repoURL, projectDir]);
        }
    });
}

function pushProject(projectID) {
    const projectDir = getProjectDir(projectID);
    return executeInProject(projectID, (project) => {
        console.log("add files");
        return spawn('git', ['add', '.'], { cwd: projectDir });
    }).then(() =>
        executeInProject(projectID, (project) => {
            console.log("commit");
            return spawn('git', ['commit', '-m', '"Server side commit"'], { cwd: projectDir });
        }).then(() =>
            executeInProject(projectID, (project) => {
                console.log("push");
                return spawn('git', ['push'], { cwd: projectDir });
            })
        ).catch(() =>
            console.log("catch 1")
        )
    );
}

 updateProject("110ec58a-a0f2-4ac4-8393-c866d813b8d1").then(() => {
     console.log("updated!");
     pushProject("110ec58a-a0f2-4ac4-8393-c866d813b8d1").then(() => console.log("pushed!"));
 });

function nextUserSync(projectID, project) {
    project.activeSyncClient = project.unsyncedUsers.shift();
    
    if (project.activeSyncClient !== undefined) {
        project.activeSyncClient.send(JSON.stringify({type: 'startUserSync', status: 200}));
    } else {
        completeSync(projectID, project);
    }
}

function startSync(projectID) {
    if (projects.hasOwnProperty(projectID)) {
        broadcastToProject(projectID, null, {type: 'startSync', status: 200});
        const project = projects[projectID];
        project.inSync = true;
        project.unsyncedUsers = Object.values(project.users)
        pushProject(projectID).then(() => {
            nextUserSync(projectID, project);
        })
    }
}

function completeSync(projectID, project) {
    projects.unsyncedUsers = [];
    updateProject(projectID).then(() => {
        broadcastToProject(projectID, null, {type: 'completedSync', status: 200});
        project.inSync = false;
    })
}

function userCompletedSync(projectID) {
    if (projects.hasOwnProperty(projectID)) {
        const project = projects[projectID];
        project.activeSyncClient = undefined;
        nextUserSync(projectID, project);
    }
}

function joinProject(projectID, userID, ws) {
    if (projects.hasOwnProperty(projectID)) {
        const project = projects[projectID];
        project.users[userID] = ws;
        
        if (projects.inSync) {
            projects.unsyncedUsers.push(ws);
        }
        
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
            msg = joinProject(url[2], userID, ws);
            ws.projectID = url[2];
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

Array.prototype.removeByVal = function(val) {
    for (var i = 0; i < this.length; i++) {
        if (this[i] === val) {
            this.splice(i, 1);
            i--;
        }
    }
    return this;
}

function removeClient(ws) {
    // TODO Notify others about this state
    console.log("Client disconnected");
    getProject(ws.projectID).then((project) => {
        delete project.users[ws.userID];
        
        if (project.inSync) {
          if (project.activeSyncClient === ws) {
              project.activeSyncClient = undefined;
              nextUserSync(project);
          } else {
              project.unsyncedUsers = project.unsyncedUsers.removeByVal(ws);
          }
        }
    });
    ws.terminate();
    broadcastToProject(ws.projectID, ws.userID, {
        type: 'disconnect',
        status: 200,
        userID: ws.userID
    });
}

function broadcastToProject(projectID, uID, data) {
    getProject(projectID).then((project) => {
        for (let userID in project.users) {
            if (!project.users.hasOwnProperty(userID) || userID === uID) continue;
            const ws = project.users[userID];
            ws.send(JSON.stringify(data));
        }
    });
}

function heartbeat() {
    this.isAlive = true;
}

export function setupWebsocket(server) {
    const wss = new WebSocket.Server({server});
    wss.on('connection', (ws, req) => {
        ws.userID = uuidv4();
        ws.isAlice = true

        ws.on('message', (message) => {
            console.log('received: %s', message);
            let data;
            try {
                data = JSON.parse(message);
            } catch (e) {
                console.warn("Received bogus message", data);
                return;
            }
              
            if (projects.hasOwnProperty(ws.projectID) && projects[ws.projectID].inSync) {
              switch (data.type) {
                case 'completedUserSync':
                    userCompletedSync(ws.projectID)
              }
            } else {
                switch (data.type) {
                    case 'cursor':
                        data.userID = ws.userID;
                        broadcastToProject(ws.projectID, ws.userID, data);
                        break;
                    case 'edit':
                        broadcastToProject(ws.projectID, ws.userID, data);
                        break;
                    case 'startSync':
                        startSync(ws.projectID)
                        break;
                }
            }
        });

        ws.on('pong', heartbeat);

        ws.on('close', (code, reason) => {
            if (ws.isAlive === true) {
                removeClient(ws);
            }
        })

        handshake(ws, req, ws.userID);
    });

    const interval = setInterval(function ping() {
        wss.clients.forEach(function each(ws) {
            if (ws.isAlive === false) {
                removeClient(ws);
            } else {
                ws.isAlive = false;
                ws.ping('', false, true);
            }
        });
    }, 1000);
}
