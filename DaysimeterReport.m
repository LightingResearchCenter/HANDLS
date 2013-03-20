function DaysimeterReport(subject,time,lux,CLA,CS,activity)
%DAYSIMETERREPORT Generates graphical summary od processed Dasimeter data

% Set color values
FaceColor = 'k';
EdgeColor = 'none';

% Set position values
x1 = 0.05;
w1 = 0.6-x1;
h1 = 0.1;

h2 = 0.4;
y2 = 0.8-h2;
w2 = h2*7.5/10;
x2 = 1-0.05-w2;

h3 = 0.04;
y3 = y2-h3-0.02;

% Create figure
figure1 = figure;
set(figure1,'PaperUnits','inches',...
    'PaperType','usletter',...
    'PaperOrientation','landscape',...
    'PaperPositionMode','manual',...
    'PaperPosition',[0.5 0.5 10 7.5],...
    'Units','inches',...
    'Position',[0 0 11 8.5]);

% Create title
StartDate = datestr(time(1),'mmm dd, yyyy HH:MM');
EndDate = datestr(time(end),'mmm dd, yyyy HH:MM');
DateRange = [StartDate,' - ',EndDate];
titleHandle = annotation(figure1,'textbox',...
    [0.3 0.85 0.1 0.1],...
    'String',{subject;DateRange},...
    'FitBoxToText','on',...
    'HorizontalAlignment','center',...
    'LineStyle','none');
% Center the title
P = get(titleHandle,'Position');
P(1) = 0.5-P(3)/2;
set(titleHandle,'Position',P);

% Panel 1 Activity
aPanel(time,activity,'Activity',figure1,[x1 0.7 w1 h1],FaceColor,EdgeColor);

% Panel 2 CS
aPanel(time,CS,'CS',figure1,[x1 0.5 w1 h1],FaceColor,EdgeColor);

% Panel 3 CLA
aPanel(time,CLA,'CLA',figure1,[x1 0.3 w1 h1],FaceColor,EdgeColor);
axis tight;

% Panel 4 lux
aPanel(time,lux,'lux',figure1,[x1 0.1 w1 h1],FaceColor,EdgeColor);
axis tight;

% Panel 5 Phasors
%   Calculate phasors
[phiCS,magCS] = Cosinor(time,CS,1);
[phiCLA,magCLA] = Cosinor(time,CS,1);
[phiLux,magLux] = Cosinor(time,CS,1);
%   Plot phasors
axes5 = axes('Parent',figure1,'Position',[x2 y2 w2 h2]);
PhasorPlot24hr([phiCS phiCLA phiLux], [magCS magCLA magLux], 'o')
legend1 = legend(axes5,'show');
set(legend1,'Orientation','horizontal','Position',[x2 y3 w2 h3]);

% Panel 6 Text annotations
notes = cell(3,1);
notes{1} = ['Median CS: ', num2str(median(CS), '%.3f')];
notes{2} = ['Median CLA: ', num2str(median(CLA), '%.1f')];
notes{3} = ['Median Illuminance: ', num2str(median(lux), '%.1f'), ' lux'];
annotation(figure1,'textbox', [x2 0.1 w2 0.2], 'String',notes,...
    'BackgroundColor','w');
end

function aPanel(x,y,label,Parent,Postion,FaceColor,EdgeColor)
H = axes('Parent',Parent,'Position',Postion);
area(H,x,y,'FaceColor',FaceColor,'EdgeColor',EdgeColor);
set(H,'Box','off','TickDir','out');
ticks = get(H,'xtick');
set(H,'xtick',ticks,'xticklabel',datestr(ticks,'mm/dd'));
ylabel(label);
end