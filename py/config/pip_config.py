# -*- coding: utf-8 -*-
"""
Module/Script Name: pip_config
Author: Spring
Date: 22/08/2023
Description: 
"""
import os
import platform


def initialize_pip_config(mirror_url="mirrors.aliyun.com"):
    """
    Initializes the pip configuration file.
    :param mirror_url: Mirror source URL
    :return: None
    """
    if platform.system() == "Windows":
        pip_config_path = os.path.expanduser('~/pip/pip.ini')
        print("Current system is Windows")
    elif platform.system() == "Linux":
        pip_config_path = os.path.expanduser('~/.pip/pip.conf')
        print("Current system is Linux")
    else:
        print("Unsupported operating system")
        return

    if not os.path.exists(pip_config_path):
        os.makedirs(os.path.dirname(pip_config_path), exist_ok=True)

        with open(pip_config_path, 'w') as f:
            f.write("[global]\n")
            f.write(f"index-url = https://{mirror_url}/pypi/simple/\n")
            f.write("[install]\n")
            f.write(f"trusted-host = {mirror_url}\n")
        print("pip configuration file initialized")
    else:
        print("pip configuration file already exists")
