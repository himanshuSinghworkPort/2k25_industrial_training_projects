import sys, socket, json

if len(sys.argv)!=2:
    print("Usage: python admin_client.py questions.json")
    sys.exit(1)

with open(sys.argv[1],'r') as f:
    questions = json.load(f)

HOST, PORT = '127.0.0.1', 9999
ADMIN_PASS     = 'supersecret'

sock = socket.socket()
sock.connect((HOST, PORT))
f = sock.makefile('r')

# Authenticate as admin
sock.sendall((json.dumps({
    'action':'auth','role':'admin','password':ADMIN_PASS
})+'\n').encode())
print("Auth:", json.loads(f.readline()))

# Load questions
sock.sendall((json.dumps({
    'action':'load','questions': questions
})+'\n').encode())
print("Load:", json.loads(f.readline()))

# Start quiz
sock.sendall((json.dumps({
    'action':'start'
})+'\n').encode())
print("Start:", json.loads(f.readline()))

sock.close()
