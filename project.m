clear all; close all; clc;
warning off;

% image acquitise
T_template = imread('01.jpg');
T_input = imread('07.jpg');

tempResize = imresize(T_template, 0.8);
inputResize = imresize(T_input, 0.8);

tempGray = rgb2gray(tempResize);
inputGray = rgb2gray(inputResize);

tempGray = imgaussfilt(tempGray,2);
inputGray = imgaussfilt(inputGray,2);

template = imbinarize(tempGray,0.185);
input = imbinarize(inputGray,0.185);


preresult = xor(template,input);


de = strel('disk',2,0);
se = strel('line',10,7);
die = strel('disk',3,0);
result = imclose(preresult,de);
result = imopen(result,se);

imshow(result);


BW = logical(result);
connectCom = bwconncomp(result,4);
L = bwlabel(BW,4);

[r, c] = find(L==1);
rc = [r,c];
%rc = sort(rc);
rr = unique(r);
cc = unique(c);

[B,L] = bwboundaries(result, 'noholes');
STATS = regionprops(L, 'all');
%W = zeros(1,length(STATS));
%tembMat = cell2mat(B);

%for i = 1 : length(STATS)
%    W(i) = abs(STATS(i).BoundingBox(3)-STATS(i).BoundingBox(4))
%    W(i) = W(i) + 2 * uint8((STATS(i).Extent - 1) == 0 );
%end


position = [rc(1,2) rc(1,1) size(cc,1) size(rr,1)];
label_str = "missing hole";
s = insertObjectAnnotation(inputResize,'rectangle',position,label_str,...
    'TextBoxOpacity',0.9,'FontSize',10);


%position = [rc(1,2) rc(1,1) size(cc,1) size(rr,1)];
%label_str = "missing hole";
%s = insertObjectAnnotation(inputResize,'rectangle',position,label_str,...
%    'TextBoxOpacity',0.9,'FontSize',10);

%imshow(s);

tempb = bwboundaries(result);

tembMat = cell2mat(tempb);
[nrows,~] = cellfun(@size,tempb);

% ---- Fourier Descriptor ----

% ---- reconstruct of the contour b(k) ----

b = zeros(3,max(nrows));
Binv = zeros(3,max(nrows));

for i = 1 : size(tempb,1)
    for k = 1 : nrows(i)
        b(i,k) = tembMat(k,1) + (1i * tembMat(k,2));
    end
end

% ---- A(v) ----

A = zeros(size(tempb,1),1);

for v = 1 : size(tempb,1)
    temp = 0;
    for k = 1 : nrows(i)
        temp = temp + b(v,k) * exp(-1i * 2 * pi * v * k/nrows(i));
    end
    A(v) =  temp;
end

% --- approximate reconstruct ---
P = 3;
for i = 1 : size(tempb,1)
    
    for k = 1 : nrows(i)
        for v = 1 : P 
          temp = temp + A(v) * exp(1i * 2 * pi * v * k /nrows(i));
        end
        Binv(i, k) = (1/P) * sum(temp);
        temp = 0;
    end
end

[rowinput,colinput] = size(inputGray);

imgtemp = zeros(rowinput,colinput);

Binv_matone = reshape(Binv,[1,max(nrows)*3]);
Binv_matone(any(Binv_matone == (0.000000000000000 + 0.000000000000000i), 1)) = [];

for j = 1 : sum(nrows)
    imgtemp(tembMat(j,1),tembMat(j,2)) = Binv_matone(j);
end
























