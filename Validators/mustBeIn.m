function mustBeIn(A,B)
%MUSTBEIN Validate that value is in specified set
%   MUSTBEIN(A,B) throws an error if A is not in B, which can be any type of iterable and must be cell for non-scalar A.

% Copyright (C) 2025 by Pietro Bozzo
%
% This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.

err = true;

if iscell(A)
  error('mustBeIn:inputClass','Value of type cell is not supported')
end

% compare A with every element of B
if iscell(B)
  for i = 1 : numel(B)
    % check class and size
    if isa(A,class(B{i})) && numel(size(A))==numel(size(B{i})) && all(size(A)==size(B{i}),'all')
      % check values, also NaNs and <missing>
      if all(A==B{i} | (ismissing(A) & ismissing(B{i})),'all')
        err = false;
        break
      end
    end
  end
else
  % A must be scalar
  err = ~(isscalar(A) && isa(A,class(B)) && (any(A==B,'all') || (ismissing(A) && any(ismissing(B),'all'))));
end

if err
  if numel(B) > 5 || (iscell(B) && (any(cellfun(@(x) length(x),B)>1) || any(cellfun(@iscell,B))))
    msg = "in specified set";
  else
    msg = "one of:";
    if iscell(B)
      for i = 1 : numel(B)
        if isnumeric(B{i}) && isempty(B{i})
          msg = msg + " []";
        elseif isstring(B{i}) && isempty(B{i})
          msg = msg + " <empty_string>";
        else
          msg = msg + " " + string(B{i});
        end
      end
    else
      msg = msg + strjoin(string(B)," ");
    end
  end
  error('mustBeIn:notIn',"Value must be "+msg)
end