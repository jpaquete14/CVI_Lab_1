clear all, close all

thr = 140;
tform = [1 0 0; .5 1 0; 0 0 1];
minArea = 10;
circularityThr = 0.05;
img = imread('Moedas3.jpg');


%%Ask which image to use
fprintf('1: Choose image samples from collection\n')
fprintf('2: Choose your own image from directory\n')

command = input('>> ');

if command == 1
    fprintf('1: Moedas1.jpg\n');
    fprintf('2: Moedas2.jpg\n');
    fprintf('3: Moedas3.jpg\n');
    fprintf('4: Moedas4.jpg\n');
           
    imgNr = input('>> ');
    
    switch imgNr
            case 1
                imgPath = 'Moedas1.jpg';
                img = imread(imgPath);
            case 2
                imgPath = 'Moedas2.jpg';
                img = imread(imgPath);
            case 3
                imgPath = 'Moedas3.jpg';
                img = imread(imgPath);
            case 4
                imgPath = 'Moedas4.jpg';
                img = imread(imgPath);
            otherwise
                fprintf('\nInvalid image number\n');
    end
end

if command == 2
    fprintf('Place the image int the following path:\n');
    dir = pwd;
    disp(dir);
    
    fprintf('\nInsert filename of image\n');
    filename = input('>> ', 's');
     try
            imgPath = strcat(dir,'/',filename);
            originalImage = imread(imgPath);
    catch
        fprintf('\nFile not found in directory!\n')
     end
end
    
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

mainFigure = figure('Name', 'CVI LAB 1', 'units','normalized','outerposition',[0 0 1 1]);
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
        text(ulp(1), ulp(2), txt,'HorizontalAlignment','center', 'FontSize',14)
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
str = strcat(num2str(length(find([regionProps.Area] > minArea))), ' objects, ', num2str(num_of_coins), ' coins with value of coins: ', num2str(value_of_coins));
annotation('textbox',dim,'String',str,'FitBoxToText','on', 'FontSize',18);

guides = {'a: Show object Areas', 'p: Show object Perimeters', 's: Show object Sharpnesses', 't: Transform a selected object', 'b: Order by similarity (Circularity)','h: Heatmap of selected images', 'Press x to close new images'};
guide = strjoin(guides, '\n');

closeText = {'Press x to close the image'};
closeImageText = strjoin(closeText, '\n');

%Select which coin to show the details
%but = 1;
while (true)
    t = text(width + 10, 100, guide, 'FontSize',15);
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
            text(0, y + 20, area, 'FontSize',18);
            
            %Show original image cropped
            images(i) = subplot(2, length(order), length(order) + i); imshow(cropped);
            
            %Press x to quit message
            if i == 1
                [x, y, color] = size(cropped);
                t = text(0, y + 20, closeImageText, 'FontSize',18);
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
            text(0, y + 20, perimeter, 'FontSize',18)
            
            %Show original image cropped
            images(i) = subplot(2, length(order), length(order) + i); imshow(cropped);
            
            %Press x to quit message
            if i == 1
                [x, y, color] = size(cropped);
                t = text(0, y + 20 , closeImageText, 'FontSize',18);
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
                t = text(0, y + 100, closeImageText, 'FontSize',18);
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
    
