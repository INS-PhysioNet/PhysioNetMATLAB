function s = structFun(func,a,b,opt)
% structFun Extension of built-in structfun to two input structures, apply func(x,y) to each field of 'a' and 'b'
%
% arguments:
%     func             function handle, must have signature c = func(x) if 'b' is not provided, c = func(x,y) otherwise
%     a                struct
%     b                struct = struct.empty, optional, all fields of 'a' must also be fields of 'b'
%
% name-value arguments:
%     UniformOutput    logical = true, concatenate the outputs of 'func' for each field and return that instead of a struct
%     fields           (1,:) string = string.empty, fields to operate on, default is all fields of 'a'
%
% output:
%     concat           struct, each field contains the output of 'func' for the respective field of 'a' and 'b';
%                      if UniformOutput is true, 'concat' is an array

arguments
  func {mustBeA(func,'function_handle')}
  a {mustBeA(a,'struct')}
  b {mustBeA(b,'struct')} = struct.empty
  opt.UniformOutput {mustBeLogical} = true
  opt.fields (1,:) string = string.empty
end

% keep requested fields
if ~isempty(opt.fields)
  for field = opt.fields
    sub_a.(field) = a.(field);
  end
  a = sub_a;

  if ~isempty(b)
    for field = opt.fields
      sub_b.(field) = b.(field);
    end
    b = sub_b;
  end
  
end

if isempty(b)
  % built-in call of structfun
  try
    s = structfun(func,a,'UniformOutput',opt.UniformOutput);
  catch ME
    throw(ME)
  end

else
  for field = fieldnames(a)'
    s.(field{1}) = func(a.(field{1}),b.(field{1}));
  end

  if opt.UniformOutput && all(structfun(@isscalar,s))
    s = structfun(@(x) x,s);
  end

end