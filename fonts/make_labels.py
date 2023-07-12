import os
import string
import pipes

font = '/usr/share/fonts/truetype/dongle/Futura_Medium.ttf'

def make_labels(s):
    l = string.printable
    for word in l:
        if word == ' ':
            err = os.system('convert-im6.q16 -fill black -background white -bordercolor white -font %s -pointsize %d label:"\ " 32_%d.png'%(font,s,s/12-1) )
            if 0 != err:
                print('ERR 0')
        elif word == '@':
            err = os.system('convert -fill black -background white -bordercolor white -font %s -pointsize %d label:"\@" 64_%d.png'%(font,s,s/12-1))
            if 0 != err:
                print('ERR 1')
        elif word == '\\':
            err = os.system('convert -fill black -background white -bordercolor white -font %s -pointsize %d label:"\\\\\\\\" 92_%d.png'%(font,s,s/12-1))
            if 0 != err:
                print('ERR 2')
        elif ord(word) in [9,10,11,12,13,14]:
            pass
        else:
            err = os.system("convert -fill black -background white -bordercolor white -font %s -pointsize %d label:%s \"%d_%d.png\""%(font,s,pipes.quote(word), ord(word),s/12-1))
            if 0 != err:
                print('ERR 3')

for i in [12,24,36,48,60,72,84,96]:
    make_labels(i)