%     if but == 116   %t for geometrical transformation
%         %TODO: Add text for object selection
%         selectObject = 'Select object to be transformed';
%         aux = text(100, 100, selectObject, 'FontSize',15);
%         while(true)
%             [ci, li, but] = ginput(1);
%             %Wait for selection of the object
%             if but == 1 %click
%                  sel = lb(round(li), round(ci));
%                  if(sel ~= 0)
%                     boundingBox = regionProps(sel).BoundingBox;
%                     cropped = imcrop(img, boundingBox);
%                     
%                     [h, w] = size(regionProps(1).FilledImage);
%                     indecies = find(regionProps(1).FilledImage);
%                     [Y, X] = ind2sub([h w], indecies)
%                     %{
%                     
%                     transformationFigure = figure('Name', 'Upside-Down Transformation', 'units','normalized','outerposition',[0 0 1 1]);
%                     subplot(1, 2, 1);
%                     [B, L, N, A] = bwboundaries(lb);
%                     boundary = B{sel};
%                     size_boundary = size(boundary);
%                     matrix = [boundary ones(length(boundary),1)]
%                     imshow(img);
%                     
%                     theta = pi/2;
%                     t = [1    0   0
%                          0    1   0
%                          0    0   0.2];
%                     
%                     tform = matrix * t;
%                     
%                     
%                     subplot(1, 2, 2);
%                     [x, y] = ind2sub()
%                     imshow(bw); hold on;
%                     plot(tform(:,1),tform(:,2),'b.','markersize',10);
%                     [x, y, color] = size(img);
%                     t = text(0, 10, 'Transformed Image');
%                     
%                     %Press x to quit text
%                     [x, y, color] = size(img);
%                     t = text(0, y, closeImageText);
%                     
%                     t = text(0, 10, 'Original Image');
%                     %}
%                     %{
%                     subplot(1, 2, 2);
%                     flipped = flipud(cropped); 
%                     hold on, imshow(img);
%                     image(flipped, 'XData', [regionProps(sel).BoundingBox(1) regionProps(sel).BoundingBox(1)+regionProps(sel).BoundingBox(3)], 'YData', [regionProps(sel).BoundingBox(2) regionProps(sel).BoundingBox(2)+regionProps(sel).BoundingBox(4)]);
%                     %}
%                     
%                      
%                     %[rows_boundary,cols_boundary]=find(lb());
%                     %matrix = [rows_boundary, cols_boundary];
%                     %size_matrix = size(matrix)
%                     %size_aux = size(ones(length(matrix),1))
%                     
%                     %size_matrix = size(matrix_new);
%                     
%                 
%                  end
%                  break;
%             end
%         end
%         while(true)
%             [ci, li, but] = ginput(1);
%             if but == 120   %press x to leave current image
%                 close(transformationFigure);
%                 %imshow(img);
%                 delete(aux);
%                 break;
%             end
%         end
%     end    
    
    if but == 98 %order by similarity
        selectObject = 'Select object';
        aux = text(100, 100, selectObject, 'FontSize',15);
        while(true)
            [ci, li, but] = ginput(1);
            %Wait for selection of the object
            if but == 1 %click
                sel = lb(round(li), round(ci));
                if (sel ~= 0)
                    [B, L, N, A] = bwboundaries(lb);
                    boundary = B{sel};
                    
                    % Using Circularity as a measure
                    % Initialise struct to contain similarity values
                    listSimilarity = struct('Similarity', {}, 'Index', {});
                    ind = [regionProps.Circularity];
                    
                   for r=1:num
                       if(r ~= sel)
                           similarity = abs(regionProps(r).Circularity - regionProps(sel).Circularity);

                           % Add similarity and index to struct
                           simil = struct('Similarity', similarity, 'Index', r);
                           listSimilarity = [listSimilarity ; simil];
                       end
                   end

                   [sorted, ind] = sort([listSimilarity.Similarity]);
                   similarityFigure = figure('Name','Similarity between objects');
                   
                   hold on;
                   

                   for o=1:(num-1)
                       boundingBox = regionProps(listSimilarity(ind(o)).Index).BoundingBox;
                       cropped = imcrop(img, boundingBox);
                       subplot(1, length(ind), o), imshow(cropped);
                   end
                end
            end
            break;
        end
        while(true)
            [ci, li, but] = ginput(1);
            if but == 120   %press x to leave current image
                close(similarityFigure);
                %imshow(img);
                delete(aux);
                break;
            end
        end
    end

    % NEW
    if but == 116   %t for transform
        selectObject = 'Select objects for tansform';
        aux = text(100, 100, selectObject);
        elementsToCompare = [];
        while(true)
            [ci, li, but] = ginput(1);
           
            %Select objects for comparision 
            if but == 1 %click with mouse
                sel = lb(round(li), round(ci));
                if (sel ~= 0)
                    elementsToCompare(end+1) = sel;
                end
            end
            
            %Display results
            if but == 114 %press r for results
                relativeHatmapFigure = figure('Name', 'Transform selected objects', 'units','normalized','outerposition',[0 0 1 1]);
                n = length(elementsToCompare);
                for i = 1:n
                    bbox = regionProps(elementsToCompare(i)).BoundingBox;
                    cropped = imcrop(img, bbox);
                    subplot(2,n,i);
                    imshow(cropped);
                    subplot(2,n,i+n);
                    result = transform(img, bbox, tform);
                    imshow(result);
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
    
    if but == 104   %h for relative heatmaps
        selectObject = 'Select objects for heatmaps';
        aux = text(100, 100, selectObject);
        elementsToCompare = [];
        while(true)
            [ci, li, but] = ginput(1);
           
            %Select objects for comparision 
            if but == 1 %click with mouse
                sel = lb(round(li), round(ci));
                if (sel ~= 0)
                    elementsToCompare(end+1) = sel;
                end
            end
            
            %Display results
            if but == 114 %press r for results
                relativeHatmapFigure = figure('Name', 'Relative heatmap to other selected elements', 'units','normalized','outerposition',[0 0 1 1]);

                [imgh, imgw, imgd] = size(img);
                [Y,X] = ind2sub([imgh, imgw], 1:imgw*imgh);
                if length(elementsToCompare) > 1
                    distancesFromCenter = zeros([length(elementsToCompare) imgw*imgh]);
                    for i = 1:length(elementsToCompare)
                        distancesFromCenter(i, :) = sqrt((X-regionProps(elementsToCompare(i)).Centroid(1)).^2+(Y-regionProps(elementsToCompare(i)).Centroid(2)).^2);
                    end
                    heatmap(reshape(min(distancesFromCenter),[imgh, imgw]));
                else
                    distancesFromCenter = sqrt((X-regionProps(elementsToCompare(1)).Centroid(1)).^2+(Y-regionProps(elementsToCompare(1)).Centroid(2)).^2);
                    heatmap(reshape(distancesFromCenter,[imgh, imgw]));
                end


                ax = gca;
                ax.XDisplayLabels = nan(size(ax.XDisplayData));
                ax.YDisplayLabels = nan(size(ax.YDisplayData));
                colormap hot;
                grid off;
                figure(mainFigure)
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


