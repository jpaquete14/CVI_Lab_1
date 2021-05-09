function result = transform(img, boundingBox, t)
se = strel('disk',3);
thr = 140;
cropped = imcrop(img, boundingBox);
cropped_bw = imclose(cropped(:,:,1) > thr,se);

% figure
% subplot(4,1,1)
% imshow(cropped_bw);
% subplot(4,1,2)
% imshow(cropped);

% R = cropped(:,:,1)
indecies = find(cropped_bw);
% R(indecies) = 0;
% subplot(4,1,3)
% imshow(R);

[Y, X] = ind2sub(size(cropped_bw), indecies);
M = [X Y ones(length(X), 1)];
M_transformed = M * t
X = fix(M_transformed(:, 1)./M_transformed(:, 3));
Y = fix(M_transformed(:, 2)./M_transformed(:, 3));

new_width = max(X);
new_height = max(Y);
new_indecies = sub2ind([new_height new_width], Y, X);
R = cropped(:,:,1);
G = cropped(:,:,2);
B = cropped(:,:,3);
R_new = uint8(zeros([new_height new_width]));
G_new = uint8(zeros([new_height new_width]));
B_new = uint8(zeros([new_height new_width]));
R_new(new_indecies) = uint8(R(indecies));
G_new(new_indecies) = uint8(G(indecies));
B_new(new_indecies) = uint8(B(indecies));
imshow(cat(3, R_new, G_new, B_new));
result = cat(3, R_new, G_new, B_new)
end
