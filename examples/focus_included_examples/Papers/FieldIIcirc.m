% Script to evaluate the times and errors for the CW pressure generated by
% a circular piston using the Field II method.
% Refer: http://www.es.oersted.dtu.dk/staff/jaj/field
clc;
fprintf('==============================[ FieldIIcirc.m ]==============================\n\n');
fprintf('This example evaluates the times and errors for the continuous-wave pressure\n');
fprintf('generated by a circular transducer using Field II. You must have Field II\n');
fprintf('installed to run this example.\n\n')

field_init(0);

% datestr(now)
f0 = 1e6; % excitation frequency
fs = 200e6; % sampling frequency unit:Hz
atten = 0; % no attenuation
soundspeed = 1500; % m/s
lambda = soundspeed / f0; % wavelength
radius = 5 * lambda; % transducer radius

% create the transducer object for reference simulations
transducer=get_circ(radius,[0 0 0], [0 0 0]);

% create the data structure that specifies the attenuation value, etc.
define_media

% define the computational grid
xmin = 0;
xmax = 1.5 * radius;
ymin = 0;
ymax = 0.01;
zmin = 0.01*radius^2 / lambda;
zmax = radius^2 / lambda;

nx = 31;
ny = 61;
nz = 31;

dx = xmax / (nx - 1);
dz = zmax / (nz - 1);
ps = set_coordinate_grid([dx 0.1 dz],xmin,xmax,ymin,ymax,zmin,zmax);
x = xmin:dx:xmax;
y = ymin:0.1:ymax;
z = zmin:dz:zmax;

% generate the reference pressure field
ndiv = 200;
dflag = 0;
tic
pref=fnm_call(transducer,ps,lossless,ndiv,f0,dflag);
toc

% evaluate the times and errors as a function of the number of abscissas
ndivmtx = 20:10:100;
timevectorFieldIIrect = zeros(1, length(ndivmtx));
errorvectorFieldIIrect = zeros(1, length(ndivmtx));
for in = 1:length(ndivmtx),
%    ndiv
    ndiv = ndivmtx(in);
	tic
    p = FieldII_PressCirc(f0,fs,soundspeed,radius,x,y,z,ndiv);
	timevectorFieldIIcirc(in) = toc;
	errorvectorFieldIIcirc(in) = max(max(abs(pref - p)))/max(max(abs(pref)));
end


% show the pressure field
figure(1)
mesh(z, x, abs(squeeze(pref))/max(max(abs(squeeze(pref)))))
xlabel('axial distance (m)')
ylabel('radial distance (m)')
zlabel('normalized pressure')

% plot the times
figure(2)
plot(timevectorFieldIIcirc)
ylabel('time (s)')
xlabel('number of subdivisions')

% plot the errors
figure(3)
semilogy(errorvectorFieldIIcirc)
xlabel('number of subdivisions')
ylabel('normalized error')

% plot the errors as a function of time
figure(4)
semilogy(timevectorFieldIIcirc, errorvectorFieldIIcirc)
xlabel('time (s)')
ylabel('normalized error')

datestr(now)

field_end;