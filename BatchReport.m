clear
clc

load ProcessedData.mat ProcessedData FileDir

% % Make directory for reports if it does not exist
% PlotDir = fullfile(FileDir,'DaysimeterReports');
% if isdir(PlotDir) == 0
%     mkdir(PlotDir);
% else
%     rmdir(PlotDir,'s');
%     mkdir(PlotDir);
% end
% Plot files
close all

n = length(ProcessedData);
% for i1 = 1:n
i1 = 3;
    DaysimeterReport(ProcessedData{i1}.subject,ProcessedData{i1}.time,...
        ProcessedData{i1}.lux,ProcessedData{i1}.CLA,...
        ProcessedData{i1}.CS,ProcessedData{i1}.activity);
% end