% roifn -> allFiltersMat

% input: roifn.mat
% output: spatial_footprint.mat

[pixhw, cellnum] = size(roifn); % pixhw is just dummy, so size(roifn,2) is better:)

allFiltersMat = permute(reshape(roifn, 240, 376, cellnum), [3 2 1]); % change dimension order 1
allFiltersMat = permute(allFiltersMat, [1 3 2]); % change dimension order 2

% save('spatial_footprints.mat', 'allFiltersMat') % save converted roifn as spatial_footprint.mat in current folder
%
% clear
% clc