clear;clc;
load('ACC_heatmap_set1.mat');
load('ACC_heatmap_set2.mat');
load('ACC_heatmap_set3.mat');
load('avgDistances.mat');
load('avgWidth.mat');

ACCgroup = struct();

ACCgroup(1).setNumber = [1, 1, 2, 3, 3, 3]; 
ACCgroup(1).itemNumber = [1, 4, 7, 1, 3, 4]; 

ACCgroup(2).setNumber = [1, 1, 2, 3, 3, 3]; 
ACCgroup(2).itemNumber = [2, 5, 3, 6, 8, 9]; 

ACCgroup(3).setNumber = [1, 2, 2, 2, 3, 3]; 
ACCgroup(3).itemNumber = [6, 1, 4, 5, 2, 5]; 

ACCgroup(4).setNumber = [1, 1, 2, 2, 2, 3]; 
ACCgroup(4).itemNumber = [3, 7, 2, 6, 8, 7]; 

%% group/slice num

groupnum = 4;
slicenum = 7;

selectedSetNumber = ACCgroup(groupnum).setNumber;
selectedItemNumber = ACCgroup(groupnum).itemNumber;

totalwidth = 0;

width = 6000;
height = 6000;
binaryArrays = zeros(height, width, 6);

accumboundary = [];

for i=1:6
%    size(selectedSetNumber,2)

    SelectedLMain = ['Set', num2str(selectedSetNumber(i)), '_', 'L', '_', 'main'];
    SelectedLBound = ['Set', num2str(selectedSetNumber(i)), '_', 'L', '_', 'bound'];
    SelectedLRef = ['Set', num2str(selectedSetNumber(i)), '_', 'L', '_', 'ref'];

    SelectedMain = eval(SelectedLMain);
    SelectedBound = eval(SelectedLBound);
    SelectedRef = eval(SelectedLRef);

    % SelectedRMain = ['Set', num2str(selectedSetNumber(i)), '_', 'R', '_', 'main'];
    % SelectedRBound = ['Set', num2str(selectedSetNumber(i)), '_', 'R', '_', 'bound'];
    % SelectedRRef = ['Set', num2str(selectedSetNumber(i)), '_', 'R', '_', 'ref'];
    % 
    % SelectedMain = eval(SelectedRMain);
    % SelectedBound = eval(SelectedRBound);
    % SelectedRef = eval(SelectedRRef);

    maindots = SelectedMain{selectedItemNumber(i),slicenum};
    bounddots = SelectedBound{selectedItemNumber(i),slicenum};
    refdots = sortrows(SelectedRef{selectedItemNumber(i),slicenum},2);

    vertavg = avgDistances(slicenum);

    tform = fitgeotform2d([refdots(1, :); refdots(2, :)], [3000 3000-vertavg/2; 3000 3000+vertavg/2], "similarity");
    
    alignedbounddots = transformPointsForward(tform,bounddots);

    minX = min(alignedbounddots(:, 1));
    maxX = max(alignedbounddots(:, 1));
    width = maxX - minX;
    
    averageWidth = avgWidth(slicenum);
    scaleFactor = averageWidth / width;

    alignedbounddots(:, 1) = alignedbounddots(:, 1) * scaleFactor;

    % max x among scaled
    maxX_scaled = max(alignedbounddots(:, 1));

    % x axis movement
    xtranslationL = 3000 - maxX_scaled;
    
    % min x among scaled
    minX_scaled = min(alignedbounddots(:,1));

    % x-translation
    xtranslationR = 3000 - minX_scaled;



    [~, idxMinY] = min(alignedbounddots(:, 2));
    pointMinY = alignedbounddots(idxMinY, :);

    % max y
    [~, idxMaxY] = max(alignedbounddots(:, 2));
    pointMaxY = alignedbounddots(idxMaxY, :);

    % average y
    averageY = (pointMinY(2) + pointMaxY(2)) / 2;

    % y-translation
    ytranslation = 3000 - averageY;

    % apply tranform to main data
    alignedmaindots = transformPointsForward(tform,maindots);
    
    % scaling: main
    alignedmaindots(:, 1) = alignedmaindots(:, 1) * scaleFactor;
    
    % x-translation: main
    alignedmaindots(:, 1) = alignedmaindots(:, 1) + xtranslationL;
  %  alignedmaindots(:, 1) = alignedmaindots(:, 1) + xtranslationR;
    
   alignedbounddots(:, 1) = alignedbounddots(:, 1) + xtranslationL;
  %  alignedbounddots(:, 1) = alignedbounddots(:, 1) + xtranslationR;

    % y-translation: main
    alignedmaindots(:, 2) = alignedmaindots(:, 2) + ytranslation;
    alignedbounddots(:, 2) = alignedbounddots(:, 2) + ytranslation;

    coords = alignedmaindots;
    for j = 1:size(coords, 1)
        binaryArrays(round(coords(j,2)), round(coords(j,1)), i) = 1;
    end
    accumboundary = [accumboundary;alignedbounddots];
end

sumArray = sum(binaryArrays, 3);
averageArray = sumArray / 6;

heatmap = imgaussfilt(averageArray,30);
heatmap = im2double(heatmap);
heatmap = heatmap.*100;

[X,Y] = meshgrid(1:size(heatmap,2), 1:size(heatmap,1));

%// Define a finer grid of points
[X2,Y2] = meshgrid(1:1:size(heatmap,2), 1:1:size(heatmap,1));

%// Interpolate the data and show the output
outData = interp2(X, Y, heatmap, X2, Y2, 'linear');
imagesc(outData);

colormap jet
set(gca, 'CLim', [0, 0.025]);

%hold on;

% scatter plot for boundary
%scatter(accumboundary(:,1),accumboundary(:,2), 20, 'w', 'filled');

axis off;

%set(gca, 'Position', [0 0 1 1], 'Units', 'normalized');

% figure size
set(gcf, 'Units', 'pixels', 'Position', [0 0 size(outData, 2)/12 size(outData, 1)/12]);

% optinal: no margin
print('heatmap_sample.png', '-dpng', '-r0');