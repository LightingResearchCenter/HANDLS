function batchguicrop
% Enable required libraries
[parentDir,~,~] = fileparts(pwd);
CDFtoolkitDir = fullfile(parentDir,'LRC-CDFtoolkit');
addpath(CDFtoolkitDir);

% Select a folder to import
projectDir = fullfile([filesep,filesep],'root','projects','HANDLS');
cdfDir = fullfile(projectDir,'CDF');
newDir = fullfile(projectDir,'croppedCDF');

% Find CDFs in folder
listing = dir([cdfDir,filesep,'*.cdf']);
nCdf = numel(listing);

hCrop = figure('Units','normal','Position',[1,0,1,1]);

for i1 = 1:nCdf
    cdfPath = fullfile(cdfDir,listing(i1).name);
    [~,cdfName,cdfExt] = fileparts(cdfPath);
    newName = [cdfName,cdfExt];
    newPath = fullfile(newDir,newName);
    
    if exist(newPath,'file') == 2
        continue;
    end
    
    % Load the data
    DaysimeterData = ProcessCDF(cdfPath);
%     subjectName = DaysimeterData.GlobalAttributes.subjectID{1};
    subjectName = cdfName;
    timeArray = DaysimeterData.Variables.time;
    csArray = DaysimeterData.Variables.CS;
    activityArray = DaysimeterData.Variables.activity;
    
    % Provide GUI for cropping of the data
    logicalArray = true(size(timeArray));
    needsCropping = true;
    while needsCropping
        logicalArray = true(size(timeArray));
        plotcrop(hCrop,timeArray,csArray,activityArray,logicalArray)
        plotcroptitle(subjectName,'Select Start of Data');
        pause
        [cropStart,~] = ginput(1);
        zoom(hCrop,'out');
        zoom(hCrop,'on');
        plotcroptitle(subjectName,'Select End of Data');
        pause
        [cropStop,~] = ginput(1);
        logicalArray = (timeArray >= cropStart) & (timeArray <= cropStop);
        plotcrop(hCrop,timeArray,csArray,activityArray,logicalArray)
        plotcroptitle(subjectName,'');
        needsCropping = cropdialog;
    end
    set(hCrop,'Visible','off');
    
    % Save new file
    DaysimeterData.Variables.logicalArray = logicalArray;
    RewriteCDF(DaysimeterData, newPath);
    
end

close(hCrop);

end

function needsCropping = cropdialog
button = questdlg('Is this data cropped correctly?','Crop Data','Yes','No','Yes');
switch button
    case 'Yes'
        needsCropping = false;
    case 'No'
        needsCropping = true;
    otherwise
        needsCropping = false;
end
end

function plotcrop(hCrop,timeArray,csArray,activityArray,logicalArray2)
figure(hCrop)
clf(hCrop)
plot(timeArray(logicalArray2),[csArray(logicalArray2),activityArray(logicalArray2)])
datetick2('x');
legend('Circadian Stimulus','Activity');

end

function plotcroptitle(subjectName,subTitle)

hTitle = title({subjectName;subTitle});
set(hTitle,'FontSize',16);
    
end