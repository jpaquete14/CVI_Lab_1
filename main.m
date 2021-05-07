clear all, close all

thr = 140;
minArea = 10;
circularityThr = 0.05;
img = imread('Moedas3.jpg');

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
regionProps = regionprops(lb,'centroid', 'area', 'perimeter', 'FilledImage', 'Orientation','MajorAxisLength','MinorAxisLength', 'BoundingBox');
[height, width, dim] = size(img);
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

figure('Name', 'CVI LAB 1', 'units','normalized','outerposition',[0 0 1 1]);
imshow(img);


num_of_coins = 0;
value_of_coins = 0;

hold on
for i=1:num
    plot(regionProps(i).Centroid(1),regionProps(i).Centroid(2),'ro')
    
    %Draw radius of each coin
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
 
    %check if it's a coin
    if abs(regionProps(i).Circularity - 1.0) < circularityThr
        rectangle('Position', [fliplr(upLPoint) fliplr(dWindow)], 'Curvature',[1,1], 'EdgeColor',[1 0 1],'linewidth',2);
        %Calculate value of the coin
        r = mean([regionProps(i).MajorAxisLength, regionProps(i).MinorAxisLength])/2;
        coin = radius2cents(r);
        
        txt = strcat('Value: ', num2str(coin));
        ulp = fliplr(upLPoint);
        text(ulp(1), ulp(2), txt,'HorizontalAlignment','center')
        %add to the overall value
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

guides = {'a: Show object Areas', 'p: Show object Perimeters', 's: Show object Sharpnesses', 't: Transform a selected object', 'r: Relative heatmaps'};
guide = strjoin(guides, '\n');

closeText = {'Press x to crose the image'};
closeImageText = strjoin(closeText, '\n');

