function batchreport
%BATCHREPORT Summary of this function goes here
%   Detailed explanation goes here

% Enable required libraries
[parentDir,~,~] = fileparts(pwd);
CDFtoolkitDir = fullfile(parentDir,'LRC-CDFtoolkit');

addpath(CDFtoolkitDir);

% Select a folder to import
projectDir = '\\root\projects\HANDLS';
cdfDir = fullfile(projectDir,'CDF');

% Find CDFs in folder
listing = dir([cdfDir,filesep,'*.cdf']);
nCdf = numel(listing);

% Select a folder to save reports to
plotDir = fullfile(projectDir,'reports');

% Prepare the figure
visible = 'off';
[hFigure,~,~,units] = initializefigure(visible);

for i1 = 1:nCdf
    cdfPath = fullfile(cdfDir,listing(i1).name);
    generatereport(plotDir,cdfPath,hFigure,units);
    % Clear figure
    clf(hFigure);
end

close(hFigure);


end

