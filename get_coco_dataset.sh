#!/bin/bash -e

# Clone COCO API
git clone https://github.com/pdollar/coco
pushd coco

mkdir images
pushd images

# Download Images
[ ! -e train2014.zip ] && wget -c http://images.cocodataset.org/zips/train2014.zip -O train2014.zip
[ ! -e val2014.zip ] && wget -c http://images.cocodataset.org/zips/val2014.zip -O val2014.zip
[ ! -e test2014.zip ] && wget -c http://images.cocodataset.org/zips/test2014.zip -O test2014.zip
#[ ! -e annotations_trainval2014.zip ] && wget -c http://images.cocodataset.org/annotations/annotations_trainval2014.zip -O annotations_trainval2014.zip

# Unzip
unzip -o train2014.zip
unzip -o val2014.zip
unzip -o test2014.zip
#unzip -o annotations_trainval2014.zip

popd

# Download COCO Metadata
wget -c https://pjreddie.com/media/files/instances_train-val2014.zip -O instances_train-val2014.zip
wget -c https://pjreddie.com/media/files/coco/5k.part -O 5k.part
wget -c https://pjreddie.com/media/files/coco/trainvalno5k.part -O trainvalno5k.part
wget -c https://pjreddie.com/media/files/coco/labels.tgz -O labels.tgz
tar xzf labels.tgz
unzip -o instances_train-val2014.zip

# Set Up Image Lists
paste <(awk "{print \"$PWD\"}" <5k.part) 5k.part | tr -d '\t' > 5k.txt
paste <(awk "{print \"$PWD\"}" <trainvalno5k.part) trainvalno5k.part | tr -d '\t' > trainvalno5k.txt

popd

#python3 -c 'import sys, yaml, json; print(yaml.dump(json.loads(sys.stdin.read())))' < coco/annotations/instances_train2014.json > coco/annotations/instances_train2014.yaml

exit 0
