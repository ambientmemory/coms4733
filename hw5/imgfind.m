function [area, centroid] = imgfind(image, color)

    % TODO: optimize
    
    width = size(image, 2);
    height = size(image, 1);

    colorDistThreshold = sqrt(sum(color.^2)) * 0.2;
    
    imdouble = im2double(image);
    distMat = sqrt(sum((imdouble - repmat(color, height, width)).^2, 3));
    mask = distMat < colorDistThreshold;
    blobs = floor(+mask);
    blobs(:, :) = 0;
    k = 0;
    eqs = {1};
    
    for i=2:height
        for j=2:width
            if mask(i, j) == 1
                if mask(i-1, j) == 0 && mask(i, j-1) == 0
                    k = k + 1;
                    blobs(i, j) = k;
                    eqs = [eqs, {k}];
                elseif mask(i-1, j) == 1 && mask(i, j-1) == 0
                    blobs(i, j) = blobs(i-1, j);
                elseif mask(i-1, j) == 0 && mask(i, j-1) == 1
                    blobs(i, j) = blobs(i, j-1);
                elseif mask(i-1, j) == 1 && mask(i, j-1) == 1
                     blobs(i, j) = blobs(i-1, j);
                     if blobs(i-1, j) ~= blobs(j, i-1)
                         c1 = blobs(i-1, j);
                         c2 = blobs(i, j-1);
                         eqs{c1} = union(eqs{c1}, eqs{c2});
                         eqs{c2} = eqs{c1};
                     end
                end
            end
        end
    end
    
    blobSizes = [];
    for i=1:height
        for j=1:width
            if blobs(i, j) ~= 0
                blobs(i, j) = min(eqs{blobs(i, j)});
                blob = blobs(i, j);
                sizeInc = blob - max(size(blobSizes));
                if sizeInc > 0
                    newMat = zeros(1, sizeInc);
                    newMat(sizeInc) = 1;
                    blobSizes = [blobSizes, newMat];
                else
                    blobSizes(blob) = blobSizes(blob) + 1;
                end
            end
        end
    end
    [~, biggestBlob] = max(blobSizes);
    trackedObject = blobs == biggestBlob;

    area = sum(trackedObject(:));
    centroid = [0, 0];
    for i=1:height
        for j = 1:width
            if(trackedObject(i, j) == 1)
                centroid = centroid + [j, i];
            end
        end
    end
    centroid = centroid / area;
end