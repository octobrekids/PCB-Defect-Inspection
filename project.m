clear all; close all; clc;
warning off;

% image acquitise
T_template = imread('01.jpg');
T_input = imread('01_missing_hole_05.jpg');

% image pyramid
tempResize = impyramid(T_template, 'reduce');
inputResize = impyramid(T_input, 'reduce');

tempGray = rgb2gray(tempResize);
inputGray = rgb2gray(inputResize);

preresult = tempGray - inputGray;
preresult = imbinarize(preresult,0.05);

% label defect region
L = bwlabel(preresult,8);

% defect boundaries 
[B,A] = bwboundaries(preresult, 'noholes');

% defect region properties
STATS = regionprops(A, 'all');

% n of defect region
nDefect = size(STATS,1);

label = cell(nDefect,1);

position = cat(1, STATS(:).BoundingBox);

for i = 1 : nDefect
    if(STATS(i).Circularity >= 1)
        label(i) = cellstr("Missing Hole");
    else
        label(i) = cellstr("no missing");
    end
end

position(:,1) = position(:,1) - 5;
position(:,3) = position(:,3) + 5;
s = insertObjectAnnotation(inputResize,'rectangle',position,label,...
    'TextBoxOpacity',0.8,'FontSize',10);
figure
imshow(s);


 

