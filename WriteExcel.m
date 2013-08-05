function WriteExcel(data,outputDir,fileName)
%WRITEPROCESSED Write processed data to text and Excel files
    % data is a struct
    % outputDir is the path for the directory to save to
    % fileName is the name of the output file

% convert MATLAB time to Excel time
timeXl = m2xdate(data.time);

% create MS Excel file
xlName = fullfile(outputDir,[fileName,'.xlsx']); % name of Excel file
Header = {'time','lux','CLA','CS','activity'}; % header labels
xlswrite(xlName,Header,1,'A1'); % write header row to file
% combine output data
Output = [timeXl(:),data.lux(:),data.CLA(:),data.CS(:),data.activity(:)];
xlswrite(xlName,Output,1,'A2'); % write data to file
end

