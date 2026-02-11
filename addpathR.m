function addpathR(path)
% addpathR Add to path a folder and all of its subfolders, except for .git, private, resources, and obsolete folders
%
% arguments:
%     path      full path to target folder
%
% output:
%     <none>    

% Copyright (C) 2025 by Pietro Bozzo
%
% This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.

% add target to path
addpath(path)

% list subfodlers
d = dir(path);
subfolders = d([d(:).isdir]);

% discard '/.', '/..', '/.git', '/private', '/resources', and '/obsolete' folders (and their subfolders)
subfolders = subfolders(~ismember({subfolders(:).name},{'.','..','.git','private','resources','obsolete'}));
% discard method folders (those starting with @)
subfolders = subfolders(cellfun(@(x) x(1),{subfolders(:).name}) ~= '@');
% discard namespace folders (those starting with +)
subfolders = subfolders(cellfun(@(x) x(1),{subfolders(:).name}) ~= '+');

% add subfolders to path
for i = 1 : size(subfolders,1)
  addpathR(append(path,'/',subfolders(i).name))
end