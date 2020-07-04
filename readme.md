# Self-Supervised Temporal-Discriminative Representation Learning

The source code for our paper "Self-Supervised Temporal-Discriminative Representation
Learning for Video Action Recognition"

## Installation

### Requirements
- Python3
- pytorch1.1+
- PIL

## Structure
- datasets
    - list
        - hmdb51: the train/val lists of HMDB51
        - ucf101: the train/val lists of UCF101
        - kinetics-400: the train/val lists of kinetics-400
- experiments
    - logs: experiments record in detials
    - TemporalDis
        - hmdb51
        - ucf101
        - kinetics
    - gradientes: 
    - visualization
- src
    - data: load data
    - loss: the loss evluate in this paper
    - model: network architectures
    - scripts: train/eval scripts
    - TC: detail implementation of Spatio-temporal consistency
    - utils
    - feature_extract.py
    - main.py
    - trainer.py
    - option.py
## Dataset

Prepare dataset in txt file, and each row of txt is as below:
The split of hmdb51/ucf101/kinetics-400 can be download from 
[google driver](https://drive.google.com/drive/folders/1gOOOlBJtH1p2weC-k7TD3HcC2HSHBryw?usp=sharing).

Each item include
> video_path class frames_num

## TCA

The TCA can be implment with fully matrix operation, and can be extend to any video-based self-supervised learning method.
```python
class SpatialMixup(object):
    def __init__(self, alpha, trace=True, version=2):
        self.alpha = alpha
        self.trace = trace
        self.version = version

    def mixup_data(self, x):
        """
        return mixed inputs. pairs of targets
        """
        import random
        if self.version == 1:
        # # ================version 1: random select sample and fusion with stable frame (all video)===================
            b, c, t, h, w = x.size()
            loss_prob = random.random() * self.alpha
            if self.trace:
                mixed_x = x
            else:
                mixed_x = torch.zeros_like(x)
            for i in range(b):
                tmp = (i+1) % b
                img_index = random.randint(t)
                for j in range(t):
                    mixed_x[i, :, j, :, :] = (1-loss_prob) * x[i, :, j, :, :] + loss_prob * x[tmp, :, img_index, :, :]
                    # cv2.imshow("", mixed_x[i,:,j,:,:])
            return mixed_x
        # ================version 2: random select one same video sample and fusion with stable frame=================
        elif self.version == 2:
            b, c, t, h, w = x.size()
            from numpy import random
            loss_prob = random.random() * self.alpha
            # mixed_x = torch.zeros_like(x).cuda()
            if self.trace:
                mixed_x = x
            else:
                mixed_x = torch.zeros_like(x).cuda()
            for i in range(b):
                img_index = random.randint(t)
                for j in range(t):
                    mixed_x[i, :, j, :, :] = (1-loss_prob) * x[i, :, j, :, :] + loss_prob * x[i, :, img_index, :, :]
            return mixed_x
        # #================================ version 3: x and y all change================================
        else:
            b, c, t, h, w = x.size()
            from numpy import random
            loss_prob = random.random() * 0.3
            gama = 3  # control the importance of spatial information
            mixed_x = x
            index = torch.randperm(b)
            for i in range(b):
                img_index = random.randint(t)
                for j in range(t):
                    mixed_x[i, :, j, :, :] = (1-loss_prob) * x[i, :, j, :, :] + loss_prob * x[index[i], :, img_index, :, :]
            # return mixed_x, y, y[index], loss_prob/gama
            return mixed_x

    def mixup_criterion(self, criterion, pred, y_a, y_b, lam):
        return (1-lam) * criterion(pred, y_a) + lam * criterion(pred, y_b)

```

## VTDL
### Network Architecture
The network is in the folder **src/model/[backbone].py**

|  Method   | #logits_channel  |
|  ----  | ----  | 
| C3D  | 512 |
| R2P1D  | 2048 |
| I3D | 1024 |
| R3D  | 2048 |


### Step1: self-supervised learning
#### HMDB51
```bash
bash scripts/TemporalDisc/hmdb51.sh
```
#### UCF101
```bash
bash scripts/TemporalDisc/ucf101.sh
```
#### Kinetics-400
```bash
bash scripts/TemporalDisc/kinetics.sh
```

**Notice: More Training Options and ablation study Can be find in scripts**

### Step2: Transfer to action recognition
#### HMDB51
```bash
#!/usr/bin/env bash
python main.py \
--method ft \
--train_list ../datasets/lists/hmdb51/hmdb51_rgb_train_split_1.txt \
--val_list ../datasets/lists/hmdb51/hmdb51_rgb_val_split_1.txt \
--dataset hmdb51 \
--arch i3d \
--mode rgb \
--lr 0.001 \
--lr_steps 10 20 25 30 35 40 \
--epochs 45 \
--batch_size 4 \
--data_length 64 \
--workers 8 \
--dropout 0.5 \
--gpus 2 \
--logs_path ../experiments/logs/hmdb51_i3d_ft \
--print-freq 100 \
--weights ../experiments/MoCo/hmdb51/models/04-16-2328_aug_CJ/ckpt_epoch_48.pth
```
#### UCF101
```bash
#!/usr/bin/env bash
python main.py \
--method ft \
--train_list ../datasets/lists/ucf101/ucf101_rgb_train_split_1.txt \
--val_list ../datasets/lists/ucf101/ucf101_rgb_val_split_1.txt \
--dataset ucf101 \
--arch i3d \
--mode rgb \
--lr 0.0005 \
--lr_steps 10 20 25 30 35 40 \
--epochs 45 \
--batch_size 4 \
--data_length 64 \
--workers 8 \
--dropout 0.5 \
--gpus 2 \
--logs_path ../experiments/logs/ucf101_i3d_ft \
--print-freq 100 \
--weights ../experiments/MoCo/ucf101/models/04-18-2208_aug_CJ/ckpt_epoch_45.pth
```
**Notice: More Training Options and ablation study Can be find in scripts**

## Results
### Step2:Transfer
|  Method   | UCF101  | HMDB51 |
|  ----  | ----  | ---- |
| Baseline  | 60.3 | 22.6| 
| + BA |63.3 | 26.2|
| + Temporal Discriminative  | 72.7 | 41.2| 
| + TCA | 82.3 |52.9|

#### trained models/logs/performance
##### Baseline + BA
!()[https://github.com/FingerRec/3DNet_Visualization/raw/master/experiments/figures/BA_fine_tune_performance.pdf]

[trained_model](https://drive.google.com/file/d/10J5fKKkDF58njdsLGXkknk0RWkaINJ31/view?usp=sharing), [logs](https://drive.google.com/file/d/1K1_U692NZq5F53DDPDkpw7JFiEqIqole/view?usp=sharing)
##### Baseline + BA + Temporal Discriminative
!()[https://github.com/FingerRec/3DNet_Visualization/raw/master/experiments/figures/TCA_ins_fine_tune_performance.pdf]

[trained_model](https://drive.google.com/file/d/1HJQwzRwNs5nOseAnPW87iDpUMXOs78a8/view?usp=sharing), [logs](https://drive.google.com/file/d/13vfdQusv2Gd42nYXe4p1nWEByIJ9cLoz/view?usp=sharing)

##### Baseline + BA + Temporal Discriminative + TCA
!()[https://github.com/FingerRec/3DNet_Visualization/raw/master/experiments/figures/VTDL_fine_tune_performance.pdf]

[trained_model](https://drive.google.com/file/d/1TdxIBrdLcgKabL5A_FusomWLe4oXDcDK/view?usp=sharing), [logs](https://drive.google.com/file/d/1Q-tq9bf-J8caHxJJDMlXo4KX5cNJ_75w/view?usp=sharing)

The result is report with .

## Feature Extractor
As STCR can be easily extend to other video representation task, we offer the scripts to perform feature extract.
```bash
python feature_extractor.py
```


The feature will be saved as a single numpy file in the format [video_nums,features_dim]


## Others

The project is partly based on [Unsupervised Embedding Learning](https://github.com/mangye16/Unsupervised_Embedding_Learning) and [MOCO](https://github.com/facebookresearch/moco).