function [press]=FieldII_PressCirc(f0, fs, c, R, x, y, z, ndiv)
% FieldII_PressCirc Calculates the continuous-wave pressure generated by
% the FIELD II program for a circular piston
% Refer: http://www.es.oersted.dtu.dk/staff/jaj/field
%
%   Usage: [press]=FieldII_PressCirc(f0, fs, c, width, height, x, y, z, ndiv)
%   f0 - The central frequency of the pulse. Unit: Hz
%   fs - The sampling frequency. Unit: Hz
%   c  - The speed of sound. Unit: m/s
%   R - The radius of the circular source. unit:m
%   x - The x grid of the observation grid. Unit: m
%   y - The y grid of the observation grid. Unit: m
%   z - The z grid of the observation grid. Unit: m
%   ndiv - Number of subdivisions on the radius distance
%
%   Copyright 2009 MSU
%   $Vision: 1.0 $  $Date: 2009/05/19 $

% use rectangular
set_field('use_rectangles',1);
set_field('use_triangles',0);
% set the sampling frequency and the speed of sound
set_field('c',c);
set_field('fs',fs);
ele_size = R/ndiv;
% Define the transducer
Th = xdc_piston (R,ele_size);
xdc_focus(Th,0,[0 0 10000]);
%%########### This part for the impulse response+
xlen = max(size(x,1),size(x,2));
ylen = max(size(y,1),size(y,2));
zlen = max(size(z,1),size(z,2));
for ix = 1:xlen
    for iy = 1:ylen
        for iz = 1:zlen
            points = [x(ix)  y(iy)  z(iz)];
            [h,start_time] = calc_h(Th,points); 
            t = start_time:1/fs:start_time+(length(h)-1)/fs;
            t = t';          
            F_impulse = sum(h.*exp(-i*2*pi*f0*t))*1/fs;   %% 1/fs is the interval of integrand  
            press(ix,iy,iz) = F_impulse;    
        end
    end
end
% just normalized by 'rho*c'
%  press_field = 2*pi*f0*press_field*fs;
press = 2*pi*press*f0*1000*1j;