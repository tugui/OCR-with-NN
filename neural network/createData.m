%% Initialization
clear ; close all; clc
round = 3000;
training_labels = [];
for n = 0:9
    %{
    if n == 8
        round = round * 4;
        training_labels = [training_labels;n*ones(round,1)];
        round = round / 4;
    elseif n == 0
        round = round * 3;
        training_labels = [training_labels;n*ones(round,1)];
        round = round / 3;
    elseif n == 2
        round = round * 2;
        training_labels = [training_labels;n*ones(round,1)];
        round = round / 2;
    else
        training_labels = [training_labels;n*ones(round,1)];
    end
    %}
    training_labels = [training_labels;n*ones(round,1)];
end

%% read image data
training_imgs = [];
se = strel('square',2);
for n = 0:9
    %{
    if n == 8
        round = round * 4;
    elseif n == 0
        round = round * 3;
    elseif n == 2
        round = round * 2;
    end
    %}
    for i = 1:round
        img = imread(['test2/',num2str(n),'-',num2str(i),'.png']);
        img = rgb2gray(img);
        %img = imresize(img,[20 20]);
        thresh = graythresh(img);%自动确定二值化阈值
        img = im2bw(img,thresh);
        img = imopen(img,se);%必要处理，保证一致性

        P = [];
        for j = 1:20
            P = [P img(j,:)];%to 1*400
        end

        %if P(1,1) == 1 || P(1,20) == 1 || P(1,381) == 1 || P(1,400) == 1
        %    P = 1 - P;
        %end
        training_imgs = [training_imgs;P];

        % if we want to see the image
        %{
        img = zeros(20,20);
        for k = 1:20
            img(k,1:20) = P(1,(k-1)*20+1:k*20);
        end
        imshow(img);
        pause();
        %}
    end
    %{
    if n == 8
        round = round / 4;
    elseif n == 0
        round = round / 3;
    elseif n == 2
        round = round / 2;
    end
    %}
end

shuffle = randperm(size(training_labels,1));
training_labels = training_labels(shuffle);
training_imgs = training_imgs(shuffle,:);
training_imgs = logical(training_imgs);
training_imgs = sparse(training_imgs);
save training_imgs.mat training_imgs training_labels
