clear all, close all

thr = 140;

img = imread('./Moedas1.jpg');
se = strel('disk',3);
bw = imclose(img(:,:,1) > thr,se);
[lb num]=bwlabel(bw);
regionProps = regionprops(lb,'centroid', 'area', 'perimeter', 'FilledImage', 'Orientation','MajorAxisLength','MinorAxisLength', 'BoundingBox');
[height, width, dim] = size(img);


sel = 3;

t = [1 0 0; .5 1 0; 0 0 1]
cropped = imcrop(img, regionProps(sel).BoundingBox);

figure
subplot(2,1,1)
imshow(cropped);
subplot(2,1,2)
imshow(transform(img, regionProps(sel).BoundingBox, t));

%%
% transform = [
%     2 0 0;
%     0 1 0;
%     0 0 1;
% ]
% cropped = imcrop(img, regionProps(sel).BoundingBox);
% cropped_bw = imclose(cropped(:,:,1) > thr,se);
% 
% figure
% subplot(4,1,1)
% imshow(cropped_bw);
% subplot(4,1,2)
% imshow(cropped);
% 
% R = cropped(:,:,1)
% indecies = find(cropped_bw);
% R(indecies) = 0;
% subplot(4,1,3)
% imshow(R);
% 
% [Y, X] = ind2sub(size(cropped_bw), indecies);
% M = [X Y ones(length(X), 1)];
% M_transformed = M * transform
% X = fix(M_transformed(:, 1)./M_transformed(:, 3));
% Y = fix(M_transformed(:, 2)./M_transformed(:, 3));
% 
% new_width = max(X);
% new_height = max(Y);
% new_indecies = sub2ind([new_height new_width], Y, X);
% R = cropped(:,:,1);
% G = cropped(:,:,2);
% B = cropped(:,:,3);
% R_new = uint8(zeros([new_height new_width]));
% G_new = uint8(zeros([new_height new_width]));
% B_new = uint8(zeros([new_height new_width]));
% R_new(new_indecies) = uint8(R(indecies));
% G_new(new_indecies) = uint8(G(indecies));
% B_new(new_indecies) = uint8(B(indecies));
% subplot(4,1,4)
% imshow(cat(3, R_new, G_new, B_new));