## COCO-2014

### Annotation File

#### trainvalno5k.txt

```bash
wget -c https://pjreddie.com/media/files/coco/trainvalno5k.part -O trainvalno5k.part
paste <(awk "{print \"$PWD\"}" <trainvalno5k.part) trainvalno5k.part | tr -d '\t' > trainvalno5k.txt
```

#### 5k.txt

```bash
wget -c https://pjreddie.com/media/files/coco/5k.part -O 5k.part
paste <(awk "{print \"$PWD\"}" <5k.part) 5k.part | tr -d '\t' > 5k.txt
```

### Bounded Boxes Marking

#### Marking TXT Files

```bash
ls -l coco/images/train2014
...
-rw-rw-r-- 1 jasonc jasonc   70995 Aug 16  2014 COCO_train2014_000000581921.jpg
-rw-rw-r-- 1 jasonc jasonc      77 Jul 12 18:06 COCO_train2014_000000581921.txt
...
```

```bash
cat coco/images/train2014/COCO_train2014_000000581921.txt
...
0 0.425047 0.276405 0.334344 0.516838
31 0.462406 0.498700 0.064469 0.249859
```

#### Translation from a given JSON file

```bash
python3 COCO2YOLO/COCO2YOLO.py \
    -j coco/images/annotations/instances_train2014.json \
    -o coco/images/train2014
```

### Dataset with Bounded Boxes Marking

```
ls coco/images/train2014
```

```bash
...
COCO_train2014_000000083060.jpg  COCO_train2014_000000166137.txt  COCO_train2014_000000250516.txt  COCO_train2014_000000332960.jpg  COCO_train2014_000000415119.jpg  COCO_train2014_000000498082.txt  COCO_train2014_000000581904.jpg
COCO_train2014_000000083060.txt  COCO_train2014_000000166141.jpg  COCO_train2014_000000250517.jpg  COCO_train2014_000000332960.txt  COCO_train2014_000000415119.txt  COCO_train2014_000000498090.jpg  COCO_train2014_000000581904.txt
COCO_train2014_000000083079.jpg  COCO_train2014_000000166141.txt  COCO_train2014_000000250517.txt  COCO_train2014_000000332965.jpg  COCO_train2014_000000415131.jpg  COCO_train2014_000000498090.txt  COCO_train2014_000000581906.jpg
COCO_train2014_000000083079.txt  COCO_train2014_000000166163.jpg  COCO_train2014_000000250518.jpg  COCO_train2014_000000332965.txt  COCO_train2014_000000415131.txt  COCO_train2014_000000498091.jpg  COCO_train2014_000000581906.txt
COCO_train2014_000000083085.jpg  COCO_train2014_000000166163.txt  COCO_train2014_000000250518.txt  COCO_train2014_000000332976.jpg  COCO_train2014_000000415146.jpg  COCO_train2014_000000498091.txt  COCO_train2014_000000581909.jpg
COCO_train2014_000000083085.txt  COCO_train2014_000000166173.jpg  COCO_train2014_000000250526.jpg  COCO_train2014_000000332976.txt  COCO_train2014_000000415146.txt  COCO_train2014_000000498114.jpg  COCO_train2014_000000581909.txt
COCO_train2014_000000083090.jpg  COCO_train2014_000000166173.txt  COCO_train2014_000000250526.txt  COCO_train2014_000000333024.jpg  COCO_train2014_000000415150.jpg  COCO_train2014_000000498114.txt  COCO_train2014_000000581921.jpg
COCO_train2014_000000083090.txt  COCO_train2014_000000166179.jpg  COCO_train2014_000000250533.jpg  COCO_train2014_000000333024.txt  COCO_train2014_000000415150.txt  COCO_train2014_000000498125.jpg  COCO_train2014_000000581921.txt
```

### Printable Png files Generating from a given Font

#### Copy the `Futura_Medium.ttf` to /usr/share/fonts/truetype/dongle/Futura_Medium.ttf

```bash
sudo fc-cache -f -v
```

#### make_labels.py

Patch the make_labels.py accordingly. 