%Select which coin to show the details
%but = 1;
while (true)
    t = text(width + 10, 100, guide);
    [ci,li,but] = ginput(1)
   
    
    %{        
    if but == 1 %add point
        plot(ci,li,'r.','MarkerSize',18); drawnow;
        selected = lb(int16(li), int16(ci));
        if(selected ~= 0)
           details(regionProps(selected), img) ;
           figure(333);
        end

    end
    %}
    if but == 97   %order by area
        Areas = [regionProps.Area];
        
        %Sort areas from smallest value to highest value
        [~, order] = sort(Areas);
        OrderedAreaFigure = figure('Name', 'Objects ordered by area', 'units','normalized','outerposition',[0 0 1 1]);
        images = [];
        
        %For each object, calculate the bounding box and show the area
        for i=1:length(order)
            boundingBox = regionProps(order(i)).BoundingBox;
            cropped = imcrop(img, boundingBox);
            [x, y, color] = size(cropped);
            bw = imclose(cropped(:,:,1) > thr,se);
            images(i) = subplot(2, length(order), i); imshow(bw);
            area = num2str(regionProps(order(i)).Area);
            text(0, y + 20, area);
            
            %Show original image cropped
            images(i) = subplot(2, length(order), length(order) + i); imshow(cropped);
            
            %Press x to quit message
            if i == 1
                [x, y, color] = size(cropped);
                t = text(0, y + 20, closeImageText);
            end
        end
        
        while(true)
            [ci, li, but] = ginput(1);
            if but == 120   %press x to leave current image
                close(OrderedAreaFigure);
                %imshow(img);
            end
            break
        end
    end  
    
    if but == 112   %order by perimeter
        Perimeters = [regionProps.Perimeter];
        
        %Sort perimeters from smallest value to highest value
        [~, order] = sort(Perimeters);
        OrderedPerimeterFigure = figure('Name', 'Objects ordered by perimeter', 'units','normalized','outerposition',[0 0 1 1]);
        images = [];
        
        %For each object, calculate the bounding box and show the perimeter
        for i=1:length(order)
            boundingBox = regionProps(order(i)).BoundingBox;
            cropped = imcrop(img, boundingBox);
            [x, y, color] = size(cropped);
            bw = imclose(cropped(:,:,1) > thr,se);
            BW2 = bwperim(bw());
            images(i) = subplot(2, length(order), i); imshow(BW2);
            perimeter = num2str(regionProps(order(i)).Perimeter);
            text(0, y + 20, perimeter)
            
            %Show original image cropped
            images(i) = subplot(2, length(order), length(order) + i); imshow(cropped);
            
            %Press x to quit message
            if i == 1
                [x, y, color] = size(cropped);
                t = text(0, y + 20 , closeImageText);
            end
        end

        while(true)
            [ci, li, but] = ginput(1);
            if but == 120   %press x to leave current image
                close(OrderedPerimeterFigure);
                %imshow(img);
            end
            break
        end
    end  
    
    if but == 115   %order by sharpness
        Sharpnesses = [regionProps.Sharpness];
        fprintf('%s \n', num2str(Sharpnesses))
        [~, order] = sort(Sharpnesses);
        fprintf('%s \n', num2str(order))
        OrderedSharpnessFigure = figure('Name', 'Objects ordered by sharpness', 'units','normalized','outerposition',[0 0 1 1]);
        images = [];
        for i=1:length(order)
            boundingBox = regionProps(order(i)).BoundingBox;
            cropped = imcrop(img, boundingBox);
            images(i) = subplot(1, length(order), i); imshow(cropped);
            if i == 1
                [x, y, color] = size(cropped);
                t = text(0, y + 100, closeImageText);
            end
        end
        linkaxes(images, 'x');
        while(true)
            [ci, li, but] = ginput(1);
            if but == 120   %press x to leave current image
                close(OrderedSharpnessFigure);
                %imshow(img);
            end
            break
        end
    end 
    
    if but == 113 %q to quit
        break;
    end
    
    if but == 116   %t for geometrical transformation
        %TODO: Add text for object selection
        selectObject = 'Select object to be transformed';
        aux = text(100, 100, selectObject);
        while(true)
            [ci, li, but] = ginput(1);
            %Wait for selection of the object
            if but == 1 %click
                 sel = lb(round(li), round(ci));
                 if(sel ~= 0)
                    boundingBox = regionProps(sel).BoundingBox;
                    cropped = imcrop(img, boundingBox);
                    
                    transformationFigure = figure('Name', 'Upside-Down Transformation', 'units','normalized','outerposition',[0 0 1 1]);
                    subplot(1, 2, 1);
                    [B, L, N, A] = bwboundaries(lb);
                    boundary = B{sel};
                    imshow(img);
                    
                    %Press x to quit text
                    [x, y, color] = size(img);
                    t = text(0, y, closeImageText);
                    
                    t = text(0, 10, 'Original Image');
                    
                    subplot(1, 2, 2);
                    flipped = flipud(cropped); 
                    hold on, imshow(img);
                    image(flipped, 'XData', [regionProps(sel).BoundingBox(1) regionProps(sel).BoundingBox(1)+regionProps(sel).BoundingBox(3)], 'YData', [regionProps(sel).BoundingBox(2) regionProps(sel).BoundingBox(2)+regionProps(sel).BoundingBox(4)]);
                    [x, y, color] = size(img);
                    t = text(0, 10, 'Transformed Image');
                 end
                 break;
            end
        end
        while(true)
            [ci, li, but] = ginput(1);
            if but == 120   %press x to leave current image
                close(transformationFigure);
                %imshow(img);
                delete(aux);
                break;
            end
        end
    end    
    
    if but == 114   %t for image heatmap
        selectObject = 'Select object for heatmap';
        aux = text(100, 100, selectObject);
        while(true)
            [ci, li, but] = ginput(1);
            %Wait for selection of the object
            if but == 1 %click
                 sel = lb(round(li), round(ci));
                 if(sel ~= 0)
                    relativeHatmapFigure = figure('Name', 'Relative heatmap to other elements', 'units','normalized','outerposition',[0 0 1 1]);
                                         
                    cent_x = regionProps(sel).Centroid(1);
                    cent_y = regionProps(sel).Centroid(2);
                    
                    objects_mask = lb > 0;
                    
                    [imgh, imgw imgd] = size(img);
                    [Y,X] = ind2sub([imgh, imgw], 1:imgw*imgh);
                    distancesFromCenter = sqrt((X-cent_x).^2+(Y-cent_y).^2);
                    heatmap(reshape(distancesFromCenter,[imgh, imgw]));
                      
                    ax = gca;
                    ax.XDisplayLabels = nan(size(ax.XDisplayData));
                    ax.YDisplayLabels = nan(size(ax.YDisplayData));
                    colormap hot;
                    grid off;
                 end
                 break;
            end
        end
        while(true)
            [ci, li, but] = ginput(1);
            if but == 120   %press x to leave current image
                close(relativeHatmapFigure);
                %imshow(img);
                delete(aux);
                break;
            end
        end
    end      
end
hold off


