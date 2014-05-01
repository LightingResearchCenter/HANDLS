clear
clc

load ProcessedData.mat ProcessedData FileDir
addpath('C:\Users\jonesg5\Documents\GitHub\PhasorReport');

% Make directory for reports if it does not exist
PlotDir = fullfile(FileDir,'PhasorReports');
if isdir(PlotDir) == 0
    mkdir(PlotDir);
else
    rmdir(PlotDir,'s');
    mkdir(PlotDir);
end
% Plot files
close all

n = length(ProcessedData);
for i1 = 1:n
    PhasorReport(ProcessedData{i1}.time',smooth(ProcessedData{i1}.CS'),...
        smooth(ProcessedData{i1}.activity'),ProcessedData{i1}.subject)
    pdfName = fullfile(PlotDir,[ProcessedData{i1}.subject,'_',...
        datestr(now,'yyyy-mm-dd'),'.pdf']);
    print(gcf,'-dpdf',pdfName);
    close all
end