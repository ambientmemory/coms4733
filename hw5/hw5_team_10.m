function hw5_team_10(serPort)
    url = 'http://www.savingcountrymusic.com/wp-content/uploads/2012/01/red-solo-cup1.jpg';
    image = imread(url);
    
    width = size(image, 2);
    height = size(image, 1);
    
    figure(1);
    imshow(image);

    [x, y] = ginput(1);
    while x <= 0 || x > width || y <= 0 || y > height
        [x, y] = ginput(1);
    end
    
    imdouble = im2double(image);
    color = imdouble(floor(x), floor(y), :);
    
    [area, centroid] = imgfind(image, color)
    
    % TODO: keep grabbing images and trying to maintain area and centroid
    % by moving bot
end