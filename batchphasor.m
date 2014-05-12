function batchphasor
%BATCHPHASOR Summary of this function goes here
%   Detailed explanation goes here

% Enable required libraries
[parentDir,~,~] = fileparts(pwd);
CDFtoolkitDir = fullfile(parentDir,'LRC-CDFtoolkit');
phasorToolkitDir = fullfile(parentDir,'PhasorAnalysis');

addpath(CDFtoolkitDir,phasorToolkitDir);

% Select a folder to import
projectDir = fullfile([filesep,filesep],'root','projects','HANDLS');
cdfDir = fullfile(projectDir,'croppedCDF');

% Import the index
indexPath = fullfile(projectDir,'HandlsIndex.xlsx');
Index = importindex(indexPath);

% Find CDFs in folder
listing = dir([cdfDir,filesep,'*.cdf']);
nCdf = numel(listing);

% Select a folder to save analyses
saveDir = fullfile(projectDir,'analyses');

for i1 = 1:nCdf
    cdfPath = fullfile(cdfDir,listing(i1).name);
    % Match Index entry to file name
    indexIdx = strcmp(listing(i1).name,Index.file);
    % Skip files not listed in the index
    if ~any(indexIdx)
        continue;
    end
    fileIndex = Index(indexIdx,:);
    
    % Import the CDF and decompose struct
    Data = ProcessCDF(cdfPath);
    logicalArray = logical(Data.Variables.logicalArray);
    timeArray = Data.Variables.time(logicalArray);
    illuminanceArray = Data.Variables.illuminance(logicalArray);
    claArray = Data.Variables.CLA(logicalArray);
    csArray = Data.Variables.CS(logicalArray);
    activityArray = Data.Variables.activity(logicalArray);
    
    % Prepare data for analysis
    switch fileIndex.condition
        case 'omit'
            continue;
        case 'byteShift'
            % Correct for byte shift error before processing
            [~,~,csArray,activityArray] = correctbyteshift(timeArray,illuminanceArray,claArray,csArray,activityArray);
        case 'removeSection'
            % Remove sections of data within specified range(s)
            if ~isnan(fileIndex.removeStart1)
                [~,csArray] = removedata(timeArray,csArray,removeStart,removeStop);
                [timeArray,activityArray] = removedata(timeArray,activityArray,removeStart,removeStop);
            end
            
            if ~isnan(fileIndex.removeStart2)
                [~,csArray] = removedata(timeArray,csArray,removeStart,removeStop);
                [timeArray,activityArray] = removedata(timeArray,activityArray,removeStart,removeStop);
            end
    end
    
    % Peform analysis
    Phasor = phasoranalysis(timeArray,csArray,activityArray);
end

% Save results to a spreadsheet



end

