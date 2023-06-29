#!/bin/bash -e

NAME="yolo-default"
CFG="cfg/${NAME}.cfg"

GPUS="-gpus 0"
WEIGHT=""

##############################
[ ! -e coco/PythonAPI/setup.py ] && exit 1

##############################
pushd coco
paste <(awk "{print \"$PWD\"}" <5k.part) 5k.part | tr -d '\t' > 5k.txt
paste <(awk "{print \"$PWD\"}" <trainvalno5k.part) trainvalno5k.part | tr -d '\t' > trainvalno5k.txt
popd

##############################
pushd coco/images
#rm -rf train2014 val2014
#unzip -o train2014.zip
#unzip -o val2014.zip
popd

##############################
for C in `sed 's/ /_/g' cfg/${NAME}.names`; do echo -n "${C}, "; done | sed 's/_/ /g' > cfg/coco.cat
sed 's/, $//' -i cfg/coco.cat
git clone https://github.com/tw-yshuang/coco2yolo.git || true
git clone https://github.com/immersive-limit/coco-manager.git || true
export PYTHONPATH=`pwd`/coco2yolo:${PYTHONPATH}

##############################
#python3 coco-manager/filter.py --input_json coco/annotations/instances_train2014.json \
#	--output_json coco/annotations/filter_train2014.json \
#	--categories person bicycle car motorcycle airplane bus train truck boat

##############################
rm -rf coco/labels/train2014
coco2yolo/coco2yolo -ann-path coco/annotations/instances_train2014.json -img-dir coco/images/train2014 -task-dir coco/labels/train2014 -set union < cfg/coco.cat
rm -rf coco/labels/val2014
coco2yolo/coco2yolo -ann-path coco/annotations/instances_val2014.json -img-dir coco/images/val2014 -task-dir coco/labels/val2014 -set union < cfg/coco.cat
rm -rf cfg/coco.cat

##############################
[ "$TERM" == "xterm" ] && GPUS="${GPUS} -dont_show -map"
ln -sf coco data
../darknet detector train cfg/${NAME}.data ${CFG} ${WEIGHT} ${GPUS}

##############################
#../darknet detector test cfg/${NAME}.data cfg/${NAME}.cfg weights/yolov3-tiny.weights pixmaps//dog.jpg -dont_show

exit 0
