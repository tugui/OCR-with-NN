#coding=utf-8
import random
import string
import sys
import math
from PIL import Image,ImageDraw,ImageFont,ImageFilter

# 字体库位置
font_path = 'msyhbd.ttc'
# 生成验证码个数
number = 1
# 生成验证码图片的高度和宽度
size = (20,20)
# 背景颜色
bgcolor = (0,0,0)
# 字体颜色
fontcolor = (255,255,255)
# 是否要加入干扰线
draw_lines = True
# 加入干扰线条数的上下限
line_number = (0,1)
draw_points = True
point_rate = (0,15)
word_size = (15,20)
picture_number = 3000+1
digits = ['0','1','2','3','4','5','6','7','8','9']

# 用来随机生成一个字符串
def gene_text():
    source = list(string.digits)
    for index in range(0,10):
        source.append(str(index))
    return ''.join(random.sample(source,number)) # number是生成验证码的位数

# 用来绘制干扰线
def gene_line(draw,width,height):
    line_num = random.randint(line_number[0],line_number[1])  
    for i in range(line_num): 
        begin = (random.randint(0, width), random.randint(0, height))
        end = (random.randint(0, width), random.randint(0, height))
        if random.randint(0, 1):
            draw.line([begin, end], fill = (0, 0, 0))
        else:
            draw.line([begin, end], fill = (255, 255, 255))

# 绘制干扰点
def create_points(draw,width,height):
        chance = random.randint(point_rate[0],point_rate[1])
        for w in xrange(width):
            for h in xrange(height):
                tmp = random.randint(0, 100)
                if tmp > 100 - chance / 2:
                    draw.point((w, h), fill=(255, 255, 255))
                if tmp > 100 - chance and tmp < 100 - chance / 2:
                    draw.point((w, h), fill=(0, 0, 0))

# 生成验证码
def gene_code():
    for digit in digits:
        for k in range(1,picture_number):
            width,height = size # 宽和高
            image = Image.new('RGBA',(width,height),bgcolor) # 创建图片
            font = ImageFont.truetype(font_path,random.randint(word_size[0],word_size[1])) # 验证码的字体
            draw = ImageDraw.Draw(image)  # 创建画笔
            # text = gene_text() # 生成字符串
            text = digit
            font_width, font_height = font.getsize(text)
            draw.text((
                    (width - font_width) / 2 / number + random.randint(-4, 3), 
                    (height - font_height) / 2 /  number - 2),
                    text, font = font,fill = fontcolor) # 填充字符串

            if draw_lines:
                gene_line(draw,width,height)

            if draw_points:
                create_points(draw,width,height)
             
            params = [1 - float(random.randint(1, 2)) / 100,  
            0,  0,  0,  1 - float(random.randint(1, 10)) / 100, 
            float(random.randint(1, 2)) / 500,  0.001,  
            float(random.randint(1, 2)) / 500  ]
            image = image.transform(size, Image.PERSPECTIVE, params) # 创建扭曲
            image.save('test2/'+digit+'-'+str(k)+'.png') # 保存验证码图片

if __name__ == "__main__":
    gene_code()

