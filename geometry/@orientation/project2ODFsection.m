function S2G = project2ODFsection(o,type,sec,varargin)
% project orientation to ODF sections used by plotodf
%
%% Input
%  o  - @SO3Grid
%  type - section type
%  sec  - sections
%
%% Output
%  S2G  - vector of @S2Grid
%
%% Options
%  tolerance - 

%% get input

if length(sec) >= 2
  tol = min(5*degree,abs(sec(1)-sec(2))/2);
else
  tol = 5*degree;
end
tol = get_option(varargin,'tolerance',tol);

S2G = repmat(S2Grid(vector3d,varargin{:}),numel(sec),1);

%% symmetries and convert to Euler angle

q = quaternion(symmetrice(o));

switch lower(type)
  case {'phi_1','phi_2','phi1','phi2'}
    convention = 'Bunge';
  case {'alpha','gamma','sigma'}
    convention = 'ABG';   
end

[e1,e2,e3] = quat2euler(q,convention);

switch lower(type)
  case {'phi_1','alpha','phi1'}
    sec_angle = e1;
    rho = e3;
  case {'phi_2','gamma','phi2'}
    sec_angle = e3;
    rho = e1;
  case 'sigma'
    sec_angle = e1 + e3;
    rho = e1;
end

%% difference to the sections

sec_angle = repmat(sec_angle(:),1,numel(sec));
sec = repmat(sec(:)',size(sec_angle,1),1);

d = abs(mod(sec_angle - sec+pi,2*pi) -pi);
dmin = min(d,[],2);

%% restrict to those within tolerance

ind = dmin < tol;
if ~any(ind)
  warning('MTEX:BadSectioning',['There was no orientation plotted because there was no section within tolerance.',...
    ' You may want to increase the tolerance by setting the option ''tolerance''.'])
  return;
end

e2 = e2(ind);
rho = rho(ind);
d = d(ind,:);
dmin = dmin(ind);

%% Find closest section

ind = isappr(d,repmat(dmin,1,size(sec,2)));

%% construct output

for i = 1:size(sec,2)
  
  
  
  S2G(i) = S2Grid(sph2vec(e2(ind(:,i)),mod(rho(ind(:,i)),2*pi)),varargin{:});
  
end
