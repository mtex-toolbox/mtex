function [inpoly, onboundary] = insidepoly(x, y, Px, Py)
% [inpoly onboundary] = insidepoly(X, Y, PX, PY)
% 
% Check if (X,Y) are inside the interior of a 2D polygon delimited by the
% polygon vertices (PX,PY).
%
% INPUTS:
%   - X, Y: arrays of same size, coordinates of N data points
%   - PX, PY: arrays of same size, coordinates of M vertices
%   - Provide optionally EDGE: insidepoly(x, y, Px, Py, edges)
%   EDGES are (m x 2) linear indexes of (Px,Py) that will
%   be considered as vertices of the polygon. This allows user to provide
%   polygons with multiple connexed boundaries (e.g., having holes)
%
% Alternate calling:
%   >> inpoly = insidepoly(XY, P) % or
%   >> inpoly = insidepoly(XY, P, EDGES)
%   - XY: (n x 2) array of n points, ranged by row
%   - P: (m x 2) array of m vertices, ranged by row
%   - EDGES (if provided in third argument) correponds to the
%   first-dimension indexed of P: P(EDGES,:) is the polygone boundary
%
% Advanced control the algorithm:
%   Optionally, user can provide parameters to control the algorithm
%   >> insidepoly(..., 'property1', value1, ...)
% Valid properties (case sensitive) are
%   - 'tol': ['auto'] or positive value: eulidian distance tolerance to
%      detect boundary points. When 'tol' is is set to 'auto', the
%      tolerance value of 1e-9*max(dPx,dPy) is used, where dPx, dPy are
%      respectively the horizontal and vertical size of the polygon.
%   - 'presortflag':  ['auto'], 0, or 1:
%     For large number of vertices and points, INSIDEPOLY uses a sorting
%     strategy to reduce the data to be scanned by each polygonal edge.
%     This reduction comes at the cost of additional processing. The 
%     complexity of the sorting step is O((N + M)*log(N+M)). If the numbers
%     of vertices and/or data are small, the sorting is relatively expensive
%     with respect to the complexity of O(M*N) needed for the calculation
%     for the polygonal region determitaion. It might be preferable to
%     disable this step. By default, the presorting is enabled when:
%                      M>32 and M*N>25000.
%     Set the presortflag to 0 or 1 to enable/disable the sorting step.
% 
% OUTPUTS:
%   - INPOLY: logical array same size as (X,Y), TRUE if the point is
%   inside or on the boundary of the polygon, FALSE otherwise
%   - ONBOUNDARY: logical array same size as (X,Y) to determine points
%   on the boundary (within numercial tolerance)
%
% This functions has C-MEX engine to speed up the calculation. These Mex
% files must be compiled by lauching insidepoly_install.m
%
% See also: inpolygon, inpoly, insidepoly_dblengine, insidepoly_sglengine
%
% Acknowlegment: The idea of sorting coordinates is first implemented by
% Darren Engwirda, http://www.mathworks.com/matlabcentral/fileexchange/10391
%
% Author: Bruno Luong <brunoluong@yahoo.com>
% History:
%     Original: 06-Jun-2010

% Processing the argument list

% Default options
%options = struct('tol', 'auto', ...
%                 'presortflag', 'auto');
                 
%optionloc = cellfun('isclass',varargin,'char');
%if any(optionloc)
%    optionloc = find(optionloc,1,'first');
%    mainargin = varargin(1:optionloc-1);
%    % retreive property/value pairs
%    for k=optionloc:2:nargin-1
%        options.(varargin{k})= varargin{k+1};
%    end
%else
%    mainargin = varargin;
%end

edges = NaN;
%if length(varargin)<=3
%    [xy, P] = deal(varargin{1:2});
%    x = xy(:,1);
%    y = xy(:,2);
%    if length(mainargin)==3 % edge provided
%        edges = varargin{3};
%    end
%    Px = P(:,1);
%    Py = P(:,2);
%else
%    [x, y, Px, Py] = deal(varargin{1:4});
%     if length(varargin)==5 % edge provided
%        edges = varargin{5};
%     end
%end

edgeprovided = ~isnan(edges);

% Orginal size of the data
sz = size(x);

% Reshape in columns
Px = Px(:);
Py = Py(:);
x = x(:);
y = y(:);

