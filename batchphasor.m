function batchphasor
%BATCHPHASOR Summary of this function goes here
%   Detailed explanation goes here

% Enable required libraries
[parentDir,~,~] = fileparts(pwd);
CDFtoolkitDir = fullfile(parentDir,'LRC-CDFtoolkit');
phasorToolkitDir = fullfile(parentDir,'PhasorAnalysis');
daysigramToolkitDir = fullfile(parentDir,'DaysigramReport');

addpath(CDFtoolkitDir,phasorToolkitDir,daysigramToolkitDir);

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
plotDir = fullfile(projectDir,'secondaryPlots');

% Preallocate empty output struct
Output = struct(...
    'subjectId'             , {[]} ,...
    'age'                   , {[]} ,...
    'sex'                   , {[]} ,...
    'race'                  , {[]} ,...
    'povertyStatus'         , {[]} ,...
    'meanNonzeroCs'         , {[]} ,...
    'meanLogLux'            , {[]} ,...
    'phasorMagnitude'       , {[]} ,...
    'phasorAngleHrs'        , {[]} ,...
    'interdailyStability'   , {[]} ,...
    'intradailyVariability' , {[]} );

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
    Data = ProcessCDF(cdfPath);
    logicalArray = logical(Data.Variables.logicalArray);
    timeArray = Data.Variables.time(logicalArray);
    illuminanceArray = Data.Variables.illuminance(logicalArray);
    claArray = Data.Variables.CLA(logicalArray);
    csArray = Data.Variables.CS(logicalArray);
    activityArray = Data.Variables.activity(logicalArray);
    
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
    
    % Plot the data and save to file
    subject = num2str(fileIndex.HNDid);
    generatereport(subject,timeArray,activityArray,csArray,'cs',[0,1],11,plotDir,subject);
    
    % Peform analysis
    Phasor = phasoranalysis(timeArray,csArray,activityArray);
    
    % Assign results to Output struct
    Output(i1,1).subjectId = fileIndex.HNDid;
    Output(i1,1).age = fileIndex.age;
    Output(i1,1).sex = fileIndex.sex{1};
    Output(i1,1).race = fileIndex.race{1};
    Output(i1,1).povertyStatus = fileIndex.povertyStatus{1};
    Output(i1,1).meanNonzeroCs = nonzeromean(csArray);
    Output(i1,1).meanLogLux = logmean(illuminanceArray);
    Output(i1,1).phasorMagnitude = Phasor.magnitude;
    Output(i1,1).phasorAngleHrs = Phasor.angleHrs;
    Output(i1,1).interdailyStability = Phasor.interdailyStability;
    Output(i1,1).intradailyVariability = Phasor.intradailyVariability;
end

% Save results to a matlab file
saveDate = datestr(now,'yyyy-mm-dd_HHMM');
saveMatFile = [saveDate,'_phasorResults.mat'];
saveMatPath = fullfile(saveDir,saveMatFile);
save(saveMatPath,'Output');

% Save results to an excel file
OutputDataset = struct2dataset(Output);
outputCell = dataset2cell(OutputDataset);
varNames = outputCell(1,:);
prettyVarNames = lower(regexprep(varNames,'([^A-Z])([A-Z0-9])','$1 $2'));
outputCell(1,:) = prettyVarNames;

saveXlsxFile = [saveDate,'_phasorResults.xlsx'];
saveXlsxPath = fullfile(saveDir,saveXlsxFile);
xlswrite(saveXlsxPath,outputCell);

end

