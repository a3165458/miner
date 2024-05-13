#!/bin/bash

# 检查是否以root用户运行脚本
if [ "$(id -u)" != "0" ]; then
    echo "此脚本需要以root用户权限运行。"
    echo "请尝试使用 'sudo -i' 命令切换到root用户，然后再次运行此脚本。"
    exit 1
fi

# 节点安装功能
function install_node() {
apt update
apt install screen unzip -y

# 安装GO
wget https://go.dev/dl/go1.22.1.linux-amd64.tar.gz -P /tmp/
tar -C /usr/local -xzf /tmp/go1.22.1.linux-amd64.tar.gz
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bashrc
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
go version

wget https://github.com/ronanyeah/mineral-app/releases/download/v1/linux.zip
unzip linux.zip
read -p "请输入SUI挖矿钱包私钥: " wallet_addr
screen -dmS miner bash -c "export WALLET=$wallet_addr; ./mineral-linux mine"

echo "====================== 安装完成 请使用screen -r miner 查看运行情况 ==========================="

}

function multiple() {
# 提示用户输入包含私钥的文件路径
echo "请输入包含SUI挖矿钱包私钥的文件路径："
read file_path

# 检查文件是否存在
if [ ! -f "$file_path" ]; then
    echo "文件不存在，请检查路径是否正确。"
fi

# 为文件中的每个私钥创建一个 screen 会话
while IFS= read -r wallet_addr
do
    if [ -n "$wallet_addr" ]; then
        session_name="miner_$(echo $wallet_addr | md5sum | cut -d' ' -f1)" # 创建唯一的 session 名称
        screen -dmS "$session_name" bash -c "export WALLET=$wallet_addr; ./mineral-linux mine"
        echo "为钱包 $wallet_addr 启动了挖矿会话 $session_name"
    fi
done < "$file_path"

echo "所有挖矿会话已启动。"

}

# 主菜单
function main_menu() {
    clear
    echo "脚本以及教程由推特用户大赌哥 @y95277777 编写，免费开源，请勿相信收费"
    echo "================================================================"
    echo "节点社区 Telegram 群组:https://t.me/niuwuriji"
    echo "节点社区 Telegram 频道:https://t.me/niuwuriji"
    echo "节点社区 Discord 社群:https://discord.gg/GbMV5EcNWF"
    echo "请选择要执行的操作:"
    echo "1. 安装并启动节点"
    echo "2. 多开启动节点"
    read -p "请输入选项(1): " OPTION

    case $OPTION in
    1) install_node ;;
    2) multiple ;;
    *) echo "无效选项" ;;
    esac
}

main_menu
