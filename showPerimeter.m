function showPerimeter(regionProps, num, img)
    figure('Name', 'Object Perimeters');
    imshow(img);
    for i=1:num
        plot(regionProps(i).Centroid(1),regionProps(i).Centroid(2),'ro')

        %Draw radius of each object
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
        
        %Check if its a coin
        if abs(regionProps(i).Circularity - 1.0) < circularityThr
            rectangle('Position', [fliplr(upLPoint) fliplr(dWindow)], 'Curvature',[1,1], 'EdgeColor',[1 0 1],'linewidth',2);
            %Calculate value of the coin
            r = mean([regionProps(i).MajorAxisLength, regionProps(i).MinorAxisLength])/2;
            coin = radius2cents(r);

            txt = strcat('Value: ', num2str(coin));
            ulp = fliplr(upLPoint);
            text(ulp(1), ulp(2), txt,'HorizontalAlignment','center')
        else 
            rectangle('Position', [fliplr(upLPoint) fliplr(dWindow)], 'EdgeColor',[1 1 0],'linewidth',2);
        end 
    end
end