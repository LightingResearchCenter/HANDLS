function batchprocess
%BATCHPROCESS Summary of this function goes here
%   Detailed explanation goes here

% Enable required libraries
[parentDir,~,~] = fileparts(pwd);
CDFtoolkitDir = fullfile(parentDir,'LRC-CDFtoolkit');
addpath(CDFtoolkitDir);

% Determine input and output directories
projectDir = fullfile([filesep,filesep],'ROOT','projects','HANDLS');
dataDir = fullfile(projectDir,'Files From HANDLS');
outputDir = fullfile(projectDir,'CDF');
if ~isdir(outputDir)
    mkdir(outputDir);
end

% Find subdirectories
listing = dir(dataDir);
i1 = 1;
for i2 = 1:length(listing)
    if listing(i2).isdir && ~strncmp(listing(i2).name,'.',1)
        subDirs{i1} = listing(i2).name;
        i1 = i1 + 1;
    end
end
subDirs = subDirs'; % make vertical cell array
childDirs = fullfile(dataDir,subDirs); % complete path

% Find input files and create output file paths
% Initialize cell arrays
headerFiles = cell(0,0);
dataFiles = cell(0,0);
% Inspect each subdirectory
for i3 = 1:length(childDirs)
    subListing = dir(fullfile(childDirs{i3},'*A*.txt')); % find headers
    % create other file names from header names
    for i4 = 1:length(subListing)
        headerFiles = [headerFiles;{fullfile(childDirs{i3},...
            subListing(i4).name)}];
        baseName = regexprep(subListing(i4).name,'A','','ignorecase');
        dataFiles = [dataFiles;{fullfile(childDirs{i3},baseName)}];
    end
end

% Sort by file name
[~,baseNameArray,~] = cellfun(@fileparts,dataFiles,'UniformOutput',false);

[baseNameArray,sortIdx] = sort(baseNameArray);
headerFiles = headerFiles(sortIdx);
dataFiles = dataFiles(sortIdx);

% Read, Process, and Write all files
for i5 = 1:length(headerFiles)
    baseName = baseNameArray{i5};
    savePath = fullfile(outputDir,[baseName,'.cdf']);
    if exist(savePath,'file') == 2
        continue;
    end

    WriteProcessedCDF(headerFiles{i5},dataFiles{i5},savePath);
end

end

