function map=generate_example_map(output_file, order)
% Small ideal TM_m10 pillbox map for SOFTWARE DEMONSTRATION, not a paper map.
% Follows the spatial field/phasor convention of archived F_MultipoleCav.m.
% No beam pipes, fringe fields, walls or couplers are represented.
if nargin<1, output_file=''; end
if nargin<2, order=0; end
if ~ismember(order,[0 4 6]), error('Azimuthal:InvalidOrder','Demo supports m=0,4,6.'); end
frequency=3e9; c=299792458; k=2*pi*frequency/c; amplitude=1e5;
[x,y,z]=ndgrid(-60:10:60,-60:10:60,0:2.5:50);
r=hypot(x,y)/1000; theta=atan2(y,x);
ez=amplitude*besselj(order,k*r).*cos(order*theta);
br=1i*amplitude*order/(2*pi*frequency)*besselj(order,k*r)./r.*sin(order*theta);
bt=1i*amplitude/c*(besselj(order-1,k*r)-besselj(order+1,k*r))/2.*cos(order*theta);
br(r==0)=0; bt(r==0)=0;
map.a1=x; map.a2=y; map.a3=z;
map.E1_Mat=zeros(size(x)); map.E2_Mat=zeros(size(x)); map.E3_Mat=ez;
map.B1_Mat=br.*cos(theta)-bt.*sin(theta);
map.B2_Mat=br.*sin(theta)+bt.*cos(theta); map.B3_Mat=zeros(size(x));
map.d1=10; map.d2=10; map.d3=2.5; map.loc_x=-60; map.loc_y=-60;
map.metadata.kind='analytic_demo_not_paper_data';
map.metadata.order=order; map.metadata.frequency_Hz=frequency;
map.metadata.amplitude_V_per_m=amplitude;
map.metadata.description='Ideal pillbox spatial fields, truncated at z=0,50 mm; no pipes/fringes/walls/coupler.';
if ~isempty(output_file)
    if exist(output_file,'file'), error('Azimuthal:OutputExists','Refusing to overwrite %s',output_file); end
    save(output_file,'-struct','map','-v7');
end
end
