function generatereport(plotDir,cdfPath,hFigure,units)
%GENERATEREPORT Summary of this function goes here
%   Detailed explanation goes here

%% Import data
DaysimeterData = ProcessCDF(cdfPath);

%% Deconstruct data into components
[~,fileName,~] = fileparts(cdfPath);
subjectName = fileName;
% subjectName = DaysimeterData.GlobalAttributes.subjectID{1};
% fileName = regexprep(subjectName,'\W','','preservecase');

% logicalArray = logical(DaysimeterData.Variables.logicalArray);
timeArray = DaysimeterData.Variables.time;
csArray = DaysimeterData.Variables.CS;
activityArray = DaysimeterData.Variables.activity;
illuminanceArray = DaysimeterData.Variables.illuminance;
illuminanceArray(illuminanceArray<=0) = 0.0005;

%% Analyze data

%% Specify dimensions of plot areas
x = 0.75;
w = 8.75;
h = 1.75;

x1 = x;
y1 = 5.25;
w1 = w;
h1 = h;
box1 = [x1,y1,w1,h1];

x2 = x;
y2 = 3.125;
w2 = w;
h2 = h;
box2 = [x2,y2,w2,h2];

x3 = x;
y3 = 1;
w3 = w;
h3 = h;
box3 = [x3,y3,w3,h3];

%% Plot annotations
plotsubjectname(hFigure,subjectName)

plotreporttitle(hFigure);

%% Plot data
% Plot Activity
hAxes1 = createaxes(units,box1);
hActivity = plot(timeArray,activityArray);
ylabel('Activity');
formatplot(hActivity);
formataxes(hAxes1);

% Plot Circadian Stimulus
hAxes2 = createaxes(units,box2);
hCs = plot(timeArray,csArray);
ylabel('Circadian Stimulus');
formatplot(hCs);
formataxes(hAxes2);

% Plot Illuminance
hAxes3 = createaxes(units,box3);
hIlluminance = semilogy(timeArray,illuminanceArray);
ylabel('Illuminance (lux)');
formatplot(hIlluminance);
formatluxaxes(hAxes3);

%% Save file to disk
filePath = fullfile(plotDir,fileName);
print(gcf,'-dpdf',filePath,'-painters');

end


function hAxes = createaxes(units,position)
hAxes = axes('Units',units,'Position',position,'ActivePositionPropert','position');
end

function formataxes(hAxes)
set(hAxes,'TickDir','out');
set(hAxes,'Box','off');
datetick2('keeplimits','keepticks');

% Box in the plot
xLim = get(hAxes,'XLim');
yLim = get(hAxes,'YLim');
lineX = [xLim(1),xLim(2),xLim(2)];
lineY = [yLim(2),yLim(2),yLim(1)];
axes(hAxes); % Make sure the correct axes are active
hLine = line(lineX,lineY);
set(hLine,'Color','k');
set(hLine,'Clipping','off');

end

function formatluxaxes(hAxes)
set(hAxes,'TickDir','out');
set(hAxes,'Box','off');
datetick2('keeplimits','keepticks');

% Force Limit to start at 1
luxLim = get(hAxes,'YLim');
luxLim(1) = 1;
upperExp = ceil(log10(luxLim(2)));
luxLim(2) = 10^upperExp;
set(hAxes,'YLim',luxLim);
% Evenly distribute tick marks
yExp = 0:floor(upperExp/5):upperExp;
yTick = 10.^yExp;
set(hAxes,'YTick',yTick);

% Box in the plot
xLim = get(hAxes,'XLim');
yLim = get(hAxes,'YLim');
lineX = [xLim(1),xLim(2),xLim(2)];
lineY = [yLim(2),yLim(2),yLim(1)];
axes(hAxes); % Make sure the correct axes are active
hLine = line(lineX,lineY);
set(hLine,'Color','k');
set(hLine,'Clipping','off');

end

function formatplot(hPlot)
set(hPlot,'Color','k');
% set(hPlot,'LineWidth',2);

end
