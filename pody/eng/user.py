import sqlite3
import hashlib
import dataclasses
from threading import Lock

from .errors import InvalidUsernameError
from ..config import DATA_HOME

def locked(func):
    def wrapper(*args, **kwargs):
        with args[0].lock:
            return func(*args, **kwargs)
    return wrapper

def hash_password(username: str, password: str):
    return hashlib.sha256(f"{username}:{password}".encode()).hexdigest()

def validate_username(username: str) -> tuple[bool, str]:
    if not 3 <= len(username) <= 20:
        return False, "Username must be between 3 and 20 characters"
    if not username.isalnum():
        return False, "Username must be alphanumeric"
    if '-' in username or ':' in username:
        return False, "Username cannot contain '-' or ':'"
    return True, ""

def check_username(username: str):
    if not (res := validate_username(username))[0]: raise InvalidUsernameError(res[1])

@dataclasses.dataclass
class User:
    userid: int
    name: str
    max_pods: int

class UserDatabase:
    def __init__(self):

        DATA_HOME.mkdir(exist_ok=True)
        self.conn = sqlite3.connect(DATA_HOME / "users.db", check_same_thread=False)
        self.cursor = self.conn.cursor()
        self.lock = Lock()

        with self.lock:
            self.cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS users (
                    id INTEGER PRIMARY KEY,
                    username TEXT NOT NULL,
                    credential TEXT NOT NULL
                    max_pods INTEGER NOT NULL DEFAULT 1
                )
                """
            )
            self.conn.commit()

    @locked
    def add_user(self, username: str, password: str, max_pods: int = 1):
        check_username(username)
        self.cursor.execute(
            "INSERT INTO users (username, credential, max_pods) VALUES (?, ?, ?)",
            (username, hash_password(username, password), max_pods),
        )
        self.conn.commit()

    @locked
    def update_password(self, username: str, password: str):
        check_username(username)
        self.cursor.execute(
            "UPDATE users SET credential = ? WHERE username = ?",
            (hash_password(username, password), username),
        )
        self.conn.commit()
    
    @locked
    def update_max_pods(self, username: str, max_pods: int):
        self.cursor.execute(
            "UPDATE users SET max_pods = ? WHERE username = ?",
            (max_pods, username),
        )
        self.conn.commit()

    @locked
    def check_user(self, credential: str):
        cur = self.conn.execute(
            "SELECT id, username, max_pods FROM users WHERE credential = ?",
            (credential,),
        )
        res = cur.fetchone()
        if res is None: return User(0, '', 0)
        else: return User(*res)
    
    @locked
    def delete_user(self, username: str):
        self.cursor.execute(
            "DELETE FROM users WHERE username = ?",
            (username,),
        )
        self.conn.commit()

    def close(self):
        self.conn.close()