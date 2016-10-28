function varargout = call_extern(prg,varargin)
% execute extern program with arguments
%
% Syntax
%   varargout = call_extern(prg,variable_name,variable_value,...,flags,....)
%
% Input
%  prg            - command to be executed
%  varaiable_name - name of a variable
%  varaiable_name - value of a variable
%
% Flags
%  SILENT
%  VERBOSE
%  EXTERN
%  INTERN
%
% Output
%  varagout - list of output parameters
%

% check input
% -----------
if ispc, mtex_ext = '.exe';else mtex_ext = '';end

arch = getMTEXpref('architecture');
prgFull = fullfile(mtex_path,'c','bin',arch,prg);

if ~exist([prgFull,mtex_ext],'file')
  error('  Can not find file "%s" at directory \n   %s',[prg,mtex_ext],...
    fullfile(mtex_path,'c','bin',arch));
end

mtex_tmppath = getMTEXpref('tempdir',tempdir);

% local flags
inline = 0;
verbose = 0;
suffix = int2str(100*cputime);
[path, name] = fileparts(prgFull);
name = [name,suffix];
iname = cell(1,length(varargin)+1);

% generate parameter file
% -----------------------
fid = fopen(fullfile(mtex_tmppath,[name '.txt']),'w');
for i=1:nargin-1

  if isempty(iname{i}) && ~isempty(inputname(i+1))
    iname{i} = inputname(i+1);
  elseif strcmpi(varargin{i},'SILENT')
    continue;
  elseif strcmpi(varargin{i},'VERBOSE')
    verbose = 1;
    continue;
  elseif strcmpi(varargin{i},'EXTERN')
    inline = 0;
    continue;
  elseif strcmpi(varargin{i},'INTERN')
    inline = 1;
    continue;
  elseif isempty(iname{i}) && isa(varargin{i},'char')
    iname{i+1} = varargin{i};
    continue;
  elseif isempty(iname{i})
    error('wrong format - you may have passed an expression and not a variable');
  end

  if isempty(varargin{i})

    iname{i} = [];

  elseif issparse(varargin{i})

    vdisp(verbose,['  write files for sparse matrix ',iname{i}]);

    [jc,ir,pr] = save_sparse(varargin{i});
    fprintf(fid,'%s_jc: ',iname{i});
    fprintf(fid,[mtex_tmppath,filesep,name,'_',iname{i},'_jc.dat\n']);
    fdata = fopen([mtex_tmppath,name,'_',iname{i},'_jc.dat'],'w');
    fwrite(fdata,jc,'int32');
    fclose(fdata);
    fprintf(fid,'%s_ir: ',iname{i});
    fprintf(fid,[mtex_tmppath,name,'_',iname{i},'_ir.dat\n']);
    fdata = fopen([mtex_tmppath,name,'_',iname{i},'_ir.dat'],'w');
    fwrite(fdata,ir,'int32');
    fclose(fdata);
    fprintf(fid,'%s_pr: ',iname{i});
    fprintf(fid,[mtex_tmppath,name,'_',iname{i},'_pr.dat\n']);
    fdata = fopen([mtex_tmppath,name,'_',iname{i},'_pr.dat'],'w',mtex_machineformat);
    fwrite(fdata,pr,'double');
    fclose(fdata);

  elseif inline

    vdisp(verbose,['  write inline: ',iname{i}]);
    fprintf(fid,'%s: ',iname{i});

    if isa(varargin{i},'int32')
      fprintf(fid,'%d ',varargin{i});
    elseif isa(varargin{i},'uint32')
      fprintf(fid,'%d ',varargin{i});
    elseif isa(varargin{i},'double')
      fprintf(fid,'%.4E ',varargin{i});
    elseif isa(varargin,'char')
      fprintf(fid,'%s ',varargin{i});
    end
    fprintf(fid,'\n');
    iname{i} = [];

  else
    vdisp(verbose,['  write extern: ',iname{i}]);
    fprintf(fid,'%s: ',iname{i});

    d = varargin{i};
    s = whos('d');
    fprintf(fid,'%s\n',[mtex_tmppath,name,'_',iname{i},'.dat']);
    fdata = fopen([mtex_tmppath,name,'_',iname{i},'.dat'],'w');
    fwrite(fdata,d,s.class);
    fclose(fdata);
  end
end

for i=1:nargout
  fprintf(fid,'%s\n',['res',int2str(i),': ',mtex_tmppath,name,'_res',int2str(i),'.dat']);
end
fclose(fid);


% run external program
% -----------------
vdisp(verbose,['  call ',prgFull]);
if isunix
  cmd = [getMTEXpref('prefix_cmd'),prgFull,' ',mtex_tmppath,name,...
    '.txt 2>> ',getMTEXpref('logfile'),getMTEXpref('postfix_cmd')];
else

  %enclose whitespaces into parenthis
  prgFull = regexprep(prgFull,'[^\\]*\s+[^\\]*','"$0"');

  cmd = [getMTEXpref('prefix_cmd'),prgFull,'.exe ',mtex_tmppath,name,...
    '.txt',getMTEXpref('postfix_cmd')];
end
if check_option(varargin,'silent') && (isunix || ispc), cmd = [cmd,' >> ',getMTEXpref('logfile')]; end

if getMTEXpref('debugMode')
  disp('Stopped because of "debug_mode"');
  disp(['Files written to ',mtex_tmppath,name]);
  fprintf('You may want to execute the command\n\n%s\n\n',cmd);
  disp('hit enter if finished')
  pause
else
  if strcmp(arch,'maci64')
    env = getenv('DYLD_LIBRARY_PATH');
    setenv('DYLD_LIBRARY_PATH', fullfile(mtex_path,'c','bin','maci64'));
  end
  status = system(cmd,'-echo');
  if strcmp(arch,'maci64'), setenv('DYLD_LIBRARY_PATH', env); end
  if status ~= 0
    error(['  Error running external program: %s ' ...
    '<a href="matlab:edit %s">show logfile</a>'],...
      prg, getMTEXpref('logfile'));
  end
end

% get output
% ----------
varargout = readdata(name,verbose,nargout);

% check output
if isempty(varargout{1}) || length(varargout) < nargout
  error('Error running external program:\n\n %s\n\n To few output files.',cmd);
end

cleanup(name,verbose);

end % function


% retrieve information
function out = readdata(name,verbose,nout)

mtex_tmppath = getMTEXpref('tempdir',tempdir);
for i=1:nout
  vdisp(verbose,['  read result file ',int2str(i)]);
  fdata = fopen([mtex_tmppath,name,'_res',int2str(i),'.dat'],'r');
  if fdata == -1
    out{1} = [];
    return
  end
  out{i} = fread(fdata,'double'); %#ok<AGROW>
  fclose(fdata);
end
end

% cleanup
function cleanup(name,verbose)

mtex_tmppath = getMTEXpref('tempdir',tempdir);
% delete parameter files
vdisp(verbose,'  delete datafiles:')

state = recycle;
recycle('off')
delete([mtex_tmppath,name,'.txt']);
delete([mtex_tmppath,name,'_*.dat']);
delete([mtex_tmppath,name,'_res*.dat']);
recycle(state);

end

function vdisp(verbose,s)
if verbose, vdisp(verbose,s);end
end
