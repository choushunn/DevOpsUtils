# -*- coding:utf-8 -*-
# @Project    : DevOpsUtils
# @FileName   : main.py
# @Author     : Spring
# @Time       : 2024/3/25 10:54
# @Description:
import argparse

from sysinfo import get_cuda_info, get_cpu_info


def process_command_args():
    parser = argparse.ArgumentParser(description='Process command line arguments')
    parser.add_argument('arg1', type=str, help='First argument')
    parser.add_argument('-o', '--optional', type=int, help='Optional argument')

    args = parser.parse_args()

    print('arg1:', args.arg1)
    print('optional:', args.optional)
    return args


if __name__ == '__main__':
    process_command_args()
    get_cuda_info()
    get_cpu_info()
