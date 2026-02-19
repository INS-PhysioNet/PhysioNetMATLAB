function varargout = runBatch(batch_file,func,args,opt)
% runBatch Run a routine on multiple sessions
%
% arguments:
%     batch_file    char, path to text file, where each line contains the path to a session's xml file and optional arguments and comments (see usage)
%     func          function handle, 'func' must accept a session from 'batch_file' as its first argument and is called once for each session
%     args          (n_session,n_args) cell, i-th row contains optional additional arguments passed to func for i-th session; a single row can
%                   be given for all sessions
%
% name-value arguments:
%     ignore_args   logical = false, if true, ignore optional arguments written in 'batch_file'
%     verbose       logical = true, if true, log batch progress to console
%
% output:
%     varargout     (1,n_out_func) of (n_sessions,1) cell, i-th element of varargout is a cell array containing all i-th outputs of func for
%                   every session; outputs of func can be caught separately when calling runBatch (see usage)
%
% usage:
%
%     let batch file, named 'my_batch.txt', contain:
%         path/to/session1.xml
%         path/to/session2.xml % comment
%         % path/to/session3.xml this session is commented and will be ignored
%         path/to/session4.xml %comment
%
%     function myFunction has signature:
%         [a,b] = myFunction(session,c,d)
%
%     runBatch can be used as follows:
%         args = {c_value,d_value};
%         [a_result,b_result] = runBatch('my_batch.txt',@myFunction,args,verbose=true);
%
%     Name-Value arguments of func can be passed as:
%         args = {arg1,arg2,'NameValueArg1',Value1,'NameValueArg2',Value2};

% Copyright (C) 2025 by Pietro Bozzo
%
% This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.

% TO IMPLEMENT: error log saved in workspace, indeces of ok sessions

arguments
    batch_file (1,:) char
    func (1,1) function_handle
    args (:,:) cell = {}
    opt.ignore_args {mustBeLogical} = false
    opt.sessions = []
    opt.verbose (1,1) logical = true
end

% parse batch file
[sessions,extra_args] = readBatchFile(batch_file);
if ~isempty(opt.sessions)
  sessions = sessions(opt.sessions);
  extra_args = extra_args(opt.sessions);
end

% validate optional arguments
arg_ind = cell(numel(sessions),1);
if size(args,1) == 1
  [arg_ind{:}] = deal(1);
elseif ~isempty(args)
  if size(args,1) ~= numel(sessions)
    error('runBatch:argsSize','Arguments ''args'' must have one row for each session in batch file')
  end
  for i = 1 : numel(sessions)
    arg_ind{i} = i;
  end
end

% run routine
opt.verbose && fprintf(1,"\nStarting Batch, "+string(datetime)+" \n\n");
n_outs = nargout(func);
% set up batch output
varargout = cell(1,n_outs);
[varargout{:}] = deal(cell(numel(sessions),1));
errors = 0;
for i = 1 : numel(sessions)
  % log progress to console
  opt.verbose && fprintf(1,'Batch progress: '+sessions(i)+', '+string(i)+' out of '+string(numel(sessions))+'\n');

  % output of this iteration
  output = cell(n_outs,1);
  try
    if opt.ignore_args
      [output{:}] = func(sessions(i),args{arg_ind{i},:});
    else
      [output{:}] = func(sessions(i),args{arg_ind{i},:},extra_args{i}{:});
    end
  catch except
    errors = errors + 1;
    fprintf(2,'Error in session %s\n',sessions(i))
    fprintf(2,'%s\nStacktrace:\n\n',except.message)
    for j = 1 : length(except.stack)
      fprintf(2,'Error in %s (line %d)\n',except.stack(j).name,except.stack(j).line)
    end
    fprintf(2,'\n')
  end

  % assign session outputs, empty if an error occurred
  for j = 1 : n_outs
    varargout{j}{i} = output{j};
  end

  opt.verbose && fprintf(1,'\n');
end

opt.verbose && fprintf(1,'Batch completed with %d errors\n',errors);