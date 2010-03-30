function [chat T Tv n] = c_hat(varargin)



if isa(varargin{1},'EBSD')
  varargin{1} = get(varargin{1},'orientations','checkPhase',varargin{:});
end

if isa(varargin{1},'orientation')
  n = numel(varargin{1});
  [qm T Tv kappa q] = mean(varargin{:},'approximated');
  [T nd]=sort(T,'descend');
  Tv = Tv(:,nd);
  x = reshape(double(q),[],4);
end


chat = zeros(size(Tv));
for i=1:size(Tv,1)
  for j=1:size(Tv,2)
   chat(i,j) = ((x*Tv(:,i)).^2)' * ((x*Tv(:,j)).^2);
  end
end

chat = chat./n;