```patch
diff --git a/data/labels/make_labels.py b/data/labels/make_labels.py
index c8146f6..e1ffccf 100644
--- a/data/labels/make_labels.py
+++ b/data/labels/make_labels.py
@@ -2,22 +2,29 @@ import os
 import string
 import pipes

-font = 'futura-normal'
+font = '/usr/share/fonts/truetype/dongle/Futura_Medium.ttf'

 def make_labels(s):
     l = string.printable
     for word in l:
         if word == ' ':
-            os.system('convert -fill black -background white -bordercolor white -font %s -pointsize %d label:"\ " 32_%d.png'%(font,s,s/12-1))
-        if word == '@':
-            os.system('convert -fill black -background white -bordercolor white -font %s -pointsize %d label:"\@" 64_%d.png'%(font,s,s/12-1))
+            err = os.system('convert-im6.q16 -fill black -background white -bordercolor white -font %s -pointsize %d label:"\ " 32_%d.png'%(font,s,s/12-1) )
+            if 0 != err:
+                print('ERR 0')
+        elif word == '@':
+            err = os.system('convert -fill black -background white -bordercolor white -font %s -pointsize %d label:"\@" 64_%d.png'%(font,s,s/12-1))
+            if 0 != err:
+                print('ERR 1')
         elif word == '\\':
-            os.system('convert -fill black -background white -bordercolor white -font %s -pointsize %d label:"\\\\\\\\" 92_%d.png'%(font,s,s/12-1))
+            err = os.system('convert -fill black -background white -bordercolor white -font %s -pointsize %d label:"\\\\\\\\" 92_%d.png'%(font,s,s/12-1))
+            if 0 != err:
+                print('ERR 2')
         elif ord(word) in [9,10,11,12,13,14]:
             pass
         else:
-            os.system("convert -fill black -background white -bordercolor white -font %s -pointsize %d label:%s \"%d_%d.png\""%(font,s,pipes.quote(word), ord(word),s/12-1))
+            err = os.system("convert -fill black -background white -bordercolor white -font %s -pointsize %d label:%s \"%d_%d.png\""%(font,s,pipes.quote(word), ord(word),s/12-1))
+            if 0 != err:
+                print('ERR 3')

 for i in [12,24,36,48,60,72,84,96]:
     make_labels(i)
-
```

```bash
python3 make_labels.py
```

The following png files for Labels shall be generated. 

