# -*- coding:utf-8 -*-
# @Project    : DevOpsUtils
# @FileName   : sysinfo.py
# @Author     : Spring
# @Time       : 2024/3/25 10:56
# @Description:

import torch
from tqdm import tqdm

import torch
from rich import print
import psutil


def get_cuda_info():
    """
    获取CUDA信息
    :return:
    """
    print("Checking CUDA availability...")

    if torch.cuda.is_available():
        print("[bold green]CUDA is available.[/bold green]")

        num_gpus = torch.cuda.device_count()

        for i in range(num_gpus):
            gpu_device = torch.cuda.get_device_name(i)
            total_memory = torch.cuda.get_device_properties(i).total_memory / (1024 ** 3)
            print(f"GPU {i + 1}: {gpu_device} [cyan]{total_memory:.2f} GB[/cyan]")
    else:
        print("[bold red]CUDA is not available.[/bold red]")


def get_cpu_info():
    """
    获取CPU信息
    :return:
    """

    cpu_info = {}

    # 获取CPU逻辑核心数量
    cpu_info['Logical Cores'] = psutil.cpu_count(logical=True)

    # 获取CPU物理核心数量
    cpu_info['Physical Cores'] = psutil.cpu_count(logical=False)

    # 获取总内存
    svmem = psutil.virtual_memory()
    cpu_info['Total Memory'] = f"{svmem.total / (1024 ** 3):.2f} GB"

    # 获取CPU名称
    cpu_info['CPU Name'] = psutil.cpu_stats()

    # 获取CPU频率信息
    freq = psutil.cpu_freq()
    cpu_info['CPU Frequency'] = f"{freq.current:.2f} MHz"

    for key, value in cpu_info.items():
        print(f"{key}: {value}")
