function BatchMiller
%BATCHMILLER Create Miller plots for a batch of files
%   Detailed explanation goes here

StartPath = 'C:\Users\jonesg5\Documents\HANDLS';
FileDir = uigetdir(StartPath,'Select directory of raw Daysimeter files');
WorkingDir = cd(FileDir);
tempHeaders = ls('*A*.txt');
tempContents = ls;
cd(WorkingDir);

% Convert char matrix to cell array of strings
m = length(tempContents);
Contents = cell(m,1);
for i1 = 1:m
    Contents{i1} = strtrim(tempContents(i1,:));
end

% Convert char matrix to cell array of strings
n = length(tempHeaders);
Headers = cell(n,1);
for i1 = 1:n
    Headers{i1} = strtrim(tempHeaders(i1,:));
end

% Create list of data logs that correspond to headers
DataLogs = cell(n,1);
for i1 = 1:n
    DataLogs{i1} = regexprep(Headers{i1},'(.*)A(.*)','$1$2');
end

% Check if data log exists
i2 = 1;
for i1 = 1:n
    if max(strcmpi(DataLogs{i1},Contents)) == 0
        msg = ['Data file: ',DataLogs{i1},' is missing!'];
        warning(msg);
        idx(i2) = i1;
    end
end

% Delete non-existant files from list
if exist('idx','var') == 1
    Headers{idx} = [];
    DataLogs{idx} = [];
end

n = length(Headers);

% Generate full file paths
InfoName = cell(n,1);
DataName = cell(n,1);
for i1 = 1:n
    InfoName{i1} = fullfile(FileDir,Headers{i1});
    DataName{i1} = fullfile(FileDir,DataLogs{i1});
end

% Read and process raw files
ProcessedData = cell(n,1);
for i1 = 1:n
    ProcessedData{i1} = ReadRaw(InfoName{i1},DataName{i1});
end

% Make directory for plots if it does not exist
PlotDir = fullfile(FileDir,'MillerPlots');
if isdir(PlotDir) == 0
    mkdir(PlotDir);
else
    rmdir(PlotDir,'s');
    mkdir(PlotDir);
end
% Plot files
close all
for i1 = 1:n
    time = ProcessedData{i1}.time;
    CS = ProcessedData{i1}.CS;
    AI = ProcessedData{i1}.activity;
    % Check array orientation
    Dim = size(time);
    if Dim(2) > Dim(1)
        time = time';
    end
    Dim = size(CS);
    if Dim(2) > Dim(1)
        CS = CS';
    end
    Dim = size(AI);
    if Dim(2) > Dim(1)
        AI = AI';
    end
    Subject = regexprep(DataLogs{i1},'(.*)\.txt','$1');
    MillerPlot(time, AI, CS, 7, Subject);
    FileName = [Subject,'_',datestr(time(1),'yy-mm-dd')];
    print('-dpng','-r100',fullfile(PlotDir,FileName));
    close(gcf)
end

end