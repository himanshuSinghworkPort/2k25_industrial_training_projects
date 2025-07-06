import socket
import threading
import json
import sqlite3
import time
from datetime import datetime

HOST, PORT = '0.0.0.0', 9999

# 1) Load quiz data immediately
with open('questions.json','r') as f:
    questions = json.load(f)
print(f"[SERVER DEBUG] Loaded {len(questions)} questions")

# 2) Track connected clients
clients = []            # each is {'conn','username','score','event','last_ans'}
clients_lock = threading.Lock()
client_connected = threading.Event()

# 3) SQLite persistence
db  = sqlite3.connect('quiz.db', check_same_thread=False)
cur = db.cursor()
cur.execute('''
  CREATE TABLE IF NOT EXISTS results (
    id        INTEGER PRIMARY KEY,
    username  TEXT,
    score     INTEGER,
    taken_at  TEXT
  )
''')
db.commit()

def broadcast(msg: dict):
    data = (json.dumps(msg) + '\n').encode()
    with clients_lock:
        for c in clients:
            try:
                c['conn'].sendall(data)
            except Exception as e:
                print(f"[SERVER ERROR] to {c['username']}: {e}")

def handle_client(conn, addr):
    f = conn.makefile('r')
    username = None
    try:
        # first message must be auth
        line = f.readline().strip()
        print(f"[SERVER DEBUG] raw auth from {addr}: {repr(line)}")
        req = json.loads(line)
        if req.get('action')!='auth':
            conn.close(); return

        username = req.get('username') or f"guest_{addr[1]}"
        client = {
            'conn': conn,
            'username': username,
            'score': 0,
            'event': threading.Event(),
            'last_ans': None
        }
        with clients_lock:
            clients.append(client)
            client_connected.set()
        conn.sendall(b'{"status":"ok"}\n')
        print(f"[SERVER DEBUG] '{username}' connected")

        # then accept answer messages
        for line in f:
            msg = json.loads(line)
            if msg.get('action')=='answer':
                client['last_ans'] = (msg['question_index'], msg['choice'])
                client['event'].set()

    except Exception as e:
        print(f"[SERVER ERROR] handle_client: {e}")
    finally:
        conn.close()
        with clients_lock:
            clients[:] = [c for c in clients if c['conn'] is not conn]
        print(f"[SERVER DEBUG] '{username}' disconnected")

def quiz_manager():
    # wait for someone to join
    print("[SERVER DEBUG] Waiting for first client…")
    client_connected.wait()

    # give a 5s buffer to join more clients
    print("[SERVER DEBUG] Starting quiz in 5 seconds…")
    time.sleep(5)

    total = len(questions)
    for qi, q in enumerate(questions):
        # clear previous answers
        with clients_lock:
            for c in clients:
                c['event'].clear()
                c['last_ans'] = None

        # broadcast question
        print(f"[SERVER DEBUG] Broadcasting Q{qi+1}: {q['question']}")
        broadcast({
            'action':          'question',
            'question_index':  qi,
            'total_questions': total,
            'question':        q['question'],
            'options':         q['options'],
            'time_limit':      q.get('time_limit', 20)
        })

        # wait up to time_limit or until all answered
        deadline = time.time() + q.get('time_limit', 20)
        while time.time() < deadline:
            with clients_lock:
                if all(c['event'].is_set() for c in clients):
                    break
            time.sleep(0.1)

        # score the answers
        with clients_lock:
            for c in clients:
                ans = c['last_ans']
                if ans and ans[0] == qi and ans[1] == q['answer']:
                    c['score'] += 1

        # broadcast interim leaderboard
        board = sorted([(c['username'], c['score']) for c in clients],
                       key=lambda x: -x[1])
        broadcast({'action':'leaderboard','scores':board})

    # final results → broadcast + persist + console print
    final = [(c['username'], c['score']) for c in clients]
    broadcast({'action':'final','scores': final})

    print("[SERVER RESULT] Final Scores:")
    for user, score in final:
        print(f"  • {user}: {score}")
        cur.execute(
            "INSERT INTO results(username,score,taken_at) VALUES(?,?,?)",
            (user, score, datetime.now().isoformat())
        )
    db.commit()
    print("[SERVER DEBUG] Quiz complete – results saved to quiz.db")

def start_server():
    threading.Thread(target=quiz_manager, daemon=True).start()
    srv = socket.socket()
    srv.bind((HOST, PORT))
    srv.listen()
    print(f"[SERVER DEBUG] Listening on {HOST}:{PORT}")
    while True:
        conn, addr = srv.accept()
        threading.Thread(target=handle_client,
                         args=(conn, addr),
                         daemon=True).start()

if __name__=='__main__':
    start_server()
