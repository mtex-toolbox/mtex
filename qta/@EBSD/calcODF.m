function odf = calcODF(ebsd,varargin)
% calculate ODF from EBSD data via kernel density estimation
%
%% Input
%  ebsd - @EBSD
%
%% Output
%  odf - @ODF
%
%% Options
%  HALFWIDTH  - halfwidth of the kernel function 
%  RESOLUTION - resolution of the grid where the ODF is approximated
%  EXACT      - no approximation to a corser grid
%
%% See also
% ebsd_demo EBSD/loadEBSD ODF/simulateEBSD


disp('------ MTEX -- EBSD to ODF computation ------------------')
disp('performing kernel density estimation')

% get halfwidth
hw = get_option(varargin,'halfwidth',...
  max(getResolution(ebsd.orientations) * 3,1*degree));
k = kernel('de la Vallee Poussin','halfwidth',hw);

disp([' used kernel: ' char(k)]);

%% exact calculation
if check_option(varargin,'exact')  
  d = ones(1,GridLength(ebsd.orientations)) ./ GridLength(ebsd.orientations);  
  odf = ODF(ebsd.orientations,d,k,...
    ebsd(1).CS,ebsd(1).SS,'comment',['ODF estimated from ',getcomment(ebsd(1))]);  
  return
end

%% approximation on a corser grid

%% get resolution
res = get_option(varargin,'resolution',max(1.5*degree,hw / 2));

%% generate grid
S3G = SO3Grid(res,ebsd(1).CS,ebsd(1).SS);
disp([' approximation grid: ' char(S3G)]);

%% restrict single orientations to this grid
ind = find(S3G,quaternion(ebsd.orientations));
d = zeros(1,GridLength(S3G));
for i = 1:length(ind)
  d(ind(i)) = d(ind(i)) + 1;
end
d = d ./ GridLength(ebsd.orientations);

%% generate ODF

odf = ODF(S3G,d,k,ebsd(1).CS,ebsd(1).SS,...
  'comment',['ODF estimated from ',getcomment(ebsd(1))]);

%% check wether kernel is to wide
if check_option(varargin,'small_kernel') && hw > 2*getResolution(S3G)
  
  hw = 2/3*getResolution(S3G);
  k = kernel('de la Vallee Poussin','halfwidth',hw);
  disp([' recalculate ODF for kernel: ',char(k)]);
  d = eval(odf,S3G);
  odf = ODF(S3G,d./sum(d),k,ebsd(1).CS,ebsd(1).SS,...
    'comment',['ODF estimated from ',getcomment(ebsd(1))]);
end
