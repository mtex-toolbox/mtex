%FCW  Figure Control Widget: Manipulate figures with key and button presses
%
%   fcw([fig], [buttons])
%   fcw(..., '-link')
%
% Allows the user to rotate, pan and zoom an axes using key presses and
% mouse gestures. Additionally, press q to quit the widget, r to reset the
% axes and escape to close the figure. This function is non-blocking, but
% fixes axes aspect ratios.
%
% IN:
%   fig - Handle of the figure to be manipulated (default: gcf).
%   buttons - 4x1 cell array indicating the function to associate with
%             each mouse button (left to right) and the scroll action.
%             Functions can be any of:
%                'rot' - Rotate about x and y axes of viewer's coordinate
%                        frame
%                'rotz' - Rotate about z axis of viewer's coordinate frame
%                'zoom' - Zoom (change canera view angle)
%                'zoomz' - Move along z axis of viewer's coordinate frame
%                'pan' - Pan
%                '' - Don't use that button
%             Default: {'rot', 'zoomz', 'pan', 'zoomz'}).
%   '-link' - Specify each axis in the image to maintain the same pose.

% (C) Copyright Oliver Woodford 2006-2013

% Much of the code here comes from Torsten Vogel's view3d function, which
% was in turn inspired by rotate3d from The MathWorks, Inc.

% Thanks to Sam Johnson for some bug fixes and good feature requests.

function fcw(varargin)
% Parse input arguments
assert(nargin < 4, 'Too many input arguments');
buttons = {'rot', 'zoomz', 'pan', 'zoom'};
fig = gcf();
link = false;
for a = 1:nargin
    v = varargin{a};
    if ischar(v) && strcmp(v, '-link')
        link = true;
    elseif ishandle(v)
        fig = ancestor(v, 'figure');
        assert(~isempty(fig), 'Unrecognized handle');
    elseif iscell(v) && numel(v) == 4 && all(cellfun(@ischar, v))
        buttons = v;
    else
        error('Input not recognized');
    end
end

% Clear any visualization modes we might be in
pan(fig, 'off');
zoom(fig, 'off');
rotate3d(fig, 'off');
% Find all the axes
hAx = findobj(fig, 'Type', 'axes', '-depth', 1);
% For each set of axes
for h = hAx'
    % Set everything to manual
    set(h, 'CameraViewAngleMode', 'manual', 'CameraTargetMode', 'manual', 'CameraPositionMode', 'manual');
    % Store the camera viewpoint
    set(h, 'UserData', camview(h));
end
% Link if necessary
if link
    link = linkprop(hAx, {'CameraPosition', 'CameraTarget', 'CameraViewAngle', 'CameraUpVector', 'Projection'});
end
% Initialize the callbacks
set(fig, 'WindowButtonDownFcn', {@mousedown, {str2func(['fcw_' buttons{1}]), str2func(['fcw_' buttons{2}]), str2func(['fcw_' buttons{3}])}}, ...
         'WindowButtonUpFcn', @mouseup, ...
         'KeyPressFcn', @keypress, ... 
         'WindowScrollWheelFcn', {@scroll, str2func(['fcw_' buttons{4}])}, ...
         'BusyAction', 'cancel', 'UserData', link);
return

function keypress(src, eventData)
fig = ancestor(src, 'figure');
cax = get(fig, 'CurrentAxes');
if isempty(cax)
    return;
end
step = 1;
if ismember('shift', eventData.Modifier)
    step = 2;
end
if ismember('control', eventData.Modifier)
    step = step * 4;
end
% Which keys do what
switch eventData.Key
    case {'v', 'leftarrow'}
        fcw_pan([], [step 0], cax);
    case {'g', 'rightarrow'}
        fcw_pan([], [-step 0], cax);
    case {'b', 'downarrow'}
        fcw_pan([], [0 step], cax);
    case {'h', 'uparrow'}
        fcw_pan([], [0 -step], cax);
    case {'n', 'x'}
        fcw_rotz([], [0 step], cax);
    case {'j', 's'}
        fcw_rotz([], [0 -step], cax);
    case {'m', 'z'}
        fcw_zoom([], [0 -step], cax);
    case {'k', 'a'}
        fcw_zoom([], [0 step], cax);
    case 'r'
        % Reset all the axes
        for h = findobj(fig, 'Type', 'axes', '-depth', 1)'
            camview(h, get(h, 'UserData'));
        end
    case 'q'
        % Quit the widget
        set(fig, 'WindowButtonDownFcn', [], 'WindowButtonUpFcn', [], 'KeyPressFcn', [], 'WindowScrollWheelFcn', []);
    case 'escape'
        close(fig);
