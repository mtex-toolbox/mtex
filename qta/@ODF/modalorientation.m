function g0 = modalorientation(odf,varargin)
% caclulate the modal orientation of the odf
%
%% Input
%  odf - @ODF 
%
%% Output
%  g0 - @quaternion
%
%% See also
%

res = 5*degree;
resmax = min(2.5*degree,get_option(varargin,'resolution',...
  max(0.5*degree,get(odf,'resolution')/2)));

if isempty(resmax)
  warning('constant ODF - no modalorientation'); %#ok<WNTAG>
  g0 = idquaternion;
  return
end

% initial gues
S3G = SO3Grid(2*res,odf(1).CS,odf(1).SS);
if 2*res - get(odf,'resolution') > res/2
  f = eval(smooth(odf,'halfwidth',2*res),S3G,varargin{:}); %#ok<EVLC>
else
  f = eval(odf,S3G,varargin{:}); %#ok<EVLC>
end

epsilon = sort(f(:));
epsilon = epsilon(max(1,length(epsilon)-100));
g0 = S3G(f>=epsilon);

f0 = max(f(:));

while res >= resmax || (0.95 * max(f(:)) > f0)

  %disp('.')
  f0 = max(f(:));
  
  % new grid
  if res < 2*degree
    S3G = SO3Grid(res,odf(1).CS,odf(1).SS,'max_angle',2*res,'center',g0);
  else    
    S3G = SO3Grid(res,odf(1).CS,odf(1).SS);
    S3G = subGrid(S3G,g0,2*res);
  end
  
  % evaluate ODF
  if res - get(odf,'resolution') > res/4
    f = eval(smooth(odf,'halfwidth',res),S3G,varargin{:}); %#ok<EVLC>
  else
    f = eval(odf,S3G,varargin{:}); %#ok<EVLC>
  end
  
  %g0 = quaternion(S3G,find(f(:)==max(f(:))));
  epsilon = sort(f(:));
  epsilon = epsilon(max(1,length(epsilon)-100));
  g0 = quaternion(S3G,find(f>=epsilon));  
  f=  f(f>epsilon);
  res = res / 2;
end

g0 = g0(f(:)==max(f(:)));
g0 = orientation(g0,odf(1).CS,odf(1).SS);
