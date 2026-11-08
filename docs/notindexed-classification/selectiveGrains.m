function [grains,ebsdG,fillMask,c,T,P,info,t] = selectiveGrains(ebsd,varargin)
% two pass reconstruction: classify the notIndexed parts against a small-alpha
% segmentation, fill pores and cracks up to a width, segment again
%
% Options
%  alpha  - the closing radius for noise, its floor the opening radius of the parts (3.1)
%  wCrack - cracks are filled where they are narrower than this, in pixels (30)
%  pores  - fill the pores (true)

alpha  = get_option(varargin,'alpha',3.1);
wCrack = get_option(varargin,'wCrack',30);
pores  = get_option(varargin,'pores',true);
args   = {'angle',10*degree,'minPixel',get_option(varargin,'minPixel',5)};

tic; [g1,e1] = calcGrains(ebsd,'angle',10*degree,'alpha',1.1); t(1) = toc;
tic;
[T,P,info] = niParts(ebsd,e1.grainId,g1,floor(alpha));
c = classifyParts(T,varargin{:});

% pores whole, cracks where a disk of diameter wCrack does not fit
crack = ismember(P,find(c == "crack"));
fillGrid = crack & ~imopen(crack,strel('disk',floor(wCrack/2),0));
if pores, fillGrid = fillGrid | ismember(P,find(c == "pore")); end
g = ebsd.gridify;
fillMask = false(length(ebsd),1);
fillMask(g.id(fillGrid)) = true;
t(2) = toc;

tic; [grains,ebsdG] = calcGrains(ebsd,args{:},'alpha',alpha,'fillMask',fillMask); t(3) = toc;
end
