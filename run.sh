#!/bin/bash -e

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
for I in `sed 's/ /_/g' cfg/coco.names`; do echo -n "${I}, "; done | sed 's/_/ /g' > cfg/coco.cat
sed 's/, $//' -i cfg/coco.cat

##############################
git clone https://github.com/tw-yshuang/coco2yolo.git || true
export PYTHONPATH=`pwd`/coco2yolo:${PYTHONPATH}
rm -rfv coco/labels/train2014
coco2yolo/coco2yolo -ann-path coco/annotations/instances_train2014.json -img-dir coco/images/train2014 -task-dir coco/labels/train2014 < cfg/coco.cat
rm -rfv coco/labels/val2014
coco2yolo/coco2yolo -ann-path coco/annotations/instances_val2014.json -img-dir coco/images/val2014 -task-dir coco/labels/val2014 < cfg/coco.cat

##############################
mkdir -p backup
if [ "$TERM" == "xterm" ]; then
	../darknet detector train cfg/coco.data cfg/yolo-fastest-coco.cfg -dont_show -map -gpus 0
else
	../darknet detector train cfg/coco.data cfg/yolo-fastest-coco.cfg -gpus 0
fi

exit 0
