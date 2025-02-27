function [values,modes] = max(sF,varargin)
% global, local and pointwise maxima of periodic functions
%
% Syntax
%   % global maximum
%   [v,pos] = max(sF)
%
%   % local maxima
%   [v,pos] = max(sF,'numLocal',5) % the 5 largest local maxima
%
%   % pointwise maxima
%   sF = max(sF, c) % pointwise maximum of a S1Fun and the constant c
%   sF = max(sF1, sF2) % pointwise maximum of two S1Fun's
%   sF = max(sF1, sF2, 'bandwidth', bw) % specify the new bandwidth
%
%   % pointwise maxima of a multivariate function along dim
%   sF = max(S1Fmulti,[],dim)
%
% Input
%  sF, sF1, sF2 - @S1Fun
%  S1Fmulti     - a multivariate @S1Fun
%  c            - double
%
% Output
%  v - double
%  pos - double
%
% Options
%  kmax          - number of iterations
%  numLocal      - number of local minima to return
%  startingNodes - double
%  tolerance     - minimum distance between two peaks
%  resolution    - minimum step size 
%  maxStepSize   - maximm step size
%
% See also
% S1Fun/min

modes=[];

if isa(sF,'function_handle'), sF = S1FunHandle(sF); end
if nargin>1 && isa(varargin{1},'function_handle'),  varargin{1}= S1FunHandle(varargin{1}); end

% max(sF1, sF2)
if ( nargin > 1 ) && ( isa(varargin{1}, 'S1Fun') )
  sF2 = varargin{1};
  values = S1FunHandle(@(o) max(sF.eval(o),sF2.eval(o)));
  if isa(sF,'S1FunHarmonic') || isa(sF2,'S1FunHarmonic')
    values = S1FunHarmonic(values,'bandwidth', ...
        min(getMTEXpref('maxS1Bandwidth'),max(sF.bandwidth,sF2.bandwidth)));  
  end
  
elseif ( nargin > 1 ) && ( isnumeric(varargin{1}) ) % max(sF1,c)

  values = S1FunHandle(@(o) max(sF.eval(o),varargin{1}));
  if isa(sF,'S1FunHarmonic')
    values = S1FunHarmonic(values,'bandwidth',min(getMTEXpref('maxS1Bandwidth'),sF.bandwidth));
  end
  
else

  % initial resolution
  res0 = get_option(varargin,'resolution',5*degree);

  % target resolution
  targetRes = get_option(varargin,'accuracy',0.25*degree);

  % initial seed
  S1G = get_option(varargin,'startingNodes');
  
  if isempty(S1G)
    S1G = 0:res0:2*pi;
  end
  S1G = reshape(S1G,[],1);

  % evaluate function on grid
  f = eval(sF,S1G,varargin{:});

  % take only local minima as starting points
  ind = isLocalMinD(-f,S1G,1.5*res0,varargin{:});
  modes = S1G(ind);
  values = f(ind);

  % the total walking distance
  sumOmega = zeros(size(modes));

  numLocal = get_option(varargin, 'numLocal',1);

  % local refinement
  res = res0;
  while res > targetRes
    res = res / 1.25;

    % neighborhood search
    S1Glocal = -2*res:res/2:2*res;
    newModes = (S1Glocal + modes);
    f = eval(sF,newModes,varargin{:});
  
    if numLocal == 1

      [values,id] = max(f(:));
      modes = newModes(id);
        
    else
      [values,id] = max(f,[],2);
      modes = newModes(sub2ind(size(newModes),(1:length(modes)).',id));

      % keep track of the walking distance
      sumOmega = sumOmega + abs(S1Glocal(id)).';

      % maybe we can reduce the number of points a bit
      [~,~,I] = uniquetol(modes, 1.5*res0);
%      modes = normalize(accumarray(I,modes));
      modes = accumarray(I,modes,[],@mean);
      values = accumarray(I,values,[],@mean);
      sumOmega = accumarray(I,sumOmega,[],@min);

      % consider only points that did not walked too far
      values(sumOmega>5*res0) = [];
      modes(sumOmega>5*res0) = [];
      sumOmega(sumOmega>5*res0) = [];
    end
  end

  [modes,~,I] = uniquetol(modes,1.5*res0);
  values = accumarray(I,values,[],@mean);

  % format output
  [values, I] = sort(values,'descend');
  numLocal = min(length(values), numLocal);
  values = values(1:numLocal);
  modes = modes(I(1:numLocal));
  
end
