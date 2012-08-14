function hg = scaleBar(data,scanunits,varargin)
% Inserts a scale bar on the current ebsd or grain map.
%
%% Syntax
%  hg = scaleBar(ebsd, scanunits, ...)
%
%% Input
%  ebsd      - an mtex ebsd or grain object
%  scanunits - units of the xy coordinates of the ebsd scan (e.g., 'um')
%
%% Output
%  oval  - output value 
%  ounit - output unit
%
%% Options
%  BACKGROUNDCOLOR - background color (ColorSpec)
%  BACKGROUNDALPHA - background transparency (scalar 0<=a<=1)
%  LINECOLOR       - border color and text color (ColorSpec)
%  BORDER          - controls whether the box has a border ('on', 'off')
%  BORDERWIDTH     - width of border (scalar)
%  LOCATION        - location of the scale bar ('nw,'ne','sw','se', or
%                    [x,y] coordinate vector (len(vector)==2)
%  LENGTH          - desired scale bar length or array of allowable lengths
%
%% Example
%  Use a scale bar on the aachen mtexdata.
%
%   mtexdata aachen
%   plot(ebsd)
%   scaleBar(ebsd,'um','BackgroundColor','k','LineColor','w', ...
%                 'Border','off','BackgroundAlpha',0.6,'Location','nw')
%
%% Bugs/Issues
%  [1] Using the hardware OpenGL renderer can sometimes cause the text not
%  to appear on the scale bar. This can usually be fixed by adding the line
%
%   opengl software
%
%  _Before_ the call to scaleBar().
%
%  [2] The font and the bounding box do not scale with the figure window.
%  Therefore, the desired figure window size needs to be set before the
%  call to scaleBar().
%
%% Authors
%  Eric Payton, eric.payton@bam.de
%  Philippe Pinard, pinard@gfe.rwth-aachen.de 
%
%% Revision History
%  2012.07.17 EJP - First version submitted for mtex commit. 
%  2012.07.27 EJP - Added option for specifying scale bar lengths.
%
%% See also
%  EBSD/plot GRAINSET/plot
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Throw an early error if the current figure is not a grain or ebsd map
if ~strcmpi(get(gcf,'tag'),'ebsd_spatial')
    error(['scaleBar: Cannot add a scale bar to a figure that is not ' ...
           'a map of ebsd data, grains, or boundaries.'])
end
   
%% Parse varargins and set defaults

% Set defaults
bgclr = 'w'; % Default background color is white
bgalph= 1;
fgclr = 'k'; % Default border and font color is black
sbloc = 'sw'; % Default is southwest
brdr = 'on'; % Default is a bounding box with a border
lwth = 2; % Default line width of the bounding box
sbxyvals = [0,0]; % Initial scalebox x,y position values. Later redefined.
val_override = [1 2 5 10 15 20 25 50 75 100 125 150 200 500 750]; % Possible values for scale bar length
val_override_flag = 0; % Do not set a specific scale bar length

% Parse varargins
for i=1:length(varargin)
    if strcmpi('BackgroundColor',varargin{i})
        if i+1<=length(varargin)
            bgclr = varargin{i+1}; % background color
        else
            error('scaleBar: BackgroundColor not specified')
        end
    end
    
    if strcmpi('BackgroundAlpha',varargin{i})
        if i+1<=length(varargin)
            bgalph = varargin{i+1}; % background transparency
        else
            error('scaleBar: BackgroundAlpha not specified.')
        end
    end
    
    if strcmpi('LineColor',varargin{i})
        if i+1<=length(varargin)
            fgclr = varargin{i+1}; % foreground color
        else
            error('scaleBar: LineColor not specified')
        end
    end

    if strcmpi('Border',varargin{i})
        if i+1<=length(varargin)
            brdr = varargin{i+1}; % foreground color
        else
            error('scaleBar: Border option not specified')
        end
    end 
    
    if strcmpi('BorderWidth',varargin{i})
        if i+1<=length(varargin)
            lwth = varargin{i+1}; % border width
        else
            error('scaleBar: BorderWidth option not specified')
        end
    end
    
    if strcmpi('Location',varargin{i})
        if i+1<=length(varargin)
            sbloc = varargin{i+1};
            if isnumeric(sbloc)
                sbxyvals = sbloc;
                sbloc = 'xy';
                if length(sbloc)~=2
                    error(['scaleBar: User-defined location must be ' ...
                          'specified by a numeric xy pair'])
                end
            end
        else
            error('scaleBar: Location option not specified.')
        end
    end
    
    if strcmpi('Length',varargin{i})
        if i+1<=length(varargin)
            val_override = varargin{i+1};
            val_override_flag = 1;
            if ~isnumeric(val_override)
                error(['scaleBar: User-defined scale bar length must ' ...
                    'be numeric.'])
            end
        end
    end                
 
end

% If no border, set it to background color
if strcmp(brdr,'on')
    bdclr = fgclr;
else
    bdclr = bgclr;
end

% Estimate reasonable values
arx = range(get(data,'x'));
ary = range(get(data,'y'));

if ~ismember({'ne','se','sw','nw','xy'},sbloc)
    error(['scaleBar: Unknown location option. Available values are ' ...
        '''ne'',''se'',''sw'',''nw'', or a numberic xy pair.']); 
end

%% Create scale bar and overlay on EBSD scan

% Axes are redundant with micron bar, so turn off axes
hold on; axis off; box on

% Find the range in meters for later determination of magnitude
% We do this so that we never display 10000 nm and always something like 
% 10 microns. Also, the correct choice of units will avoid decimals.
[llen uunits] = closest_length(0.2*arx, scanunits);

% If the user has defined an overriding scalebar length, check if it is
% reasonable
if val_override_flag~=0    
    % Do not allow the scale bar to be more than 80% of the width of the
    % scan -- set this as a maximum and make sure units make sense.
    [chkllen chkunits] = closest_length(0.8*arx, scanunits);
    if all(val_override>=chkllen)
        error(['scaleBar: The requested scale bar length is too large.']);
    end    
    if ~strcmp(chkunits,scanunits)
        error(['scaleBar: The requested scale bar length is not ' ...
            ' appropriate for the scan. Check units.']);
    end   
    if any(val_override<=0)
        error('scaleBar: A scale bar length must be positive & nonzero.');
    end    
end

% Fix the actual scalebar length to defined values
llen = val_override( ...
    abs(llen-val_override)==min(abs(llen-val_override)));
llen = llen(1); % in case of multiple matches

% Use tex if microns
if strcmpi(uunits,'um')
    uunits = '\mum';
end

% A gap around the bar of 1% of bar length looks nice
gap = 0.01 * arx; %EJP! should be llen?

% Calculate box size
boxwidth = llen + 4.0 * gap;
boxheight = 10; % dummy, will change later based on line & text properties

% Box position, using 2% offsets from the edges of the scan. If the user
% wants a different offset, they can define the xy position themselves.
boxx = min(get(data,'x'))+0.02*arx; 
boxy = min(get(data,'y'))+0.02*ary;

% Throw a warning if the transparency isn't going to work
if bgalph<1 && ~strcmpi(get(gcf,'renderer'),'opengl')
    warning('mtex:scaleBar',['Transparency is only supported when ' ...
        'the OpenGL renderer is used.\n']);
end

% Make bounding box. The z-coordinate is used to put the box under the
% line.
verts = [boxx, boxy, 0.1; 
         boxx, boxy + boxheight, 0.1; 
         boxx + boxwidth, boxy + boxheight, 0.1; 
         boxx + boxwidth, boxy, 0.1];
hb = patch('Vertices', verts, ...
    'Faces', [1 2 3 4], ... 
    'FaceColor', bgclr, 'EdgeColor', bdclr, ...
    'LineWidth', lwth, 'FaceAlpha', bgalph);

% Create text
ht = text('String', [num2str(llen) ' ' uunits], 'Position', ...
    [boxx+boxwidth/2,boxy+2.5*gap,0.2], 'HorizontalAlignment', 'Center',...
    'VerticalAlignment', 'bottom', 'Color', fgclr);

% Readjust the box height based on the text height
xt = get(ht, 'Extent');
verts(2,2) = boxy + 3 * gap + xt(4);
verts(3,2) = boxy + 3 * gap + xt(4);
set(hb, 'Vertices', verts);

% Create line as a patch. The z-coordinate is used to layer the patch over
% top of the bounding box.
hl = patch('Vertices',[boxx+2*gap, boxy+gap, 0.2; ...
                       boxx+2*gap, boxy+2*gap, 0.2; ...
                       boxx+2*gap+llen, boxy+2*gap, 0.2; ...
                       boxx+2*gap+llen, boxy+gap, 0.2], ...
           'Faces',[1 2 3 4], ...
           'FaceColor','k', ...
           'FaceAlpha',1);

% Group objects together
hg = hgtransform;
set(hl, 'Parent', hg);
set(ht, 'Parent', hg);
set(hb, 'Parent', hg);

% Translate the group as necessary
switch sbloc
    case 'sw'
        sbxyvals = [0.0, 0.0]; % pass
    case 'nw'
        sbxyvals = [0.0, ...
                    max(get(data,'y'))-xt(4)-3*gap-boxy-0.02*ary];
    case 'ne'
        sbxyvals = [max(get(data,'x'))-boxwidth-boxx-0.02*arx, ...
                    max(get(data,'y'))-xt(4)-3*gap-boxy-0.02*ary];
    case 'se'
        sbxyvals = [max(get(data,'x'))-boxwidth-boxx-0.02*arx, 0.0];
    case 'xy'
        sbxyvals = [sbxyvals(1)-0.02*arx, sbxyvals(2)-0.02*ary];
end
M = makehgtform('translate',[sbxyvals(1) sbxyvals(2) 0.0]);
set(hg,'Matrix',M);

end % scaleBar

% -------------------------------------------------------------------------

%% Subfunction for finding the closest length
function [oval ounit] = closest_length(val, unit)
% returns the closest length to a known unit.
% For example, 10e3m will give 10km.
%
%% Syntax
% [fval funit] = closest_value(val, unit)
%
%% Input
%  val  - a value
%  unit - unit of the value (e.g. nm, m, ...)
%
%% Output
%  oval  - output value 
%  ounit - output unit
%
%% Options
%
%% See also
%

% References lookup table
ref_units = {'ym' 'zm' 'am' 'fm' 'pm' 'nm' 'um' 'mm' 'm' ...
             'km' 'Mm' 'Gm' 'Tm' 'Pm' 'Em' 'Zm' 'Ym'};
ref_values = [1e-24, 1e-21, 1e-18, 1e-15, 1e-12, 1e-9, 1e-6, 1e-3, 1e-0,...
              1e3, 1e6, 1e9, 1e12, 1e15, 1e18, 1e21, 1e24];

% Find unit index
n_unit = ismember(ref_units, unit)==1; 
if any(n_unit) == 0 % No unit found
    ex = MException('MTEX:BadValue', ...
        ['Specified unit (' unit ') is invalid']);
    throw(ex);
end

val_m = val * ref_values(n_unit); % Convert to meters
pow = floor(log10(val_m)); % Get power of value
n = floor(pow / 3) + 9; % Get the closest unit

% Check if n is in array
if n < 1
    ex = MException('MTEX:BadValue', ...
            ['Specified value (' num2str(val_m) ' m) is too small']);
    throw(ex);
end
if n >= length(ref_units)
   ex = MException('MTEX:BadValue', ...
            ['Specified value (' num2str(val_m) ' m) is too large']);
    throw(ex);
end 

ounit = char(ref_units(n)); % Return units
oval = val_m / ref_values(n); % Return formatted value
end % closest_length