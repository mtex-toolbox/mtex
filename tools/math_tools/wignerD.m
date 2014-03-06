function D = wignerD(g,varargin)
% Wiegner-D function
%
%% Syntax
%
%  Dl = wignerD(g,'degree',l)
%  D = wignerD(l,'bandwidth',l)
%
%% Input
%  l - degree
%  g - single quaternion
%
%% Output
%  Dl - $(2l+1) \times (2l+1)$
%  D - $(l(2*l--1)(2*l+1)/3) \times 1$
%
%% See also
% sphericalY

argin_check(g,'quaternion');
if ~check_option(varargin,{'degree','bandwidth','order'})
  help wignerD
  error('No polynomial degree l specified');
end

c = 1./numel(g);
g = Euler(g,'nfft');
l = get_option(varargin,{'degree','bandwidth','order'});
L = max(l,3);
A = ones(L+1,1);

% run NFSOFT
D = call_extern('odf2fc','EXTERN',g,c,A);
      
% extract result
D = complex(D(1:2:end),D(2:2:end));

if check_option(varargin,{'order','degree'})
  D = reshape(D(deg2dim(l)+1:deg2dim(l+1)),2*l+1,2*l+1);
end


function d = deg2dim(l)
% dimension of the harmonic space up to order l

d = l*(2*l-1)*(2*l+1)/3;

