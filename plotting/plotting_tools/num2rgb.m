function rgb  = num2rgb(val,cmap,varargin)
% derive RGB triplets from scalar input
%
% Input:
%  val      - list of scalar values
%  cmap     - name of the colormap, either buildin or mtexColormap
%             or
%
% Output:
%  rgb      - n-by-3 rgb triplets
%
% Options:
%  N        -  number of colors (default 255)
%  range    - [lower, upper] limit of value (default is min() max())
%
%

if ischar(cmap)
    N = get_option(varargin,'N',255);
else
    N = size(cmap,1);
end

% in case some limits are supplied
rval = get_option(varargin,'range',[min(val(:)) max(val(:))]);
val(val<rval(1))=rval(1);
val(val>rval(2))=rval(2);

ind = ceil((val-rval(1)) / (rval(2)-rval(1)) * (N));

% scale value to N
if ischar(cmap)
    rgb  = squeeze(ind2rgb(ind,eval([cmap '(N)'])));
else
    rgb  = squeeze(ind2rgb(ind,cmap));
end

end