import json
import requests

# ----------------------------
# Configuration
# ----------------------------
HIKARI_URL = "http://hikari-cp:8088/query"  # use Docker network hostname

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

    # Fetch from HikariService via HTTP
    try:
        resp = requests.post(HIKARI_URL, data=query.encode("utf-8"), timeout=10)
        resp.raise_for_status()
        rows = resp.json()
    except Exception as e:
        return f"DB fetch failed via HikariService: {e}"

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
