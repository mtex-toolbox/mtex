function ebsd = fixPos(ebsd,varargin)
% correct x,y coordinates suffering from rounding issues
% Either provide the desired regilar step size, otherwise 
% it is intended to find a likely step size by rounding 
% 
% Syntax
%   ebsd = fixPos(ebsd)
%   ebsd = fixPos(ebsd,'tolerance',1e-3,'sigFigure',4)
%   ebsd = fixPos(ebsd, dPos)
%
% Input
%    ebsd
%    dPos  - anticipated step size (optional)
%
% Output
%   ebsd
%
% Options
%   'tolerance' 'tol' - absolute allowed variation in stepsize
%                       (default 1e-6)
%                       assuming micron as scan units, nobody (as of 2026)
%                       on the planet has step sizes accurate at a 
%                       sub-nanometer level!
%
% 'sigFigure' 'sig'   - significant decimals in fixed step size used for
%                       rounding (default 3)
%

% TODO: add hexEBSD

% check if ebsd hex
if length(ebsd.unitCell) == 6
    disp("not implemented for EBSD on a hexagonal grid")
end

% user did provide a step size
if nargin > 1 && isnumeric(varargin{1})
    % use provided step size
    uC = (varargin{1} / 2) * [1 -1 -1 1 ; 1 1 -1 -1].';


% derive /check stepsize
else
    % get options
    tol = get_option(varargin,{'tolerance' 'tol'},1e-6);
    sig = get_option(varargin,{'sigFigure' 'sig'},3);

    % check for constant stepsize
    stepsx = unique(diff(unique(ebsd.pos.x(:),'stable')));
    stepsy = unique(diff(unique(ebsd.pos.y(:),'stable')));

    % is there just one step size?
    if numel(stepsx) == 1 && numel(stepsy) == 1
        % nothing to do
        return
    end

    % is there more than one step size AND differences in step size are
    % smaller than tol
    xNotConst = numel(stepsx)> 1 & any(diff(stepsx) <= tol);
    yNotConst = numel(stepsy)> 1 & any(diff(stepsy) <= tol);

    if  ~(xNotConst || yNotConst)
        mtexError(['could not come up with a unitCell at the desired precision of ' num2str(tol) ])
        return
    end

    % eventually start from the old unitcell and round it
    uC = calcUnitCell([ebsd.pos.x(:),ebsd.pos.y(:)]);
    uC = round(uC,sig);

end

% construct new x,y positions
s1 = uC(1,1) - uC(2,1);
s2 = uC(1,2) - uC(4,2);

p1 = 0 : s1 : (size(ebsd,1)-1) * s1;
p2 = 0 : s2 : (size(ebsd,2)-1) * s2;

[xnew, ynew] = meshgrid(p2,p1);

pos = vector3d(xnew,ynew,0);

ebsd.pos = pos;
ebsd = ebsd.updateUnitCell(uC);

end

