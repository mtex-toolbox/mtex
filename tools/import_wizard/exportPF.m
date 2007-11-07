function str = exportPF( pn, fn, pf )
%EXPORTPF Summary of this function goes here
%   Detailed explanation goes here

str = ['%% created by importwizard';{''}];

%% specify crystal and specimen symmetries

str = [ str; '%% specify crystal and specimen symmetries';{''}];
cs =get(pf,'CS');
a = getaxes(cs); 
c = norm(a);
a = a./c;
alpha = acos(dot(a(1),a(3)));
beta = acos(dot(a(2),a(3)));
gamma = acos(dot(a(1),a(2)));

axis =  strcat(n2s(c));
angle =  strcat(n2s([alpha beta gamma]));

cs = strrep(char(cs),'"','');

switch cs
    case {'-1','2/m'}
        str = [str; strcat('CS = symmetry(''', cs,''',', axis, ',' , angle, ');')];
    case {'m-3','m-3m'}
        str = [str; strcat('CS = symmetry(''', cs,''');')];
    otherwise
        str = [str; strcat('CS = symmetry(''', cs,''',', axis, ');')];   
end
ss = get(pf,'SS');
str = [ str; strcat('SS = symmetry(''',strrep(char(ss),'"',''), ''');')];

%% specify the file names

pn = strrep(pn,'\','/');
pn = strrep(pn,'./','');

str = [ str; {''};'%% specify file names'; {''};'% path to data files'; ...
  strcat('pname = ''',pn,''';')];

str = [ str; {''};'% file names';'fname = { ...'];

for k = 1:length(fn)
    str = [ str; strcat('[pname,''', fn{k}, '''], ...')];
end
str = [ str; '};'; {''}];

%% specify crystal directions
str = [ str; {'%% specify crystal directions'; 'h = { ...'}];

for k = 1:length(pf)
   m = get( pf(k),'h');
   if any(strcmp(Laue(getCS(pf)),{'-3m','-3','6/m','6/mmm'}))
     str = [ str; strcat('Miller(',n2s(get(m,'h')),',',n2s(get(m,'k')), ...
       ',',n2s(-get(m,'h')-get(m,'k')),',',n2s(get(m,'l')),',CS), ...')];
   else
     str = [ str; strcat('Miller(',n2s(get(m,'h')),',',n2s(get(m,'k')), ...
       ',',n2s(get(m,'l')),',CS), ...')];
   end
end
str = [ str; '};'; {''}];

%% specifiy structural coefficients for superposed pole figures

if length(getc(pf)) > length(pf)

  str = [ str; {'%% specifiy structural coefficients for superposed pole figures';}];
  c = [];
  for k = 1:length(pf)
    c = strcat(c,n2s(get(pf(k),'c')),',');
  end
  str = [ str; strcat('c = {',c(1:end-1),'};'); {''}];
end

%% import the data 

str = [ str; '%% import the data'; {''}];
if length(getc(pf)) > length(pf)
  str = [ str; 'pf = loadPoleFigure(fname,h,CS,SS,''superposition'',c);'];
else
  str = [ str; 'pf = loadPoleFigure(fname,h,CS,SS);'];
end

function s = n2s(n)

s = num2str(n);
s = regexprep(s,'\s*',',');
if length(n) > 1, s = ['[',s,']'];end