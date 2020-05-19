% thresholding
% can't use ; - ;
clear all; close all; clc;
warning off;

img = rgb2gray(imread('01.JPG'));
thvalue = 95;
    [m,n] = size(img);
    img = medfilt2(img);
    result = zeros(m,n);
    for i = 1 : m
        for j = 1 : n 
            if img(i,j) <= thvalue 
                result(i,j) = 0;
            else
                result(i,j) = 1;
            end
        end
    end
   
    sw = strel('disk',1);
    result = imdilate(result,sw);
    result = imfill(result,'holes');
    se = strel('disk',6);
    result = imerode(result,se);
    result = imfill(result,'holes');


    
    figure
    imshow(result);
