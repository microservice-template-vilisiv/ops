import json
import pg8000

# ----------------------------
# Configuration
# ----------------------------
PG_CONFIG = {
    "user": "crbusr",
    "password": "crb42069$$",
    "host": "pgbouncer",
    "port": 5432,
    "database": "crbdev"
}

# ----------------------------
# Persistent DB Connection
# ----------------------------
_db_conn = None

def get_db_connection():
    global _db_conn
    if _db_conn is None:
        _db_conn = pg8000.connect(**PG_CONFIG)
    return _db_conn

# ----------------------------
# Dynamic Trigger Function
# ----------------------------
def execute_dynamic_query(args):
    """
    Args:
      args[0]: trigger name (reserved)
      args[1]: cache key
      args[2]: SQL query
      args[3]: TTL in seconds
    """
    if len(args) < 4:
        return "Usage: RG.TRIGGER <trigger> <cache_key> <SQL query> <TTL>"

    cache_key = args[1]
    query = args[2]
    try:
        ttl = int(args[3])
    except Exception:
        ttl = 300  # default TTL

    # Try reading from cache first
    cached = execute('GET', cache_key)
    if cached:
        return cached

    # Fetch from DB
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute(query)
        columns = [desc[0] for desc in cur.description]
        rows = [dict(zip(columns, r)) for r in cur.fetchall()]
        cur.close()
    except Exception as e:
        return f"DB fetch failed: {e}"

    # Serialize result
    payload = json.dumps(rows, default=str)

    # Write to Redis cache
    try:
        execute('SET', cache_key, payload, 'EX', ttl)
    except Exception as e:
        print(f"Cache write failed for {cache_key}: {e}")

    return payload

# ----------------------------
# Register Trigger
# ----------------------------
GB('CommandReader').map(execute_dynamic_query).register(trigger='executeDynamicQuery')
