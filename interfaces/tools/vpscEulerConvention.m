function out = vpscEulerConvention(in)
% the Euler angle convention a VPSC file names by a letter, and back
%
% Syntax
%   name = vpscEulerConvention('K')        % 'Kocks'
%   letter = vpscEulerConvention('Bunge')  % 'B'
%
% See also
% loadODF_VPSC orientation/export_VPSC

t = {'B','Bunge'; 'K','Kocks'; 'R','Roe'};

i = find(strcmpi(t(:,1),in),1);
if ~isempty(i), out = t{i,2}; return; end

if strcmpi(in,'zxz'), in = 'Bunge'; end
i = find(strcmpi(t(:,2),in),1);
assert(~isempty(i),'MTEX:export_VPSC',['VPSC stores Euler angles in the Bunge, the ' ...
  'Kocks or the Roe convention. %s is none of them.'],char(in));
out = t{i,1};

end
