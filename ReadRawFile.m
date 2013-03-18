function ReadRawFile
% READRAWFILE processes Daysimeter files that have been downloaded directly
% Assumes files are in the same directory

% select raw data and header files
StartPath = '\\ROOT\projects\HANDLS\Files From HANDLS'; % directory to start in
[InfoName,InfoPath] = uigetfile('*.txt','Select Header/"A" File',StartPath);
[DataName,DataPath] = uigetfile('*.txt','Select Data File',InfoPath);
% save the full paths for the source files
InfoName = fullfile(InfoPath,InfoName);
DataName = fullfile(DataPath,DataName);

% read the header file
fid = fopen(InfoName,'r','b');
I = fread(fid,'uchar');
fclose(fid);

% read the data file
fid = fopen(DataName,'r','b');
D = fread(fid,'uint16');
fclose(fid);

% find the ID number
q = find(I==10,4,'first');
IDstr = char(I(q(1)+1:q(1)+4))';
IDnum = str2double(IDstr);

% find the start date time
startDateTimeStr = char(I(q(2)+1:q(2)+14))';
startTime = datenum(startDateTimeStr,'mm-dd-yy HH:MM');

% find the log interval
logInterval = str2double(char(I(q(3)+1:q(3)+5))');

% seperate data into raw R,G,B,A
R = zeros(1,floor(length(D)/4));
G = zeros(1,floor(length(D)/4));
B = zeros(1,floor(length(D)/4));
A = zeros(1,floor(length(D)/4));
for i1 = 1:floor(length(D)/4)
    R(i1) = D((i1-1)*4+1);
    G(i1) = D((i1-1)*4+2);
    B(i1) = D((i1-1)*4+3);
    A(i1) = D((i1-1)*4+4);
end

% remove resets (value = 65278) and unwritten (value = 65535)
q = find(R~=65278 & R~=65535);
R = R(q);
G = G(q);
B = B(q);
A = A(q);

% create a time array
time = (1:length(R))/(1/logInterval*60*60*24)+startTime;
% convert time to string format
timeStr = datestr(time,'dd/mm/yyyy HH:MM:SS');
% convert MATLAB time to Excel time
timeXl = m2xdate(time);

% read R,G,B calibration constants
g = fopen('\\ROOT\projects\Daysimeter and dimesimeter reference files\data\Day12 RGB Values.txt');
%find line corresponding to id number
for i = 1:IDnum
    fgetl(g);
end

%pull in RGB calibration constants
fscanf(g, '%d', 1);
cal = zeros(1,3);
for i = 1:3
    cal(i) = fscanf(g, '%f', 1);
end

% convert activity to rms g
% raw activity is a mean squared value, 1 count = .0039 g's, and the 4 comes
% from four right shifts in the source code
activity = (sqrt(A))*.0039*4;

% calibrate to illuminant A
red = R*cal(1);
green = G*cal(2);
blue = B*cal(3);

% calculate lux and CLA
[lux, CLA] = Day12luxCLA(red, green, blue, IDnum);
CLA(CLA < 0) = 0;

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

% create MS Excel file
xlName = [DataName(1:end-4) '_Processed.xlsx']; % name of Excel file
Header = {'time','red','green','blue','lux','CLA','activity'}; % header labels
xlswrite(xlName,Header,1,'A1'); % write header row to file
Output = [timeXl',red',green',blue',lux',CLA',activity']; % combine output data
xlswrite(xlName,Output,1,'A2'); % write data to file

end