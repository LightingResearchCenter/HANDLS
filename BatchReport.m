load ProcessedData.mat ProcessedData DataLogs FileDir

n = length(ProcessedData);

% Make directory for reports if it does not exist
PlotDir = fullfile(FileDir,'DaysimeterReports');
if isdir(PlotDir) == 0
    mkdir(PlotDir);
else
    rmdir(PlotDir,'s');
    mkdir(PlotDir);
end
% Plot files
close all