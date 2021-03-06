#!/usr/bin/env bash
for arch in i3d c3d r3d r2p1d
do
    python main.py \
    --method ft \
    --train_list ../datasets/lists/ucf101/ucf101_rgb_train_split_1.txt \
    --val_list ../datasets/lists/ucf101/ucf101_rgb_val_split_1.txt \
    --dataset ucf101 \
    --arch ${arch} \
    --mode rgb \
    --lr 0.01 \
    --lr_steps 10 20 25 30 35 40 \
    --epochs 45 \
    --batch-size 8 \
    --dropout 0.5 \
    --gpus 2 \
    --logs_path ../experiments/logs/ucf101_${arch}_benchmark
done