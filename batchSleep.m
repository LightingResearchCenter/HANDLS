function batchSleep
%BATCHSLEEP Summary of this function goes here
%   Detailed explanation goes here

[gitHubDir,~,~] = fileparts(pwd);
circadianDir = fullfile(gitHubDir,'circadian');
addpath(circadianDir);

% Select a folder to import
projectDir = fullfile([filesep,filesep],'root','projects','HANDLS');
cdfDir = fullfile(projectDir,'identifiedCDF');

% Import the index
indexPath = fullfile(projectDir,'HandlsIndex.xlsx');
Index = importindex(indexPath);

% Find CDFs in folder
listing = dir([cdfDir,filesep,'*.cdf']);
nCdf = numel(listing);

% Select a folder to save analyses
saveDir = fullfile(projectDir,'analyses');

% Import Sleep questionnaire
Q = importQuestionnaire;

% Preallocate variables
sleepCell = cell(nCdf,1);
HNDidArray = cell(nCdf,1);
template = sleepTemplate;

for iCdf = 1:nCdf
    cdfPath = fullfile(cdfDir,listing(iCdf).name);
    % Match Index entry to file name
    [~,HNDid,~] = fileparts(cdfPath);
    HNDid = str2double(HNDid);
    HNDidArray{iCdf} = HNDid;
    indexIdx = HNDid == Index.HNDid;
    % Skip files not listed in the index
    if ~any(indexIdx)
        continue;
    end
    fileIndex = Index(indexIdx,:);
    
    % Import the CDF and decompose struct
    cdfData = daysimeter12.readcdf(cdfPath);
    [absTime,relTime,epoch,light,activity,masks,subjectID,deviceSN] = daysimeter12.convertcdf(cdfData);
    
    timeArray = absTime.localDateNum(masks.observation);
    illuminanceArray = light.illuminance(masks.observation);
    claArray = light.cla(masks.observation);
    csArray = light.cs(masks.observation);
    activityArray = activity(masks.observation);
    
    % Prepare data for analysis
    switch fileIndex.condition{1}
        case 'omit'
            continue;
        case 'byteShift'
            % Correct for byte shift error before processing
            [illuminanceArray,claArray,csArray,activityArray] = correctbyteshift(timeArray,illuminanceArray,claArray,csArray,activityArray);
        case 'removeSection'
            % Remove sections of data within specified range(s)
            if ~isnan(fileIndex.removeStart1)
%                 [~,csArray] = removedata(timeArray,csArray,fileIndex.removeStart1,fileIndex.removeStop1);
%                 [~,illuminanceArray] = removedata(timeArray,illuminanceArray,fileIndex.removeStart1,fileIndex.removeStop1);
                [timeArray,activityArray] = removedata(timeArray,activityArray,fileIndex.removeStart1,fileIndex.removeStop1);
            end
            
            if ~isnan(fileIndex.removeStart2)
%                 [~,csArray] = removedata(timeArray,csArray,fileIndex.removeStart2,fileIndex.removeStop2);
%                 [~,illuminanceArray] = removedata(timeArray,illuminanceArray,fileIndex.removeStart2,fileIndex.removeStop2);
                [timeArray,activityArray] = removedata(timeArray,activityArray,fileIndex.removeStart2,fileIndex.removeStop2);
            end
    end
    
    try
    [bedTimeArray,riseTimeArray] = questionnaire2bedlog(Q,HNDid,timeArray);
    tempCell = cell(1,numel(bedTimeArray));
    for iBed = 1:numel(bedTimeArray)
        thisBed = bedTimeArray(iBed);
        thisRise = riseTimeArray(iBed);
        thisStart = thisBed - 20/60/24;
        thisEnd = thisRise + 20/60/24;
        
        tempCell{iBed} = sleep.sleep(timeArray,activityArray,epoch,...
            thisStart,thisEnd,thisBed,thisRise,'auto');
        
        if isempty(tempCell{iBed}.sleepEfficiency)
           tempCell{iBed} = template;
        end
    end
    tempStruct = [tempCell{:}];
    sleepCell{iCdf} = tempStruct;
    catch err
        warning(err.message);
    end
end

idxEmpty = cellfun(@isempty,sleepCell);
sleepCell(idxEmpty)  = [];
HNDidArray(idxEmpty) = [];
varNameArray = fieldnames(template);
xlsFilename = 'test.xlsx';
for iVar = 1:numel(varNameArray)
    thisVarName = varNameArray{iVar};
    tempSheet = cellTable2sheet(sleepCell,thisVarName);
    header = [{'HNDid'},num2cell(1:size(tempSheet,2))];
    thisSheet = [header;[HNDidArray,tempSheet]];
    xlswrite(xlsFilename,thisSheet,thisVarName);
end

winopen(xlsFilename);

end

function sheet = cellTable2sheet(cellTable,varName)

maxHeight = numel(cellTable);
maxWidth = max(cellfun(@numel,cellTable));

sheet = cell(maxHeight,maxWidth);

for iRow = 1:maxHeight
    temp = {cellTable{iRow}.(varName)};
    sheet(iRow,1:numel(temp)) = temp;
end

end


function param = sleepTemplate

param = struct('timeInBed',              'NaN',...
               'sleepStart',             'NaN',...
               'sleepEnd',               'NaN',...
               'assumedSleepTime',       'NaN',...
               'threshold',              'NaN',...
               'actualSleepTime',        'NaN',...
               'actualSleepPercent',     'NaN',...
               'actualWakeTime',         'NaN',...
               'actualWakePercent',      'NaN',...
               'sleepEfficiency',        'NaN',...
               'sleepLatency',           'NaN',...
               'sleepBouts',             'NaN',...
               'wakeBouts',              'NaN',...
               'meanSleepBoutTime',      'NaN',...
               'meanWakeBoutTime',       'NaN',...
               'immobileTime',           'NaN',...
               'immobilePercent',        'NaN',...
               'mobileTime',             'NaN',...
               'mobilePercent',          'NaN',...
               'immobileBouts',          'NaN',...
               'mobileBouts',            'NaN',...
               'meanImmobileBoutTime',   'NaN',...
               'meanMobileBoutTime',     'NaN',...
               'immobile1MinBouts',      'NaN',...
               'immobile1MinPercent',    'NaN',...
               'totalActivityScore',     'NaN',...
               'meanActivityScore',      'NaN',...
               'meanScoreActivePeriods', 'NaN',...
               'moveAndFragIndex',       'NaN');

end