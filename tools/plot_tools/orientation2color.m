function [c,options] = orientation2color(o,coloring,varargin)
% convert orientation to color
%
%% Input
%  o    - @orientation
%  coloring -
%    IPDF, HKL
%    BUNGE, BUNGE2, EULER, IHS
%    SIGMA, RODRIGUES
%    ANGLE
%%
%

options = {};

switch lower(coloring)
  case 'angle' %ok
    c = angle(o(:))./degree;
  case {'bunge','euler'} % ok
    c = euler2rgb(o,varargin{:});
  case 'rodrigues' % to be worked on
    c = rodrigues2rgb(o);  
  case 'orientations' % to be checked
    c = orientation2custom(o,varargin{:});  
  case 'ipdf'
    [c,options] = ipdf2rgb(o,varargin{:});
  case 'hkl'
    c = ipdf2hkl(o,varargin{:});
  case 'h'
    c = ipdf2custom(o,varargin{:});
  case 'ipdfangle'
    c = ipdfangle(o,varargin{:});
  case 'pdfangle'
    c = pdfangle(o,varargin{:});
  otherwise
    error('Unknown Colorcoding')
end

%%
if 3*numel(o) == numel(c)
  c = reshape(c,[],3);
end
