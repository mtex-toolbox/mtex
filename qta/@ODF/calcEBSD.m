function ebsd = calcEBSD(odf,points,varargin)
% simulate EBSD data from ODF
%
%% Syntax
%  ebsd = calcEBSD(odf,points)
%
%% Input
%  odf    - @ODF
%  points - number of orientation to be simualted
%
%% Output
%  ebsd   - @EBSD
%
%
%% See Also
% ODF_calcPoleFigure

% get input
argin_check(points,'double');
res = get_option(varargin,'resolution',5*degree);
cs = odf(1).CS;
ss = odf(1).SS;

% distribute samples over the parts of the ODF
if length(odf) == 1
  iodf = ones(points,1);
else
  iodf = discretesample(get(odf,'weights'), points);
end

ori = repmat(orientation(cs,ss),points,1);

for i = 1:length(odf)

  points = nnz(iodf==i);

  if check_option(odf(i),'UNIFORM') % uniform portion

    ori(iodf==i) = SO3Grid('random',cs,ss,'points',points);

  elseif check_option(odf(i),'unimodal') 
    
    if length(odf(i).c) == 1
      ic = ones(points,1);
    else
      ic = discretesample(odf(i).c, points);
    end
    
    axis = S2Grid('random','points',points);
    angle = randomSample(odf(i).psi,points);

    ori(iodf==i) = quaternion(odf(i).center,ic) .* axis2quat(vector3d(axis),angle);

  elseif check_option(odf(i),'fibre')
     
    theta = randomSample(odf(i).psi,points,'fibre');
    rho   = 2*pi*rand(points,1);
    angle = 2*pi*rand(points,1);
    
    h = odf(i).center{1};
    r = odf(i).center{2};
    q0 = hr2quat(h,r);
    
    ori(iodf==i) =  axis2quat(r,rho) .* axis2quat(orth(r),theta) .* axis2quat(r,angle) .* q0;
    
  else

    % some local grid
    S3G_local = SO3Grid(res/5,cs,ss,'max_angle',res);

    % the global grid
    if check_option(varargin,'precompute_d')
      S3G_global = get_option(varargin,'S3G');
      d = get_option(varargin,'precompute_d',[]);
    else
      S3G_global = SO3Grid(res,cs,ss);
      d = eval(odf,S3G_global); %#ok<EVLC>
    end
    
    d(d<0) = 0;
    
    r1 = discretesample(d,points);
    r2 = discretesample(numel(S3G_local),points,'XX');

    ori(iodf==i) = quaternion(S3G_global,r1) .* quaternion(S3G_local,r2);

    clear S3G_global; clear S3G_local;
  end
end


comment = get_option(varargin,'comment',...
  ['EBSD data simulated from ',get(odf,'comment')]);

ebsd = EBSD(ori,'comment',comment);
