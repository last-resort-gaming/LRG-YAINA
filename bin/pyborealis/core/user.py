
from pyborealis.db import DB
from pyborealis.util import steamid_to_guid

class User(object):

    @staticmethod
    def getAllUsers():
        r = [];
        for row in DB.get().execute("""
            SELECT name,steamid,zeus_trained
            FROM users
            ORDER BY lower(name)
        """):
            r.append(User(*row))
        return r

    @staticmethod
    def getUser(steamid):
        row = DB.get().execute("""
            SELECT name,steamid,zeus_trained
            FROM users
            WHERE steamid=?
        """, [steamid]).fetchone()

        if row is None:
            return

        return User(*row)

    @staticmethod
    def add_user(name, steamid):
        c = DB.get()
        c.execute('INSERT INTO users (name,steamid) VALUES (?, ?)', [name, steamid])
        c.commit()

    def __init__(self, name, steamid, zeus_trained):
        self.name = name
        self.steamid = steamid
        self.__zeus_trained = zeus_trained == 1

    @property
    def beguid(self):   return steamid_to_guid(self.steamid)


    @property
    def zeus_trained(self):
        return self.__zeus_trained

    @zeus_trained.setter
    def zeus_trained(self, x):
        if x != self.__zeus_trained:
            self._update_bool('zeus_trained', x)
            self.__zeus_trained = x

    def _update(self, k, v):
        print 'UPDATE users SET %s=%s WHERE steamid=%s' % (k, v, self.steamid)
        DB.get().execute('UPDATE users SET %s=? WHERE steamid=?' % k, (v, self.steamid))
        DB.get().commit()

    def _update_bool(self, k, v):
        self._update(k, '1' if v else '0')

    def delete(self):
        c = DB.get()
        c.execute('DELETE FROM members WHERE steamid=?', [self.steamid])
        c.execute('DELETE FROM users WHERE steamid=?', [self.steamid])
        c.commit()