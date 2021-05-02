function [area, major_axis, minor_axis, radius] = details(regionProps, img)
    figure(666);
    subplot(1,2,1);
    imshow(regionProps.FilledImage);

    ha = subplot(1,2,2);
    pos = get(ha,'Position');
    un = get(ha,'Units');
    delete(ha)
    area = regionProps.Area;
    major_axis = regionProps.MajorAxisLength;
    minor_axis = regionProps.MinorAxisLength;
    radius = mean([regionProps.MajorAxisLength, regionProps.MinorAxisLength])/2;
    sharpness = regionProps.Sharpness;
    prop = {'Area', 'MajorAxisLength', 'MinorAxisLength', 'Radius', 'Sharpness'}
    data = [
        area;
        major_axis;
        minor_axis;
        radius;
        sharpness;
    ];

    uitable('Data', data , 'ColumnName', {'Value'}, 'RowName', prop, 'Units',un,'Position',pos);
end