function uvtw = v2d(m,varargin)
% vector3d --> Miller-indece (u,v,w)
%
%% Syntax
%  [u,v,w] = v2d(m)
%
%% Input
%  m - @Miller
%
%% Output
%  u,v,w - integer

%% set up matrix
a = get(m.CS,'axis');
aa = squeeze(double(a(1)));
bb = squeeze(double(a(2)));
cc = squeeze(double(a(3)));
M = [aa,bb,cc];

%% compute Miller indice
mdouble = reshape(double(m),[],3).';

mv = M \ mdouble;

if any(strcmp(Laue(m.CS),{'-3','-3m','6/m','6/mmm'}))
    
  mv(4,:) = mv(3,:);
  mv(3,:) = -(mv(1,:) + mv(2,:))./3;
  [mv(1,:), mv(2,:)] = deal((2*mv(1,:)-mv(2,:))./3,(2*mv(2,:)-mv(1,:))./3);
  
end

%% Find common divisor

mbr = selectMaxbyColumn(abs(mv));
mv = mv * diag(1./mbr);

uvtw = zeros(numel(m),size(mv,1));

for im = 1:numel(m)

  mm = mv(:,im) * (1:20);
  e = sum(abs(mm-round(mm)));
    
  j = find(e<10e-4,1,'first');
    
  if ~isempty(j)
    uvtw(im,:) = round(mm(:,j).');
  else
    uvtw(im,:) = mv(:,im).';    
  end

end




