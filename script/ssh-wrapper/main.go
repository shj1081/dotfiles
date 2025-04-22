package main

import (
	"bufio"
	"fmt"
	"os"
	"os/exec"
	"os/signal"
	"strconv"
	"strings"
	"syscall"
	"time"

	"github.com/charmbracelet/huh"
	"github.com/creack/pty"
	"github.com/pquerna/otp/totp"
	"gopkg.in/yaml.v3"

	"golang.org/x/term"
)

// ANSI 색상
const (
	ColorReset  = "\033[0m"
	ColorGreen  = "\033[32m"
	ColorYellow = "\033[33m"
	ColorCyan   = "\033[36m"
	ColorBold   = "\033[1m"
)

type Server struct {
	Name      string `yaml:"name"`
	Host      string `yaml:"host"`
	Port      int    `yaml:"port"`
	User      string `yaml:"user"`
	Password  string `yaml:"password"`
	OTPSecret string `yaml:"otp_secret,omitempty"`
}

type Config struct {
	VPNOTPSecret string   `yaml:"vpn_otp_secret"`
	Servers      []Server `yaml:"servers"`
}

func main() {
	// 서버 정보 파일 경로
	const serverFile = "/Users/hyzoon/dotfiles/script/servers.yaml"
	data, err := os.ReadFile(serverFile)
	if err != nil {
		fmt.Printf("Server file '%s' not found.\n", serverFile)
		os.Exit(1)
	}

	// YAML 파싱 (config struct)
	var config Config
	if err := yaml.Unmarshal(data, &config); err != nil {
		fmt.Println("Failed to parse YAML:", err)
		os.Exit(1)
	}

	// VPN OTP 표시 (terminal printout)
	if config.VPNOTPSecret != "" {
		otp, err := totp.GenerateCode(config.VPNOTPSecret, time.Now())
		if err == nil {
			fmt.Printf("%s[VPN OTP]%s %s\n\n", ColorBold, ColorReset, otp)
		} else {
			fmt.Printf("%s[VPN OTP]%s (invalid secret)\n\n", ColorBold, ColorReset)
		}
	}

	servers := config.Servers

	// 서버 이름 최대 길이 계산
	maxNameLen := 0
	for _, s := range servers {
		nameLen := len([]rune(s.Name))
		if nameLen > maxNameLen {
			maxNameLen = nameLen
		}
	}

	// 선택지 구성
	var selectedIdx int
	options := []huh.Option[int]{}
	for idx, s := range servers {
		namePadded := fmt.Sprintf("%-*s", maxNameLen, s.Name)
		label := fmt.Sprintf(
			"%s[%2d]%s %s%s%s (%s%s%s:%s%d%s)",
			ColorBold, idx+1, ColorReset,
			ColorBold, namePadded, ColorReset,
			ColorCyan, s.Host, ColorReset,
			ColorGreen, s.Port, ColorReset,
		)
		options = append(options, huh.NewOption(label, idx))
	}

	// TUI 폼 구성
	form := huh.NewForm(
		huh.NewGroup(
			huh.NewSelect[int]().
				Title("SSH Server Selector").
				Description("Select a server to connect via SSH").
				Options(options...).
				Value(&selectedIdx),
		),
	)

	// TUI 실행
	if err := form.Run(); err != nil {
		fmt.Println("Selection cancelled.")
		os.Exit(0)
	}

	server := servers[selectedIdx]
	fmt.Printf(
		"\n%sConnecting to%s %s%s%s (%s%s:%d%s)...\n\n",
		ColorBold, ColorReset,
		ColorGreen, server.Name, ColorReset,
		ColorCyan, server.Host, server.Port, ColorReset,
	)

	// SSH 명령 구성
	args := []string{
		"-tt",
		"-o", "LogLevel=QUIET",
		"-p", strconv.Itoa(server.Port),
		fmt.Sprintf("%s@%s", server.User, server.Host),
	}
	cmd := exec.Command("ssh", args...)
	// 실제 터미널의 TERM 환경변수 사용
	cmd.Env = append(os.Environ(), "TERM="+os.Getenv("TERM"))

	// PTY 시작
	ptmx, err := pty.Start(cmd)
	if err != nil {
		fmt.Println("Failed to start SSH session:", err)
		os.Exit(1)
	}
	defer ptmx.Close()

	// 터미널 크기 동기화
	ch := make(chan os.Signal, 1)
	signal.Notify(ch, syscall.SIGWINCH)
	go func() {
		for range ch {
			_ = pty.InheritSize(os.Stdin, ptmx)
		}
	}()
	ch <- syscall.SIGWINCH // 초기 크기 동기화

	// stdin을 raw mode로 전환
	oldState, err := term.MakeRaw(int(os.Stdin.Fd()))
	if err != nil {
		fmt.Println("Failed to set raw mode:", err)
		os.Exit(1)
	}
	defer term.Restore(int(os.Stdin.Fd()), oldState)

	// 사용자 입력 → SSH
	go func() {
		_, _ = bufio.NewReader(os.Stdin).WriteTo(ptmx)
	}()

	// SSH 출력 → 프롬프트 감지 및 자동 응답
	go func() {
		buf := make([]byte, 1024)
		line := ""
		passwordSent := false // Only send password once
		for {
			n, err := ptmx.Read(buf)
			if err != nil {
				break
			}
			chunk := string(buf[:n])
			fmt.Print(chunk)
			line += chunk

			lower := strings.ToLower(line)

			// 비밀번호 감지 (only once)
			if !passwordSent && strings.Contains(lower, "password:") && server.Password != "" {
				time.Sleep(150 * time.Millisecond)
				ptmx.Write([]byte(server.Password + "\n"))
				passwordSent = true
				line = ""
				continue
			}
			// OTP 감지
			if strings.Contains(lower, "verification code:") && server.OTPSecret != "" {
				otp, err := totp.GenerateCode(server.OTPSecret, time.Now())
				if err == nil {
					time.Sleep(150 * time.Millisecond)
					ptmx.Write([]byte(otp + "\n"))
					line = ""
					continue
				}
			}

			if len(line) > 2048 {
				line = ""
			}
		}
	}()

	if err := cmd.Wait(); err != nil {
		fmt.Println("SSH session ended with error:", err)
	}
}
