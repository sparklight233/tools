#!/bin/bash

# 函数：输出颜色定义
color_print() {
    local color_code=""
    case $1 in
        red)    color_code="31;31";;
        green)  color_code="31;32";;
        yellow) color_code="31;33";;
        blue)   color_code="31;36";;
        *)      color_code="0";;
    esac
    printf '\033[0;%sm%b\033[0m\n' "$color_code" "$2"
}

# 函数：打印分隔符
greenline() {
    color_print green "----------------------------------------------"
}

# 函数：如果非root登录则退出
check_root() {
    if [ "$UID" -ne 0 ]; then
        color_print red "必须以root用户执行此脚本"
        exit 1
    fi
}

# 函数：介绍
print_intro() {
    clear
    greenline
    color_print yellow "SSH服务配置工具"
    echo -e "此脚本可以帮助您：\n- 修改SSH端口\n- 启用公钥认证\n- 添加SSH公钥\n- 禁用密码登录"
    greenline
    color_print yellow "按任意键继续..."
    read -s -n1 -p ""
}

# 函数：备份SSH配置文件
backup_ssh_config() {
    SSH_CONFIG="/etc/ssh/sshd_config"
    if [[ -f /etc/ssh/sshd_config.backup ]]; then
        color_print blue "已存在备份文件：/etc/ssh/sshd_config.backup"
    else
        cp $SSH_CONFIG /etc/ssh/sshd_config.backup
        color_print blue "SSH配置已备份为：/etc/ssh/sshd_config.backup"
    fi
}

# 函数：修改SSH端口
change_ssh_port() {
    greenline
    current_port=$(grep -w "^Port" $SSH_CONFIG | awk '{print $2}')
    if [ -z "$current_port" ]; then
        current_port=22
    fi
    
    color_print yellow "当前SSH端口为：$current_port"
    read -p "是否要修改SSH端口？(y/n): " change_port
    
    if [[ $change_port == "y" ]]; then
        while true; do
            read -p "请输入新的SSH端口号(1-65535): " new_port
            
            # 验证端口号是否在有效范围内
            if [[ $new_port -ge 1 && $new_port -le 65535 ]]; then
                # 替换或添加端口配置
                if grep -q "^Port " $SSH_CONFIG; then
                    sed -i "s/^Port .*/Port $new_port/" $SSH_CONFIG
                else
                    echo "Port $new_port" >> $SSH_CONFIG
                fi
                color_print green "SSH端口已修改为：$new_port"
                break
            else
                color_print red "错误：端口号必须在1-65535之间"
            fi
        done
    else
        color_print blue "保持当前SSH端口：$current_port"
    fi
}

# 函数：配置公钥登录
setup_key_authentication() {
    greenline
    read -p "是否启用密钥登录？(y/n): " enable_key_login
    
    if [[ $enable_key_login == "y" ]]; then
        # 设置公钥登录
        if grep -q "^PubkeyAuthentication" $SSH_CONFIG; then
            sed -i 's/^PubkeyAuthentication.*/PubkeyAuthentication yes/' $SSH_CONFIG
        else
            echo "PubkeyAuthentication yes" >> $SSH_CONFIG
        fi
        
        # 创建.ssh目录并设置权限
        mkdir -p ~/.ssh
        chmod 700 ~/.ssh
        
        # 检查是否存在authorized_keys文件
        if [ -f ~/.ssh/authorized_keys ]; then
            color_print yellow "检测到authorized_keys文件，当前内容为："
            cat ~/.ssh/authorized_keys
        fi
        
        # 提示用户输入公钥
        color_print yellow "请输入您的SSH公钥 (输入'n'取消):"
        read ssh_pubkey
        
        if [[ $ssh_pubkey == "n" ]]; then
            color_print blue "已取消添加公钥"
        else
            if [[ -n "$ssh_pubkey" ]]; then
                # 检查公钥是否已存在
                if [ -f ~/.ssh/authorized_keys ] && grep -q "$ssh_pubkey" ~/.ssh/authorized_keys; then
                    color_print red "此公钥已存在"
                else
                    # 将公钥写入authorized_keys文件
                    echo "$ssh_pubkey" >> ~/.ssh/authorized_keys
                    chmod 600 ~/.ssh/authorized_keys
                    color_print green "公钥已添加到 ~/.ssh/authorized_keys"
                fi
            else
                color_print red "未提供公钥，请确保手动添加公钥后再禁用密码登录"
            fi
        fi
        
        color_print green "密钥登录已启用"
    else
        # 禁用公钥登录
        if grep -q "^PubkeyAuthentication" $SSH_CONFIG; then
            sed -i 's/^PubkeyAuthentication.*/PubkeyAuthentication no/' $SSH_CONFIG
        else
            echo "PubkeyAuthentication no" >> $SSH_CONFIG
        fi
        color_print blue "密钥登录已禁用"
    fi
}

