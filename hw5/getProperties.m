function [x_center, y_center, area] = getProperties(img)
    
    num_obj = max(max(img));
    db = zeros(7, num_obj);

    for i = 1:num_obj
       % 1. Object label
       db(1,i) = i;
       
       [y,x] = find(img == i);
       area = size(find(img == i), 1);
       % 2. Row position of center
       x_center = sum(x) / area;
       db(3,i) = x_center;
       % 3. Column position of center
       y_center = sum(y) / area;
       db(2,i) = y_center;
       
       % 7. Area
       db(7,i) = area;
       
       plot(x_center, y_center, 'b.','MarkerSize',10);
       if (theta <= 0)
          x1 = x_center; 
          x2 = max(x);
       else
           x1 = min(x);
           x2 = x_center;
       end

       xPlot = linspace(x1, x2);
       yPlot = tand(theta)*(xPlot - x_center) + y_center;
       line(xPlot, yPlot, 'Color', [0, 0, 1], 'LineWidth', 1);
    end

end