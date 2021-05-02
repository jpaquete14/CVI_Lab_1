clear all, close all

thr = 140;
minArea = 20;
circularityThr = 0.05;
img = imread('Moedas1.jpg');

%% Plot image and each layer of the color
%figure;
%subplot(3,3,2);
%imshow(img);
%subplot(3,3,4);
%imshow(img(:,:,1));
%subplot(3,3,5);
%imshow(img(:,:,2));
%subplot(3,3,6);
%imshow(img(:,:,3));
%subplot(3,3,7);
%imhist(img(:,:,1));
%subplot(3,3,8);
%imhist(img(:,:,2));
%subplot(3,3,9);
%imhist(img(:,:,3));
%% Use the layer that separates the background best 
%%figure;
%%imshow(img(:,:,1) > thr);

%% Remove noises (?)
%%figure;
se = strel('disk',3);
bw = imclose(img(:,:,1) > thr,se);
%%imshow(bw);

%% Conected components
[lb num]=bwlabel(bw);
% imshow(uint8(lb * 20));

%%
regionProps = regionprops(lb,'centroid', 'area', 'perimeter', 'FilledImage', 'Orientation','MajorAxisLength','MinorAxisLength');

%Compute and add fields to imageProps
newField = 'Circularity';
for i=1:num
   regionProps(i).(newField) = (4 * pi * regionProps(i).Area) / ((regionProps(i).Perimeter).^2);
end

newField = 'Sharpness';                   
for i=1:num
   [Gx, Gy] = gradient(regionProps(i).FilledImage);
   S = sqrt(Gx.*Gx+Gy.*Gy);
   sharpness = sum(sum(S))./(numel(Gx));
   regionProps(i).(newField) = sharpness;
end

figure(333);
imshow(img);


num_of_coins = 0;
value_of_coins = 0;

hold on
for i=1:num
    plot(regionProps(i).Centroid(1),regionProps(i).Centroid(2),'ro')
    
    x=regionProps(i).Centroid(1);
    y=regionProps(i).Centroid(2);
    L=regionProps(i).MajorAxisLength/2;
    x2=x+(L*cos(-regionProps(i).Orientation*pi/180));
    y2=y+(L*sin(-regionProps(i).Orientation*pi/180));
    plot([x x2],[y y2], 'r');

    L=regionProps(i).MinorAxisLength/2;
    x2=x+(L*cos(pi/2 - regionProps(i).Orientation*pi/180));
    y2=y+(L*sin(pi/2 - regionProps(i).Orientation*pi/180));
    plot([x x2],[y y2], 'r');
    
    [lin col] = find(lb == i);
    upLPoint = min([lin col]);
    dWindow  = max([lin col]) - upLPoint + 1;
    
% Doesn't work for me     
%     ellipse(int8(regionProps(i).MajorAxisLength/2),...
%             int8(regionProps(i).MinorAxisLength/2),...
%             int8(-regionProps(i).Orientation*pi/180),...
%             int8(regionProps(i).Centroid(1)),...
%             int8(regionProps(i).Centroid(2)),'r');
 
    if abs(regionProps(i).Circularity - 1.0) < circularityThr
        rectangle('Position', [fliplr(upLPoint) fliplr(dWindow)], 'Curvature',[1,1], 'EdgeColor',[1 0 1],'linewidth',2);
        
        r = mean([regionProps(i).MajorAxisLength, regionProps(i).MinorAxisLength])/2;
        coin = radius2cents(r);
        
        txt = strcat('Value: ', num2str(coin));
        ulp = fliplr(upLPoint);
        text(ulp(1), ulp(2), txt,'HorizontalAlignment','center')
        
        if coin ~= 0
          num_of_coins = num_of_coins + 1;
          value_of_coins = value_of_coins + coin;
        end
    else 
        rectangle('Position', [fliplr(upLPoint) fliplr(dWindow)], 'EdgeColor',[1 1 0],'linewidth',2);
    end 
end

dim = [0.1 0 0 .95];
str = strcat(num2str(length(find([regionProps.Area] > minArea))), ' objects, ', num2str(num_of_coins), ' coins with value of coins ', num2str(value_of_coins));
annotation('textbox',dim,'String',str,'FitBoxToText','on');

but = 1;

while (but == 1)
    [ci,li,but] = ginput(1)
   
            
    if but == 1 %add point
        plot(ci,li,'r.','MarkerSize',18); drawnow;
        selected = lb(int16(li), int16(ci));
        if(selected ~= 0)
           details(regionProps(selected), img) ;
           figure(333);
        end

    end
end
hold off


