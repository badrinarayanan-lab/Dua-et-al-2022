% This m file will be used as an alternative implementation of my python
% code for DAPI analysis. 
% This file will be used to analyze and export DAPI result one frame at a
% time.
% Creator: Varshit Dusad
% Date: 27/07/2019
%% Enter the relevant parameters
thresh_1 = 0.97;
thresh_2 = 0.96;
area_min = 1;
area_max = 50;

%% Take the image inputs
% Enter the phase file
[file, path] = uigetfile('', 'Choose the phase image');
im_phase = imread(strcat(path, file));
% Enter the corresponding DAPI maximum projection file
[file, path] = uigetfile('', 'Choose the dapi image');
im_dapi = imread(strcat(path, file));

%% Segment the phase file to generate the mask for DAPI images
% Segment the cells
[~,threshold] = edge(im_phase,'sobel');
fudgeFactor = 0.5;
BWs = edge(im_phase,'sobel',threshold * fudgeFactor);
fudgeFactor = 1;
BWs = edge(im_phase,'sobel',threshold * fudgeFactor);
se90 = strel('line',3,90);
se0 = strel('line',3,0);
BWsdil = imdilate(BWs,[se90 se0]);
BWdfill = imfill(BWsdil,'holes');
bounding_box = regionprops(BWdfill, 'Area', 'BoundingBox');

%% Process DAPI image and create img_new
img_new = zeros(size(im_dapi), 'uint16');
foci_image = zeros(size(im_dapi), 'uint16');
for k = 1 : length(bounding_box)
thisBB = bounding_box(k).BoundingBox;
if bounding_box(k).Area>0
xMin = ceil(thisBB(1));
xMax = xMin + thisBB(3) - 1;
yMin = ceil(thisBB(2));
yMax = yMin + thisBB(4) - 1;
img_new(yMin:yMax, xMin:xMax) = im_dapi(yMin:yMax, xMin:xMax);
end
end
% Create an image intensity threshold
[f, x] = ecdf(img_new(:));
y = x(and(f>thresh_1,f<1));
thresh = y(1);
img_new(img_new<thresh) = 0;

%% Process all the cells
% cell_ids, cell_coord, foci_coord, total_cell,
Cell_id = [];
cell_coordinate = [];
foci_coordinate = [];
total_cells = [];
foci_cell = [];

foci_count_cell = containers.Map;
for item = 1:length(bounding_box)
    foci_count_cell(num2str(item)) = 0; 
end

for crop_index = 1:length(bounding_box)
cell_coords = bounding_box(crop_index).BoundingBox;
xMin = ceil(cell_coords(1));
xMax = xMin + (cell_coords(3) - 1);
yMin = ceil(cell_coords(2));
yMax = yMin + cell_coords(4) - 1;

s_crop_area = process_crop(crop_index, im_dapi, img_new, bounding_box, thresh_2);
for k = 1:length(s_crop_area)
    thisBB = s_crop_area(k).BoundingBox;
    if and(s_crop_area(k).Area>area_min, s_crop_area(k).Area<area_max)
        xMin_foci = ceil(thisBB(1));
        xMax_foci = xMin_foci + thisBB(3) - 1;
        yMin_foci = ceil(thisBB(2));
        yMax_foci = yMin_foci + thisBB(4) - 1;
        %rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],...
        %'EdgeColor','g','LineWidth',2 )
        %rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],...
        %'EdgeColor','r','LineWidth',1, 'FaceColor', 'r')
        foci_image(yMin+yMin_foci:yMin+yMax_foci, xMin+xMin_foci:xMin+xMax_foci) = 60000;
        
        Cell_id = [Cell_id; crop_index]; % Put the cell Id
        cell_coordinate = [cell_coordinate; {cell_coords}]; % Coordinates of the cell
        foci_coordinate = [foci_coordinate;{thisBB}]; % Coordinates of the foci
        total_cells = [total_cells; length(bounding_box)]; % Total Cells
        
        foci_count_cell(num2str(crop_index)) = foci_count_cell(num2str(crop_index)) + 1; 
    end
end
end

foci_cell = zeros(length(Cell_id),1);
for item = 1:length(Cell_id)
    foci_cell(item) = foci_count_cell(num2str(Cell_id(item)));
end

export_file.Cell_id = Cell_id;
export_file.cell_coordinate = cell_coordinate;
export_file.total_cells = total_cells;
export_file.foci_coordinate = foci_coordinate;
export_file.Foci_Per_Cell = foci_cell;
export_file = struct2table(export_file);
%% Do the exports
folder = uigetdir('', 'Choose the results folder to export results');
folder = strcat(folder, '\');

foci_image = foci_image(1:2044,1:2048);
file_prefix = split(file, '.');
file_prefix = file_prefix{1};

imwrite(foci_image, strcat(folder,strcat('FociMAX', strcat(file_prefix, '.tif'))), 'Compression', 'none');

writetable(export_file, strcat(folder,strcat(file_prefix, '.csv')));
%% Custom function call
function s_crop_area = process_crop(crop_index, im_dapi, img_new, bounding_box, thresh_2)
    bbx = bounding_box(crop_index).BoundingBox;
    im_crop = imcrop(img_new, bbx);
    % Identifying spot in cropped cell
    [f, x] = ecdf(im_crop(:));
    try
        y = x(and(f>thresh_2,f<1));
        thresh = y(1);
    catch
        thresh = 0;
    end
    
    im_crop(im_crop<thresh) = 0;
        

    im_crop(im_crop>0) = 60000;%max(im_phase(:));
    s_crop_area = regionprops(imbinarize(im_crop), 'Area', 'BoundingBox');
end
%% add a line to get average number of foci 
