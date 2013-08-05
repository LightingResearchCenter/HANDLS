function BatchProcess
%BATCHPROCESS Summary of this function goes here
%   Detailed explanation goes here

%% Determine input and output directories
startDir = fullfile([filesep,filesep],'ROOT','projects','HANDLS',...
    'Files From HANDLS'); % directory to start in
parentDir = uigetdir(startDir,'Select parent directory of input.');
outputDir = fullfile(parentDir,'processedFiles');
if ~isdir(outputDir)
    mkdir(outputDir);
end

%% Find subdirectories
listing = dir(parentDir);
i1 = 1;
for i2 = 1:length(listing)
    if listing(i2).isdir && ~strncmp(listing(i2).name,'.',1)
        subDirs{i1} = listing(i2).name;
        i1 = i1 + 1;
    end
end
subDirs = subDirs'; % make vertical cell array
childDirs = fullfile(parentDir,subDirs); % complete path

%% Find input files and create output file paths
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

%% Read, Process, and Write all files
for i5 = 1:length(headerFiles)
    try
        data = ReadRaw(headerFiles{i5},dataFiles{i5});
        [~,baseName,~] = fileparts(dataFiles{i5});
        fileName = [baseName,'_processed.xlsx'];
        WriteExcel(data,outputDir,fileName);
    catch err
        display(dataFiles{i5});
        display(err);
    end
end

end

