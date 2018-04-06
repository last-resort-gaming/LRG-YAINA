
import sqlite3
import os
from os.path import expanduser
from .constants import INFI_COMMANDS, YAINA_COMMANDS

class DB(object):
    """
    Little helper for initializing the database / tables
    """

    singleton_object = None
    db_file = os.path.join(expanduser("~"), '.borealis', 'borealis.sqlite3')

    @classmethod
    def get(cls):
        if cls.singleton_object is None:
            cls.singleton_object = cls()
        return cls.singleton_object.conn

    def __init__(self):
        data_dir = os.path.dirname(DB.db_file)

        if not os.path.exists(data_dir):
            os.makedirs(data_dir)
        self.conn = sqlite3.connect(DB.db_file)

        self.validate_db()

    def validate_db(self):

        # Validate users

        user_cols = []
        for row in self.conn.execute("pragma table_info('users')").fetchall():
            user_cols.append(row[1])
        if user_cols == []:
            self.conn.execute("""
                        CREATE TABLE users (
                            steamid bigint not null unique,
                            name text not null,
                            zeus_trained boolean not null default 0
                        )
                    """)
        else:
            if 'zeus_trained' not in user_cols:
                self.conn.execute('ALTER TABLE users ADD COLUMN zeus_trained BOOLEAN NOT NULL DEFAULT 0')

        # Validate groups
        group_cols = []
        for row in self.conn.execute("pragma table_info('groups')").fetchall():
            group_cols.append(row[1])
        if group_cols == []:
            self.conn.execute("""
                CREATE TABLE groups (
                    idx INTEGER PRIMARY KEY AUTOINCREMENT,
                    name TEXT NOT NULL UNIQUE,
                    immutable boolean not null default 0
                )
            """)

        # Validate members
        member_cols = []
        for row in self.conn.execute("pragma table_info('members')").fetchall():
            member_cols.append(row[1])
        if member_cols == []:
            self.conn.execute("""
                CREATE TABLE members (
                    groupid bigint not null,
                    steamid bigint not null,
                    unique (groupid, steamid)
                )
            """)

        # Validate members
        cols = []
        for row in self.conn.execute("pragma table_info('members_group')").fetchall():
            cols.append(row[1])
        if cols == []:
            self.conn.execute("""
                CREATE TABLE members_group (
                    groupid_p bigint not null,
                    groupid_c bigint not null,
                    unique (groupid_p, groupid_c)
                )
            """)

        # Just dump permission table if it doesn't exist
        cols = []
        for row in self.conn.execute("pragma table_info('providers')").fetchall():
            cols.append(row[1])
        if cols == []:
            self.conn.execute("""
                CREATE TABLE providers (
                    idx INTEGER PRIMARY KEY AUTOINCREMENT,
                    name text
                )
            """)
            self.conn.execute('INSERT INTO providers (name) VALUES ("InfiSTAR")')
            self.conn.execute('INSERT INTO providers (name) VALUES ("YAINA")')
            self.conn.execute('INSERT INTO providers (name) VALUES ("ZEUS")')
            self.conn.commit()


        # Just dump permission table if it doesn't exist
        cols = []
        for row in self.conn.execute("pragma table_info('permissions')").fetchall():
            cols.append(row[1])
        if cols == []:
            self.conn.execute("""
                CREATE TABLE permissions (
                    idx INTEGER PRIMARY KEY AUTOINCREMENT,
                    provider bigint not null,
                    permission text
                )
            """)

            # Insert Commands
            for x in INFI_COMMANDS:
                self.conn.execute('INSERT INTO permissions(provider,permission) VALUES (1, ?)', [x])
            for x in YAINA_COMMANDS:
                self.conn.execute('INSERT INTO permissions(provider,permission) VALUES (2, ?)', [x])

            self.conn.execute('INSERT INTO permissions(provider,permission) VALUES (3, "Whitelisted")')
            self.conn.commit()

        # Just dump permission table if it doesn't exist
        cols = []
        for row in self.conn.execute("pragma table_info('permissions_map')").fetchall():
            cols.append(row[1])
        if cols == []:
            self.conn.execute("""
                CREATE TABLE permissions_map (
                    groupid bigint not null,
                    permission bigint not null
                )
                """)

        # Just dump permission table if it doesn't exist
        cols = []
        for row in self.conn.execute("pragma table_info('paths')").fetchall():
            cols.append(row[1])
        if cols == []:
            self.conn.execute("""
                CREATE TABLE paths (
                    id text not null UNIQUE,
                    path text not null
                )
                """)
