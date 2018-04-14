clear ; close all; clc

[fn,pn,fi]=uigetfile('*.png','选择图片');
I=imread([pn fn]);%读取图片

figure();
subplot(3,2,1),imshow(I),title('原始图像');

I1=rgb2gray(I);%灰度化
subplot(3,2,2),imshow(I1),title('灰度图像');

I2=edge(I1,'canny');%边缘检测
subplot(3,2,3),imshow(I2),title('边缘检测后图像');

se=[1;1;1];%线型结构元素
I3=imerode(I2,se);%腐蚀操作
subplot(3,2,4),imshow(I3),title('腐蚀后边缘图像');

se=strel('rectangle',[25,25]); 
I4=imclose(I3,se);%闭运算
subplot(3,2,5),imshow(I4),title('填充后图像');

I5=bwareaopen(I4,100);%去除聚团灰度值小于100的部分
subplot(3,2,6),imshow(I5),title('形态滤波后图像');

[y,x,z]=size(I5);
I6=double(I5);
%% 计算行像素灰度累积值
Y1=zeros(y,1);%行像素统计
for i=1:y
	for j=1:x
        if I6(i,j,1)==1
            Y1(i,1)= Y1(i,1)+1; 
        end
    end
end
[temp,MaxY]=max(Y1);
figure();
subplot(3,2,1),plot(0:y-1,Y1),title('行方向像素点灰度值累计和'),xlabel('行值'),ylabel('像素');  

%% 从最大像素量所在行处往上下扫描，如果像素量大于阈值则继续直到尽头
shreshold = 110;
PY1=MaxY;
while Y1(PY1,1)>=shreshold && PY1>1
	PY1=PY1-1;
end
PY2=MaxY;
while Y1(PY2,1)>=shreshold && PY2<y
	PY2=PY2+1;
end

%% 计算列像素灰度累积值
IY=I(PY1:PY2,:,:);
X1=zeros(1,x);%列像素统计
for j=1:x
	for i=PY1:PY2
        if(I6(i,j,1)==1)
            X1(1,j)= X1(1,j)+1;
        end 
	end
end
subplot(3,2,2),plot(0:x-1,X1),title('列方向像素点灰度值累计和'),xlabel('列值'),ylabel('像素');

%% 从两边向中间扫描，如果像素量小于阈值则剪掉
%{
shreshold = 5;
PX1=1;
while X1(1,PX1)<shreshold && PX1<x
	PX1=PX1+1;
end
PX2=x;
while X1(1,PX2)<shreshold && PX2>PX1
	PX2=PX2-1;
end
%}

%% 从中间列处往左右扫描，如果像素量大于阈值则停止
shreshold = 20;
PX1=fix(x/2);
while X1(1,PX1)<=shreshold && PX1>1
	PX1=PX1-1;
end
PX2=fix(x/2);
while X1(1,PX2)<=shreshold && PX2<x
	PX2=PX2+1;
end

%% 后续处理
position=I(PY1:PY2,PX1:PX2,:);%定位切割
subplot(3,2,3),imshow(position),title('定位剪切图像')
h=fspecial('gaussian',[3 3],0.1);
position = imfilter(position,h);%高斯滤波

I1 = rgb2gray(position);%灰度化
I1=im2bw(I1,0.27);%二值化-阈值(0.26~0.28)
I1=1-I1;%黑白反转
subplot(3,2,4),imshow(I1),title('二值化图像');

se = strel('rectangle',[2 2]);
I2=imclose(I1,se);%开运算
subplot(3,2,5),imshow(I2),title('开运算后二值化图像');

[y1,x1,z1]=size(I2);
I3=double(I2);

%% 去除图像顶端和底端的无用区域
shreshold = 10;
Y1=zeros(y1,1);
for i=1:y1
	for j=1:x1
        if(I3(i,j,1)==1)
            Y1(i,1)=Y1(i,1)+1;
        end
	end       
end
%剪掉行像素总量不够阈值的上下部分
Py0=1;
while Y1(Py0,1)<shreshold && Py0<y1
	Py0=Py0+1;
end
Py1=Py0;
while Y1(Py1,1)>=shreshold && Py1<y1
	 Py1=Py1+1;
end
I2=I2(Py0:Py1,:,:);
subplot(3,2,6),imshow(I2),title('目标字符区域');


%% 重新计算列灰度累积值
X1=zeros(1,x1);
for j=1:x1
	for i=1:y1
        if I3(i,j,1)==1
            X1(1,j)= X1(1,j)+1;
        end
    end
end
figure(3);
plot(0:x1-1,X1),title('列方向像素点灰度值累计和'),xlabel('列值'),ylabel('累计像素量');

%% 分割字符
load 神经网络/Theta1
load 神经网络/Theta2
Px0=1;%起始位置
Px1=1;%终止位置
count=1;%字符个数
P2 = [];
[~,n]=size(I2);
for i=1:20
	while X1(1,Px0)<2 && Px0<x1
        Px0=Px0+1;
    end
    
	Px1=Px0;
	while (Px1<x1 && X1(1,Px1)>=3) || ((Px1-Px0)<4 && Px1<n)
        Px1=Px1+1;
    end

	Z=I2(:,Px0:Px1,:);
    
    l=Px1-Px0;
    if l>4 %限制宽度,避免误计(去除斜线、冒号、噪点等)
        Z(all(Z==0,1),:) = []; %去掉矩阵中的全零列
        Z(all(Z==0,2),:) = []; %去掉矩阵中的全零行
        
        diss = max(size(Z)) - min(size(Z));
        [a,b] = size(Z);
        if a > b
            c = zeros(a,fix(diss/2));
            d = zeros(a,diss-fix(diss/2));
            P = [c Z d];
        end
        if a < b
            c = zeros(fix(diss/2),b);
            d = zeros(diss-fix(diss/2),b);
            P = [c;Z;d];
        end
        
        [a,b] = size(P);
        if b < 20
            c = zeros(a,20-b);
            P = [c P];
        end
        if a < 20
            c = zeros(20-a,20);
            P = [P;c];
        end
        
        if a > 20
            P = imresize(P,20/a,'bicubic');
            se = strel('square',2);
        	P = imclose(P,se);%闭运算
        end
        
        P = bwareaopen(P,10);%2~30
        figure(4),subplot(3,5,count),imshow(P);
        
        count = count + 1;
        
        P1 = [];
        for j = 1:20
            P1 = [P1 P(j,:)];
        end
        
        %recover
        %{
        img = zeros(20,20);
        for k = 1:20
            img(k,1:20) = P1(1,(k-1)*20+1:k*20);
        end
        figure(4),subplot(3,5,count),imshow(img);
        %}

        P2 = [P2;P1];
        
    end
	Px0=Px1;
end

pred = [2;10;1;2;10;1;10;8;1;1;10;1;1];
y = predict(Theta1,Theta2,P2)
fprintf('\nTraining Set Accuracy: %f\n', mean(double(pred(1:12) == y(1:12))) * 100);