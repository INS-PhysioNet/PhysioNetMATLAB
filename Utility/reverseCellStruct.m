function structure = reverseCellStruct(x,field_f,cat_f,opt)
% reverseCellStruct Given a cell array of structs sharing the same fields, concatenate them into fields of a struct
%
% arguments:
%     x          (n,1) cell, each cell containing a struct
%     field_f    function handle, optional, applied to each field value before concatenation; must accept and return one input
%     cat_f      function handle, optional, called to concatenate field values across cells; must accept a cell array of
%                   field values and return a concatenated result, default is @(y) vertcat(y{:})

% Copyright (C) 2025 by Pietro Bozzo
%
% This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.

arguments
  x cell
  field_f function_handle = @(x) x
  cat_f function_handle = @(x) vertcat(x{:})
  opt.fields (1,:) string = string.empty
end

x = x(~cellfun(@isempty, x));

if isempty(x)
  structure = struct;
  return
end

if isempty(opt.fields)
  opt.fields = string(fieldnames(x{1}))';
end

try
  for field = opt.fields
    temp = cellfun(@(y) field_f(y.(field)),x,'UniformOutput',false);
    structure.(field) = cat_f(temp);
  end
catch ME
  throw(ME)
end