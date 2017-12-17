#!/usr/bin/env python

import asyncio
import websockets
import uuid
import json
import os.path
import urllib.parse


class Project:
    def __init__(self, gitURL):
        self.gitURL = gitURL
        self.clients = set()
        self.currentSyncClient = None
        self.waitingSyncClients = set()

    def add_client(self, client):
        self.clients.add(client)
        if self.currentSyncClient is not None:
            self.waitingSyncClients.add(client)

    async def remove_client(self, client, user_id):
        self.clients.remove(client)

        await self.broadcast(json.dumps({
            'type': 'disconnect',
            'status': 200,
            'userID': user_id
        }), client)

        if self.currentSyncClient is client:
            self.sync_next_step()
        elif client in self.waitingSyncClients:
            self.waitingSyncClients.remove(client)

    async def broadcast(self, message, send_client):
        for client in self.clients:
            if client != send_client:
                await client.send(message)

    async def start_sync(self):
        await self.broadcast(json.dumps({
            'type': 'startSync',
            'status': 200
        }), None)

        self.waitingSyncClients = self.clients.copy()
        await self.sync_next_step()

    async def sync_next_step(self):
        if len(self.waitingSyncClients) == 0:
            await self.complete_sync()
        else:
            self.currentSyncClient = self.waitingSyncClients.pop()
            await self.currentSyncClient.send(json.dumps({
                'type': 'startUserSync',
                'status': 200
            }))

    async def complete_sync(self):
        self.currentSyncClient = None
        await self.broadcast(json.dumps({
            'type': 'completedSync',
            'status': 200
        }), None)


projects = {}
filename = 'projects.json'

if os.path.isfile(filename):
    f = open(filename)
    l_projects = json.loads(f.read())
    f.close()

    for pid in l_projects:
        projects[pid] = Project(l_projects[pid])
#
#
# projects = {
#     '110ec58a-a0f2-4ac4-8393-c866d813b8d1': Project('ssh://git@gitlab.com/TheMegaTB/testLatex.git')
# }


def save_projects():
    global projects
    s_projects = {}

    for save_pid in projects:
        s_projects[save_pid] = projects[save_pid].gitURL

    f = open(filename, 'w')
    f.write(json.dumps(s_projects))
    f.close()


async def handler(websocket, path: str):
    global projects
    path_components = path.split("/")

    if len(path_components) != 4:
        return
    elif path_components[0] != '':
        return
    elif path_components[1] != 'project':
        return

    project: Project = None
    project_id: str = None
    user_id = str(uuid.uuid1())

    if path_components[2] == 'join':
        if path_components[3] in projects:
            project_id = path_components[3]
            project = projects[project_id]
        else:
            return
    elif path_components[2] == 'create':
        git_url = urllib.parse.unquote(path_components[3])
        project = Project(git_url)
        project_id = str(uuid.uuid1())
        projects[project_id] = project
        save_projects()
    else:
        return

    project.add_client(websocket)

    try:
        await websocket.send(json.dumps({
            'type': 'project-open',
            'status': 200,
            'userID': user_id,
            'projectID': project_id,
            'repoURL': project.gitURL
        }))

        async for raw_message in websocket:
            message = json.loads(raw_message)

            if 'status' not in message or 'type' not in message or message['status'] != 200:
                continue

            message_type = message['type']

            if message_type == 'cursor' or message_type == 'edit':
                await project.broadcast(raw_message, websocket)
            elif message_type == 'startSync':
                await project.start_sync()
            elif message_type == 'completedUserSync':
                if project.currentSyncClient == websocket:
                    await project.sync_next_step()
    finally:
        await project.remove_client(websocket, user_id)

start_server = websockets.serve(handler, 'localhost', 8080)

asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()