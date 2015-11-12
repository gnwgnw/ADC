function [ vector ] = shift( vector, shift )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if shift > 0
    temp(1:shift) = vector(1);
    temp = temp';
    vector = [temp; vector(1:end-shift)];
elseif shift < 0
    shift = -shift;
    temp(1:shift) = vector(end);
    temp = temp';
    vector = [vector(shift+1:end); temp];
end

end

