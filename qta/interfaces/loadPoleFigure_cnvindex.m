function pf = loadPoleFigure_cnvindex(data,sfile,CS,SS,varargin)
% load dubna cnv file
%
%% Syntax
% data = {{fname_1,h_1},{fname_2,h_2},..,{fname_N,h_N}}
% pf = loadPoleFigure_cnvindex(data,sfile,CS,SS,varargin)
%
%% Input
%  fname_i - i--th file name
%  h_i     - indece to the i--th crystal direction in the structure file
%  sfile  - structure file
%  CS, SS - crystal, specimen @symmetry
%
%% Output
%  pf    - vector of @PoleFigure

for i=1:length(data)

  comment = get_option(varargin,'comment',...
    ['Pole figures imported from ',data{i}{1}]);
  
  d = load(data{i}{1});
  d = reshape(d.',72,19);
  
  h_id = data{i}{2};
  
  pf(i) = DubnaPoleFigure(sfile,h_id,d,CS,SS,varargin,...
    'comment',comment); %#ok<AGROW>
  
end
