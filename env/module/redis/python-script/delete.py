import json
import psycopg2
from redisgears import executeCommand, GB


def user_task_progress(user_id):
    key = f"userTaskProgress:{user_id}"

    cached = executeCommand('GET', key)
    if cached:
        log(f"Cache hit for :{key}")
        return cached

    log(f"cache miss for: {key}")
    
    db_data = []
    conn = None
    try:
        conn = get_db_connection()
        db_data = get_data_from_db(conn, user_id)
    finally:
        if conn:
            conn.close()


    executeCommand('SETEX', key, 50, json.dumps(db_data))

    return json.dumps(db_data)


def get_data_from_db(conn, user_id):
    try:
        
        cur = conn.cursor()

        cur.execute("SELECT education_level, area FROM user_data.user_profile WHERE user_id = %s", (user_id,))
        user_profile = cur.fetchone()
        if not user_profile:
            log(f"User dengan ID {user_id} tidak ditemukan.")
            return json.dumps({"error": "User not found"})
        
        log(f"fetch user data: {user_profile}")
        education_level, area = user_profile
    
        cur.execute(
            "SELECT task_id, title, xp_reward, image_url FROM gamification.general_tasks WHERE education_level = %s AND area = %s",
            (education_level, area),
        )
        general_tasks = [{'taskId': r[0], 'title': r[1], 'xp_reward': r[2], 'image_url': r[3]} for r in cur.fetchall()]
        # log(f"fetch general task: {general_tasks}")
        
        cur.execute("SELECT task_id, status, proof_url FROM gamification.user_general_task_progress WHERE user_id = %s", (user_id,))
        user_progress = {r[0]: r[1] for r in cur.fetchall()}
        # log(f"fetch user progress: {user_progress}")

        dtos = []
        for task in general_tasks:
            status = user_progress.get(task['taskId'], 'progress')
            dtos.append({
                'taskId': task['taskId'],
                'title': task['title'],
                'imageUrl': task['image_url'], 
                'xpReward': task['xp_reward'],
                'status': status
            })

        return sorted(dtos, key=lambda d: 1 if d['status'].lower() == 'selesai' else 0)

    except Exception as ex:
        log(f"error: {ex}")

def log(msg):
    print(msg)

def get_db_connection():
    return psycopg2.connect(
        host='100.71.2.11', 
        port='5432', 
        dbname='crbdev', 
        user='crbusr', 
        password='crb42069$$'
    )


GB().register(trigger="userTaskProgress", callback=user_task_progress)