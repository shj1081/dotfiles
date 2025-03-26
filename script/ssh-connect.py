#!/Users/hyzoon/.pyenv/versions/3.9.5/bin/python
import pexpect
import pyotp
import sys
import json
import os
import wcwidth  # 한글 및 유니코드 정렬을 위해 추가
import signal

# ANSI 색상 코드
COLOR_YELLOW = "\033[93m"  # 노란색
COLOR_GREEN = "\033[92m"  # 초록색
COLOR_BOLD = "\033[1m"  # 굵게
COLOR_RESET = "\033[0m"  # 기본색 복원

# 서버 정보 파일 로드
SERVER_FILE = "/Users/hyzoon/dotfiles/script/servers.json"

if not os.path.exists(SERVER_FILE):
    print(
        f"{COLOR_BOLD}❌ Server file '{SERVER_FILE}' not found. Exiting.{COLOR_RESET}"
    )
    sys.exit(1)

with open(SERVER_FILE, "r", encoding="utf-8") as f:
    servers = json.load(f)


# 한글 정렬을 위한 너비 계산 함수
def display_length(text):
    """유니코드 문자의 실제 화면 출력 폭을 반환"""
    return sum(wcwidth.wcswidth(c) for c in text)


# 서버 이름 중 가장 긴 너비 찾기
MAX_NAME_LENGTH = max(display_length(s["name"]) for s in servers.values())

# 서버 목록 출력
print(f"\n{COLOR_BOLD}🔹 Available SSH Servers:{COLOR_RESET}\n")
sorted_servers = sorted(servers.items(), key=lambda x: int(x[0]))

for key, server in sorted_servers:
    colored_key = f"{COLOR_YELLOW}[{key:>2}]{COLOR_RESET}"
    name_padding = " " * (MAX_NAME_LENGTH - display_length(server["name"]))
    print(
        f"  {colored_key} {server['name']}{name_padding}  ({server['host']}:{server['port']})"
    )

# 사용자 입력 받기 (q로 종료 가능)
while True:
    selected = input(
        f"\n💡 {COLOR_GREEN}Select a server (number, or 'q' to quit): {COLOR_RESET}"
    ).strip()

    if selected.lower() == "q":
        print(f"\n🚪 {COLOR_BOLD}Exiting. Goodbye!{COLOR_RESET}\n")
        sys.exit(0)

    if selected in servers:
        server = servers[selected]
        print(
            f"\n🔗 {COLOR_BOLD}Connecting to {server['name']} ({server['host']}:{server['port']})...{COLOR_RESET}\n"
        )
        break
    else:
        print(
            f"\n{COLOR_BOLD}❌ Invalid selection.{COLOR_RESET} Please enter a valid number or 'q' to quit."
        )


# --- Terminal Size Helpers ---
def get_local_win_size():
    """Return (rows, cols) for the current local terminal."""
    rows_cols = os.popen("stty size", "r").read().strip().split()
    if len(rows_cols) == 2:
        return int(rows_cols[0]), int(rows_cols[1])
    return 24, 80  # default fallback if stty fails


def sigwinch_passthrough(sig, frame):
    """Update the child’s win size whenever the local terminal is resized."""
    if child.isalive():
        rows, cols = get_local_win_size()
        child.setwinsize(rows, cols)


# SSH 접속 준비
extra_ssh_options = server.get("extra_ssh_options", "")
ssh_command = (
    f"ssh -tt -o LogLevel=QUIET -p {server['port']} "
    f"{extra_ssh_options} {server['user']}@{server['host']}"
).strip()


# --- Spawn Child Process ---
child = pexpect.spawn(ssh_command, timeout=15, encoding="utf-8")

# 1) Set initial window size
initial_rows, initial_cols = get_local_win_size()
child.setwinsize(initial_rows, initial_cols)

# 2) Catch SIGWINCH to keep resizing in sync
signal.signal(signal.SIGWINCH, sigwinch_passthrough)

child.logfile = None  # 중복 출력 방지 (원하면 sys.stdout으로 지정 가능)

# 비밀번호 입력
child.expect(r"[Pp]assword:")
child.sendline(server["password"])

# OTP가 필요한 경우 추가 입력
if server.get("otp_secret"):
    # OTP 프롬프트 가정
    child.expect(r"[Vv]erification [Cc]ode:")
    totp = pyotp.TOTP(server["otp_secret"])
    otp_code = totp.now()
    child.sendline(otp_code)

# 터미널 세션 유지
print(
    f"✅ {COLOR_BOLD}Connected to {server['name']}. Now in interactive mode.{COLOR_RESET}\n"
)
child.interact()

print(f"\n{COLOR_BOLD}Session closed. Goodbye!{COLOR_RESET}\n")
