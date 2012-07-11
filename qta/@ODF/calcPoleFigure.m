function pf = calcPoleFigure(odf,h,varargin)
% simulate pole figures from an ODF
%
% *calcPoleFigure* allows to simulate diffraction counts given an ODF.
% Setting the option SUPERPOSITION one can deside wether to to simulate a
% bunch of single PoleFigures or one superposed PoleFigire.
%
%% Syntax
%
%   pf = calcPolefigure(odf,h,r)
%   pf = calcPolefigure(odf,h,'resolution',5*degree)
%   pf = calcPoleFigure(odf,h,'resolution',5*degree,'complete')
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
  varargin = [{'antipodal'},varargin];
end

% get crystal and specimen directions
argin_check(h,{'Miller'});
h = ensureCS(odf(1).CS,{h});
if nargin >= 3 && isa(varargin{1},'vector3d')
  r = varargin{1};
else
  r = S2Grid('regular',varargin{:});
end


comment = get_option(varargin,'comment',...
    ['Pole figures simulated from ',get(odf,'comment')]);

c = get_option(varargin,'SUPERPOSITION',1);
c = c ./ sum(c);

%% construct pole figures
for iv = 1:length(h)/length(c)
      
  Z = zeros(size(r));
  for ic = 0:length(c)-1
    Z = Z + c(ic+1) * ...
      reshape(pdf(odf,vector3d(h(iv+ic)),r,varargin{:}),size(r));
  end

  if length(c) == 1
    pf(iv) = PoleFigure(h(iv),r,Z,odf(1).CS,odf(1).SS,'comment',comment,varargin{:}); %#ok<AGROW>
  else
    pf = PoleFigure(h,r,Z,odf(1).CS,odf(1).SS,'SUPERPOSITION',c,'comment',comment,varargin{:});
  end
end
