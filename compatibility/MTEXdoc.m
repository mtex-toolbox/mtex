function  MTEXdoc(varargin)
% open a page of the MTEX documentation
%
% Superseded by mtexShowDoc, which is where the local/online lookup lives.

if nargin==0
  varargin{1} = 'DocumentationMatlab';
end

mtexShowDoc(varargin{1});

end
