function inset_ax = makeInset(a,b,c,d,varargin,opt)
% makeInset Add inset to axis
%
% arguments:
%     a, b, c, d    double, multiplicative factors for original axis Position, i.e., [a0, b0, c0, d0]: inset will have Position:
%                     [a0+a*c0, b0+b*d0, c*c0, d*d0]
%                   thus, a and b control the position of the origin of the inset, while c and d control its heigth and width
%                   if either c or d is NaN, the inset will be square
%
% repeating arguments:
%     varargin      all extra arguments are passed to adjustAxes() (NOTE: name='value' syntax is not supported for varargin)
%
% name-value arguments:
%     ax            axis to add inset to, default is gca()
%
% examples:
%
%     % make an inset spanning the top-right quadrant of current axis
%     >> makeInset(0.5,0.5,0.5,0.5);
%
%     % make an inset spanning the top half of current axis
%     >> makeInset(0,0.5,1,0.5);
%
%     % make an inset located east of current axis, slightly suprassing its right border
%     >> makeInset(0.7,0.3,0.4,0.4);

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

inset_ax = axes('Position',pos);
if nan_ind ~= 0
  orig_units = inset_ax.Units;
  set(inset_ax,'Units','centimeters')
  pos = get(inset_ax,'Position');
  pos(nan_ind) = pos(7-nan_ind);
  set(inset_ax,'Position',pos);
  set(inset_ax,'Units',orig_units)
end

adjustAxes(inset_ax,varargin{:})