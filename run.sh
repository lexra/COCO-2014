#!/bin/bash -e

GPUS="-gpus 0"

##############################
[ ! -e coco/PythonAPI/setup.py ] && exit 1

##############################
pushd coco
paste <(awk "{print \"$PWD\"}" <5k.part) 5k.part | tr -d '\t' > 5k.txt
paste <(awk "{print \"$PWD\"}" <trainvalno5k.part) trainvalno5k.part | tr -d '\t' > trainvalno5k.txt

##############################
pushd PythonAPI
#python3 setup.py build_ext install --prefix=${HPME}/.local
popd

popd

##############################
for C in `sed 's/ /_/g' cfg/coco.names`; do echo -n "${C}, "; done | sed 's/_/ /g' > cfg/coco.cat
sed 's/, $//' -i cfg/coco.cat

##############################
git clone https://github.com/tw-yshuang/coco2yolo.git || true
export PYTHONPATH=`pwd`/coco2yolo:${PYTHONPATH}
rm -rf coco/labels/train2014
coco2yolo/coco2yolo -ann-path coco/annotations/instances_train2014.json -img-dir coco/images/train2014 -task-dir coco/labels/train2014 < cfg/coco.cat
rm -rf coco/labels/val2014
coco2yolo/coco2yolo -ann-path coco/annotations/instances_val2014.json -img-dir coco/images/val2014 -task-dir coco/labels/val2014 < cfg/coco.cat
rm -rf cfg/coco.cat

##############################
CLASSES=`wc -l cfg/coco.names | awk '{print $1}'`
git checkout cfg/yolo-fastest-coco.cfg
sed "s/classes=80/classes=${CLASSES}/g" -i cfg/yolo-fastest-coco.cfg

##############################
[ "$TERM" == "xterm" ] && GPUS="${GPUS} -dont_show -map"
mkdir -p backup
../darknet detector train cfg/coco.data cfg/yolo-fastest-coco.cfg ${GPUS}

exit 0
