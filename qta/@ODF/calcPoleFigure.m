function pf = calcPoleFigure(odf,h,varargin)
% simulate pole figures from an ODF
%
% *calcPoleFigure* allows to simulate diffraction counts given an ODF.
% It supports superposed pole figures and irregular sampling grids.
%
%% Syntax
%
%   pf = calcPolefigure(odf,h,r)
%   pf = calcPolefigure(odf,h,'resolution',5*degree)
%   pf = calcPoleFigure(odf,h,'resolution',5*degree,'complete')
%   pf = calcPoleFigure(odf,{h1,h2,h3},{r1,r2,r3})
%   pf = calcPoleFigure(odf,{h1,{h2,h3]},'superposition',{[1,[0.2 0.8]]})
%
%% Input
%  odf - @ODF
%  h   - @Miller / @vector3d crystallographic directions
%  r   - @vector3d specimen directions
%
%% Options
%  antipodal    - include [[AxialDirectional.html,antipodal symmetry]]
%  complete     - do not include [[AxialDirectional.html,antipodal symmetry]]
%  SUPERPOSITION - [double] superposition weights
%
%% See also
% PoleFigure/scale PoleFigure/calcPoleFigure PoleFigure/noisepf

% check for antipodal symmetry
if ~check_option(varargin,'complete')
  varargin = [varargin,{'antipodal'}];
end

% convert to cell
if ~iscell(h), h = vec2cell(h);end

% ensure crystal symmetry
argin_check([h{:}],'Miller');
for i = 1:length(h)
  h{i} = ensureCS(odf(1).CS,h(i));
end

if nargin >= 3 && (isa(varargin{1},'vector3d') || ...
    (iscell(varargin{1}) && ~isempty(varargin{1}) && isa(varargin{1}{1},'vector3d')))
  r = ensurecell(varargin{1});
  varargin(1) = [];
else
  r = {S2Grid('regular',varargin{:})};
end

comment = get_option(varargin,'comment',...
  ['Pole figures simulated from ',get(odf,'comment')]);

c = ensurecell(get_option(varargin,'SUPERPOSITION',repcell(1,1,numel(h))));
varargin = delete_option(varargin,'SUPERPOSITION');

%% construct pole figures
for iv = 1:numel(h)
  
  % find specimen directions
  if numel(r) == 1
    ir = r{1};
  else
    ir = r{iv};
  end
  
  % compute data
  Z = reshape(pdf(odf,h{iv},ir,varargin{:},'superposition',c{iv}),size(ir));
  
  pf(iv) = PoleFigure(h{iv},ir,Z,odf(1).CS,odf(1).SS,...
    'comment',comment,varargin{:},'superposition',c{iv}); %#ok<AGROW>
  
end
