function mustBe2Or3D(A,varargin)
%MUSTBE2OR3D Validate that value is two- or three-dimensional array
%   MUSTBE2OR3D(A) throws an error if A is not two- or three-dimensional

% Copyright (C) 2025 by Pietro Bozzo
%
% This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.

for i = 1 : length(varargin)
    if numel(varargin{i}) ~= 1 || ~isnumeric(varargin{i}) || mod(varargin{i},1) ~= 0 || varargin{i} < -1
        error('Dimensions must be integers greater then or equal to -1')
    end
end

disp(numel(varargin))

if ndims(A) > numel(varargin) || 

end

if (~isnumeric(A)&&~islogical(A)) || ~all(A(A~=0)==1)
    error('mustBeLogical:notLogical','Value must be logical.')
end