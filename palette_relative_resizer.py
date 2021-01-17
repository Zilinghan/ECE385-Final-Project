from PIL import Image
from collections import Counter
from scipy.spatial import KDTree
import numpy as np
print("Module Imported!")

def hex_to_rgb(num):
    h = str(num)
    return int(h[0:4], 16), int(('0x' + h[4:6]), 16), int(('0x' + h[6:8]), 16)
def rgb_to_hex(num):
    h = str(num)
    return int(h[0:4], 16), int(('0x' + h[4:6]), 16), int(('0x' + h[6:8]), 16)

palette_hex = ['0x0D01FF', '0xF83800', '0xF0D0B0', '0x503000', '0xFFE0A8', '0x0058F8', '0xFCFCFC', '0xBA340C', 
               '0xA40000', '0xD82800', '0xFC7460', '0xFCBCB0', '0xF0BC3C', '0xAEACAE', '0x363301', '0x6C6C01',
               '0xBBBD00', '0x88D500', '0x398802', '0x65B0FF', '0x155ED8', '0x800080', '0x24188A', '0xE10B0B',
               '0xCC1919', '0xEA2F12', '0xEA4213', '0xEE6011', '0xD45611', '0xD47911', '0xEAAA2B', '0xE6B312',
               '0xC1981C', '0xB9A35E', '0xEAD07E', '0x80640C', '0xEADD1D', '0xBDB32C', '0xBDB104', '0xCFDB22',
               '0xD7DF6C', '0xB4DB18', '0x90AE1B', '0xAAB96C', '0x8BF612', '0x71BB1D', '0x4A8408', '0x2BF20C',
               '0x0CF235', '0x0CF287', '0x0CF2A5', '0x12E3C2', '0x32F6E0', '0x09D4F9', '0x09A9F9', '0x2812B5',
               '0x6022EA', '0x6A0AE3', '0x8014D0', '0xAF48E3', '0xC30AF2', '0xF20AE2', '0xD01D64', '0xF20726']
palette_rgb = [hex_to_rgb(color) for color in palette_hex]

pixel_tree = KDTree(palette_rgb)

while(1):
    filename = input("What's the image name? ")
    new_w, new_h = map(int, input("What's the new height x width? Like 28 28. ").split(' '))
    im = Image.open("../sprite_originals/" + filename+ ".png") #Can be many different formats.
    im = im.convert("RGBA")
    im = im.resize((new_w, new_h),Image.ANTIALIAS) # regular resize
    pix = im.load()
    pix_freqs = Counter([pix[x, y] for x in range(im.size[0]) for y in range(im.size[1])])
    pix_freqs_sorted = sorted(pix_freqs.items(), key=lambda x: x[1])
    pix_freqs_sorted.reverse()
    #print(pix)
    outImg = Image.new('RGB', im.size, color='white')
    outFile = open("../sprite_bytes/" + filename + '.txt', 'w')
    i = 0
    for y in range(im.size[1]):
        for x in range(im.size[0]):
            pixel = im.getpixel((x,y))
            #print(pixel)
            if(pixel[3] < 200):
                outImg.putpixel((x,y), palette_rgb[0])
                outFile.write("%x\n" % (0))
                #print(i)
            else:
                index = pixel_tree.query(pixel[:3])[1]
                outImg.putpixel((x,y), palette_rgb[index])
                outFile.write("%x\n" % (index))
            i += 1
    outFile.close()
    outImg.save("../sprite_converted/" + filename + ".png")
