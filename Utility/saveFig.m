function status = saveFig(fig,file_name,format,opt)
% saveFig Save figure to file
%
% arguments:
%     fig          figure handle, figure to save
%     file_name    string, file name to save figure
%     format       (n_formats,1) string, file types
%
% name-value arguments:
%     res          double = 300, image resolution
%     pause        double = 0, pause time before saving, useful to allow MATLAB to render figures before saving
%
% output:
%     status       logical, always true; necessary to allow the syntax:
%
%                  >> logical_flag && saveFig(fig,file_name,format);
%
%                  which will save the figure only if logical_flag is true

% Copyright (C) 2025 by Pietro Bozzo
%
% This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.

arguments
  fig (1,1) matlab.ui.Figure
  file_name (1,1) string
  format (:,1) string
  opt.res (1,1) {mustBeNumeric,mustBeNonnegative} = 300
  opt.pause (1,1) {mustBeNumeric,mustBeNonnegative} = 0
end

% force graphics update before save  
drawnow

if opt.pause ~= 0
  pause(opt.pause)
end

% save in all formats
for fmat = format'

  if fmat == "svg"
    % remove white background from figure and axes
    set(findall(fig,'type','axes'),'Color','none')
    fig.Color = 'none';
  end

  exportgraphics(fig,file_name+"."+fmat,'Resolution',opt.res,'BackgroundColor','none');

  if fmat == "svg"
    % restore white backgrounds
    set(findall(fig,'type','axes'),'Color','white')
    fig.Color = 'white';
    disp('This warning can be safely ignored, exported image has no background :)')
  end

end

status = true;