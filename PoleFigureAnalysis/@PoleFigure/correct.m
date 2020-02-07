function pf = correct( pf, varargin )
% corrects polfigures for background and defocussing
%
% Syntax
%   pf = correct(pf,'bg',bg_pf)
%   pf = correct(pf,'def',def_pf)
%
% Input
%  pf - list of @PoleFigure
%
% Options
%  BACKGROUND | BG               - Background PoleFigure
%  DEFOCUSING | DEF              - Defocusing PoleFigure
%  BACKGROUND DEFOCUSING | DEFBG - Background of defocusing PoleFigure
%
% Output
%  pf    - @PoleFigure
%
% See also
%  ModifyPoleFigureData

% Background correction
bg = get_option(varargin,{'background','bg'});
if ~isempty(bg)
  bg = adapt_pf(bg,pf,'Background correction pole figure');
  pf = pf-bg;
end

% Defocussing
def = get_option(varargin,{'defocussing','defocusing','def'});
def_bg = get_option(varargin,{'defocussing bg','defocussing background','defocusing background','defocusing bg','defbg'});

if isempty(def), return;end % no Defocussing

def = adapt_pf(def,pf,'Defocusing pole figure');
  
if ~isempty(def_bg)
    
  def_bg = adapt_pf(def_bg,pf,'Defocusing background pole figure');
  def = def-def_bg;
    
end
  
pf = pf./def;


% handle the case of correction pole figurs that are given only by theta angles
function pf_orig = adapt_pf(pf,pf_orig,msg)

% only a single pole figure given
if pf.numPF == 1
  pf.allH = pf_orig.allH;
  pf.allR = repmat(pf.allR,size(pf_orig.allR));
  pf.allI = repmat(pf.allI,size(pf_orig.allI));
end
   
if pf.numPF ~= pf_orig.numPF
  error(['number of ' msg ' does not fitt number of pole figures']);
end

% check for identical specimen directions
if all(pf.r == pf_orig.r)
  pf_orig.allI = pf.allI;
  return
end

% otherwise interpolate according to theta
try
  for i = 1:pf.numPF
    % if defocussing data are given on a grid -> do full spherical interpolation
    if length(uniquetol(pf.allR{i}.rho(:),0.1)) > 17
      pf_orig.allI{i} = interp(pf.allR{i},pf.allI{i},pf_orig.allR{i});
    else % interpolate as a radial function
      pf_orig.allI{i} = interp1(pf.allR{i}.theta,pf.allI{i},...
        pf_orig.allR{i}.theta,'spline');
    end
  end
catch
  error([msg ' does not fit original pole figure data!']);
end
