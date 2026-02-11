function status = saveMatrix(A,file,labels)
% saveMatrix Save content of matrix A in a text file, prepending a metadata header
%
% arguments:
%     A         matrix to save
%     file      string, file name to save matrix to
%     labels    string, repeating, names of columns
%
% output:
%     status    logical, always true; necessary to allow the syntax:
%
%               >> logical_flag && saveMatrix(A,file,label1,label2,<other_labels>);
%
%               which will save A only if logical_flag is true;
%               first line of file is:
%               % columns : label1, label2, <other_labels>

% Copyright (C) 2025 by Pietro Bozzo
%
% This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.

arguments
  A
  file (1,1) string
end
arguments (Repeating)
  labels (1,1) string
end

% save result, adding a header to describe file content
header = ["% columns : " + strjoin(cellstr(labels),', '), ...
          "% to read this file on MATLAB:    >> readmatrix(file_path,FileType='text',CommentStyle='%');"];
writelines(header,file);
writematrix(A,file,FileType='text',WriteMode='append')

status = true;