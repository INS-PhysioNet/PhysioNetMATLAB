function concat = structCat(str,dim,opt)
% structCat Concatenate field values of a struct
%
% arguments:
%     str       struct
%     dim       int = 1, dimension of field values along which to concatenate
%
% name-value arguments:
%     fields    (1,:) string = string.empty, fields to operate on, default is all fields of 'str'
%
% output:
%     concat    concatenated values

arguments
  str (1,1) struct
  dim (1,1) {mustBeInteger,mustBePositive} = 1
  opt.fields (1,:) string = string.empty
end

if ~isempty(opt.fields)
  for field = opt.fields
    sub_struct.(field) = str.(field);
  end
  str = sub_struct;
end

str = struct2cell(str);
concat = cat(dim,str{:});