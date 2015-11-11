function [ C ] = replace_component( C, val, comp )
%REPLACE_COMPONENT Summary of this function goes here
%   Detailed explanation goes here

if strcmp(comp, 'X')
    i = imag(C);
    C = complex(val, i);
elseif strcmp(comp, 'Y')
    r = real(C);
    C = complex(r, val);
end

end

