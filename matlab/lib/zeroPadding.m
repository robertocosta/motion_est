function out = zeroPadding(in)
global wx
global wy
[h, w] = size(in);
out = [zeros(h+2*wy,wx),...
    [zeros(wy,w);in;zeros(wy,w)],...
    zeros(h+2*wy,wx)];