function varargout = get(pf,vname,varargin)
% extract data from a Pole Figure object
%
%% Syntax
%  d = get(pf,'intensities,'id)  - raw diffraction intensities
%  s = get(pf,'CS')              - crystal symmetry
%  r = get(pf,'r')               - specimen directions
%  h = get(pf,'h')               - crystal directions
%  b = get(pf,'bg')              - background intensities
%  c = get(pf,'c')               - superposition coefficients
%  t = get(pf,'theta')           - polar angle of specimen directions
%  r = get(pf,'rho')             - azimuthal angle of specimen directions
%
%% Input
%  pf - @PoleFigure
%  id - index set (optional)
%
%% Output
%  d - raw diffraction intensities
%  s - @symmetry
%  h - @Miller
%  r - @vector3d
%
%% See also
% PoleFigure/set PoleFigure/copy PoleFigure/delete


if nargin == 1
	vnames = get_obj_fields(pf(1),'options');
  vnames = [vnames;{'theta';'rho';'polar';'azimuth';'intensities';'Miller';'crystal directions';'resolution'}];
  if nargout, varargout{1} = vnames; else disp(vnames), end
  return
end


switch vname
  
  case {'SS','CS','comment','options'}
    varargout{1} = pf(1).(vname);
    
  case {'data','intensities'}
    cs = cumsum([0,GridLength(pf)]);
    if nargin == 2
      id = 1:cs(end);
    else
      id = varargin{1};
    end
    
    if isa(id,'logical'), id = find(id);end
    
    d = zeros(length(id),1);
    for i= 1:length(pf)
      idi = (id > cs(i)) & (id<=cs(i+1));
      d(idi) = pf(i).data(id(idi)-cs(i));
    end

    varargout{1} = d;

  case 'r'
    if nargout == 1
      varargout{1} = [pf.r];
    else
      varargout = {pf.r};
    end 
  
  case {'Miller','h','crystal directions'}
    varargout{1} = [pf.h];
    
  case {'hCell'}
    varargout{1} = {pf.h};
    
  case fields(pf)
    varargout{1} = [pf.(vname)];
    
  case {'theta','polar'}
    [theta,rho] = polar([pf.r]);
    varargout{1} = theta;
    varargout{2} = rho;    
    
  case {'rho','azimuth'}
    [theta,rho] = polar([pf.r]); %#ok<ASGLU>
    varargout{1} = rho;
        
  case {'resolution'}
    
    for i = 1:length(pf)
      res(i) = get(pf(i).r,'resolution'); %#ok<AGROW>
    end
    varargout{1} = max(res);
    
  case fields(pf(1).options)
    varargout{1} = [];
    for i = 1:length(pf)
      varargout{1} = [varargout{1};reshape(pf(i).options.(vname),[],1)]; 
    end
  otherwise
    error(['There is no ''' vname ''' property in the ''PoleFigure'' object'])
end

