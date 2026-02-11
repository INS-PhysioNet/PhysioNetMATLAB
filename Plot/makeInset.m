function ax = makeInset(a,b,c,d,varargin,opt)
% makeInset Add inset to axes
%
% arguments:
%     a           double, factor for original x position
%     b           double, factor for original y position
%     c           double, factor for original width, if NaN, inset will be squared
%     d           double, factor for original heigth, if NaN, inset will be squared
%
% name-value arguments:
%     ax
%
%     varargin    all extra arguments are passed to adjustAxes

arguments
  a (1,1)
  b (1,1)
  c (1,1)
  d (1,1)
end
arguments (Repeating)
  varargin
end
arguments
  opt.ax (1,1) = gca
end

% force graphics update
drawnow

pos = get(opt.ax,'Position');
pos = pos.*[1,1,c,d] + pos([3,4,3,4]).*[a,b,0,0];

nan_ind = 0;
if isnan(pos(3))
  pos(3) = pos(4);
  nan_ind = 3;
end
if isnan(pos(4))
  pos(4) = pos(3);
  nan_ind = 4;
end

ax = axes('Position',pos);
if nan_ind ~= 0
  set(ax,'Units','centimeters')
  pos = get(ax,'Position');
  pos(nan_ind) = pos(7-nan_ind);
  set(ax,'Position',pos);
  set(ax,'Units','normalized')
end

adjustAxes(ax,varargin{:})