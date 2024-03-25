# -*- coding: utf-8 -*-
"""
Module/Script Name: visualization
Author: Spring
Date: 22/08/2023
Description: 
"""
import os
import platform

import numpy as np
from matplotlib import pyplot as plt


def plot3sub_images(images, sub_titles=None, title=None, is_show=False):
    """
    Plot 3 sub images
    :param images:
    :param sub_titles:
    :param title:
    :param is_show:
    :return:
    """
    plt.figure(figsize=(16, 9), dpi=72)
    grid = plt.GridSpec(2, 2, wspace=0.4, hspace=0.3)
    for i in range(len(images)):
        if i == 0:
            plt.subplot(grid[:, 0])
        else:
            plt.subplot(grid[i // 2, i % 2])
        plt.imshow(images[i])
        plt.axis("off")
        if sub_titles:
            plt.title(sub_titles[i])
    if title:
        plt.suptitle(title, fontsize=16, fontweight="bold")
    if is_show:
        plt.show()
    else:
        plt.savefig("comparison_plot.png")

