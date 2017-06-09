#!/bin/env python3

import i3ipc

i3 = i3ipc.Connection()

workspaces = i3.get_tree().workspaces()
for workspace in workspaces:
    print('%s is id %s is name ' % (workspace.name, workspace.type))
