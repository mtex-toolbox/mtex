function pf = calcPoleFigure(odf,h,varargin)
% simulate pole figures from an ODF
%
% *calcPoleFigure* allows to simulate diffraction counts given an ODF.
% It supports superposed pole figures and irregular sampling grids.
%
% Syntax
%   pf = calcPolefigure(odf,h,r)
%   pf = calcPolefigure(odf,h,'resolution',5*degree)
%   pf = calcPoleFigure(odf,h,'resolution',5*degree,'complete')
%   pf = calcPoleFigure(odf,{h1,h2,h3},{r1,r2,r3})
%   pf = calcPoleFigure(odf,{h1,{h2,h3]},'superposition',{[1,[0.2 0.8]]})
%
% Input
%  odf - @ODF
%  h   - @Miller / @vector3d crystallographic directions
%  r   - @vector3d specimen directions
%
% Options
%  antipodal    - include <VectorsAxes.html,antipodal symmetry>
%  complete     - do not include <VectorsAxes.html antipodal symmetry>
%  superposition - [double] superposition weights
%
% See also
% PoleFigure/scale PoleFigure/calcPoleFigure PoleFigure/noisepf

% ------ crystal directions -------------

% convert to cell
if ~iscell(h), h = vec2cell(h);end

% ensure crystal symmetry
for i = 1:length(h)
  argin_check(h{i},'Miller');
  h{i} = odf.CS.ensureCS(h{i});
end

% ------ specimen directions -------------

% ensure antipodal symmetry if complete is not set
% PoleFigure will set antipodal to true anyway
if ~check_option(varargin,'complete')
  varargin = [varargin,{'antipodal'}];
end

% get directions
if nargin >= 3 && isa(varargin{1},'vector3d')

  r = repcell(varargin{1},length(h),1);

elseif nargin >= 3 && iscell(varargin{1}) && ...
    length(varargin{1}) == length(h) && isa(varargin{1}{1},'vector3d')

  r = varargin{1};

else
  r = repcell(regularS2Grid(varargin{:}),length(h),1);
end

% ----- structure coefficients -------------
c = ensurecell(get_option(varargin,'superposition',repcell(1,1,length(h))));

% ----- intensities --------------------------
for ip = 1:length(h)

  intensities{ip} = reshape(calcPDF(odf,h{ip},r{ip},varargin{:},...
    'superposition',c{ip}),size(r{ip})); %#ok<AGROW>

end

% set up the pole figures
pf = PoleFigure(h,r,intensities,odf.CS,odf.SS,varargin{:},'superposition',c);
