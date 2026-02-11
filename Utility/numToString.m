function converted = numToString(numeric)
% numToString Customized numeric to string casting which returns scalar empty string for empty input, instead of 
%   empty string array
%
% arguments:
% numeric {mustBeNumeric}    numeric to cast to string

arguments
    numeric {mustBeNumeric}
end

if isempty(numeric)
    converted = "";
else
    converted = string(numeric);
end