#!/bin/zsh

# 설정: JSON 파일 경로
SERVER_FILE="$HOME/dotfiles/script/servers.json"

# ANSI 색상 코드
COLOR_YELLOW="\033[93m"
COLOR_GREEN="\033[92m"
COLOR_BOLD="\033[1m"
COLOR_RESET="\033[0m"

# 서버 정보 파일 확인
if [[ ! -f "$SERVER_FILE" ]]; then
    echo -e "${COLOR_BOLD}❌ Server file '$SERVER_FILE' not found. Exiting.${COLOR_RESET}"
    exit 1
fi

# JSON 파싱
SERVERS=()
while IFS= read -r line; do
    SERVERS+=("$line")
done < <(jq -r 'to_entries | map("\(.key) \(.value.name) \(.value.host) \(.value.port)") | .[]' "$SERVER_FILE")

# 최대 이름 길이 계산
function display_length {
    print -n "$1" | awk '{print length}'
}

MAX_NAME_LENGTH=0
for entry in "${SERVERS[@]}"; do
    name=$(echo "$entry" | awk '{print $2}')
    name_len=$(display_length "$name")
    (( name_len > MAX_NAME_LENGTH )) && MAX_NAME_LENGTH=$name_len
done

# 서버 목록 출력
echo -e "\n${COLOR_BOLD}🔹 Available SSH Servers:${COLOR_RESET}\n"
for entry in "${SERVERS[@]}"; do
    key=$(echo "$entry" | awk '{print $1}')
    name=$(echo "$entry" | awk '{print $2}')
    host=$(echo "$entry" | awk '{print $3}')
    port=$(echo "$entry" | awk '{print $4}')
    
    name_padding=$(( MAX_NAME_LENGTH - $(display_length "$name") ))
    printf "  ${COLOR_YELLOW}[%2s]${COLOR_RESET} %s%*s  (%s:%s)\n" "$key" "$name" "$name_padding" "" "$host" "$port"
done

# 사용자 입력 받기
while true; do
    read -r "selected?💡 \033[92mSelect a server (number, or 'q' to quit): \033[0m"

    if [[ "$selected" == "q" ]]; then
        echo -e "\n🚪 ${COLOR_BOLD}Exiting. Goodbye!${COLOR_RESET}\n"
        exit 0
    fi

    # 선택한 서버 정보 가져오기
    server_info=$(jq -r --arg sel "$selected" '.[$sel] // empty' "$SERVER_FILE")

    if [[ -n "$server_info" ]]; then
        name=$(echo "$server_info" | jq -r '.name')
        host=$(echo "$server_info" | jq -r '.host')
        port=$(echo "$server_info" | jq -r '.port')
        user=$(echo "$server_info" | jq -r '.user')
        password=$(echo "$server_info" | jq -r '.password')
        otp_secret=$(echo "$server_info" | jq -r '.otp_secret // empty')
        extra_ssh_options=$(echo "$server_info" | jq -r '.extra_ssh_options // empty')

        echo -e "\n🔗 ${COLOR_BOLD}Connecting to $name ($host:$port)...${COLOR_RESET}\n"
        break
    else
        echo -e "\n${COLOR_BOLD}❌ Invalid selection.${COLOR_RESET} Please enter a valid number or 'q' to quit."
    fi
done

# Expect 스크립트 실행 (OTP 감지 및 SSH 유지)
expect <<EOF
set timeout -1
spawn ssh -tt -p $port $user@$host $extra_ssh_options

expect {
    -re {[Pp]assword:} {
        send "$password\r"
        exp_continue
    }
    -re {[Vv]erification [Cc]ode:} {
        if { "$otp_secret" ne "" } {
            set otp_code [exec python3 -c "import pyotp; print(pyotp.TOTP(\"$otp_secret\").now())"]
            send "$otp_code\r"
            exp_continue
        } else {
            send_user "\n⚠️  OTP is required, but not provided.\n"
            exit 1
        }
    }
    -re {[$] } {
        send_user "\n✅ Logged in successfully! You can now execute commands.\n"
        interact
    }
    eof {
        send_user "\n❌ SSH connection closed unexpectedly.\n"
        exit 1
    }
}
EOF
