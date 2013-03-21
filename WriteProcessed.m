function WriteProcessed
%WRITEPROCESSED Write processed data to text and Excel files

% select raw data and header files
StartPath = '\\ROOT\projects\HANDLS\Files From HANDLS'; % directory to start in
[InfoName,InfoPath] = uigetfile('*.txt','Select Header/"A" File',StartPath);
[DataName,DataPath] = uigetfile('*.txt','Select Data File',InfoPath);
% save the full paths for the source files
InfoName = fullfile(InfoPath,InfoName);
DataName = fullfile(DataPath,DataName);

ProcessedData = ReadRaw(InfoName,DataName);
time = ProcessedData.time;
red = ProcessedData.red;
green = ProcessedData.green;
blue = ProcessedData.blue;
lux = ProcessedData.lux;
CLA = ProcessedData.CLA;
activity = ProcessedData.activity;

% convert time to string format
timeStr = datestr(time,'dd/mm/yyyy HH:MM:SS');

% create text file
txtName = [DataName(1:end-4) '_Processed.txt']; % name of text file
fid = fopen(txtName,'w'); % create text file and open for writing
% write header row to file
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\r\n','time','red','green','blue',...
    'lux','CLA','activity');
% write data to file
for i1 = 1:length(time)
    fprintf(fid,'%s\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\r\n',...
    timeStr(i1,:),red(i1),green(i1),blue(i1),lux(i1),CLA(i1),activity(i1));
end
fclose(fid);

% convert MATLAB time to Excel time
timeXl = m2xdate(time);

% create MS Excel file
xlName = [DataName(1:end-4) '_Processed.xlsx']; % name of Excel file
Header = {'time','red','green','blue','lux','CLA','activity'}; % header labels
xlswrite(xlName,Header,1,'A1'); % write header row to file
Output = [timeXl',red',green',blue',lux',CLA',activity']; % combine output data
xlswrite(xlName,Output,1,'A2'); % write data to file
end

