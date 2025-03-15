#!/bin/bash
export LANG=en_US.UTF-8
# 定义颜色
re='\e[0m'
red='\e[1;91m'
white='\e[1;97m'
green='\e[1;32m'
yellow='\e[1;33m'
purple='\e[1;35m'
skyblue='\e[1;96m'

# 检查是否为root下运行
[[ $EUID -ne 0 ]] && echo -e "${red}注意: 请在root用户下运行脚本${re}" && sleep 1 && exit 1


# 获取当前服务器ipv4和ipv6
ip_address() {
    ipv4_address=$(curl -s ipv4.ip.sb)
    ipv6_address=$(curl -s --max-time 1 ipv6.ip.sb)
}

# 安装依赖包
install() {
    if [ $# -eq 0 ]; then
        echo -e "${red}未提供软件包参数!${re}"
        return 1
    fi

    for package in "$@"; do
        if command -v "$package" &>/dev/null; then
            echo -e "${green}${package}已经安装了！${re}"
            continue
        fi
        echo -e "${yellow}正在安装 ${package}...${re}"
        if command -v apt &>/dev/null; then
            apt install -y "$package"
        elif command -v dnf &>/dev/null; then
            dnf install -y "$package"
        elif command -v yum &>/dev/null; then
            yum install -y "$package"
        elif command -v apk &>/dev/null; then
            apk add "$package"
        else
            echo -e"${red}暂不支持你的系统!${re}"
            return 1
        fi
    done

    return 0
}


# 卸载依赖包
remove() {
    if [ $# -eq 0 ]; then
        echo -e "${red}未提供软件包参数!${re}"
        return 1
    fi

    for package in "$@"; do
        if command -v apt &>/dev/null; then
            apt remove -y "$package" && apt autoremove -y
        elif command -v dnf &>/dev/null; then
            dnf remove -y "$package" && dnf autoremove -y
        elif command -v yum &>/dev/null; then
            yum remove -y "$package" && yum autoremove -y
        elif command -v apk &>/dev/null; then
            apk del "$package"
        else
            echo -e "${red}暂不支持你的系统!${re}"
            return 1
        fi
    done

    return 0
}

# 初始安装依赖包
install_dependency() {
      clear
      install wget socat unzip tar
}

# 等待用户返回
break_end() {
    echo -e "${green}执行完成${re}"
    echo -e "${yellow}按任意键返回...${re}"
    read -n 1 -s -r -p ""
    echo ""
    clear
}
# 返回主菜单
main_menu() {
    cd ~
    ./ssh_tool.sh
    exit
}



# 主菜单循环
while true; do
clear
echo "-------------------------------------------------------------------"
echo -e "${skyblue} ##  ## #####   ####       ######  ####   ####  ##      ${re}" 
echo -e "${skyblue} ##  ## ##  ## ##            ##   ##  ## ##  ## ##      ${re}" 
echo -e "${skyblue} ##  ## #####   ####.        ##   ##  ## ##  ## ##      ${re}" 
echo -e "${skyblue}  ####  ##         ##        ##   ##  ## ##  ## ##      ${re}" 
echo -e "${skyblue}   ##   ##     ####          ##    ####   ####  ######  ${re}"  
echo -e ""
echo -e "                 ${yellow}VPS一键脚本工具 v8.8.8${re}"
echo -e ""
echo "-------------------------------------------------------------------"
echo -e "${green} 1. 本机信息${re}"
echo -e "${green} 2. 系统更新${re}"
echo -e "${green} 3. 系统清理${re}"
echo -e "${green} 4. 系统工具${re}"
echo -e "${green} 5. 测试脚本${re}"
echo "-------------------------------------------------------------------"       
echo -e "${purple} 6. 魔法工具${re}"        
echo -e "${green}00. 脚本更新${re}"
echo "-------------------------------------------------------------------"
echo -e "${red} 88. 退出脚本${re}"
echo -e "${yellow}-------------------------------------------------------------------${re}"
read -p $'\033[1;91m请输入你的选择: \033[0m' choice

case $choice in
  1)
    clear
    ip_address
    
    if [ "$(uname -m)" == "x86_64" ]; then
      cpu_info=$(cat /proc/cpuinfo | grep 'model name' | uniq | sed -e 's/model name[[:space:]]*: //')
    else
      cpu_info=$(lscpu | grep 'Model name' | sed -e 's/Model name[[:space:]]*: //')
    fi

    cpu_usage=$(top -bn1 | grep 'Cpu(s)' | awk '{print $2 + $4}')
    cpu_usage_percent=$(printf "%.2f" "$cpu_usage")%

    cpu_cores=$(nproc)

    mem_info=$(free -b | awk 'NR==2{printf "%.2f/%.2f MB (%.2f%%)", $3/1024/1024, $2/1024/1024, $3*100/$2}')

    disk_info=$(df -h | awk '$NF=="/"{printf "%d/%dGB (%s)", $3,$2,$5}')

    country=$(curl -s ipinfo.io/country)
    city=$(curl -s ipinfo.io/city)

    isp_info=$(curl -s ipinfo.io/org)

    cpu_arch=$(uname -m)

    hostname=$(hostname)

    kernel_version=$(uname -r)

    congestion_algorithm=$(sysctl -n net.ipv4.tcp_congestion_control)
    queue_algorithm=$(sysctl -n net.core.default_qdisc)

    # 尝试使用 lsb_release 获取系统信息
    os_info=$(lsb_release -ds 2>/dev/null)

    # 如果 lsb_release 命令失败，则尝试其他方法
    if [ -z "$os_info" ]; then
      # 检查常见的发行文件
      if [ -f "/etc/os-release" ]; then
        os_info=$(source /etc/os-release && echo "$PRETTY_NAME")
      elif [ -f "/etc/debian_version" ]; then
        os_info="Debian $(cat /etc/debian_version)"
      elif [ -f "/etc/redhat-release" ]; then
        os_info=$(cat /etc/redhat-release)
      else
        os_info="Unknown"
      fi
    fi

    clear
    output=$(awk 'BEGIN { rx_total = 0; tx_total = 0 }
        NR > 2 { rx_total += $2; tx_total += $10 }
        END {
            rx_units = "Bytes";
            tx_units = "Bytes";
            if (rx_total > 1024) { rx_total /= 1024; rx_units = "KB"; }
            if (rx_total > 1024) { rx_total /= 1024; rx_units = "MB"; }
            if (rx_total > 1024) { rx_total /= 1024; rx_units = "GB"; }

            if (tx_total > 1024) { tx_total /= 1024; tx_units = "KB"; }
            if (tx_total > 1024) { tx_total /= 1024; tx_units = "MB"; }
            if (tx_total > 1024) { tx_total /= 1024; tx_units = "GB"; }

            printf("总接收: %.2f %s\n总发送: %.2f %s\n", rx_total, rx_units, tx_total, tx_units);
        }' /proc/net/dev)


    current_time=$(date "+%Y-%m-%d %I:%M %p")


    swap_used=$(free -m | awk 'NR==3{print $3}')
    swap_total=$(free -m | awk 'NR==3{print $2}')

    if [ "$swap_total" -eq 0 ]; then
        swap_percentage=0
    else
        swap_percentage=$((swap_used * 100 / swap_total))
    fi

    swap_info="${swap_used}MB/${swap_total}MB (${swap_percentage}%)"

    runtime=$(cat /proc/uptime | awk -F. '{run_days=int($1 / 86400);run_hours=int(($1 % 86400) / 3600);run_minutes=int(($1 % 3600) / 60); if (run_days > 0) printf("%d天 ", run_days); if (run_hours > 0) printf("%d时 ", run_hours); printf("%d分\n", run_minutes)}')

    echo ""
    echo -e "${white}系统信息详情${re}"
    echo "------------------------"
    echo -e "${white}主机名: ${purple}${hostname}${re}"
    echo -e "${white}运营商: ${purple}${isp_info}${re}"
    echo "------------------------"
    echo -e "${white}系统版本: ${purple}${os_info}${re}"
    echo -e "${white}Linux版本: ${purple}${kernel_version}${re}"
    echo "------------------------"
    echo -e "${white}CPU架构: ${purple}${cpu_arch}${re}"
    echo -e "${white}CPU型号: ${purple}${cpu_info}${re}"
    echo -e "${white}CPU核心数: ${purple}${cpu_cores}${re}"
    echo "------------------------"
    echo -e "${white}CPU占用: ${purple}${cpu_usage_percent}${re}"
    echo -e "${white}物理内存: ${purple}${mem_info}${re}"
    echo -e "${white}虚拟内存: ${purple}${swap_info}${re}"
    echo -e "${white}硬盘占用: ${purple}${disk_info}${re}"
    echo "------------------------"
    echo -e "${purple}$output${re}"
    echo "------------------------"
    echo -e "${white}网络拥堵算法: ${purple}${congestion_algorithm} ${queue_algorithm}${re}"
    echo "------------------------"
    echo -e "${white}公网IPv4地址: ${purple}${ipv4_address}${re}"
    echo -e "${white}公网IPv6地址: ${purple}${ipv6_address}${re}"
    echo "------------------------"
    echo -e "${white}地理位置: ${purple}${country} $city${re}"
    echo -e "${white}系统时间: ${purple}${current_time}${re}"
    echo "------------------------"
    echo -e "${white}系统运行时长: ${purple}${runtime}${re}"
    echo

    ;;

  2)
    clear
    update_system() {
        if command -v apt &>/dev/null; then
            apt-get update && apt-get upgrade -y
        elif command -v dnf &>/dev/null; then
            dnf check-update && dnf upgrade -y
        elif command -v yum &>/dev/null; then
            yum check-update && yum upgrade -y
        elif command -v apk &>/dev/null; then
            apk update && apk upgrade
        else
            echo -e "${red}不支持的Linux发行版${re}"
            return 1
        fi
        return 0
    }

    update_system

    ;;
  3)
    clear
        clean_system() {

            if command -v apt &>/dev/null; then
                apt autoremove --purge -y && apt clean -y && apt autoclean -y
                apt remove --purge $(dpkg -l | awk '/^rc/ {print $2}') -y
                # 清理包配置文件
                journalctl --vacuum-time=1s
                journalctl --vacuum-size=50M
                # 移除不再需要的内核
                apt remove --purge $(dpkg -l | awk '/^ii linux-(image|headers)-[^ ]+/{print $2}' | grep -v $(uname -r | sed 's/-.*//') | xargs) -y
            elif command -v yum &>/dev/null; then
                yum autoremove -y && yum clean all
                # 清理日志
                journalctl --vacuum-time=1s
                journalctl --vacuum-size=50M
                # 移除不再需要的内核
                yum remove $(rpm -q kernel | grep -v $(uname -r)) -y
            elif command -v dnf &>/dev/null; then
                dnf autoremove -y && dnf clean all
                # 清理日志
                journalctl --vacuum-time=1s
                journalctl --vacuum-size=50M
                # 移除不再需要的内核
                dnf remove $(rpm -q kernel | grep -v $(uname -r)) -y
            elif command -v apk &>/dev/null; then
                apk autoremove -y
                apk clean
                # 清理包配置文件
                apk del $(apk info -e | grep '^r' | awk '{print $1}') -y
                # 清理日志文件
                journalctl --vacuum-time=1s
                journalctl --vacuum-size=50M
                # 移除不再需要的内核
                apk del $(apk info -vv | grep -E 'linux-[0-9]' | grep -v $(uname -r) | awk '{print $1}') -y
            else
                echo -e "${red}暂不支持你的系统！${re}"
                exit 1
            fi
        }
        clean_system
    ;;

  4)
    while true; do
      clear
      echo -e "${purple} ▶ 系统工具${re}"
      echo "------------------------"
      echo -e "${yellow} 1. 魔法工具${re}"
      echo "------------------------"
      echo -e "${skyblue} 2. 修改ssh设置${re}"
      echo -e "${skyblue} 3. 虚拟内存${re}"
      echo -e "${skyblue} 4. BBR管理${re}"
      echo -e "${skyblue} 5. 安装防火墙${re}"
      echo -e "${skyblue} 6. 节点搭建${re}"
      echo -e "${skyblue} 7. 端口转发${re}"
      echo -e "${skyblue} 8. dd系统(bin456789)${re}"
      echo -e "${skyblue} 9. dd系统(leitbogioro)${re}"
      echo -e "${skyblue} 10. warp管理${re}"
      echo -e "${skyblue} 11. 挂探针${re}"
      echo -e "${skyblue} 12. 安装1Panel${re}"
      echo -e "${skyblue} 13. DNS解锁${re}"
      echo -e "${skyblue} 14. 必要组件${re}"
      echo -e "${skyblue} 15. 安装docker${re}"        
      echo "---------------------------"
      echo -e "${skyblue} 0. 返回主菜单${re}"
      read -p $'\033[1;91m请输入你的选择: \033[0m' sub_choice

      case $sub_choice in
          1)
              clear
              install wget
              wget https://raw.githubusercontent.com/sparklight233/tools/refs/heads/main/sh/magic.sh && chmod +x magic.sh && ./magic.sh
               rm magic.sh
            ;;
          2)
              clear
              install wget
              wget -q https://raw.githubusercontent.com/sparklight233/tools/refs/heads/main/sh/ssh.sh && chmod +x  ssh.sh && ./ssh.sh
              rm ssh.sh
            ;;
          3)
              clear
              curl -sS -O https://raw.githubusercontent.com/woniu336/open_shell/main/zram_manager.sh && chmod +x zram_manager.sh && ./zram_manager.sh
              rm zram_manager.sh
            ;;
          4)
              clear
              install wget
              wget --no-check-certificate -O tcpx.sh https://raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcpx.sh && chmod +x tcpx.sh && ./tcpx.sh
              rm tcpx.sh
            ;;
          5)
              clear
              current_ssh_port=$(grep "^Port" /etc/ssh/sshd_config | awk '{print $2}')
    
              if [ -z "$current_ssh_port" ]; then
                      current_ssh_port=22
              fi
              echo "${yellow}当前SSH端口为: $current_ssh_port${re}"    
              read -p "${yellow}是否启用UFW防火墙？(y/n): ${re}" enable_ufw    
              if [[ $enable_ufw == "y" ]]; then     
                  sudo apt install ufw -y
                  sudo ufw default allow outgoing
                  sudo ufw default deny incoming
                  sudo ufw allow "$current_ssh_port"/tcp      
              fi
              echo "SSH端口 $current_ssh_port 已放行"    

              read -p "${red}确认启用UFW防火墙？启用后如果配置不当可能会断开连接(y/n): ${re}" confirm_enable
              if [[ $confirm_enable == "y" ]]; then
                  sudo ufw enable
                  echo "${yellow}UFW已启用${re}"
              else
                  echo "${yellow}已取消UFW配置${re}"               
              fi
            ;;
          6)
              clear
              bash <(wget -qO- -o- https://github.com/233boy/sing-box/raw/main/install.sh)
             ;;
          7)
              clear
              wget -N https://raw.githubusercontent.com/qqrrooty/EZrealm/main/realm.sh && chmod +x realm.sh && ./realm.sh
              rm realm.sh
             ;;
         8)
              clear
              echo -e "${red}警告: 重装系统会导致所有数据丢失！请确保已备份重要数据！${re}"
              read -p "是否确认继续执行dd系统操作？(y/n): " confirm_dd
              if [[ $confirm_dd != "y" ]]; then
                  echo "已取消dd系统操作"
                  break
              fi
    
              current_ssh_port=$(grep -E "^Port " /etc/ssh/sshd_config | awk '{print $2}')
              current_ssh_port=${current_ssh_port:-22}
              echo -e "${green}当前SSH端口为: ${current_ssh_port}${re}"
              read -p "请设置系统密码(默认: Lyx12345@): " custom_password
              custom_password=${custom_password:-Lyx12345@}  
              curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh || wget -O reinstall.sh $_
              bash reinstall.sh debian12 --password $custom_password
              echo -e "${yellow}脚本已安装完毕，30秒后将重启系统并开始安装，请牢记下面信息，并耐心等待重装完成...${re}"
              echo -e "${yellow}新系统SSH端口为: $current_ssh_port${re}"
              echo -e "${yellow}新系统SSH用户为: root${re}"
              echo -e "${yellow}新系统SSH密码为: $custom_password${re}"
              sleep 30
              reboot
            ;;
         9)
              clear
              echo -e "${red}警告: 重装系统会导致所有数据丢失！请确保已备份重要数据！${re}"
              read -p "是否确认继续执行dd系统操作？(y/n): " confirm_dd
              if [[ $confirm_dd != "y" ]]; then
                  echo "已取消dd系统操作"
                  break
              fi

              read -p "请设置系统密码(默认: Lyx12345@): " custom_password
              custom_password=${custom_password:-Lyx12345@}
        
              read -p "请设置SSH端口(默认: 51888): " custom_port
              custom_port=${custom_port:-51888}
        
              read -p "请设置主机名(默认: debian12): " custom_hostname
              custom_hostname=${custom_hostname:-debian12}
              
              apt update -y
              apt install wget -y
              wget --no-check-certificate -qO InstallNET.sh 'https://raw.githubusercontent.com/leitbogioro/Tools/master/Linux_reinstall/InstallNET.sh' && chmod a+x InstallNET.sh
              bash InstallNET.sh -debian -pwd ${custom_password} -hostname ${custom_hostname} -port ${custom_port}
              echo -e "${yellow}脚本已安装完毕，30秒后将重启系统并开始安装，请牢记下面信息，并耐心等待重装完成...${re}"
              echo -e "${yellow}新系统SSH端口为: $custom_port${re}"
              echo -e "${yellow}新系统SSH用户为: root${re}"
              echo -e "${yellow}新系统SSH密码为: $custom_password${re}"
              sleep 30
              reboot
            ;;
          10)
              clear
              install wget
              wget -N https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh && bash menu.sh [option] [lisence/url/token]
            ;;
          11)
              clear
              mkdir -p /root/data/cgent
              mkdir /root/data/cgent
              docker run -d -v=/root/cgent/:/root/ --name=cgent --restart=always --net=host --cap-add=NET_RAW -e SECRET=8vb0R7wuNjrXdxZgkrNQAgsRhfyhtesF -e SERVER=nezha.20061222.xyz:443 -e TLS=true ghcr.io/yosebyte/cgent
            ;;
          12)
              clear
              curl -sSL https://resource.fit2cloud.com/1panel/package/quick_start.sh -o quick_start.sh && sudo bash quick_start.sh
            ;;
          13)
              clear
              wget https://raw.githubusercontent.com/Jimmyzxk/DNS-Alice-Unlock/refs/heads/main/dns-unlock.sh && bash dns-unlock.sh
            ;;
          14)
              clear
              apt update -y
              apt install sudo
              apt install wget -y
              apt install curl -y
            ;;
          15)
              clear
              curl -fsSL https://get.docker.com -o get-docker.sh
              sudo sh get-docker.sh
            ;;
          0)
              main_menu
              ;;
          *)
              echo "无效的输入!"
              ;;
       esac
      break_end
    done
    ;;
  5)
    while true; do
      clear
      echo -e "${purple}▶ 测试脚本合集${re}"
      echo ""
      echo -e "${skyblue} 1. 融合怪${re}"
      echo -e "${skyblue} 2. yabs${re}"
      echo -e "${skyblue} 3. 网络质量${re}"
      echo -e "${skyblue} 4. IP解锁${re}"
      echo -e "${skyblue} 5. 三网测速${re}"
      echo -e "${skyblue} 6. 回程路由${re}"
      echo "---------------------------"
      echo -e "${skyblue} 0. 返回主菜单${re}"
      echo "---------------------------"
      read -p $'\033[1;91m请输入你的选择: \033[0m' sub_choice
      case $sub_choice in
          1)
              clear
              curl -L https://gitlab.com/spiritysdx/za/-/raw/main/ecs.sh -o ecs.sh && chmod +x ecs.sh && bash ecs.sh
              ;;
          2)
              clear
              curl -sL https://yabs.sh | bash
              ;;
          3)
              clear
              bash <(curl -sL Net.Check.Place)
              ;;
          4)
              clear
              bash <(curl -Ls IP.Check.Place)
              ;;
          5)
              clear
              bash <(curl -sL https://raw.githubusercontent.com/i-abc/Speedtest/main/speedtest.sh)
              ;;
          6)
              clear
              curl nxtrace.org/nt |bash
              nexttrace --fast-trace --tcp
              ;;
          0)
              main_menu
              ;;
          *)
              echo "无效的输入!"
              ;;
      esac
        break_end
    done
    ;;


 
  6)
    clear
    install wget
    wget https://raw.githubusercontent.com/sparklight233/tools/refs/heads/main/sh/magic.sh && chmod +x magic.sh && ./magic.sh
    rm magic.sh
    ;;

  00)
    cd ~
    rm ssh_tool.sh
    echo ""
    curl -fsSL https://raw.githubusercontent.com/sparklight233/tools/refs/heads/main/ssh_tool.sh -o ssh_tool.sh && chmod +x ssh_tool.sh && ./ssh_tool.sh    echo -e "${green}脚本已更新到最新版本！${re}"
    sleep 1
    main_menu
    ;;
    
  88)
    clear
    exit
    ;;

  *)
    echo -e "${purple}无效的输入!${re}"
    ;;
esac
    break_end
done
