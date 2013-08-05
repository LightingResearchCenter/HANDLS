function WriteProcessed(data,outputDir,fileName)
%WRITEPROCESSED Write processed data to text and Excel files
    % data is a struct
    % outputDir is the path for the directory to save to
    % fileName is the name of the output file without an extension

% Break out variables
time = data.time;
lux = data.lux;
CLA = data.CLA;
CS = data.CS;
activity = data.activity;

% convert time to string format
timeStr = datestr(time,'dd/mm/yyyy HH:MM:SS');

% create text file
txtName = fullfile(outputDir,[fileName,'.txt']); % name of text file
fid = fopen(txtName,'w'); % create text file and open for writing
% write header row to file
fprintf(fid,'%s\t%s\t%s\t%s\t%s\r\n','time','lux','CLA','CS','activity');
% write data to file
for i1 = 1:length(time)
    fprintf(fid,'%s\t%%.2f\t%.2f\t%.2f\t%.2f\r\n',...
    timeStr(i1,:),lux(i1),CLA(i1),CS(i1),activity(i1));
end
fclose(fid);

% convert MATLAB time to Excel time
timeXl = m2xdate(time);

% create MS Excel file
xlName = fullfile(outputDir,[fileName,'.xlsx']); % name of Excel file
Header = {'time','lux','CLA','CS','activity'}; % header labels
xlswrite(xlName,Header,1,'A1'); % write header row to file
Output = [timeXl(:),lux(:),CLA(:),CS(:),activity(:)]; % combine output data
xlswrite(xlName,Output,1,'A2'); % write data to file
end