```bash
100_0.png  113_5.png  32_2.png  45_7.png  59_4.png  73_1.png  86_6.png
100_1.png  113_6.png  32_3.png  46_0.png  59_5.png  73_2.png  86_7.png
100_2.png  113_7.png  32_4.png  46_1.png  59_6.png  73_3.png  87_0.png
100_3.png  114_0.png  32_5.png  46_2.png  59_7.png  73_4.png  87_1.png
100_4.png  114_1.png  32_6.png  46_3.png  60_0.png  73_5.png  87_2.png
100_5.png  114_2.png  32_7.png  46_4.png  60_1.png  73_6.png  87_3.png
100_6.png  114_3.png  33_0.png  46_5.png  60_2.png  73_7.png  87_4.png
100_7.png  114_4.png  33_1.png  46_6.png  60_3.png  74_0.png  87_5.png
101_0.png  114_5.png  33_2.png  46_7.png  60_4.png  74_1.png  87_6.png
101_1.png  114_6.png  33_3.png  47_0.png  60_5.png  74_2.png  87_7.png
101_2.png  114_7.png  33_4.png  47_1.png  60_6.png  74_3.png  88_0.png
101_3.png  115_0.png  33_5.png  47_2.png  60_7.png  74_4.png  88_1.png
101_4.png  115_1.png  33_6.png  47_3.png  61_0.png  74_5.png  88_2.png
101_5.png  115_2.png  33_7.png  47_4.png  61_1.png  74_6.png  88_3.png
101_6.png  115_3.png  34_0.png  47_5.png  61_2.png  74_7.png  88_4.png
101_7.png  115_4.png  34_1.png  47_6.png  61_3.png  75_0.png  88_5.png
102_0.png  115_5.png  34_2.png  47_7.png  61_4.png  75_1.png  88_6.png
102_1.png  115_6.png  34_3.png  48_0.png  61_5.png  75_2.png  88_7.png
102_2.png  115_7.png  34_4.png  48_1.png  61_6.png  75_3.png  89_0.png
102_3.png  116_0.png  34_5.png  48_2.png  61_7.png  75_4.png  89_1.png
102_4.png  116_1.png  34_6.png  48_3.png  62_0.png  75_5.png  89_2.png
102_5.png  116_2.png  34_7.png  48_4.png  62_1.png  75_6.png  89_3.png
102_6.png  116_3.png  35_0.png  48_5.png  62_2.png  75_7.png  89_4.png
102_7.png  116_4.png  35_1.png  48_6.png  62_3.png  76_0.png  89_5.png
103_0.png  116_5.png  35_2.png  48_7.png  62_4.png  76_1.png  89_6.png
103_1.png  116_6.png  35_3.png  49_0.png  62_5.png  76_2.png  89_7.png
103_2.png  116_7.png  35_4.png  49_1.png  62_6.png  76_3.png  90_0.png
103_3.png  117_0.png  35_5.png  49_2.png  62_7.png  76_4.png  90_1.png
103_4.png  117_1.png  35_6.png  49_3.png  63_0.png  76_5.png  90_2.png
103_5.png  117_2.png  35_7.png  49_4.png  63_1.png  76_6.png  90_3.png
103_6.png  117_3.png  36_0.png  49_5.png  63_2.png  76_7.png  90_4.png
103_7.png  117_4.png  36_1.png  49_6.png  63_3.png  77_0.png  90_5.png
104_0.png  117_5.png  36_2.png  49_7.png  63_4.png  77_1.png  90_6.png
104_1.png  117_6.png  36_3.png  50_0.png  63_5.png  77_2.png  90_7.png
104_2.png  117_7.png  36_4.png  50_1.png  63_6.png  77_3.png  91_0.png
104_3.png  118_0.png  36_5.png  50_2.png  63_7.png  77_4.png  91_1.png
104_4.png  118_1.png  36_6.png  50_3.png  64_0.png  77_5.png  91_2.png
104_5.png  118_2.png  36_7.png  50_4.png  64_1.png  77_6.png  91_3.png
104_6.png  118_3.png  37_0.png  50_5.png  64_2.png  77_7.png  91_4.png
104_7.png  118_4.png  37_1.png  50_6.png  64_3.png  78_0.png  91_5.png
105_0.png  118_5.png  37_2.png  50_7.png  64_4.png  78_1.png  91_6.png
105_1.png  118_6.png  37_3.png  51_0.png  64_5.png  78_2.png  91_7.png
105_2.png  118_7.png  37_4.png  51_1.png  64_6.png  78_3.png  92_0.png
105_3.png  119_0.png  37_5.png  51_2.png  64_7.png  78_4.png  92_1.png
105_4.png  119_1.png  37_6.png  51_3.png  65_0.png  78_5.png  92_2.png
105_5.png  119_2.png  37_7.png  51_4.png  65_1.png  78_6.png  92_3.png
105_6.png  119_3.png  38_0.png  51_5.png  65_2.png  78_7.png  92_4.png
105_7.png  119_4.png  38_1.png  51_6.png  65_3.png  79_0.png  92_5.png
106_0.png  119_5.png  38_2.png  51_7.png  65_4.png  79_1.png  92_6.png
106_1.png  119_6.png  38_3.png  52_0.png  65_5.png  79_2.png  92_7.png
106_2.png  119_7.png  38_4.png  52_1.png  65_6.png  79_3.png  93_0.png
106_3.png  120_0.png  38_5.png  52_2.png  65_7.png  79_4.png  93_1.png
106_4.png  120_1.png  38_6.png  52_3.png  66_0.png  79_5.png  93_2.png
106_5.png  120_2.png  38_7.png  52_4.png  66_1.png  79_6.png  93_3.png
106_6.png  120_3.png  39_0.png  52_5.png  66_2.png  79_7.png  93_4.png
106_7.png  120_4.png  39_1.png  52_6.png  66_3.png  80_0.png  93_5.png
107_0.png  120_5.png  39_2.png  52_7.png  66_4.png  80_1.png  93_6.png
107_1.png  120_6.png  39_3.png  53_0.png  66_5.png  80_2.png  93_7.png
107_2.png  120_7.png  39_4.png  53_1.png  66_6.png  80_3.png  94_0.png
107_3.png  121_0.png  39_5.png  53_2.png  66_7.png  80_4.png  94_1.png
107_4.png  121_1.png  39_6.png  53_3.png  67_0.png  80_5.png  94_2.png
107_5.png  121_2.png  39_7.png  53_4.png  67_1.png  80_6.png  94_3.png
107_6.png  121_3.png  40_0.png  53_5.png  67_2.png  80_7.png  94_4.png
107_7.png  121_4.png  40_1.png  53_6.png  67_3.png  81_0.png  94_5.png
108_0.png  121_5.png  40_2.png  53_7.png  67_4.png  81_1.png  94_6.png
108_1.png  121_6.png  40_3.png  54_0.png  67_5.png  81_2.png  94_7.png
108_2.png  121_7.png  40_4.png  54_1.png  67_6.png  81_3.png  95_0.png
108_3.png  122_0.png  40_5.png  54_2.png  67_7.png  81_4.png  95_1.png
108_4.png  122_1.png  40_6.png  54_3.png  68_0.png  81_5.png  95_2.png
108_5.png  122_2.png  40_7.png  54_4.png  68_1.png  81_6.png  95_3.png
108_6.png  122_3.png  41_0.png  54_5.png  68_2.png  81_7.png  95_4.png
108_7.png  122_4.png  41_1.png  54_6.png  68_3.png  82_0.png  95_5.png
109_0.png  122_5.png  41_2.png  54_7.png  68_4.png  82_1.png  95_6.png
109_1.png  122_6.png  41_3.png  55_0.png  68_5.png  82_2.png  95_7.png
109_2.png  122_7.png  41_4.png  55_1.png  68_6.png  82_3.png  96_0.png
109_3.png  123_0.png  41_5.png  55_2.png  68_7.png  82_4.png  96_1.png
109_4.png  123_1.png  41_6.png  55_3.png  69_0.png  82_5.png  96_2.png
109_5.png  123_2.png  41_7.png  55_4.png  69_1.png  82_6.png  96_3.png
109_6.png  123_3.png  42_0.png  55_5.png  69_2.png  82_7.png  96_4.png
109_7.png  123_4.png  42_1.png  55_6.png  69_3.png  83_0.png  96_5.png
110_0.png  123_5.png  42_2.png  55_7.png  69_4.png  83_1.png  96_6.png
110_1.png  123_6.png  42_3.png  56_0.png  69_5.png  83_2.png  96_7.png
110_2.png  123_7.png  42_4.png  56_1.png  69_6.png  83_3.png  97_0.png
110_3.png  124_0.png  42_5.png  56_2.png  69_7.png  83_4.png  97_1.png
110_4.png  124_1.png  42_6.png  56_3.png  70_0.png  83_5.png  97_2.png
110_5.png  124_2.png  42_7.png  56_4.png  70_1.png  83_6.png  97_3.png
110_6.png  124_3.png  43_0.png  56_5.png  70_2.png  83_7.png  97_4.png
110_7.png  124_4.png  43_1.png  56_6.png  70_3.png  84_0.png  97_5.png
111_0.png  124_5.png  43_2.png  56_7.png  70_4.png  84_1.png  97_6.png
111_1.png  124_6.png  43_3.png  57_0.png  70_5.png  84_2.png  97_7.png
111_2.png  124_7.png  43_4.png  57_1.png  70_6.png  84_3.png  98_0.png
111_3.png  125_0.png  43_5.png  57_2.png  70_7.png  84_4.png  98_1.png
111_4.png  125_1.png  43_6.png  57_3.png  71_0.png  84_5.png  98_2.png
111_5.png  125_2.png  43_7.png  57_4.png  71_1.png  84_6.png  98_3.png
111_6.png  125_3.png  44_0.png  57_5.png  71_2.png  84_7.png  98_4.png
111_7.png  125_4.png  44_1.png  57_6.png  71_3.png  85_0.png  98_5.png
112_0.png  125_5.png  44_2.png  57_7.png  71_4.png  85_1.png  98_6.png
112_1.png  125_6.png  44_3.png  58_0.png  71_5.png  85_2.png  98_7.png
112_2.png  125_7.png  44_4.png  58_1.png  71_6.png  85_3.png  99_0.png
112_3.png  126_0.png  44_5.png  58_2.png  71_7.png  85_4.png  99_1.png
112_4.png  126_1.png  44_6.png  58_3.png  72_0.png  85_5.png  99_2.png
112_5.png  126_2.png  44_7.png  58_4.png  72_1.png  85_6.png  99_3.png
112_6.png  126_3.png  45_0.png  58_5.png  72_2.png  85_7.png  99_4.png
112_7.png  126_4.png  45_1.png  58_6.png  72_3.png  86_0.png  99_5.png
113_0.png  126_5.png  45_2.png  58_7.png  72_4.png  86_1.png  99_6.png
113_1.png  126_6.png  45_3.png  59_0.png  72_5.png  86_2.png  99_7.png
113_2.png  126_7.png  45_4.png  59_1.png  72_6.png  86_3.png
113_3.png  32_0.png   45_5.png  59_2.png  72_7.png  86_4.png
113_4.png  32_1.png   45_6.png  59_3.png  73_0.png  86_5.png
```

