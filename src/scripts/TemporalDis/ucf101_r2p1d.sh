#!/usr/bin/env bash
CUDA_VISIBLE_DEVICES=1 python train_temporal_dis.py --arch r2p1d  --batch_size 8 --num_workers 4 --nce_k 5000 --softmax --moco --print_freq 100 --dataset 'ucf101' --train_list '../datasets/lists/ucf101/ucf101_rgb_train_split_1.txt' --val_list '../datasets/lists/ucf101/ucf101_rgb_val_split_1.txt'