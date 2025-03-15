  4)
    while true; do
      clear
      echo -e "${skyblue}" ▶ 系统工具"
      echo "------------------------"
      echo -e "${skyblue}" 1. 设置脚本启动快捷键"
      echo "------------------------"
      echo -e "${skyblue}" 2. 修改ssh设置"
      echo -e "${skyblue}" 3. 虚拟内存"
      echo -e "${skyblue}" 4. BBR管理"
      echo -e "${skyblue}" 5. 安装防火墙"
      echo -e "${skyblue}" 6. 节点搭建"
      echo -e "${skyblue}" 7. 端口转发"
      echo -e "${skyblue}" 8. dd系统(bin456789)"
      echo -e "${skyblue}" 9. dd系统(史上最强)"
      echo -e "${skyblue}" 10. warp管理"
      echo -e "${skyblue}" 11. 挂探针"
      echo -e "${skyblue}" 12. 安装1Panel"
      echo -e "${skyblue}" 13. DNS解锁"
      echo -e "${skyblue}" 14. 必要组件" 
      echo -e "${skyblue}" 15. 安装docker"         
      echo "---------------------------"
      echo -e "${skyblue} 0. 返回主菜单${re}"
      read -p $'\033[1;91m请输入你的选择: \033[0m' sub_choice

      case $sub_choice in
          1)
              clear
              read -p $'\033[1;91m请输入你的快捷按键: \033[0m' kuaijiejian              
                [ -z "$kuaijiejian" ] && echo -e "${red}你似乎什么也没输入${re}" && main_menu || kuaijiejian_value="$kuaijiejian"
    
                # 将 $kuaijiejian 转换为大写和小写
                uppercase_value=$(echo "$kuaijiejian_value" | tr '[:lower:]' '[:upper:]')
                lowercase_value=$(echo "$kuaijiejian_value" | tr '[:upper:]' '[:lower:]')

                # 判断 $kuaijiejian 的值是大写还是小写
                if [[ "$kuaijiejian_value" == "$uppercase_value" ]]; then
                    sed -i "s/alias L=/alias $kuaijiejian_value=/g" ~/.bashrc ~/.profile ~/.bash_profile
                    sed -i "s/alias l=/alias $lowercase_value=/g" ~/.bashrc ~/.profile ~/.bash_profile
                elif [[ "$kuaijiejian_value" == "$lowercase_value" ]]; then
                    sed -i "s/alias l=/alias $kuaijiejian_value=/g" ~/.bashrc ~/.profile ~/.bash_profile
                    sed -i "s/alias L=/alias $uppercase_value=/g" ~/.bashrc ~/.profile ~/.bash_profile
                else
                    echo -e "${red}请输入大写或小写字母${re}"
                fi
                source ~/.bashrc && source ~/.profile && source ~/.bash_profile
                echo -e "${green}快捷键已设置${re}"
              ;;


          2)
              clear
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
              echo "当前SSH端口为: $current_ssh_port"    
              read -p "是否启用UFW防火墙？(y/n): " enable_ufw    
              if [[ $enable_ufw == "y" ]]; then     
                  sudo apt install ufw -y
                  sudo ufw default allow outgoing
                  sudo ufw default deny incoming
                  sudo ufw allow "$current_ssh_port"/tcp      
              fi
              echo "SSH端口 $current_ssh_port 已放行"    

              read -p "确认启用UFW防火墙？启用后如果配置不当可能会断开连接(y/n): " confirm_enable
              if [[ $confirm_enable == "y" ]]; then
                  sudo ufw enable
                  echo "UFW已启用"
              else
                  echo "已取消UFW配置"               
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
              curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh || wget -O reinstall.sh $_
              bash reinstall.sh debian12 --password Lyx12345@
            ;;
          9)
              clear
              apt update -y
              apt install wget -y
              wget --no-check-certificate -qO InstallNET.sh 'https://raw.githubusercontent.com/leitbogioro/Tools/master/Linux_reinstall/InstallNET.sh' && chmod a+x InstallNET.sh
              bash InstallNET.sh -debian -password Lyx12345@ -hostname debian12 -port 51888
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