### Detector

#### Detector Training

```
../darknet detector train cfg/yolo-person.data cfg/yolo-person.cfg -gpus 0
```

#### Detector Test

![image](https://github.com/lexra/COCO-2014/assets/33512027/ef1e20ee-4a6f-496c-9100-8785c1d6258e)

```bash
../darknet detector test \
	   cfg/yolo-person.data \
    cfg/yolo-person.cfg backup/yolo-person_final.weights \
    pixmaps/people.jpg \
    -thresh 0.40 \
    -dont_show
```

```bash
 CUDA-version: 11070 (12010), cuDNN: 8.9.2, GPU count: 1
 OpenCV version: 4.2.0
 0 : compute_capability = 610, cudnn_half = 0, GPU: NVIDIA GeForce MX250
net.optimized_memory = 0
mini_batch = 1, batch = 1, time_steps = 1, train = 0
   layer   filters  size/strd(dil)      input                output
   0 Create CUDA-stream - 0
 Create cudnn-handle 0
conv      8       3 x 3/ 2    160 x 160 x   1 ->   80 x  80 x   8 0.001 BF
   1 conv      8       1 x 1/ 1     80 x  80 x   8 ->   80 x  80 x   8 0.001 BF
   2 conv      8/   8  3 x 3/ 1     80 x  80 x   8 ->   80 x  80 x   8 0.001 BF
   3 conv      4       1 x 1/ 1     80 x  80 x   8 ->   80 x  80 x   4 0.000 BF
   4 conv      8       1 x 1/ 1     80 x  80 x   4 ->   80 x  80 x   8 0.000 BF
   5 conv      8/   8  3 x 3/ 1     80 x  80 x   8 ->   80 x  80 x   8 0.001 BF
   6 conv      4       1 x 1/ 1     80 x  80 x   8 ->   80 x  80 x   4 0.000 BF
   7 dropout    p = 0.150        25600  ->   25600
   8 Shortcut Layer: 3,  wt = 0, wn = 0, outputs:  80 x  80 x   4 0.000 BF
   9 conv     24       1 x 1/ 1     80 x  80 x   4 ->   80 x  80 x  24 0.001 BF
  10 conv     24/  24  3 x 3/ 2     80 x  80 x  24 ->   40 x  40 x  24 0.001 BF
  11 conv      8       1 x 1/ 1     40 x  40 x  24 ->   40 x  40 x   8 0.001 BF
  12 conv     32       1 x 1/ 1     40 x  40 x   8 ->   40 x  40 x  32 0.001 BF
  13 conv     32/  32  3 x 3/ 1     40 x  40 x  32 ->   40 x  40 x  32 0.001 BF
  14 conv      8       1 x 1/ 1     40 x  40 x  32 ->   40 x  40 x   8 0.001 BF
  15 dropout    p = 0.150        12800  ->   12800
  16 Shortcut Layer: 11,  wt = 0, wn = 0, outputs:  40 x  40 x   8 0.000 BF
  17 conv     32       1 x 1/ 1     40 x  40 x   8 ->   40 x  40 x  32 0.001 BF
  18 conv     32/  32  3 x 3/ 1     40 x  40 x  32 ->   40 x  40 x  32 0.001 BF
  19 conv      8       1 x 1/ 1     40 x  40 x  32 ->   40 x  40 x   8 0.001 BF
  20 dropout    p = 0.150        12800  ->   12800
  21 Shortcut Layer: 16,  wt = 0, wn = 0, outputs:  40 x  40 x   8 0.000 BF
  22 conv     32       1 x 1/ 1     40 x  40 x   8 ->   40 x  40 x  32 0.001 BF
  23 conv     32/  32  3 x 3/ 2     40 x  40 x  32 ->   20 x  20 x  32 0.000 BF
  24 conv      8       1 x 1/ 1     20 x  20 x  32 ->   20 x  20 x   8 0.000 BF
  25 conv     48       1 x 1/ 1     20 x  20 x   8 ->   20 x  20 x  48 0.000 BF
  26 conv     48/  48  3 x 3/ 1     20 x  20 x  48 ->   20 x  20 x  48 0.000 BF
  27 conv      8       1 x 1/ 1     20 x  20 x  48 ->   20 x  20 x   8 0.000 BF
  28 dropout    p = 0.150        3200  ->   3200
  29 Shortcut Layer: 24,  wt = 0, wn = 0, outputs:  20 x  20 x   8 0.000 BF
  30 conv     48       1 x 1/ 1     20 x  20 x   8 ->   20 x  20 x  48 0.000 BF
  31 conv     48/  48  3 x 3/ 1     20 x  20 x  48 ->   20 x  20 x  48 0.000 BF
  32 conv      8       1 x 1/ 1     20 x  20 x  48 ->   20 x  20 x   8 0.000 BF
  33 dropout    p = 0.150        3200  ->   3200
  34 Shortcut Layer: 29,  wt = 0, wn = 0, outputs:  20 x  20 x   8 0.000 BF
  35 conv     48       1 x 1/ 1     20 x  20 x   8 ->   20 x  20 x  48 0.000 BF
  36 conv     48/  48  3 x 3/ 1     20 x  20 x  48 ->   20 x  20 x  48 0.000 BF
  37 conv     16       1 x 1/ 1     20 x  20 x  48 ->   20 x  20 x  16 0.001 BF
  38 conv     96       1 x 1/ 1     20 x  20 x  16 ->   20 x  20 x  96 0.001 BF
  39 conv     96/  96  3 x 3/ 1     20 x  20 x  96 ->   20 x  20 x  96 0.001 BF
  40 conv     16       1 x 1/ 1     20 x  20 x  96 ->   20 x  20 x  16 0.001 BF
  41 dropout    p = 0.150        6400  ->   6400
  42 Shortcut Layer: 37,  wt = 0, wn = 0, outputs:  20 x  20 x  16 0.000 BF
  43 conv     96       1 x 1/ 1     20 x  20 x  16 ->   20 x  20 x  96 0.001 BF
  44 conv     96/  96  3 x 3/ 1     20 x  20 x  96 ->   20 x  20 x  96 0.001 BF
  45 conv     16       1 x 1/ 1     20 x  20 x  96 ->   20 x  20 x  16 0.001 BF
  46 dropout    p = 0.150        6400  ->   6400
  47 Shortcut Layer: 42,  wt = 0, wn = 0, outputs:  20 x  20 x  16 0.000 BF
  48 conv     96       1 x 1/ 1     20 x  20 x  16 ->   20 x  20 x  96 0.001 BF
  49 conv     96/  96  3 x 3/ 1     20 x  20 x  96 ->   20 x  20 x  96 0.001 BF
  50 conv     16       1 x 1/ 1     20 x  20 x  96 ->   20 x  20 x  16 0.001 BF
  51 dropout    p = 0.150        6400  ->   6400
  52 Shortcut Layer: 47,  wt = 0, wn = 0, outputs:  20 x  20 x  16 0.000 BF
  53 conv     96       1 x 1/ 1     20 x  20 x  16 ->   20 x  20 x  96 0.001 BF
  54 conv     96/  96  3 x 3/ 1     20 x  20 x  96 ->   20 x  20 x  96 0.001 BF
  55 conv     16       1 x 1/ 1     20 x  20 x  96 ->   20 x  20 x  16 0.001 BF
  56 dropout    p = 0.150        6400  ->   6400
  57 Shortcut Layer: 52,  wt = 0, wn = 0, outputs:  20 x  20 x  16 0.000 BF
  58 conv     96       1 x 1/ 1     20 x  20 x  16 ->   20 x  20 x  96 0.001 BF
  59 conv     96/  96  3 x 3/ 2     20 x  20 x  96 ->   10 x  10 x  96 0.000 BF
  60 conv     24       1 x 1/ 1     10 x  10 x  96 ->   10 x  10 x  24 0.000 BF
  61 conv    136       1 x 1/ 1     10 x  10 x  24 ->   10 x  10 x 136 0.001 BF
  62 conv    136/ 136  3 x 3/ 1     10 x  10 x 136 ->   10 x  10 x 136 0.000 BF
  63 conv     24       1 x 1/ 1     10 x  10 x 136 ->   10 x  10 x  24 0.001 BF
  64 dropout    p = 0.150        2400  ->   2400
  65 Shortcut Layer: 60,  wt = 0, wn = 0, outputs:  10 x  10 x  24 0.000 BF
  66 conv    136       1 x 1/ 1     10 x  10 x  24 ->   10 x  10 x 136 0.001 BF
  67 conv    136/ 136  3 x 3/ 1     10 x  10 x 136 ->   10 x  10 x 136 0.000 BF
  68 conv     24       1 x 1/ 1     10 x  10 x 136 ->   10 x  10 x  24 0.001 BF
  69 dropout    p = 0.150        2400  ->   2400
  70 Shortcut Layer: 65,  wt = 0, wn = 0, outputs:  10 x  10 x  24 0.000 BF
  71 conv    136       1 x 1/ 1     10 x  10 x  24 ->   10 x  10 x 136 0.001 BF
  72 conv    136/ 136  3 x 3/ 1     10 x  10 x 136 ->   10 x  10 x 136 0.000 BF
  73 conv     24       1 x 1/ 1     10 x  10 x 136 ->   10 x  10 x  24 0.001 BF
  74 dropout    p = 0.150        2400  ->   2400
  75 Shortcut Layer: 70,  wt = 0, wn = 0, outputs:  10 x  10 x  24 0.000 BF
  76 conv    136       1 x 1/ 1     10 x  10 x  24 ->   10 x  10 x 136 0.001 BF
  77 conv    136/ 136  3 x 3/ 1     10 x  10 x 136 ->   10 x  10 x 136 0.000 BF
  78 conv     24       1 x 1/ 1     10 x  10 x 136 ->   10 x  10 x  24 0.001 BF
  79 dropout    p = 0.150        2400  ->   2400
  80 Shortcut Layer: 75,  wt = 0, wn = 0, outputs:  10 x  10 x  24 0.000 BF
  81 conv    136       1 x 1/ 1     10 x  10 x  24 ->   10 x  10 x 136 0.001 BF
  82 conv    136/ 136  3 x 3/ 2     10 x  10 x 136 ->    5 x   5 x 136 0.000 BF
  83 conv     48       1 x 1/ 1      5 x   5 x 136 ->    5 x   5 x  48 0.000 BF
  84 conv    224       1 x 1/ 1      5 x   5 x  48 ->    5 x   5 x 224 0.001 BF
  85 conv    224/ 224  3 x 3/ 1      5 x   5 x 224 ->    5 x   5 x 224 0.000 BF
  86 conv     48       1 x 1/ 1      5 x   5 x 224 ->    5 x   5 x  48 0.001 BF
  87 dropout    p = 0.150        1200  ->   1200
  88 Shortcut Layer: 83,  wt = 0, wn = 0, outputs:   5 x   5 x  48 0.000 BF
  89 conv    224       1 x 1/ 1      5 x   5 x  48 ->    5 x   5 x 224 0.001 BF
  90 conv    224/ 224  3 x 3/ 1      5 x   5 x 224 ->    5 x   5 x 224 0.000 BF
  91 conv     48       1 x 1/ 1      5 x   5 x 224 ->    5 x   5 x  48 0.001 BF
  92 dropout    p = 0.150        1200  ->   1200
  93 Shortcut Layer: 88,  wt = 0, wn = 0, outputs:   5 x   5 x  48 0.000 BF
  94 conv    224       1 x 1/ 1      5 x   5 x  48 ->    5 x   5 x 224 0.001 BF
  95 conv    224/ 224  3 x 3/ 1      5 x   5 x 224 ->    5 x   5 x 224 0.000 BF
  96 conv     48       1 x 1/ 1      5 x   5 x 224 ->    5 x   5 x  48 0.001 BF
  97 dropout    p = 0.150        1200  ->   1200
  98 Shortcut Layer: 93,  wt = 0, wn = 0, outputs:   5 x   5 x  48 0.000 BF
  99 conv    224       1 x 1/ 1      5 x   5 x  48 ->    5 x   5 x 224 0.001 BF
 100 conv    224/ 224  3 x 3/ 1      5 x   5 x 224 ->    5 x   5 x 224 0.000 BF
 101 conv     48       1 x 1/ 1      5 x   5 x 224 ->    5 x   5 x  48 0.001 BF
 102 dropout    p = 0.150        1200  ->   1200
 103 Shortcut Layer: 98,  wt = 0, wn = 0, outputs:   5 x   5 x  48 0.000 BF
 104 conv    224       1 x 1/ 1      5 x   5 x  48 ->    5 x   5 x 224 0.001 BF
 105 conv    224/ 224  3 x 3/ 1      5 x   5 x 224 ->    5 x   5 x 224 0.000 BF
 106 conv     48       1 x 1/ 1      5 x   5 x 224 ->    5 x   5 x  48 0.001 BF
 107 dropout    p = 0.150        1200  ->   1200
 108 Shortcut Layer: 103,  wt = 0, wn = 0, outputs:   5 x   5 x  48 0.000 BF
 109 max                3x 3/ 1      5 x   5 x  48 ->    5 x   5 x  48 0.000 BF
 110 route  108                                            ->    5 x   5 x  48
 111 max                5x 5/ 1      5 x   5 x  48 ->    5 x   5 x  48 0.000 BF
 112 route  108                                            ->    5 x   5 x  48
 113 max                9x 9/ 1      5 x   5 x  48 ->    5 x   5 x  48 0.000 BF
 114 route  113 111 109 108                        ->    5 x   5 x 192
 115 conv     96       1 x 1/ 1      5 x   5 x 192 ->    5 x   5 x  96 0.001 BF
 116 conv     96/  96  5 x 5/ 1      5 x   5 x  96 ->    5 x   5 x  96 0.000 BF
 117 conv     96       1 x 1/ 1      5 x   5 x  96 ->    5 x   5 x  96 0.000 BF
 118 conv     96/  96  5 x 5/ 1      5 x   5 x  96 ->    5 x   5 x  96 0.000 BF
 119 conv     96       1 x 1/ 1      5 x   5 x  96 ->    5 x   5 x  96 0.000 BF
 120 conv     18       1 x 1/ 1      5 x   5 x  96 ->    5 x   5 x  18 0.000 BF
 121 yolo
[yolo] params: iou loss: ciou (4), iou_norm: 0.07, obj_norm: 1.00, cls_norm: 1.00, delta_norm: 1.00, scale_x_y: 1.00
nms_kind: greedynms (1), beta = 0.600000
 122 route  115                                            ->    5 x   5 x  96
 123 upsample                 2x     5 x   5 x  96 ->   10 x  10 x  96
 124 route  123 80                                 ->   10 x  10 x 120
 125 conv    120/ 120  5 x 5/ 1     10 x  10 x 120 ->   10 x  10 x 120 0.001 BF
 126 conv    120       1 x 1/ 1     10 x  10 x 120 ->   10 x  10 x 120 0.003 BF
 127 conv    120/ 120  5 x 5/ 1     10 x  10 x 120 ->   10 x  10 x 120 0.001 BF
 128 conv    120       1 x 1/ 1     10 x  10 x 120 ->   10 x  10 x 120 0.003 BF
 129 conv     18       1 x 1/ 1     10 x  10 x 120 ->   10 x  10 x  18 0.000 BF
 130 yolo
[yolo] params: iou loss: ciou (4), iou_norm: 0.07, obj_norm: 1.00, cls_norm: 1.00, delta_norm: 1.00, scale_x_y: 1.00
nms_kind: greedynms (1), beta = 0.600000
Total BFLOPS 0.054
avg_outputs = 15199
 Allocate additional workspace_size = 0.04 MB
Loading weights from backup/yolo-person_last.weights...
 seen 64, trained: 3568 K-images (55 Kilo-batches_64)
Done! Loaded 131 layers from weights-file
 Detection layer: 121 - type = 28
 Detection layer: 130 - type = 28
pixmaps/people.jpg: Predicted in 439.069000 milli-seconds.
person: 56%
person: 99%
person: 77%
person: 28%
person: 65%
person: 98%
person: 98%
person: 57%
person: 43%
person: 100%
person: 89%
person: 40%
person: 81%
person: 80%
person: 40%
```

### .CC file Generation

#### Python Packages Requirement

```bash
typing-extensions==3.10.0
python-dateutil==2.8.2
packaging==21.2
flatbuffers==23.1.21
requests==2.31.0
chardet==4.0.0
elastic-transport==8.0.0
google-auth==2.15.0
protobuf==3.20.3
urllib3==1.26.2
grpcio==1.48.2
testresources
numpy==1.23.5
setuptools
scipy
scikit-learn==0.20.3
opencv-python==4.2.0.32
opencv-contrib-python==4.2.0.32
tensorflow==2.13.0
tensorrt
keras_applications
tensorflow-model-optimization==0.5.0
tensorflow-addons
matplotlib
tqdm
pillow
mnn
Cython
pycocotools
keras2onnx
tf2onnx==0.4.2
onnx
onnxruntime
tfcoreml==1.1
sympy
imgaug
imagecorruptions
bokeh==2.4.0
tidecv
```

```bash
pip3 install -r requirements.txt
```

#### Convert to Keras

```bash
python3 ../keras-YOLOv3-model-set/tools/model_converter/fastest_1.1_160/convert.py \
    --config_path cfg/yolo-person.cfg \
    --weights_path backup/yolo-person.weights \
    --output_path backup/yolo-person.h5
```

#### Convert to Tensorflow Lite

```bash
python3 ../keras-YOLOv3-model-set/tools/model_converter/fastest_1.1_160/post_train_quant_convert_demo.py \
    --keras_model_file backup/yolo-person.h5 \
    --annotation_file coco/trainvalno5k.txt \
    --output_file backup/yolo-person.tflite
```

Note please, we use the `trainvalno5k.txt` annotation file for `--annotation_file` input parameter. 

#### XXD

```
xxd -i backup/yolo-person.tflite > backup/yolo-person.cc
```

