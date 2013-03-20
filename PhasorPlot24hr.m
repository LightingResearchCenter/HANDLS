function hpol = PhasorPlot24hr(varargin)
%PHASORPLOT24HR Polar coordinate plot.

% Parse possible Axes input
[cax, args, nargs] = axescheck(varargin{:});
error(nargchk(1, 3, nargs, 'struct'));

if nargs < 1 || nargs > 3
    error(message('MATLAB:polar:InvalidDataInputs'));
elseif nargs == 2
    phase = args{1};
    rho = args{2};
    if ischar(rho)
        line_style = rho;
        rho = phase;
        [mr, nr] = size(rho);
        if mr == 1
            phase = 1 : nr;
        else
            th = (1 : mr)';
            phase = th(:, ones(1, nr));
        end
    else
        line_style = 'auto';
    end
elseif nargs == 1
    phase = args{1};
    line_style = 'auto';
    rho = phase;
    [mr, nr] = size(rho);
    if mr == 1
        phase = 1 : nr;
    else
        th = (1 : mr)';
        phase = th(:, ones(1, nr));
    end
else % nargs == 3
    [phase, rho, line_style] = deal(args{1 : 3});
end
if ischar(phase) || ischar(rho)
    error(message('MATLAB:polar:InvalidInputType'));
end
if ~isequal(size(phase), size(rho))
    error(message('MATLAB:polar:InvalidInputDimensions'));
end

% Convert phase to theta
theta = -phase + pi/2;

% get hold state
cax = newplot(cax);

next = lower(get(cax, 'NextPlot'));
hold_state = ishold(cax);

% get x-axis text color so grid is in same color
tc = [.5 .5 .5];
ls = get(cax, 'GridLineStyle');

% Hold on to current Text defaults, reset them to the
% Axes' font attributes so tick marks use them.
fAngle = get(cax, 'DefaultTextFontAngle');
fName = get(cax, 'DefaultTextFontName');
fSize = get(cax, 'DefaultTextFontSize');
fWeight = get(cax, 'DefaultTextFontWeight');
fUnits = get(cax, 'DefaultTextUnits');
set(cax, ...
    'DefaultTextFontAngle', get(cax, 'FontAngle'), ...
    'DefaultTextFontName', get(cax, 'FontName'), ...
    'DefaultTextFontSize', get(cax, 'FontSize'), ...
    'DefaultTextFontWeight', get(cax, 'FontWeight'), ...
    'DefaultTextUnits', 'data');

% only do grids if hold is off
if ~hold_state

    % make a radial grid
    hold(cax, 'on');
    % ensure that Inf values don't enter into the limit calculation.
    arho = abs(rho(:));
    maxrho = max(arho(arho ~= Inf));
    hhh = line([-maxrho, -maxrho, maxrho, maxrho], [-maxrho, maxrho, maxrho, -maxrho], 'Parent', cax);
    set(cax, 'DataAspectRatio', [1, 1, 1], 'PlotBoxAspectRatioMode', 'auto');
    v = [get(cax, 'XLim') get(cax, 'YLim')];
    ticks = sum(get(cax, 'YTick') >= 0);
    delete(hhh);
    % check radial limits and ticks
    rmin = 0;
    rmax = v(4);
    rticks = max(ticks - 1, 2);
    if rticks > 5   % see if we can reduce the number
        if rem(rticks, 2) == 0
            rticks = rticks / 2;
        elseif rem(rticks, 3) == 0
            rticks = rticks / 3;
        end
    end

    % define a circle
    th = 0 : pi / 50 : 2 * pi;
    xunit = cos(th);
    yunit = sin(th);
    % now really force points on x/y axes to lie on them exactly
    inds = 1 : (length(th) - 1) / 4 : length(th);
    xunit(inds(2 : 2 : 4)) = zeros(2, 1);
    yunit(inds(1 : 2 : 5)) = zeros(3, 1);
    % plot background if necessary
    if ~ischar(get(cax, 'Color'))
        patch('XData', xunit * rmax, 'YData', yunit * rmax, ...
            'EdgeColor', tc, 'FaceColor', get(cax, 'Color'), ...
            'HandleVisibility', 'off', 'Parent', cax);
    end

    % draw radial circles
    rinc = (rmax - rmin) / rticks;
    for i = (rmin + rinc) : rinc : rmax
        hhh = line(xunit * i, yunit * i, 'LineStyle', ls, 'Color', tc, 'LineWidth', 1, ...
            'HandleVisibility', 'off', 'Parent', cax);
    end
    set(hhh, 'LineStyle', '-'); % Make outer circle solid

    % plot spokes
    th = (1 : 12) * 2 * pi / 24;
    cst = cos(th);
    snt = sin(th);
    cs = [-cst; cst];
    sn = [-snt; snt];
    line(rmax * cs, rmax * sn, 'LineStyle', ls, 'Color', tc, 'LineWidth', 1, ...
        'HandleVisibility', 'off', 'Parent', cax);

    % annotate spokes in hours
    rt = 1.1 * rmax;
    hour = {'5','4','3','2','1','0','23','22','21','20','19','18',...
        '17','16','15','14','13','12','11','10','9','8','7','6'};
    for i = 1 : length(th)
        text(rt * cst(i), rt * snt(i), hour(i),...
            'HorizontalAlignment', 'center', ...
            'HandleVisibility', 'off', 'Parent', cax);
        text(-rt * cst(i), -rt * snt(i), hour(i+12),...
            'HorizontalAlignment', 'center', ...
            'HandleVisibility', 'off', 'Parent', cax);
    end

    % set view to 2-D
    view(cax, 2);
    % set axis limits
    axis(cax, rmax * [-1, 1, -1.15, 1.15]);
end

% Reset defaults.
set(cax, ...
    'DefaultTextFontAngle', fAngle , ...
    'DefaultTextFontName', fName , ...
    'DefaultTextFontSize', fSize, ...
    'DefaultTextFontWeight', fWeight, ...
    'DefaultTextUnits', fUnits );

% transform data to Cartesian coordinates.
xx = rho .* cos(theta);
yy = rho .* sin(theta);

% plot data on top of grid
if strcmp(line_style, 'auto')
    q = plot(xx, yy, 'Parent', cax);
else
    q = plot(xx, yy, line_style, 'Parent', cax);
end

if nargout == 1
    hpol = q;
end

if ~hold_state
    set(cax, 'DataAspectRatio', [1, 1, 1]), axis(cax, 'off');
    set(cax, 'NextPlot', next);
end
set(get(cax, 'XLabel'), 'Visible', 'on');
set(get(cax, 'YLabel'), 'Visible', 'on');

if ~isempty(q) && ~isdeployed
    makemcode('RegisterHandle', cax, 'IgnoreHandle', q, 'FunctionName', 'polar');
end
end
