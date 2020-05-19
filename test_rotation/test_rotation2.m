clear all; close all; clc;
%warning off;

% image acquitise
original_in = imread('01.JPG');
distorted_in = imread('01_missing_hole_20.JPG');

% using image pyramid to reduce image size
original_reduce = impyramid(original_in, 'reduce');
distorted_reduce = impyramid(distorted_in, 'reduce');

% rgb2gray
original = rgb2gray(original_reduce);
distorted = rgb2gray(distorted_reduce);

%imtool(original);

% image regristation using automated feature matching
ptsOriginal  = detectSURFFeatures(original);
ptsDistorted = detectSURFFeatures(distorted);

[featuresOriginal,  validPtsOriginal]  = extractFeatures(original,  ptsOriginal);
[featuresDistorted, validPtsDistorted] = extractFeatures(distorted, ptsDistorted);

indexPairs = matchFeatures(featuresOriginal, featuresDistorted);

matchedOriginal  = validPtsOriginal(indexPairs(:,1));
matchedDistorted = validPtsDistorted(indexPairs(:,2));

% show match feature
%figure;
%showMatchedFeatures(original,distorted,matchedOriginal,matchedDistorted);
%title('Putatively matched points (including outliers)');

[tform, inlierDistorted, inlierOriginal] = estimateGeometricTransform(...
    matchedDistorted, matchedOriginal, 'similarity');

% show match feature
%figure;
%showMatchedFeatures(original,distorted,inlierOriginal,inlierDistorted);
%title('Matching points (inliers only)');
%legend('ptsOriginal','ptsDistorted');

Tinv  = tform.invert.T;

ss = Tinv(2,1);
sc = Tinv(1,1);
scaleRecovered = sqrt(ss*ss + sc*sc);
thetaRecovered = atan2(ss,sc)*180/pi;

outputView = imref2d(size(original));
recovered  = imwarp(distorted,tform,'OutputView',outputView);

% show recovered image
%figure, imshowpair(original,recovered,'montage')

% ----------------------------------------

% adjust histogram recovered to match histogram original image
adjustHist = imhistmatch(recovered,original);
%figure;
%imshowpair(original,adjustHist,'montage');

% normalized cross correlation -> matching image
corrCheck = normxcorr2(original,adjustHist);
[ypeak,xpeak] = find(corrCheck==max(corrCheck(:)));

% ------------------ end of pre-processing ----------------------

% subtract image 
preresult = original - recovered;

% grayscale to binary-image
preresult = imbinarize(preresult,0.05);

preresult = medfilt2(preresult);
%figure;
%imshow(preresult);

% morphological to remove noise
% disk-shaped structuring element
%se = strel('disk',3);
%preresult = imerode(preresult,se);
%imshow(preresult);

% --------------------------------

% label defect region
% L = bwlabel(preresult,8);

countL = bwconncomp(preresult,8);

% defect boundaries 
[B,A] = bwboundaries(preresult, 'noholes');

% defect region properties
STATS = regionprops(A, 'all');

% check defect inside-outside PCB
premask = medfilt2(original);
premask = imbinarize(premask);
premask = bwperim(premask,8);
statMask = regionprops(premask, 'all');
[maxValue,idx] = max([statMask.Area]);
%Area = cat(1,statMask.Area);
%idx = find(Area==max(Area(:)));
PCBBounding = cat(1,statMask(idx).BoundingBox);

% create mask
%x = [PCBBounding(1,1) PCBBounding(1,1) PCBBounding(1,1)+PCBBounding(1,3) PCBBounding(1,1)+PCBBounding(1,3)];
%y = [PCBBounding(1,2) PCBBounding(1,2)+PCBBounding(1,4) PCBBounding(1,2) PCBBounding(1,2)+PCBBounding(1,4)];
%m = round((PCBBounding(1,4)-PCBBounding(1,1))+1);
%n = round((PCBBounding(1,3)-PCBBounding(1,2))+1);
%mask = poly2mask(x,y,m,n);
%imshow(mask);

% n of defect region
%nDefect = size(STATS,1);

pre_position = cat(1, STATS(:).BoundingBox);
check_x = (pre_position(:,1)>=PCBBounding(:,1))&(pre_position(:,1)<=PCBBounding(:,3));
check_y = (pre_position(:,2)>=PCBBounding(:,2))&(pre_position(:,2)<=PCBBounding(:,4));
pos_idx = find(check_x & check_y);
position = zeros(numel(pos_idx),4);


% real n Defect 
nDefect = numel(pos_idx);
label = cell(nDefect,1);

for i = 1 : nDefect
    position(i,:) = pre_position(pos_idx(i),:);
    statDefect(i,:) = STATS(i);
end

for i = 1 : nDefect
    if(statDefect(i).Circularity >= 0.99)
        label(i) = cellstr("Missing Hole");
    else
        label(i) = cellstr("no missing");
    end
end

position(:,3) = position(:,3) + 5;
position(:,4) = position(:,4) + 5;
s = insertObjectAnnotation(recovered,'rectangle',position,label,...
    'TextBoxOpacity',0.8,'FontSize',10);
figure
imshow(s);








