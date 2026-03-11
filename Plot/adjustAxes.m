function adjustAxes(axes,varargin,opt)
% adjustAxes Adjust axes properties using default values
%
% arguments:
%     axes        axes to modify
%
% repeating arguments:
%     varargin    all extra arguments are passed to set() (NOTE: name='value' syntax is not supported for varargin)
%                 to leave a property unchanged, specify 'Name',missing
%
% name-value arguments:
%     format      string, either 'paper' (default) or 'poster', controls font sizes and lines' width

% Copyright (C) 2025 by Pietro Bozzo
%
% This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.

% NOTE see AdjustAxes for interesting feature on passing fig AS ARG AND SETTING XLim

arguments
  axes
end
arguments (Repeating)
  varargin
end
arguments
  opt.format (1,1) string {mustBeMember(opt.format,["paper","poster"])} = "paper"
end

% validate input
if mod(numel(varargin),2) ~= 0
  error('adjustAxes:ArgNumber','Number of name-value arguments must be even')
end

% set default values
if opt.format == "paper"
  fs = 8;
  lw = 1;
  mksz = 20;
  axlw = 1;
  labelfs = 1.125;
else
  fs = 14;
  lw = 1.5;
  mksz = 60;
  axlw = 2;
  labelfs = 1.286;
end
args = {'FontSize',                      fs;
        'TitleFontSizeMultiplier',       1.25;
        'DefaultLineLineWidth',          lw;
        %'DefaultBoxChartLineWidth',      lw; % not yet available in R2025a
        %'DefaultBoxChartMarkerSize',     mksz;
        %'DefaultViolinPlotLineWidth',    lw;
        'TitleFontWeight',               'normal';
        'TickDir',                       'out';
        'Color',                         [1,1,1];
        'Box'                            'off' }';
if isa(axes,'matlab.graphics.axis.PolarAxes')
  args1 = {'LineWidth';
           axlw};
  args = [args,args1];
else
  args1 = {'LineWidth', 'LabelFontSizeMultiplier', 'XColor', 'YColor', 'ZColor';
           axlw,        labelfs,                   [0,0,0],  [0,0,0],  [0,0,0]};
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

  % set tick marks length based on axes size
  old_units = axes(i).Units;
  axes(i).Units = 'pixels';
  position = axes(i).Position;
  axes(i).Units = old_units;
  position = max(position(3),position(4));
  if position > 100
    args = [args,{"TickLength";[0.01,0.01]}];
  else
    args = [args,{"TickLength";[0.02,0.01]}];
  end

  set(axes(i),args{:},varargin{:})
  hold(axes(i),'on')

end