#!/bin/bash -e

CFG_ADJUSTMENT=0

#GPUS=""
GPUS="-gpus 0"

#WEIGHT=""
WEIGHT="weights/darknet53.conv.74"
#WEIGHT="weights/yolo-fastest.conv.109"

#CFG=cfg/yolo-fastest-1.1_160_person.cfg
CFG="cfg/yolov3-tiny.cfg"
#CFG="cfg/yolo-fastest-coco.cfg"

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
coco2yolo/coco2yolo -ann-path coco/annotations/instances_train2014.json -img-dir coco/images/train2014 -task-dir coco/labels/train2014 -set union < cfg/coco.cat

rm -rf coco/labels/val2014
coco2yolo/coco2yolo -ann-path coco/annotations/instances_val2014.json -img-dir coco/images/val2014 -task-dir coco/labels/val2014 -set union < cfg/coco.cat
rm -rf cfg/coco.cat

##############################
CLASSES=`wc -l cfg/coco.names | awk '{print $1}'`
sed "1s/classes = [0-9]\+/classes = $CLASSES/" -i cfg/coco.data
FILTERS=`echo "(${CLASSES} + 5) * 3" | bc`
MAX_BATCHES=`echo "${CLASSES} * 2000" | bc`
S8=`echo "${MAX_BATCHES} * 8 / 10" | bc`; S9=`echo "${MAX_BATCHES} * 9 / 10" | bc`
STEPS=`echo ${S8},${S9}`
if [ 1 -eq ${CFG_ADJUSTMENT} ]; then
	git checkout ${CFG}
	sed "s/classes=80/classes=${CLASSES}/g" -i ${CFG}
	sed "s/filters=255/filters=${FILTERS}/g" -i ${CFG}
	sed "s/max_batches=500000/max_batches=${MAX_BATCHES}/g" -i ${CFG}
	sed "s/steps=400000,450000/steps=${STEPS}/g" -i ${CFG}
fi

##############################
[ "$TERM" == "xterm" ] && GPUS="${GPUS} -dont_show -map"
mkdir -p backup
../darknet detector train cfg/coco.data ${CFG} ${GPUS} ${WEIGHT}

exit 0
