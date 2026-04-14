clc; clear; close all;

% Read grayscale image
img = rgb2gray(imread('image1.png')); % use 'image2.png' for the other image

%% Part A – Morphological Boundary Extraction
figure('Name','Morphological Processing Stages','NumberTitle','off');
subplot(2,3,1);
imshow(img); title('Original Grayscale');

% Binarize image
threshold = 98; % 98 for image1, 105 for image2
bw = img < threshold;
subplot(2,3,2);
imshow(bw); title('Binarized Image');
imwrite(bw, 'binarized.png');

% Structuring Element
se = ones(5,5);

% Denoising with Opening (Erosion followed by Dilation)
eroded = Erosion(bw, se);
opened = Dilation(eroded, se);
subplot(2,3,3);
imshow(opened); title('After Denoising (Opening)');
imwrite(opened, 'denoised.png');

% Fixing Cracks and Gaps with Closing (Dilation followed by Erosion)
dilated = Dilation(opened, se);
closed = Erosion(dilated, se);
subplot(2,3,4);
imshow(closed); title('After Fixing Cracks and Gaps (Closing)');
imwrite(closed, 'cracks_gaps_fixed.png');

% External Boundary = Dilated - Original 
dilated_image = Dilation(closed, se);
boundary = dilated_image - closed;
subplot(2,3,5);
imshow(boundary); title('External Boundary');
imwrite(boundary, 'external_boundary.png');

%% Part B – Bit Plane Slicing and Structural Feature Analysis
figure('Name','Bit Plane Slicing with Morphological Enhancement','NumberTitle','off');

% Structuring Element 
se = ones(3,3);  

for bit = 1:8
    % Extract Bit Plane using logical operation 
    bit_plane = bitand(img, 2^(bit-1)) > 0;

    % Display bit planes 
    % subplot(3, 4, bit); imshow(bit_plane); title(['Bit Plane ', num2str(bit)]);

    % Save bit planes
    imwrite(bit_plane, ['bit_plane', num2str(bit), '.png']);

    % Apply Morphological Operations 
    % Noise Removal by Opening 
    eroded = Erosion(bit_plane, se);
    opened = Dilation(eroded, se);

    % Display enhanced bit planes
     subplot(2,4,bit); imshow(opened); title(['Enhanced Bit Plane ', num2str(bit)]);
    
    % Save enhanced bit planes
    imwrite(opened, ['enhanced_bit_plane', num2str(bit), '.png']);
end

% Function Definitions 
% Erosion 
function eroded = Erosion(image, se)
    [rows, cols] = size(image);
    [se_rows, se_cols] = size(se);
    pad_r = floor(se_rows / 2);
    pad_c = floor(se_cols / 2);

    padded_image = padarray(image, [pad_r, pad_c], 0);
    eroded = zeros(rows, cols);

    for i = 1:rows
        for j = 1:cols
            region = padded_image(i:i+se_rows-1, j:j+se_cols-1);
            eroded(i,j) = all(region(se == 1));
        end
    end
end

% Dilation 
function dilated = Dilation(image, se)
    [rows, cols] = size(image);
    [se_rows, se_cols] = size(se);
    pad_r = floor(se_rows / 2);
    pad_c = floor(se_cols / 2);

    padded_image = padarray(image, [pad_r, pad_c], 0);
    dilated = zeros(rows, cols);

    for i = 1:rows
        for j = 1:cols
            region = padded_image(i:i+se_rows-1, j:j+se_cols-1);
            dilated(i,j) = any(region(se == 1));
        end
    end
end