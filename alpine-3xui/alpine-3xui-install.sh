#!/bin/sh

# 清理屏幕
clear

# 显示主菜单
show_menu() {
  clear
  echo -e "\033[32m3X-UI for Alpine by ZedWAre\033[0m" "v1.0.1"
  echo "目前暂不支持开机自启"
  echo ""
  echo "请选择操作："
  echo "0. 退出脚本"
  echo "1. 安装并启动 3X-UI for Alpine"
  echo "2. 卸载 3X-UI for Alpine"
  echo "3. 启动 3X-UI for Alpine"
  echo "4. 重启 3X-UI for Alpine"
  echo "5. 停止 3X-UI for Alpine"
}

# 等待用户按下 Enter 键
pause() {
  echo ""
  read -p "按 Enter 键返回主菜单..."
}

# 检查是否以 root 身份运行
check_root() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "请以 root 身份运行此脚本。"
    exit 1
  fi
}

# 安装并启动 3X-UI for Alpine
install_3x_ui() {
  # 定向到主目录
  cd ~
  
# 清理屏幕
  clear
  echo "正在更新系统..."
  apk update
  apk upgrade
  echo ""
  echo "正在安装必要依赖包..."
  apk add bash sudo docker docker-compose git


  # 获取 3X-UI 文件
  if [ ! -d "3x-ui" ]; then
  echo ""
  echo "正在获取 3X-UI 文件"
    git clone https://github.com/MHSanaei/3x-ui.git
  else
    echo ""
    echo "您似乎已经安装了 3X-UI for Alpine"
    echo "如果未正常启动请尝试启动"
    pause
    return
  fi

  # 进入 3X-UI 主目录
  cd 3x-ui
  # 启动 Docker 服务
  if ! service docker status | grep -q "started"; then
    echo ""
    echo "Docker 服务未运行，正在启动 Docker 服务..."
    sudo service docker start
  fi

  # 等待 Docker Daemon 启动
  sleep 5
  echo ""
  echo "启动并部署 3X-UI 服务"
  sudo docker compose up -d
  echo ""
  echo -e "\033[32m3X-UI for Alpine 安装成功！\033[0m"
  echo ""
  echo "默认用户名和密码为 admin ，端口为 2053"
  echo "请尽快进入面板修改用户名、密码和访问端口"
  pause
}

# 永久关闭并卸载 3X-UI for Alpine
uninstall_3x_ui() {
  clear
  echo "选择卸载选项："
  echo "1. 直接卸载 3X-UI for Alpine"
  echo "2. 卸载依赖与 3X-UI for Alpine"
  read -p "请输入选项 [1-2]: " choice

  case "$choice" in
    1)
      # 直接卸载 3X-UI for Alpine
      cd ~
      sudo docker stop 3x-ui
      sudo docker rm 3x-ui
      sudo rm -rf 3x-ui
      echo "3X-UI for Alpine 已卸载。"
      ;;
    2)
      # 卸载依赖与 3X-UI for Alpine
      cd ~
      sudo docker stop 3x-ui
      sudo docker rm 3x-ui
      sudo rm -rf 3x-ui
      sudo apk del docker docker-compose git
      echo "3X-UI for Alpine 和其依赖已卸载。"
      ;;
    *)
      echo "无效的选项。"
      ;;
  esac
  pause
}

start_3x_ui() {
  cd ~/3x-ui

  # 检查 Docker 服务是否正在运行
  if ! service docker status | grep -q "started"; then
    echo ""
    echo "Docker 服务未运行，正在启动 Docker 服务..."
    sudo service docker start
  fi

  # 检查 3x-ui 容器是否正在运行
  if sudo docker ps --filter "name=3x-ui" --filter "status=running" | grep -q 3x-ui; then
    echo ""
    echo -e "\033[32m3X-UI 似乎正在运行\033[0m"
  else
    echo ""
    echo "3X-UI 未运行，正在启动 3X-UI..."
    sudo docker compose up -d
    echo -e "\033[32m3X-UI for Alpine 已经启动\033[0m"
  fi

  pause
}

restart_3x_ui() {
  cd ~/3x-ui

  # 检查 Docker 服务是否正在运行
  if ! service docker status | grep -q "started"; then
  echo ""
    echo "Docker 服务未运行，正在启动 Docker 服务..."
    sudo service docker start
  fi

  # 重启 3x-ui 容器
  echo "正在重启 3X-UI..."
  sudo docker compose down
  sudo docker compose up -d
  echo ""
  echo -e "\033[32m3X-UI for Alpine 已经重启\033[0m"

  pause
}

stop_3x_ui() {
  cd ~/3x-ui
  sudo docker stop 3x-ui
  echo ""
  echo -e "\033[32m3X-UI for Alpine 已经停止\033[0m"
  pause
}
# 主程序
check_root
while true; do
  show_menu
  read -p "请输入选项 [0-5]: " option

  case $option in
    0) exit 0 ;;
    1) install_3x_ui ;;
    2) uninstall_3x_ui ;;
    3) start_3x_ui ;;
    4) restart_3x_ui ;;
    5) stop_3x_ui ;;
    *) echo "" && echo "无效的选项，请重新选择。" && pause ;;
  esac
done
