function  MTEXdoc(varargin)

if nargin==0
  varargin{1} = 'DocumentationMatlab';
end

if verLessThan('matlab','8.0')
  doc(varargin{:})
elseif verLessThan('matlab','9.0')
  doc(varargin{:},'-classic')
else
  hfile = fullfile(mtex_path,'doc','html',[varargin{1} '.html']);
  web(hfile, '-helpbrowser');
  %com.mathworks.mlservices.MLHelpServices.cshSetLocation(hfile);
end

end