end
return

function mousedown(src, eventData, funcs)
% Get the button pressed
fig = ancestor(src, 'figure');
cax = get(fig, 'CurrentAxes');
if isempty(cax)
    return;
end
switch get(fig, 'SelectionType')
    case 'extend' % Middle button
        method = funcs{2};
    case 'alt' % Right hand button
        method = funcs{3};
    case 'open' % Double click
        camview(cax, get(cax, 'UserData'));
        return;
    otherwise
        method = funcs{1};
end
% Set the cursor
switch func2str(method)
    case {'fcw_zoom', 'fcw_zoomz'}
        shape=[ 2   2   2   2   2   2   2   2   2   2 NaN NaN NaN NaN NaN NaN  ;
                2   1   1   1   1   1   1   1   1   2 NaN NaN NaN NaN NaN NaN  ;
                2   1   2   2   2   2   2   2   2   2 NaN NaN NaN NaN NaN NaN  ;
                2   1   2   1   1   1   1   1   1   2 NaN NaN NaN NaN NaN NaN  ;
                2   1   2   1   1   1   1   1   2 NaN NaN NaN NaN NaN NaN NaN  ;
                2   1   2   1   1   1   1   2 NaN NaN NaN NaN NaN NaN NaN NaN  ;
                2   1   2   1   1   1   1   1   2 NaN NaN NaN   2   2   2   2  ;
                2   1   2   1   1   2   1   1   1   2 NaN   2   1   2   1   2  ;
                2   1   2   1   2 NaN   2   1   1   1   2   1   1   2   1   2  ;
                2   2   2   2 NaN NaN NaN   2   1   1   1   1   1   2   1   2  ;
                NaN NaN NaN NaN NaN NaN NaN NaN   2   1   1   1   1   2   1   2  ;
                NaN NaN NaN NaN NaN NaN NaN   2   1   1   1   1   1   2   1   2  ;
                NaN NaN NaN NaN NaN NaN   2   1   1   1   1   1   1   2   1   2  ;
                NaN NaN NaN NaN NaN NaN   2   2   2   2   2   2   2   2   1   2  ;
                NaN NaN NaN NaN NaN NaN   2   1   1   1   1   1   1   1   1   2  ;
                NaN NaN NaN NaN NaN NaN   2   2   2   2   2   2   2   2   2   2  ];
    case 'fcw_pan'
        shape=[ NaN NaN NaN NaN NaN NaN NaN   2   2 NaN NaN NaN NaN NaN NaN NaN ;
                NaN NaN NaN NaN NaN NaN   2   1   1   2 NaN NaN NaN NaN NaN NaN ;
                NaN NaN NaN NaN NaN   2   1   1   1   1   2 NaN NaN NaN NaN NaN ;
                NaN NaN NaN NaN NaN   1   1   1   1   1   1 NaN NaN NaN NaN NaN ;
                NaN NaN NaN NaN NaN NaN   2   1   1   2 NaN NaN NaN NaN NaN NaN ;
                NaN NaN   2   1 NaN NaN   2   1   1   2 NaN NaN   1   2 NaN NaN ;
                NaN   2   1   1   2   2   2   1   1   2   2   2   1   1   2 NaN ;
                2   1   1   1   1   1   1   1   1   1   1   1   1   1   1   2 ;
                2   1   1   1   1   1   1   1   1   1   1   1   1   1   1   2 ;
                NaN   2   1   1   2   2   2   1   1   2   2   2   1   1   2 NaN ;
                NaN NaN   2   1 NaN NaN   2   1   1   2 NaN NaN   1   2 NaN NaN ;
                NaN NaN NaN NaN NaN NaN   2   1   1   2 NaN NaN NaN NaN NaN NaN ;
                NaN NaN NaN NaN NaN   1   1   1   1   1   1 NaN NaN NaN NaN NaN ;
                NaN NaN NaN NaN NaN   2   1   1   1   1   2 NaN NaN NaN NaN NaN ;
                NaN NaN NaN NaN NaN NaN   2   1   1   2 NaN NaN NaN NaN NaN NaN ;
                NaN NaN NaN NaN NaN NaN NaN   2   2 NaN NaN NaN NaN NaN NaN NaN ];
    case {'fcw_rotz', 'fcw_rot'}
        % Rotate
        shape=[ NaN NaN NaN   2   2   2   2   2 NaN   2   2 NaN NaN NaN NaN NaN ;
                NaN NaN NaN   1   1   1   1   1   2   1   1   2 NaN NaN NaN NaN ;
                NaN NaN NaN   2   1   1   1   1   2   1   1   1   2 NaN NaN NaN ;
                NaN NaN   2   1   1   1   1   1   2   2   1   1   1   2 NaN NaN ;
                NaN   2   1   1   1   2   1   1   2 NaN NaN   2   1   1   2 NaN ;
                NaN   2   1   1   2 NaN   2   1   2 NaN NaN   2   1   1   2 NaN ;
                2   1   1   2 NaN NaN NaN NaN NaN NaN NaN NaN   2   1   1   2 ;
                2   1   1   2 NaN NaN NaN NaN NaN NaN NaN NaN   2   1   1   2 ;
                2   1   1   2 NaN NaN NaN NaN NaN NaN NaN NaN   2   1   1   2 ;
                2   1   1   2 NaN NaN NaN NaN NaN NaN NaN NaN   2   1   1   2 ;
                NaN   2   1   1   2 NaN NaN   2   1   2 NaN   2   1   1   2 NaN ;
                NaN   2   1   1   2 NaN NaN   2   1   1   2   1   1   1   2 NaN ;
                NaN NaN   2   1   1   1   2   2   1   1   1   1   1   2 NaN NaN ;
                NaN NaN NaN   2   1   1   1   2   1   1   1   1   2 NaN NaN NaN ;
                NaN NaN NaN NaN   2   1   1   2   1   1   1   1   1 NaN NaN NaN ;
                NaN NaN NaN NaN NaN   2   2 NaN   2   2   2   2   2 NaN NaN NaN ];
    otherwise
        return
