function  MTEXdoc(varargin)

if verLessThan('matlab','8.0')
  doc(varargin{:})
elseif verLessThan('matlab','9.0')
  doc(varargin{:},'-classic')
else
  hfile = fullfile(mtex_path,'doc','html','mtex_product_page.html');
  web(hfile, '-helpbrowser');
  %com.mathworks.mlservices.MLHelpServices.cshSetLocation(hfile);
end

end
