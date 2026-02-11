function adjustAxes(axes,varargin)
% adjustAxes Adjust axes properties using default values
%
% arguments:
%     varargin    list of 'property', 'value' pairs, used as name-value arguments
%                 to set axis properties (NOTE: property='value' syntax is not
%                 supported)
%                 to leave a property unchanged, specify 'property',missing

% Copyright (C) 2025 by Pietro Bozzo
%
% This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.

% NOTE see AdjustAxes for interesting feature on passing fig AS ARG AND SETTING XLim

% validate input
if mod(numel(varargin),2) ~= 0
  error('adjustAxes:ArgNumber','Number of arguments must be even')
end

% set default values
args = {'FontSize', 'TitleFontSizeMultiplier', 'TitleFontWeight', 'TickDir', 'Color', 'Box';
        12,         1.3,                       'normal',          'out',     [1,1,1], 'off'};
if isa(axes,'matlab.graphics.axis.PolarAxes')
  args1 = {'LineWidth';
           1.3};
  args = [args,args1];
else
  args1 = {'LineWidth', 'LabelFontSizeMultiplier', 'XColor', 'YColor', 'ZColor';
           1.7,         1.2,                       [0,0,0],  [0,0,0],  [0,0,0]};
  args = [args,args1];
end

% parse input
varg_to_keep = true(size(varargin));
for i = 1 : 2 : numel(varargin)

  % validate input
  if ~isstring(varargin{i}) && ~ischar(varargin{i})
    error('adjustAxes:NotProperty',"Argument in position " + num2str(i) + ' is not a property')
  end

  % check if property is in args
  ind = ismember(args(1,:),varargin{i});

  if isa(varargin{i+1},'missing')
    % do not set property, remove it from args
    args = args(:,~ind);
    % remove from varargin
    varg_to_keep(i:i+1) = false;
  elseif any(ind)
    % set property
    args{2,ind} = varargin{i+1};
    % remove from varargin
    varg_to_keep(i:i+1) = false;
  end
end
% remove from varargin properties found in args
varargin = varargin(varg_to_keep);

for i = 1 : numel(axes)
  set(axes(i),args{:},varargin{:})
  hold(axes(i),'on')
end