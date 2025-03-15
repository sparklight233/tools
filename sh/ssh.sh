#!/bin/bash

# 检查是否以root权限运行
if [[ $EUID -ne 0 ]]; then
   echo "此脚本必须以root权限运行" 
   exit 1
fi

# 备份原始SSH配置文件
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# 定义SSH配置文件
SSH_CONFIG="/etc/ssh/sshd_config"

# 端口设置
while true; do
    read -p "是否要修改SSH端口？(y/n): " change_port
    if [[ $change_port == "y" ]]; then
        while true; do
            read -p "请输入新的SSH端口号(小于65535): " new_port
            
            # 验证端口号是否在有效范围内
            if [[ $new_port -ge 0 && $new_port -le 65535 ]]; then
                # 替换或添加端口配置
                if grep -q "^Port " $SSH_CONFIG; then
                    sed -i "s/^Port .*/Port $new_port/" $SSH_CONFIG
                else
                    echo "Port $new_port" >> $SSH_CONFIG
                fi
                break
            else
                echo "错误：端口号必须在小于65532"
            fi
        done
        break
    elif [[ $change_port == "n" ]]; then
        break
    else
        echo "请输入 y 或 n"
    fi
done

# 密钥登录设置
while true; do
    read -p "是否启用密钥登录？(y/n): " enable_key_login
    if [[ $enable_key_login == "y" ]]; then
        sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/' $SSH_CONFIG
        break
    elif [[ $enable_key_login == "n" ]]; then
        sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication no/' $SSH_CONFIG
        break
    else
        echo "请输入 y 或 n"
    fi
done

# 密码登录设置
while true; do
    read -p "是否禁用密码登录？(y/n): " disable_password_login
    if [[ $disable_password_login == "y" ]]; then
        sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' $SSH_CONFIG
        break
    elif [[ $disable_password_login == "n" ]]; then
        sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' $SSH_CONFIG
        break
    else
        echo "请输入 y 或 n"
    fi
done

# 重启SSH服务
systemctl restart sshd

echo "SSH配置已更新，请使用新配置连接服务器"
