#!/usr/bin/env bash
CUDA_VISIBLE_DEVICES=2 python train_temporal_dis.py --batch_size 10 --num_workers 5 --nce_k 12500 --softmax --moco --print_freq 100 --dataset 'kinetics' --train_list '../datasets/lists/kinetics-400/ssd_kinetics_video_trainlist_1of10.txt' --val_list '../datasets/lists/kinetics-400/ssd_kinetics_video_vallist.txt'