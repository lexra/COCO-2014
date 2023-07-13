#!/bin/bash -e

#NAME="yolo-default"
NAME="yolo-person"
CFG="cfg/${NAME}.cfg"

GPUS="-gpus 0"
WEIGHTS=""

##############################
[ ! -e coco/PythonAPI/setup.py ] && exit 1

##############################
pushd coco
paste <(awk "{print \"$PWD\"}" <5k.part) 5k.part | tr -d '\t' > 5k.txt
paste <(awk "{print \"$PWD\"}" <trainvalno5k.part) trainvalno5k.part | tr -d '\t' > trainvalno5k.txt
popd
sed "s|^/work/himax/Yolo-Fastest/COCO-2014|`pwd`|" -i cfg/${NAME}.data

##############################
pushd coco/images
#rm -rf train2014 val2014
#unzip -o train2014.zip
#unzip -o val2014.zip
popd

##############################
git clone https://github.com/tw-yshuang/coco2yolo.git || true
git clone https://github.com/immersive-limit/coco-manager.git || true
git clone https://github.com/alexmihalyk23/COCO2YOLO.git || true
export PYTHONPATH=`pwd`/coco2yolo:${PYTHONPATH}

##############################
#python3 coco-manager/filter.py --input_json coco/annotations/instances_train2014.json \
#	--output_json coco/annotations/filter_train2014.json \
#	--categories person bicycle car motorcycle airplane bus train truck boat

##############################
find coco/images/train2014 -name "*.txt" | xargs rm -rf
find coco/images/val2014 -name "*.txt" | xargs rm -rf
#python3 COCO2YOLO/COCO2YOLO.py -j coco/annotations/instances_train2014.json -o coco/images/train2014
#python3 COCO2YOLO/COCO2YOLO.py -j coco/annotations/instances_val2014.json -o coco/images/val2014
python3 COCO2YOLO/COCO2YOLO.py -j coco/images/annotations/instances_train2014.json -o coco/images/train2014 > /dev/null
python3 COCO2YOLO/COCO2YOLO.py -j coco/images/annotations/instances_val2014.json -o coco/images/val2014 > /dev/null

##############################
for C in `sed 's/ /_/g' cfg/${NAME}.names`; do echo -n "${C}, "; done | sed 's/_/ /g' > cfg/coco.cat
sed 's/, $//' -i cfg/coco.cat
#rm -rf coco/labels/train2014
#coco2yolo/coco2yolo -ann-path coco/annotations/instances_train2014.json -img-dir coco/images/train2014 -task-dir coco/labels/train2014 -set union < cfg/coco.cat
#rm -rf coco/labels/val2014
#coco2yolo/coco2yolo -ann-path coco/annotations/instances_val2014.json -img-dir coco/images/val2014 -task-dir coco/labels/val2014 -set union < cfg/coco.cat
rm -rf cfg/coco.cat

##############################
[ "$TERM" == "xterm" ] && GPUS="${GPUS} -dont_show -map"
[ -e ../data/labels/100_0.png ] && ln -sf ../data .
mkdir -p backup
[ -e "backup/${NAME}_last.weights" ] && WEIGHTS="backup/${NAME}_last.weights"
../darknet detector train cfg/${NAME}.data ${CFG} ${WEIGHTS} ${GPUS}

##############################
if [ -e ../keras-YOLOv3-model-set/tools/model_converter/fastest_1.1_160/convert.py ]; then
	python3 ../keras-YOLOv3-model-set/tools/model_converter/fastest_1.1_160/convert.py \
		--config_path cfg/${NAME}.cfg \
		--weights_path backup/${NAME}_final.weights \
		--output_path backup/${NAME}.h5
	python3 ../keras-YOLOv3-model-set/tools/model_converter/fastest_1.1_160/post_train_quant_convert_demo.py \
		--keras_model_file backup/${NAME}.h5 \
		--annotation_file coco/trainvalno5k.txt \
		--output_file backup/${NAME}.tflite

	#python3 ../keras-YOLOv3-model-set/eval_yolo_fastest_160_1ch_tflite.py \
	#	--model_path backup/${NAME}.tflite --anchors_path cfg/${NAME}.anchors --classes_path cfg/${NAME}.names --annotation_file coco/trainvalno5k.txt --json_name ${NAME}.json || true
	#python3 ../pycooc_person.py \
	#	--res_path ../keras-YOLOv3-model-set/coco_results/${NAME}.json --instances_json_file coco/images/annotations/instances_train2014.json || true

	xxd -i backup/${NAME}.tflite > backup/${NAME}.cc
fi

##############################
echo ""
echo "Detector Test: "
echo "../darknet detector test cfg/${NAME}.data cfg/${NAME}.cfg backup/${NAME}_final.weights COCO-2014/pixmaps/people.jpg"
exit 0
