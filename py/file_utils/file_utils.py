# -*- coding: utf-8 -*-
"""
Module/Script Name: file_utils
Author: Spring
Date: 22/08/2023
Description: 
"""
import os
import glob


def walk_files(directory):
    """
    Walk through a directory
    :param directory:
    :return:
    """

    for root, dirs, files in os.walk(directory):
        for f in files:
            print(os.path.abspath(f))
        for d in dirs:
            print(os.path.abspath(d))


def get_file_list(path, file_type='jpg', abs_path=False):
    """
    Get file list
    :param path:
    :param file_type:
    :param abs_path:
    :return:
    """
    if abs_path:
        return glob.glob(os.path.abspath(os.path.join(path, '*.' + file_type)))

    return glob.glob(f'{path}/*.{file_type}', recursive=True)