% Cast to double of one of them is (required by Mex)
isxdbl = isa(x,'double');
isydbl = isa(y,'double');
isPxdbl = isa(Px,'double');
isPydbl = isa(Py,'double');
doubleengine = isxdbl || isydbl || isPxdbl|| isPydbl;
if doubleengine
    if ~isxdbl, x = double(x); end
    if ~isydbl, y = double(y); end
    if ~isPxdbl, Px = double(Px); end
    if ~isPydbl, Py = double(Py); end   
end

Pxmin = min(Px);
Pxmax = max(Px);
Pymin = min(Py);
Pymax = max(Py);

% Select the tolerance for determining on-boundary points
%if isequal(options.tol,'auto')
    ontol = 1e-9*max(Pxmax-Pxmin,Pymax-Pymin);
%else
%    ontol = options.tol;
%end

if ~edgeprovided
    % We don't want duplicate end vertices
    if Px(1)==Px(end) && Py(1)==Py(end)
        Px(end) = [];
        Py(end) = [];
    end
    % Linear wrap around the points
    Px1 = Px;
    Py1 = Py;
    Px2 = Px([2:end 1]);
    Py2 = Py([2:end 1]);
else
    Px1 = Px(edges(:,1),:);
    Py1 = Py(edges(:,1),:);
    Px2 = Px(edges(:,2),:);
    Py2 = Py(edges(:,2),:);
end

% Filter data outside the rectangular box
inpoly = x>=Pxmin-ontol & x<=Pxmax+ontol & ...
         y>=Pymin-ontol & y<=Pymax+ontol;
x = x(inpoly);
y = y(inpoly);

%if isequal(options.presortflag,'auto')
    n = size(x,1);
    m = size(Px1,1);
    % We don't do presorting for small size polygon or small size data
    % Empirical law from experimental tests (Bruno)
    presortflag = (m>32) && (n*m > 4*25000);
%else
%    presortflag = options.presortflag;
%end

if presortflag
    % Sort the array in x, and find the brackets. This is used to find
    % easily which data points have abscissa fall into the abcissa bracket
    % of each edge of the polygon.
    [x, ix, first, last] = presort(Px1, Px2, x);
    y = y(ix); % arrange y in the same order
    
    % Call mex engine
    if doubleengine
        [in, on] = insidepoly_dblengine(x, y, Px1, Py1, Px2, Py2, ontol, ...
                                       first, last);
    else % single arrays
        [in, on] = insidepoly_sglengine(x, y, Px1, Py1, Px2, Py2, ontol, ...
                                       first, last);
    end
    
    % Restore the original order
    in(ix) = in;
    on(ix) = on;
else % No presorting
    % Call mex engine, without presorting
    if doubleengine
        [in, on] = insidepoly_dblengine(x, y, Px1, Py1, Px2, Py2, ontol);
    else % single arrays
        [in, on] = insidepoly_sglengine(x, y, Px1, Py1, Px2, Py2, ontol);
    end
end

in = in | on;

if nargout>=2
    onboundary = inpoly;
    onboundary(inpoly) = on;
    % Reshape to original size
    onboundary = reshape(onboundary, sz);
end

inpoly(inpoly) = in;
% Reshape to original size
inpoly = reshape(inpoly, sz);

end % insidepoly

%%
function [xsorted, ix, first, last] = presort(Px1, Px2, x)
% (Px1, Px2) abscissa of vertices, x abscissa of data, they are supposed
% to be ranged in column.
% Return:
%   xsorted as sort(x) = x(ix)
%   "first" & "last" indexes such that, for each vertice point
%       min(Px1,Px2) <= xsorted(first:last) <= max(Px1,Px2)

% left and right brackets of the segment
Pmin = min(Px1,Px2);
Pmax = max(Px1,Px2);

nvertices = size(Px1,1);

% We seek to see how x interveaves with Pmin by sorting the ensemble
[trash is] = sort([Pmin; x],1); %#ok
isdata = is>nvertices; % tail index, i.e., belong to data abscissa x
anchor = find(~isdata);
% Get the sorted data alone
ix = is(isdata)-nvertices;
xsorted = x(ix); % sorted x
% Index of the first element in xsorted such that
%   xsorted(first)>=sort(Pmin)
first = anchor-(0:nvertices-1).';
% Rearrange first corresponds to the original order
ip = is(anchor);
first(ip) = first;

% determine how Pmax interleaves with xsorted, i.e.,
% index of the last element in xsorted such that xsorted(first)<=Pmax
% Note: in case of draw in binning edges, HISTC must return the last edge
[~,~, last] = histcounts(Pmax, [xsorted; inf]);

end % presort
