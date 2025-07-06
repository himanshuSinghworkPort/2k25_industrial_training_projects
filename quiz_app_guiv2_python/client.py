import socket
import json
import threading
import tkinter as tk
from tkinter import messagebox

HOST, PORT = '127.0.0.1', 9999

class QuizClientApp:
    def __init__(self, root):
        self.root = root
        root.title("🌈 Quiz System 🌈")

        # — Window size & center —
        win_w, win_h = 900, 740
        scr_w = root.winfo_screenwidth()
        scr_h = root.winfo_screenheight()
        x = (scr_w - win_w) // 2
        y = (scr_h - win_h) // 2
        root.geometry(f"{win_w}x{win_h}+{x}+{y}")
        root.configure(bg='#F0F8FF')  # AliceBlue

        self.build_login()

    def build_login(self):
        self.login_frame = tk.Frame(self.root,
                                    bg='#FFDAB9',  # PeachPuff
                                    bd=2, relief='ridge',
                                    padx=30, pady=30)
        self.login_frame.place(relx=0.5, rely=0.5, anchor='c')

        tk.Label(self.login_frame,
                 text="Enter Your Username",
                 font=('Georgia', 18, 'bold'),
                 bg='#FFDAB9', fg='#4B0082')\
          .grid(row=0, column=0, columnspan=2, pady=(0,15))

        tk.Label(self.login_frame,
                 text="Username:",
                 font=('Arial', 14),
                 bg='#FFDAB9')\
          .grid(row=1, column=0, sticky='e', padx=(0,10))
        self.username_entry = tk.Entry(self.login_frame,
                                       font=('Arial', 14))
        self.username_entry.grid(row=1, column=1, padx=(10,0))
        self.username_entry.focus()

        tk.Button(self.login_frame,
                  text="Join Quiz",
                  font=('Arial', 14, 'bold'),
                  bg='#8A2BE2', fg='white',
                  activebackground='#4B0082',
                  padx=15, pady=8,
                  command=self.on_join)\
          .grid(row=2, column=0, columnspan=2, pady=(20,0))

    def on_join(self):
        self.username = self.username_entry.get().strip()
        if not self.username:
            messagebox.showwarning("Input Error", "Please enter a username.")
            return

        # Remove login, build full UI
        self.login_frame.destroy()
        self.build_banner()
        self.build_quiz_frame()
        self.build_footer()
        self.connect_to_server()

    def build_banner(self):
        # Top banner
        self.banner = tk.Frame(self.root, bg='#FFD700', height=80)  # Gold
        self.banner.pack(fill='x')
        tk.Label(self.banner,
                 text="Quiz System by Student Drive Academy",
                 font=('Georgia', 24, 'bold'),
                 bg='#FFD700', fg='#8B0000')\
          .pack(pady=(10,0))
        # Username display
        tk.Label(self.banner,
                 text=f"Player: {self.username}",
                 font=('Arial', 12, 'italic'),
                 bg='#FFD700', fg='#000080')\
          .pack(pady=(0,8))

    def build_quiz_frame(self):
        # Main quiz area
        self.quiz_frame = tk.Frame(self.root,
                                   bg='#E6E6FA',  # Lavender
                                   padx=20, pady=20)
        self.quiz_frame.pack(fill='both', expand=True)

        # Question label
        self.question_lbl = tk.Label(self.quiz_frame,
                                     text="",
                                     font=('Arial', 16, 'bold'),
                                     wraplength=800,
                                     justify='left',
                                     bg='#E6E6FA',
                                     fg='#2F4F4F')
        self.question_lbl.pack(pady=(0,20))

        # Options
        opts_frame = tk.LabelFrame(self.quiz_frame,
                                   text="Options",
                                   font=('Arial', 12, 'bold'),
                                   bg='#FFFACD',  # LemonChiffon
                                   fg='#8B4513',  # SaddleBrown
                                   padx=10, pady=10)
        opts_frame.pack(fill='x', pady=(0,20))
        self.radio_var = tk.IntVar(value=-1)
        self.opts = []
        for i in range(4):
            rb = tk.Radiobutton(opts_frame,
                                text="",
                                variable=self.radio_var,
                                value=i,
                                font=('Arial', 14),
                                bg='#FFFACD',
                                activebackground='#FAFAD2',
                                selectcolor='#FFEFD5')
            rb.pack(anchor='w', pady=5)
            self.opts.append(rb)

        # Controls (timer, progress, submit)
        ctrl = tk.Frame(self.quiz_frame, bg='#E6E6FA')
        ctrl.pack(fill='x', pady=(0,20))
        self.timer_lbl = tk.Label(ctrl,
                                  text="Time left: --",
                                  font=('Arial', 12),
                                  bg='#E6E6FA')
        self.timer_lbl.pack(side='left')
        # Progress bar (canvas)
        self.prog_canvas = tk.Canvas(ctrl,
                                     width=400, height=20,
                                     bg='#D3D3D3',
                                     highlightthickness=0)
        self.prog_canvas.pack(side='left', padx=10)
        self.prog_bar = self.prog_canvas.create_rectangle(
            0,0,0,20, fill='#7FFFD4')  # Aquamarine
        # Submit button
        self.submit_btn = tk.Button(ctrl,
                                    text="Submit",
                                    font=('Arial', 12, 'bold'),
                                    bg='#32CD32', fg='white',
                                    activebackground='#228B22',
                                    state='disabled',
                                    padx=15, pady=5,
                                    command=self.on_submit)
        self.submit_btn.pack(side='right')

        # Leaderboard
        tk.Label(self.quiz_frame,
                 text="Leaderboard",
                 font=('Arial', 14, 'underline'),
                 bg='#E6E6FA')\
          .pack()
        self.lb = tk.Listbox(self.quiz_frame,
                             font=('Arial', 12),
                             bg='#F5FFFA',  # MintCream
                             fg='#006400',  # DarkGreen
                             height=6)
        self.lb.pack(fill='x', padx=100, pady=(5,0))

    def build_footer(self):
        # Bottom footer
        self.footer = tk.Label(self.root,
                               text=("developed by himanshu singh @sv infotech kanpur    "
                                     "mail: himanshusingh1814@gmail.com"),
                               font=('Arial', 10),
                               bg='#D3D3D3',
                               fg='#333333')
        self.footer.pack(side='bottom', fill='x')

    def connect_to_server(self):
        self.sock = socket.socket()
        try:
            self.sock.connect((HOST, PORT))
            self.sock_file = self.sock.makefile('r')
            self.send({'action':'auth','username':self.username})
            resp = json.loads(self.sock_file.readline())
            if resp.get('status')!='ok':
                raise RuntimeError(resp.get('msg','Auth failed'))
        except Exception as e:
            messagebox.showerror("Connection Error", str(e))
            self.root.destroy()
            return
        threading.Thread(target=self.listen, daemon=True).start()

    def send(self, msg):
        self.sock.sendall((json.dumps(msg)+'\n').encode())

    def listen(self):
        for line in self.sock_file:
            m = json.loads(line.strip())
            act = m.get('action')
            if act=='question':
                self.root.after(0, lambda msg=m: self.on_question(msg))
            elif act=='leaderboard':
                self.root.after(0, lambda msg=m: self.on_leaderboard(msg))
            elif act=='final':
                self.root.after(0, lambda msg=m: self.on_final(msg))
                break
        self.sock.close()

    def on_question(self, m):
        self.current = m
        idx, tot = m['question_index'], m['total_questions']
        self.question_lbl.config(text=f"Q{idx+1}/{tot}: {m['question']}")
        for i, opt in enumerate(m['options']):
            self.opts[i].config(text=opt)
        self.radio_var.set(-1)
        self.submit_btn.config(state='normal')
        # reset & start timer/progress
        self.time_left = m.get('time_limit',20)
        self.update_progress()
        self.countdown()

    def update_progress(self):
        idx, tot = self.current['question_index'], self.current['total_questions']
        width = 400 * (idx+1)/tot
        self.prog_canvas.coords(self.prog_bar, 0,0, width,20)

    def countdown(self):
        if self.time_left >= 0:
            self.timer_lbl.config(text=f"Time left: {self.time_left}s")
            self.time_left -= 1
            self.root.after(1000, self.countdown)
        else:
            self.submit_btn.config(state='disabled')

    def on_submit(self):
        choice = self.radio_var.get()
        if choice<0:
            messagebox.showwarning("No Selection", "Please pick an option.")
            return
        self.send({
            'action':'answer',
            'question_index': self.current['question_index'],
            'choice': choice
        })
        self.submit_btn.config(state='disabled')

    def on_leaderboard(self, m):
        self.lb.delete(0, 'end')
        for user, sc in m.get('scores', []):
            self.lb.insert('end', f"{user}: {sc}")

    def on_final(self, m):
        final = m.get('scores', [])
        your = next((s for u,s in final if u==self.username), None)
        board = "\n".join(f"{u}: {s}" for u,s in final)
        messagebox.showinfo("Quiz Over",
            f"Your score: {your}\n\nFinal leaderboard:\n{board}")
        self.root.destroy()

if __name__ == '__main__':
    root = tk.Tk()
    app = QuizClientApp(root)
    root.mainloop()
