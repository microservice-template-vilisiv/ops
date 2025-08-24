import json
import threading
import time
import pg8000

# ----------------------------
# Configuration
# ----------------------------
PG_CONFIG = {
    "user": "crbusr",
    "password": "crb42069$$",
    "host": "pgbouncer",
    "port": 6432,
    "database": "crbdev"
}

CACHE_KEY = "general::dump"
CACHE_TTL = 300        # seconds
LIMIT = 10000
SCHEMA = "public"
TABLE = "google_playstore"

# ----------------------------
# Persistent DB Connection
# ----------------------------
_db_conn = None

def get_db_connection():
    global _db_conn
    try:
        if _db_conn is None:
            _db_conn = pg8000.connect(**PG_CONFIG)
    except Exception as e:
        print("DB connection error:", e)
        _db_conn = None
    return _db_conn

# ----------------------------
# Polling function
# ----------------------------
def refresh_cache():
    while True:
        try:
            conn = get_db_connection()
            if conn:
                cur = conn.cursor()
                cur.execute(f"SELECT * FROM {SCHEMA}.{TABLE} ORDER BY id LIMIT {LIMIT}")
                columns = [desc[0] for desc in cur.description]
                rows = [dict(zip(columns, r)) for r in cur.fetchall()]
                payload = json.dumps(rows, default=str)
                execute('PSETEX', CACHE_KEY, CACHE_TTL, payload)
                cur.close()
        except Exception as e:
            print("Cache refresh error:", e)

        time.sleep(CACHE_TTL)  # wait TTL seconds before next refresh

# Start background polling thread
threading.Thread(target=refresh_cache, daemon=True).start()

# ----------------------------
# Trigger function
# ----------------------------
def get_all_play_store_data(args):
    """
    RG.TRIGGER getAllPlayStoreData
    Returns cached JSON. If cache empty, waits for next poll.
    """
    cached = execute('GET', CACHE_KEY)
    if cached:
        return cached
    return "Cache not ready yet"

# ----------------------------
# Register the trigger
# ----------------------------
GB('CommandReader').map(get_all_play_store_data).register(trigger='getAllPlayStoreData')
