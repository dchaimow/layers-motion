function y= hrffunc(t,ts,te)
%HRFFUNC  ...
%   Requirements
%
%   Design
%
%   Interfaces
%
%   Discussion
%

% Copyright 2008 Denis Chaimow.
% Created by Denis Chaimow on 19-Dec-2008 23:18:34
% $Id$'

%TODO: Write documentation
%TODO: Implement first version
a1 =      0.0669;
a2 =      0.3158;
n1 =       2.886;
n2 =       4.425;
t1 =       1.729;
t2 =       1.892;

y = zeros(size(t));
for zStim = 1:length(ts) 
    y = y + (a1*(gamcdf((t-ts(zStim)),n1,t1)-a2*gamcdf((t-ts(zStim)),n2,t2)))-...
        (a1*(gamcdf((t-te(zStim)),n1,t1)-a2*gamcdf((t-te(zStim)),n2,t2)));
end
