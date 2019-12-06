function S2F = radon(SO3F,h,r,varargin)
% Radon transform of the SO(3) function
%
% Syntax
%   S2F = radon(SO3F,h)
%   S2F = radon(SO3F,[],r)
%
% Input
%  SO3F - @SO3Fun
%  h    - @vector3d, @Miller
%  r    - @vector3d, @Miller
%
% Output
%  S2F - @S2FunHarmonic
%
% See also

% S2Fun in h or r?
if nargin<3 || isempty(r)
  isPF = true;
elseif isempty(h)
  isPF = false;
else
  isPF = length(h) < length(r);
end

res = get_option(varargin,'RadonResolution',2*degree);

if isPF % pole figure

  
  [r,W] = quadratureS2Grid(64);
     
  for k = 1:length(h)

    % define fibres ->  max(length(h),length(r)) x resolution
    ori = fibre2quat(h(k),r,'resolution',res);
    
    % evaluate ODF at these fibre
    f = eval(SO3F,ori);

    % take the integral over the fibres
    pdf = mean(reshape(f,size(ori)),2);
    S2F(k) = S2FunHarmonicSym.quadrature(r,pdf,'bandwidth',48); %#ok<AGROW>
       
  end
  
else % inverse pole figure

  for k = 1:length(r)
    sr = symmetrise(r(k),SO3F.SS,'unique');
    S2F(k) = S2FunHarmonicSym.quadrature(inv(SO3F.center)*sr,...
      repmat(SO3F.weights(:),1,length(sr)),SO3F.CS,...
      'symmetrise','bandwidth',SO3F.psi.bandwidth) ./ length(sr); %#ok<AGROW>
  end
  
end

% globaly set antipodal
if check_option(varargin,'antipodal') || SO3F.CS.isLaue || ...
    (nargin > 1 && ~isempty(h) && h.antipodal) || ...
    (nargin > 2 && ~isempty(r) && r.antipodal)
  S2F.antipodal = true;
end