# 函数：配置密码登录
setup_password_authentication() {
    greenline
    read -p "是否禁用密码登录？(y/n): " disable_password_login
    
    if [[ $disable_password_login == "y" ]]; then
        # 检查是否已设置公钥
        if [ ! -f ~/.ssh/authorized_keys ] || [ ! -s ~/.ssh/authorized_keys ]; then
            color_print red "警告：未检测到有效的公钥，禁用密码登录可能导致无法连接到服务器"
            read -p "确定要禁用密码登录吗？(y/n): " confirm_disable
            if [[ $confirm_disable != "y" ]]; then
                color_print blue "已取消禁用密码登录"
                return
            fi
        fi
        
        # 禁用密码登录
        if grep -q "^PasswordAuthentication" $SSH_CONFIG; then
            sed -i 's/^PasswordAuthentication.*/PasswordAuthentication no/' $SSH_CONFIG
        else
            echo "PasswordAuthentication no" >> $SSH_CONFIG
        fi
        color_print green "密码登录已禁用"
    else
        # 启用密码登录
        if grep -q "^PasswordAuthentication" $SSH_CONFIG; then
            sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/' $SSH_CONFIG
        else
            echo "PasswordAuthentication yes" >> $SSH_CONFIG
        fi
        color_print blue "密码登录已启用"
    fi
}

# 函数：设置其他SSH安全选项
setup_additional_options() {
    greenline
    color_print yellow "设置其他SSH安全选项"
    
    # 允许Root用户登录
    if grep -q "^PermitRootLogin" $SSH_CONFIG; then
        sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/' $SSH_CONFIG
    else
        echo "PermitRootLogin yes" >> $SSH_CONFIG
    fi
    
    # 设置客户端保活时间为60秒
    if grep -q "^ClientAliveInterval" $SSH_CONFIG; then
        sed -i 's/^ClientAliveInterval.*/ClientAliveInterval 60/' $SSH_CONFIG
    else
        echo "ClientAliveInterval 60" >> $SSH_CONFIG
    fi
    
    # 设置客户端最大保活次数为30次
    if grep -q "^ClientAliveCountMax" $SSH_CONFIG; then
        sed -i 's/^ClientAliveCountMax.*/ClientAliveCountMax 30/' $SSH_CONFIG
    else
        echo "ClientAliveCountMax 30" >> $SSH_CONFIG
    fi
    
    color_print green "其他SSH安全选项已设置"
}

# 函数：重启SSH服务
restart_ssh_service() {
    greenline
    color_print yellow "正在重启SSH服务..."
    systemctl restart sshd
    color_print green "SSH服务已重启，新配置已生效"
}

# 主函数
main() {
    # 检查root权限
    check_root
    
    # 显示介绍
    print_intro
    
    # 备份配置文件
    backup_ssh_config
    
    # 修改SSH端口
    change_ssh_port
    
    # 配置公钥登录
    setup_key_authentication
    
    # 配置密码登录
    setup_password_authentication
    
    # 设置其他SSH安全选项
    setup_additional_options
    
    # 重启SSH服务
    restart_ssh_service
    
    greenline
    color_print green "SSH配置已完成，请使用新配置连接服务器"
}

# 执行主函数
main
