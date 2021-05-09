close all, clear all;

seErosion = 6;
seDilation = 3;

originalImg = imread('Moedas1.jpg');
grayscaleRed = originalImg(:,:,1);
%figure,imshow(grayscaleRed);

bw1 = grayscaleRed > 120;
%imshow(bw1);

[lb, num] = bwlabel(bw1);
regionProps = regionprops(lb, 'Area', 'Perimeter', 'FilledImage', 'Centroid', 'MajorAxisLength','MinorAxisLength');
inds = find([regionProps.Area] > 6);

areas = sort([regionProps.Area]);
perimeters = sort([regionProps.Perimeter]);

%Original coin areas
coin1CentA = areas(:,1);
coin2CentA = areas(:,2);
coin10CentA = areas(:,3);
coin5CentA = areas(:,4);
coin20CentA = areas(:,5);
coin1EurA = areas(:,7);
coin50CentA = areas(:,8);

%OriginalMajorAxis
coin1CentMajor = regionProps(1).MajorAxisLength;
coin2CentMajor = regionProps(2).MajorAxisLength;
coin10CentMajor = regionProps(3).MajorAxisLength;
coin5CentMajor = regionProps(4).MajorAxisLength;
coin20CentMajor = regionProps(5).MajorAxisLength;
coin1EurMajor = regionProps(7).MajorAxisLength;
coin50CentMajor = regionProps(8).MajorAxisLength;

%OriginalMinorAxis
coin1CentMinor = regionProps(1).MinorAxisLength;
coin2CentMinor = regionProps(2).MinorAxisLength;
coin10CentMinor = regionProps(3).MinorAxisLength;
coin5CentMinor = regionProps(4).MinorAxisLength;
coin20CentMinor = regionProps(5).MinorAxisLength;
coin1EurMinor = regionProps(7).MinorAxisLength;
coin50CentMinor = regionProps(8).MinorAxisLength;


seEr = strel('disk', 6);
seOp = strel('disk', 3);
erosionImage = imerode(bw1, seEr);
dilationImage = imdilate(erosionImage, seOp);
%imshow(openImage);

[lb2, num2] = bwlabel(dilationImage);
coinPropsOpened = regionprops(lb2, 'Area', 'Perimeter', 'FilledImage', 'Centroid', 'MajorAxisLength','MinorAxisLength');

areas2 = sort([coinPropsOpened.Area]);
perimeters2 = sort([coinPropsOpened.Perimeter]);

% Coin areas post-processing
coin1CentPA = areas2(:,1);
coin2CentPA = areas2(:,2);
coin10CentPA = areas2(:,3);
coin5CentPA = areas2(:,4);
coin20CentPA = areas2(:,5);
coin1EurPA = areas2(:,7);
coin50CentPA = areas2(:,8);

%OriginalMajorAxis
coin1CentMajorP = regionProps(1).MajorAxisLength;
coin2CentMajorP = regionProps(2).MajorAxisLength;
coin10CentMajorP = regionProps(3).MajorAxisLength;
coin5CentMajorP = regionProps(4).MajorAxisLength;
coin20CentMajorP = regionProps(5).MajorAxisLength;
coin1EurMajorP = regionProps(7).MajorAxisLength;
coin50CentMajorP = regionProps(8).MajorAxisLength;

%OriginalMinorAxis
coin1CentMinorP = regionProps(1).MinorAxisLength;
coin2CentMinorP = regionProps(2).MinorAxisLength;
coin10CentMinorP = regionProps(3).MinorAxisLength;
coin5CentMinorP = regionProps(4).MinorAxisLength;
coin20CentMinorP = regionProps(5).MinorAxisLength;
coin1EurMinorP = regionProps(7).MinorAxisLength;
coin50CentMinorP = regionProps(8).MinorAxisLength;


%Coin area deltas (for calculating amount of money later)
delta1CentA = (coin1CentA - coin1CentPA) / 2;
delta2CentA = (coin2CentA - coin2CentPA) / 2;
delta10CentA = (coin10CentA - coin10CentPA) / 2;
delta5CentA = (coin5CentA - coin5CentPA) / 2;
delta20CentA = (coin20CentA - coin20CentPA) / 2;
delta1EurA = (coin1EurA - coin1EurPA) / 2;
delta50CentA = (coin50CentA - coin50CentPA) / 2;

%Coin MajorAxisLength deltas
delta1CentMajor = (coin1CentMajor - coin1CentMajorP) / 2;
delta2CentMajor = (coin2CentMajor - coin2CentMajorP) / 2;
delta10CentMajor = (coin10CentMajor - coin10CentMajorP) / 2;
delta5CentMajor = (coin5CentMajor - coin5CentMajorP) / 2;
delta20CentMajor = (coin20CentMajor - coin20CentMajorP) / 2;
delta1EurMajor = (coin1EurMajor - coin1EurMajorP) / 2;
delta50CentMajor = (coin50CentMajor - coin50CentMajorP) / 2;

%Coin MinorAxisLength deltas
delta1CentMinor = (coin1CentMinor - coin1CentMinorP) / 2;
delta2CentMinor = (coin2CentMinor - coin2CentMinorP) / 2;
delta10CentMinor = (coin10CentMinor - coin10CentMinorP) / 2;
delta5CentMinor = (coin5CentMinor - coin5CentMinorP) / 2;
delta20CentMinor = (coin20CentMinor - coin20CentMinorP) / 2;
delta1EurMinor = (coin1EurMinor - coin1EurMinorP) / 2;
delta50CentMinor = (coin50CentMinor - coin50CentMinorP) / 2;



