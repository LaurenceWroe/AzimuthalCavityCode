function [combined,scales,measured]=normalise_uniform_maps(maps,cfg)
% Fit the signed normal bore harmonic, then scale the full complex E/B map.
if numel(maps)~=numel(cfg.normalise_orders) || numel(maps)~=numel(cfg.target_g_MV_per_m)
    error('Azimuthal:InvalidConfig','One normalisation order and target strength are required per map.');
end
theta=(0:719)'*2*pi/720; a=cfg.bore_radius_m*1000;
fields={'E1_Mat','E2_Mat','E3_Mat','B1_Mat','B2_Mat','B3_Mat'};
combined=maps{1}; scales=zeros(1,numel(maps)); measured=scales;
for j=1:numel(maps)
    map=maps{j};
    if ~isequal(map.a1,combined.a1) || ~isequal(map.a2,combined.a2) || ~isequal(map.a3,combined.a3)
        error('Azimuthal:GridMismatch','Superposed maps must use identical Cartesian grids.');
    end
    z=mean(map.axes_mm{3}([1 end]));
    ez=interpn(map.axes_mm{1},map.axes_mm{2},map.axes_mm{3},map.E3_Mat, ...
               a*cos(theta),a*sin(theta),z*ones(size(theta)),'linear');
    if any(~isfinite(ez)), error('Azimuthal:MapDomain','Bore sampling circle leaves the map or intersects a wall.'); end
    m=cfg.normalise_orders(j);
    G=2*mean(ez.*cos(m*theta));
    skew=2*mean(ez.*sin(m*theta));
    if abs(G)<1e-12, error('Azimuthal:ZeroMultipole','Map has no resolvable normal m=%d component.',m); end
    if abs(skew/G)>0.01
        error('Azimuthal:RotatedMap','Map m=%d has a significant skew component; align the CST map before use.',m);
    end
    measured(j)=G/besselj(m,2*pi*cfg.frequency_Hz/299792458*cfg.bore_radius_m)/1e6;
    scales(j)=cfg.target_g_MV_per_m(j)/measured(j);
    for k=1:numel(fields)
        if j==1, combined.(fields{k})=map.(fields{k})*scales(j);
        else, combined.(fields{k})=combined.(fields{k})+map.(fields{k})*scales(j); end
    end
end
end
