# -*- coding:utf-8 -*-
# @Project    : DevOpsUtils
# @FileName   : check_env.py
# @Author     : Spring
# @Time       : 2024/3/25 11:02
# @Description:
import subprocess


def check_and_install_requirements():
    with open('requirements.txt', 'r') as file:
        requirements = file.read().splitlines()

    for requirement in requirements:
        try:
            # 导入包，如果导入成功则说明已安装
            __import__(requirement)
            print(f"[green]{requirement} is already installed.[/green]")
        except ImportError:
            print(f"[yellow]{requirement} is not installed. Installing...[/yellow]")
            subprocess.check_call(['pip', 'install', requirement])
            print(f"[green]{requirement} has been installed successfully.[/green]")
