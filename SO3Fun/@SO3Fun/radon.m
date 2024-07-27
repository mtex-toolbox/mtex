function S2F = radon(SO3F,h,r,varargin)
% Radon transform of a SO(3) function
%
% Syntax
%   S2F = radon(SO3F,h)
%   S2F = radon(SO3F,[],r)
%   S2F = radon(SO3F,h,r)
%
% Input
%  SO3F - @SO3Fun
%  h    - @vector3d, @Miller
%  r    - @vector3d, @Miller
%
% Output
%  S2F - @S2FunHarmonic
%

% S2Fun in h or r?
if nargin<3, r = []; end

if isempty(r)
  isPF = true;
elseif isempty(h)
  isPF = false;
else
  isPF = length(h) < length(r);
end

res = get_option(varargin,'RadonResolution',2*degree);
bw = get_option(varargin,'bandwidth',round(128 ./ res *degree));

S2G = quadratureS2Grid(bw);

if isPF % pole figure
     
  for k = 1:length(h)

    % define fibres ->  max(length(h),length(r)) x resolution
    ori = orientation(fibre2quat(h(k),S2G(:),'resolution',res),SO3F.CS,SO3F.SS);
    
    % evaluate ODF at these fibre
    f = SO3F.eval(ori);

    % take the integral over the fibres
    pdf = mean(reshape(f,size(ori)),2);

    % determine S2fun by quadrature
    if angle(h(k),-h(k)) < 1e-5, flag = 'antipodal'; else, flag = []; end
    S2F(k) = S2FunHarmonicSym.quadrature(S2G(:),pdf,...
      'bandwidth',bw,'weights',S2G.weights(:),SO3F.SS,flag); %#ok<AGROW>

  end
  
else % inverse pole figure

  for k = 1:length(r)

    % define fibres ->  max(length(h),length(r)) x resolution
    ori = inv(fibre2quat(r(k),S2G(:),'resolution',res));
    
    % evaluate ODF at these fibre
    f = SO3F.eval(ori);

    % take the integral over the fibres
    pdf = mean(reshape(f,size(ori)),2);
    S2F(k) = S2FunHarmonicSym.quadrature(S2G(:),pdf,'bandwidth',bw,'weights',S2G.weight(:),SO3F.CS); %#ok<AGROW>

  end
  
end

% globaly set antipodal
if check_option(varargin,'antipodal') || SO3F.CS.isLaue || ...
    (nargin > 1 && ~isempty(h) && h.antipodal) || ...
    (nargin > 2 && ~isempty(r) && r.antipodal)
  S2F.antipodal = true;
end

% evaluate S2Fun if needed
if  ~isempty(r) &&  ~isempty(h)
  if length(h) >= length(r)
    S2F = S2F.eval(h);
  else
    S2F = S2F.eval(r).';
  end
end
