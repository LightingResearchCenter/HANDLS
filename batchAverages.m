function batchAverages
%BATCHPHASOR Summary of this function goes here
%   Detailed explanation goes here

% Enable required libraries
[parentDir,~,~] = fileparts(pwd);
circadianDir = fullfile(parentDir,'circadian');
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

% Preallocate empty output struct
Output = struct(...
    'subjectId'             , {[]} ,...
    'age'                   , {[]} ,...
    'sex'                   , {[]} ,...
    'race'                  , {[]} ,...
    'povertyStatus'         , {[]} ,...
    'day1night2'            , {[]} ,...
    'arithmeticMeanCs'      , {[]} ,...
    'arithmeticMeanLux'     , {[]} ,...
    'geometricMeanLux'      , {[]} );

for i1 = 1:nCdf
    cdfPath = fullfile(cdfDir,listing(i1).name);
    % Match Index entry to file name
    [~,HNDid,~] = fileparts(cdfPath);
    HNDid = str2double(HNDid);
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
                [~,csArray] = removedata(timeArray,csArray,fileIndex.removeStart1,fileIndex.removeStop1);
                [~,illuminanceArray] = removedata(timeArray,illuminanceArray,fileIndex.removeStart1,fileIndex.removeStop1);
                [timeArray,activityArray] = removedata(timeArray,activityArray,fileIndex.removeStart1,fileIndex.removeStop1);
            end
            
            if ~isnan(fileIndex.removeStart2)
                [~,csArray] = removedata(timeArray,csArray,fileIndex.removeStart2,fileIndex.removeStop2);
                [~,illuminanceArray] = removedata(timeArray,illuminanceArray,fileIndex.removeStart2,fileIndex.removeStop2);
                [timeArray,activityArray] = removedata(timeArray,activityArray,fileIndex.removeStart2,fileIndex.removeStop2);
            end
    end
    
    hourArray = mod(timeArray,1)*24;
    idxDay = hourArray >= 6 & hourArray < 18;
    idxNight = ~idxDay;
    
    roundedIlluminanceArray = illuminanceArray;
    roundedIlluminanceArray(roundedIlluminanceArray < 0.005) = 0.005;
    
    % Assign results to Output struct    
    Output(i1,1).subjectId = fileIndex.HNDid;
    Output(i1,1).age = fileIndex.age;
    Output(i1,1).sex = fileIndex.sex{1};
    Output(i1,1).race = fileIndex.race{1};
    Output(i1,1).povertyStatus = fileIndex.povertyStatus{1};
    Output(i1,1).day1night2 = 1;
    Output(i1,1).arithmeticMeanCs = mean(csArray(idxDay));
    Output(i1,1).arithmeticMeanLux = mean(illuminanceArray(idxDay));
    Output(i1,1).geometricMeanLux = geomean(roundedIlluminanceArray(idxDay));
    
    % Assign results to Output struct
    Output(i1,2).subjectId = fileIndex.HNDid;
    Output(i1,2).age = fileIndex.age;
    Output(i1,2).sex = fileIndex.sex{1};
    Output(i1,2).race = fileIndex.race{1};
    Output(i1,2).povertyStatus = fileIndex.povertyStatus{1};
    Output(i1,2).day1night2 = 2;
    Output(i1,2).arithmeticMeanCs = mean(csArray(idxNight));
    Output(i1,2).arithmeticMeanLux = mean(illuminanceArray(idxNight));
    Output(i1,2).geometricMeanLux = geomean(roundedIlluminanceArray(idxNight));
end




% Save results to an excel file
OutputDataset = struct2dataset(Output(:));
outputCell = dataset2cell(OutputDataset);
varNames = outputCell(1,:);
prettyVarNames = lower(regexprep(varNames,'([^A-Z])([A-Z0-9])','$1 $2'));
outputCell(1,:) = prettyVarNames;

saveDate = datestr(now,'yyyy-mm-dd_HHMM');
saveXlsxFile = [saveDate,'_averageResults.xlsx'];
saveXlsxPath = fullfile(saveDir,saveXlsxFile);
xlswrite(saveXlsxPath,outputCell);

end

