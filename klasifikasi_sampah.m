% Read the image
image = imread('project/DJI_0180.jpg');

% Convert the image to HSV color space
hsvImage = rgb2hsv(image);

% Define thresholds for 'organic' and 'non-organic' based on HSV values
organicThresh = [0.11, 0.44, 0.3]; % example HSV threshold for organic waste
nonOrganicThresh = [0.5, 0.7, 0.4]; % example HSV threshold for non-organic waste

% Segment the image based on color
organicMask = (hsvImage(:,:,1) >= organicThresh(1) & hsvImage(:,:,1) <= organicThresh(2)) & ...
              (hsvImage(:,:,2) >= organicThresh(3));

nonOrganicMask = (hsvImage(:,:,1) >= nonOrganicThresh(1) & hsvImage(:,:,1) <= nonOrganicThresh(2)) & ...
                 (hsvImage(:,:,2) >= nonOrganicThresh(3));

% Perform edge detection
edgesOrganic = edge(organicMask, 'Canny');
edgesNonOrganic = edge(nonOrganicMask, 'Canny');

% Perform dilation to connect edges
se = strel('disk', 30);
dilatedOrganic = imdilate(edgesOrganic, se);
dilatedNonOrganic = imdilate(edgesNonOrganic, se);

% Remove small objects
minObjectSize = 100; % Define the minimum object size
dilatedOrganic = bwareaopen(dilatedOrganic, minObjectSize);
dilatedNonOrganic = bwareaopen(dilatedNonOrganic, minObjectSize);

% Find connected components
ccOrganic = bwconncomp(dilatedOrganic);
ccNonOrganic = bwconncomp(dilatedNonOrganic);

% Get bounding boxes for each connected component
statsOrganic = regionprops(ccOrganic, 'BoundingBox');
statsNonOrganic = regionprops(ccNonOrganic, 'BoundingBox');

% Create a figure with multiple subplots
figure;

% Display the original image
subplot(3, 3, 1);
imshow(image);
title('Original Image');

% Display the HSV image
subplot(3, 3, 2);
imshow(hsvImage);
title('HSV Image');

% Display the organic mask
subplot(3, 3, 3);
imshow(organicMask);
title('Organic Mask');

% Display the non-organic mask
subplot(3, 3, 4);
imshow(nonOrganicMask);
title('Non-Organic Mask');

% Display edges for organic waste
subplot(3, 3, 5);
imshow(edgesOrganic);
title('Edges (Organic)');

% Display edges for non-organic waste
subplot(3, 3, 6);
imshow(edgesNonOrganic);
title('Edges (Non-Organic)');

% Display the dilated edges for organic waste
subplot(3, 3, 7);
imshow(dilatedOrganic);
title('Dilated Edges (Organic)');

% Display the dilated edges for non-organic waste
subplot(3, 3, 8);
imshow(dilatedNonOrganic);
title('Dilated Edges (Non-Organic)');

% Display the original image with bounding boxes
subplot(3, 3, 9);
imshow(image);
hold on;

% Draw bounding boxes for organic waste
for k = 1 : length(statsOrganic)
    thisBB = statsOrganic(k).BoundingBox;
    rectangle('Position', thisBB, 'EdgeColor', 'g', 'LineWidth', 2); % Green for organic
end

% Draw bounding boxes for non-organic waste
for k = 1 : length(statsNonOrganic)
    thisBB = statsNonOrganic(k).BoundingBox;
    rectangle('Position', thisBB, 'EdgeColor', 'r', 'LineWidth', 2); % Red for non-organic
end

title('Final Bounding Boxes');
hold off;
