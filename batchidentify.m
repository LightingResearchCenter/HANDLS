function batchidentify
% BATCHIDENTIFY Use the file names to add identity information to CDFs

% Enable required libraries
[parentDir,~,~] = fileparts(pwd);
CDFtoolkitDir = fullfile(parentDir,'LRC-CDFtoolkit');
addpath(CDFtoolkitDir);

% Select a folder to import
projectDir = fullfile([filesep,filesep],'root','projects','HANDLS');
cdfDir = fullfile(projectDir,'croppedCDF');
newDir = fullfile(projectDir,'identifiedCDF');

% Find CDFs in folder
listing = dir([cdfDir,filesep,'*.cdf']);
nCdf = numel(listing);

for i1 = 1:nCdf
    cdfPath = fullfile(cdfDir,listing(i1).name);
    [~,cdfName,cdfExt] = fileparts(cdfPath);
    
    % Load the data
    DaysimeterData = ProcessCDF(cdfPath);
    
    % Assign new values
    DaysimeterData.GlobalAttributes.subjectID{1} = regexprep(cdfName,'^D(\d*)-(\d*)-(\d*)-(\d*)$','$2$3$4');
    DaysimeterData.GlobalAttributes.deviceSN{1} = num2str(str2double(regexprep(cdfName,'^D(\d*).*$','$1')) + 12000);
    
    % Save new file
    newName = [DaysimeterData.GlobalAttributes.subjectID{1},cdfExt];
    newPath = fullfile(newDir,newName);
    
    RewriteCDF(DaysimeterData, newPath);
    
end

end