end
% Record where the pointer is
global FCW_POS
FCW_POS = get(0, 'PointerLocation');
% Set the cursor and callback
set(ancestor(src, 'figure'), 'Pointer', 'custom', 'pointershapecdata', shape, 'WindowButtonMotionFcn', {method, cax});
return

function mouseup(src, eventData)
% Clear the cursor and callback
set(ancestor(src, 'figure'), 'WindowButtonMotionFcn', '', 'Pointer', 'arrow');
return

function scroll(src, eventData, func)
% Get the axes handle
cax = get(ancestor(src, 'figure'), 'CurrentAxes');
if isempty(cax)
    return;
end
% Call the scroll function
func([], [0 -10*eventData.VerticalScrollCount], cax);
return

function d = check_vals(s, d)
% Check the inputs to the manipulation methods are valid
global FCW_POS
if ~isempty(s)
    % Return the mouse pointers displacement
    new_pt = get(0, 'PointerLocation');
    d = FCW_POS - new_pt;
    FCW_POS = new_pt;
end
return

% Figure manipulation functions
function fcw_rot(s, d, cax)
d = check_vals(s, d);
try
    % Rotate XY
    camorbit(cax, d(1), d(2), 'camera', [0 0 1]);
catch
    % Error, so release mouse down
    mouseup(cax)
end
return

function fcw_rotz(s, d, cax)
d = check_vals(s, d);
try
    % Rotate Z
    camroll(cax, d(2));
catch
    % Error, so release mouse down
    mouseup(cax)
end
return

function fcw_zoom(s, d, cax)
d = check_vals(s, d);
% Zoom
d = (1 - 0.01 * sign(d(2))) ^ abs(d(2));
try
    camzoom(cax, d);
catch
    % Error, so release mouse down
    mouseup(cax)
end
return

function fcw_zoomz(s, d, cax)
d = check_vals(s, d);
% Zoom by moving towards the camera
d = (1 - 0.01 * sign(d(2))) ^ abs(d(2)) - 1;
try
    camdolly(cax, 0, 0, d, 'fixtarget', 'camera');
catch
    % Error, so release mouse down
    mouseup(cax)
end
return

function fcw_pan(s, d, cax)
d = check_vals(s, d);
try
    % Pan
    camdolly(cax, d(1), d(2), 0, 'movetarget', 'pixels');
catch
    % Error, so release mouse down
    mouseup(cax)
end
return
