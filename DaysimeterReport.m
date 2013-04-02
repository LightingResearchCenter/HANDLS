function DaysimeterReport(subject,time,lux,CS,activity)
%DAYSIMETERREPORT Generates graphical summary of processed Dasimeter data

% Trim data to length of experiment
days = 7;
TI = time - time(1); % time index in days from start
delta = find(TI <= days); % indices of data to keep
time = time(delta);
activity = activity(delta);
lux = lux(delta);
CS = CS(delta);

% Set color values
FaceColor = 'k';
EdgeColor = 'none';

% Set position values
x1 = 0.05;
w1 = 0.6-x1;
h1 = 0.2;

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
ylim(gca,[0 1.5]);

% Panel 2 CS
aPanel(time,CS,'CS',figure1,[x1 0.4 w1 h1],FaceColor,EdgeColor);
ylim(gca,[0 1]);

% Panel 3 lux
Panel3 = axes('Parent',figure1,'Position',[x1 0.1 w1 h1]);
semilogy(Panel3,time,lux,'Color',FaceColor);
set(Panel3,'Box','off','TickDir','out');
axis tight;
ticks = get(Panel3,'xtick');
set(Panel3,'xtick',ticks,'xticklabel',datestr(ticks,'mm/dd'));
ylim3 = get(gca,'YLim');
% ylim(gca,[1 ylim3(2)]);
ylim(gca,[1 10^5]);
ylabel('lux');

% Panel 4 Phasors
%   Calculate phasors
[magnitude, angle] = phasor24(CS, activity, time);
%   Plot phasors
axes('Parent',figure1,'Position',[x2 y2 w2 h2]);
phasorplot(magnitude,angle,1,4,6,'top','left',.1);
title(gca,'CS/Activity Phasor');

% Panel 5 Text annotations
[IS,IV] = IS_IVcalcFunction(activity,60);
notes = cell(4,1);
notes{1} = ['Phasor magnitude: ', num2str(magnitude, '%.3f')];
notes{2} = ['Phasor angle: ', num2str(angle, '%.2f'), ' hr'];
notes{3} = ['IS: ', num2str(IS, '%.4f')];
notes{4} = ['IV: ', num2str(IV, '%.4f')];
annotation(figure1,'textbox', [x2 0.1 w2 0.2], 'String',notes,...
    'EdgeColor','none');
end

function aPanel(x,y,label,Parent,Postion,FaceColor,EdgeColor)
H = axes('Parent',Parent,'Position',Postion);
area(H,x,y,'FaceColor',FaceColor,'EdgeColor',EdgeColor);
set(H,'Box','off','TickDir','out');
ticks = get(H,'xtick');
set(H,'xtick',ticks,'xticklabel',datestr(ticks,'mm/dd'));
ylabel(label);
end