clear ; close all; clc

[fn,pn,fi]=uigetfile('*.png','ѡ��ͼƬ');
I=imread([pn fn]);%��ȡͼƬ

figure();
subplot(3,2,1),imshow(I),title('ԭʼͼ��');

I1=rgb2gray(I);%�ҶȻ�
subplot(3,2,2),imshow(I1),title('�Ҷ�ͼ��');

I2=edge(I1,'canny');%��Ե���
subplot(3,2,3),imshow(I2),title('��Ե����ͼ��');

se=[1;1;1];%���ͽṹԪ��
I3=imerode(I2,se);%��ʴ����
subplot(3,2,4),imshow(I3),title('��ʴ���Եͼ��');

se=strel('rectangle',[25,25]); 
I4=imclose(I3,se);%������
subplot(3,2,5),imshow(I4),title('����ͼ��');

I5=bwareaopen(I4,100);%ȥ�����ŻҶ�ֵС��100�Ĳ���
subplot(3,2,6),imshow(I5),title('��̬�˲���ͼ��');

[y,x,z]=size(I5);
I6=double(I5);
%% ���������ػҶ��ۻ�ֵ
Y1=zeros(y,1);%������ͳ��
for i=1:y
	for j=1:x
        if I6(i,j,1)==1
            Y1(i,1)= Y1(i,1)+1; 
        end
    end
end
[temp,MaxY]=max(Y1);
figure();
subplot(3,2,1),plot(0:y-1,Y1),title('�з������ص�Ҷ�ֵ�ۼƺ�'),xlabel('��ֵ'),ylabel('����');  

%% ����������������д�������ɨ�裬���������������ֵ�����ֱ����ͷ
shreshold = 110;
PY1=MaxY;
while Y1(PY1,1)>=shreshold && PY1>1
	PY1=PY1-1;
end
PY2=MaxY;
while Y1(PY2,1)>=shreshold && PY2<y
	PY2=PY2+1;
end

%% ���������ػҶ��ۻ�ֵ
IY=I(PY1:PY2,:,:);
X1=zeros(1,x);%������ͳ��
for j=1:x
	for i=PY1:PY2
        if(I6(i,j,1)==1)
            X1(1,j)= X1(1,j)+1;
        end 
	end
end
subplot(3,2,2),plot(0:x-1,X1),title('�з������ص�Ҷ�ֵ�ۼƺ�'),xlabel('��ֵ'),ylabel('����');

%% ���������м�ɨ�裬���������С����ֵ�����
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

%% ���м��д�������ɨ�裬���������������ֵ��ֹͣ
shreshold = 20;
PX1=fix(x/2);
while X1(1,PX1)<=shreshold && PX1>1
	PX1=PX1-1;
end
PX2=fix(x/2);
while X1(1,PX2)<=shreshold && PX2<x
	PX2=PX2+1;
end

%% ��������
position=I(PY1:PY2,PX1:PX2,:);%��λ�и�
subplot(3,2,3),imshow(position),title('��λ����ͼ��')
h=fspecial('gaussian',[3 3],0.1);
position = imfilter(position,h);%��˹�˲�

I1 = rgb2gray(position);%�ҶȻ�
I1=im2bw(I1,0.27);%��ֵ��-��ֵ(0.26~0.28)
I1=1-I1;%�ڰ׷�ת
subplot(3,2,4),imshow(I1),title('��ֵ��ͼ��');

se = strel('rectangle',[2 2]);
I2=imclose(I1,se);%������
subplot(3,2,5),imshow(I2),title('��������ֵ��ͼ��');

[y1,x1,z1]=size(I2);
I3=double(I2);

%% ȥ��ͼ�񶥶˺͵׶˵���������
shreshold = 10;
Y1=zeros(y1,1);
for i=1:y1
	for j=1:x1
        if(I3(i,j,1)==1)
            Y1(i,1)=Y1(i,1)+1;
        end
	end       
end
%��������������������ֵ�����²���
Py0=1;
while Y1(Py0,1)<shreshold && Py0<y1
	Py0=Py0+1;
end
Py1=Py0;
while Y1(Py1,1)>=shreshold && Py1<y1
	 Py1=Py1+1;
end
I2=I2(Py0:Py1,:,:);
subplot(3,2,6),imshow(I2),title('Ŀ���ַ�����');


%% ���¼����лҶ��ۻ�ֵ
X1=zeros(1,x1);
for j=1:x1
	for i=1:y1
        if I3(i,j,1)==1
            X1(1,j)= X1(1,j)+1;
        end
    end
end
figure(3);
plot(0:x1-1,X1),title('�з������ص�Ҷ�ֵ�ۼƺ�'),xlabel('��ֵ'),ylabel('�ۼ�������');

%% �ָ��ַ�
load ������/Theta1
load ������/Theta2
Px0=1;%��ʼλ��
Px1=1;%��ֹλ��
count=1;%�ַ�����
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
    if l>4 %���ƿ��,�������(ȥ��б�ߡ�ð�š�����)
        Z(all(Z==0,1),:) = []; %ȥ�������е�ȫ����
        Z(all(Z==0,2),:) = []; %ȥ�������е�ȫ����
        
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
        	P = imclose(P,se);%������
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