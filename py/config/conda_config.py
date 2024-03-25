# -*- coding: utf-8 -*-
"""
Module/Script Name: conda_config
Author: Spring
Date: 22/08/2023
Description: 
"""

import os
import platform


def initialize_conda_config(mirror_url="https://mirrors.bfsu.edu.cn/"):
    """
    Initializes the conda configuration file in Windows/Linux environments.
    :return: None
    """
    if platform.system() == "Windows":
        condarc_path = os.path.expanduser('~\\.condarc')
    elif platform.system() == "Linux":
        condarc_path = os.path.expanduser('~/.condarc')
    else:
        print("Unsupported operating system")
        return

    conda_config = """
channels:
  - defaults
show_channel_urls: true
default_channels:
  - https://mirrors.bfsu.edu.cn/anaconda/pkgs/main
  - https://mirrors.bfsu.edu.cn/anaconda/pkgs/r
  - https://mirrors.bfsu.edu.cn/anaconda/pkgs/msys2
custom_channels:
  conda-forge: https://mirrors.bfsu.edu.cn/anaconda/cloud
  msys2: https://mirrors.bfsu.edu.cn/anaconda/cloud
  bioconda: https://mirrors.bfsu.edu.cn/anaconda/cloud
  menpo: https://mirrors.bfsu.edu.cn/anaconda/cloud
  pytorch: https://mirrors.bfsu.edu.cn/anaconda/cloud
  pytorch-lts: https://mirrors.bfsu.edu.cn/anaconda/cloud
  simpleitk: https://mirrors.bfsu.edu.cn/anaconda/cloud
  paddle: https://mirrors.bfsu.edu.cn/anaconda/cloud
ssl_verify: true
"""

    with open(condarc_path, 'w') as f:
        f.write(conda_config)

    print("conda configuration file initialized")
