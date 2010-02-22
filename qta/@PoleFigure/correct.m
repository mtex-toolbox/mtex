function pf = correct( pf, varargin )
% corrects a (list of) polfigure(s)
%
%% Syntax
% pf = correct(pf,<options>)
%
%% Input
%  pf - list of @PoleFigure
%
%% Options
%  BACKGROUND | BG               - Background PoleFigure
%  DEFOCUSING | DEF              - Defocusing PoleFigure
%  BACKGROUND DEFOCUSING | DEFBG - Background of defocusing PoleFigure
%
%% Output
%  pf    - @PoleFigure
%
%% See also
% xrdml_interface loadPoleFigure_xrdml

% Background correction
bg = get_option(varargin,{'background','bg'});
if ~isempty(bg)
  bg = adapt_pf(bg,pf,'Background correction pole figure');
  pf = pf-bg;
end

% Defocussing
def = get_option(varargin,{'defocusing','def'});
def_bg = get_option(varargin,{'defocusing background','defbg'});

if isempty(def), return;end % no Defocussing

def = adapt_pf(def,pf,'Defocusing pole figure');
  
if ~isempty(def_bg)
    
  def_bg = adapt_pf(def_bg,pf,'Defocusing background pole figure');
  def = def-def_bg;
    
end
  
pf = pf./def;


%% Handle the case of correction pole figurs that are given only by theta
%% angles
function pf_orig = adapt_pf(pf,pf_orig,msg)

if length(pf) == 1, pf = repmat(pf,numel(pf_orig),1);end
if numel(pf) ~= numel(pf_orig)
  error(['number of ' msg ' does not fitt number of pole figures']);
end

% check for identical specimen directions
if all([pf.r] == [pf_orig.r])
  pf_orig = setdata(pf_orig,getdata(pf));
  return
end

% otherwise interpolate according to theta
try
  for i = 1:length(pf)
    pf_orig(i).data = interp1(get(pf(i).r,'theta'),pf(i).data,get(pf_orig(i).r,'theta'),'spline');
  end
catch
  error([msg ' does not fit original pole figure data!']);
end
