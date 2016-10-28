function f = eval(component,ori,varargin)
% evaluate odf using NSOFT
%
% Input
%  odf - @ODF
%  ori - @orientation
% 
% Output
%  f - double
%

if isempty(ori), f = []; return; end

% TODO: this can be done better!!!
if component.antipodal || check_option(varargin,'antipodal')
  varargin = delete_option(varargin,'antipodal');
  component.antipodal = false;
  f = 0.5 * (eval(component,ori,varargin{:}) + eval(component,inv(ori),varargin{:}));
  return
end

% set parameter
L = dim2deg(length(component.f_hat));
L = int32(min(L,get_option(varargin,'bandwidth',L)));
Ldim = deg2dim(double(L+1));

% export to Euler angle
g = Euler(ori,'nfft');
	
f_hat = [real(component.f_hat(1:Ldim)),imag(component.f_hat(1:Ldim))].';

% run NFSOFT
f = call_extern('fc2odf','intern',L,'EXTERN',g,f_hat);
