function [CS,SS] = extractSymmetries(varargin)
% extract crystal and specimen symmetry from input arguments

CSargpos = find(cellfun(@(x) isa(x,'symmetry'),varargin));

assert(length(CSargpos)<3,'To many crystal symmetries!')

if ~isempty(CSargpos)
  CS = varargin{CSargpos(1)};
else
  CS = symmetry;
end
if length(CSargpos)>1
  SS = varargin{CSargpos(2)};
else
  SS = symmetry;
end
