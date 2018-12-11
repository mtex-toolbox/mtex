function [v, data]= project(o,type,sec,varargin)
% project orientation to ODF sections used by plotSection
%
% Input
%  o  - @SO3Grid
%  type - section type
%  sec  - sections
%
% Output
%  S2G  - vector of @S2Grid
%
% Options
%  tolerance -

%TODO: remove loop as we have a loop already in plotSection

% get input
if length(sec) >= 2
  tol = min(10*degree,abs(sec(1)-sec(2))/2);
else
  tol = 5*degree;
end
tol = get_option(varargin,'tolerance',tol);

% TODO
v = repcell(vector3d,length(sec),1);

% ------------ axis angle projection -------------------
if strcmpi(type,'axisangle')

  for i=1:length(sec)
    ind(:,i) = angle(o)-tol < sec(i) & sec(i) < angle(o)+tol;
    v{i} = axis(o.subSet(ind(:,i)));
  end

  if nargout > 1 && check_option(varargin,'data')
    dat = get_option(varargin,'data');
    if ~isempty(dat)
      for i = 1:size(sec,2), data{i} = dat(ind(:,i)); end
    else
      data = repcell([],size(sec));
    end
  end
  return
end

% symmetries and convert to Euler angle
q = symmetrise(o);

switch lower(type)
  case {'phi_1','phi_2','phi1','phi2'}
    convention = 'Bunge';
  case {'alpha','gamma','sigma','omega'}
    convention = 'ABG';
end

if strcmpi(type,'omega')
  hpos = find_type(varargin,'Miller');
  if hpos > 0
    h = varargin{hpos}(1);
  else
    h = Miller(0,0,1,o.CS);
  end
  [alpha,beta] = polar(h);
  q = q*rotation.byEuler(beta,alpha,0,'ABG');
end

[e1,e2,e3] = Euler(q,convention);

switch lower(type)
  case {'phi_1','alpha','phi1'}
    sec_angle = e1;
    rho = e3;
  case {'phi_2','gamma','phi2'}
    sec_angle = e3;
    rho = e1;
  case {'sigma','omega'}
    sec_angle = e1 + e3;
    rho = e1;
end

% difference to the sections
sec_angle = repmat(sec_angle(:),1,length(sec));
sec = repmat(sec(:)',size(sec_angle,1),1);

d = abs(mod(sec_angle - sec+pi,2*pi) -pi);
dmin = min(d,[],2);

% restrict to those within tolerance

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

% find closest section
ind2 = isappr(d,repmat(dmin,1,size(sec,2)));

% construct output
% TODO check inside?
for i = 1:size(sec,2)
  th = e2(ind2(:,i));
  rh = mod(rho(ind2(:,i)),2*pi);
  v{i} = vector3d('polar',th,rh,varargin{:});
end


if nargout > 1 && check_option(varargin,'data')
  dat = get_option(varargin,'data');
  if ~isempty(dat)
    dat = repmat(dat,length(o.CS),length(o.SS));

    dat = dat(ind);
    for i = 1:size(sec,2)
      data{i} = dat(ind2(:,i));
    end
  else
    data = repcell([],size(sec));
  end
end
