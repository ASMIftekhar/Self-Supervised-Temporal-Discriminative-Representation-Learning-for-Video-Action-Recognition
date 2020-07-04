#!/usr/bin/env bash
python main.py \
--method ft \
--train_list ../datasets/lists/hmdb51/hmdb51_rgb_train_split_1.txt \
--val_list ../datasets/lists/hmdb51/hmdb51_rgb_val_split_1.txt \
--dataset hmdb51 \
--arch i3d \
--mode rgb \
--lr 0.001 \
--optim sgd \
--spatial_size 224 \
--lr_steps 10 20 30 40 \
--epochs 45 \
--batch_size 48 \
--workers 8 \
--data_length 64 \
--dropout 0.5 --gpus 3 \
--stride 4 \
--logs_path ../experiments/logs/hmdb51_i3d_ft \
--print-freq 10 \
--weights ../experiments/logs/hmdb51_i3d_pt_and_ft/pt_and_ft_12-30-1227/temporal_consistency_rgb_model_latest.pth.tar