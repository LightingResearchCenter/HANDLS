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

end