from .user import User
from .perm import Permission
from pyborealis.db import DB

class Group(object):

    @staticmethod
    def getAllGroups():
        r = [];
        for row in DB.get().execute("""
            SELECT idx,name,immutable
            FROM groups
            ORDER BY name
        """):
            r.append(Group(*row))
        return r

    @staticmethod
    def add_group(name):
        DB.get().execute('INSERT INTO groups(name) VALUES (?)', [name])
        DB.get().commit()

    def __init__(self, id, name, immutable):
        self.id   = id
        self.name = name
        self.immutable = immutable == 1

    def delete(self):
        if self.immutable:
            raise RuntimeError('Unable to delete immutable group')

        c = DB.get()
        c.execute('DELETE FROM members WHERE groupid=?', [self.id])
        c.execute('DELETE FROM permissions_map WHERE groupid=?', [self.id])
        c.execute('DELETE FROM groups WHERE idx=?', [self.id])
        c.commit()

    def members(self, expand=False):
        r = []

        for row in DB.get().execute("""
            SELECT users.name,users.steamid,zeus_trained
            FROM members
            JOIN users
            ON members.steamid = users.steamid
            WHERE members.groupid=?
            ORDER BY users.name
        """, [self.id]):
            r.append(User(*row))

        for row in DB.get().execute("""
            SELECT groups.idx,groups.name,groups.immutable
            FROM members_group
            JOIN groups
            ON members_group.groupid_c = groups.idx
            WHERE members_group.groupid_p =?
            ORDER BY groups.name
        """, [self.id]):
            g = Group(*row)
            if expand:
                for member in g.members(expand):
                    r.append(member)
            else:
                r.append(g)

        return r

    def permissions(self):
        perms = []
        for row in DB.get().execute("""
            SELECT providers.idx, providers.name, permissions.permission
            FROM permissions_map
            JOIN permissions
                ON permissions_map.permission = permissions.idx
            JOIN providers
                ON permissions.provider = providers.idx
            WHERE permissions_map.groupid = ?
        """, [self.id]):
            perms.append(Permission(*row))

        return perms