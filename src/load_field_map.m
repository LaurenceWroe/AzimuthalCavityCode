function map = load_field_map(path)
% Validate the historical Cartesian map schema before interpolation/tracking.
map = load(path);
required = {'a1','a2','a3','E1_Mat','E2_Mat','E3_Mat', ...
            'B1_Mat','B2_Mat','B3_Mat','d1','d2','d3','loc_x','loc_y'};
for n = 1:numel(required)
    if ~isfield(map,required{n})
        error('Azimuthal:InvalidMap', '%s lacks %s. Use convert_cst_fields.', path, required{n});
    end
end
shape = size(map.a1);
if numel(shape) ~= 3 || any(shape < 2)
    error('Azimuthal:InvalidMap', 'Expected a three-dimensional Cartesian grid.');
end
for n = 1:9
    value = map.(required{n});
    if ~isnumeric(value) || ~isequal(size(value),shape) || any(isinf(value(:)))
        error('Azimuthal:InvalidMap', 'Inconsistent dimensions or infinite values in %s.',required{n});
    end
end
axes_mm = {map.a1(:,1,1), reshape(map.a2(1,:,1),[],1), reshape(map.a3(1,1,:),[],1)};
for n = 1:3
    a = axes_mm{n}; d = map.(sprintf('d%d',n));
    if ~isreal(a) || any(~isfinite(a)) || ~isscalar(d) || ~isfinite(d) || d<=0 || ...
       any(abs(diff(a)-d) > max(1e-8,d*1e-7))
        error('Azimuthal:InvalidMap', 'Axis %d must be finite, increasing and regularly spaced.',n);
    end
    dims = [1 1 1]; dims(n) = shape(n);
    difference = bsxfun(@minus,map.(sprintf('a%d',n)),reshape(a,dims));
    if any(~isfinite(difference(:))) || max(abs(difference(:))) > 1e-8
        error('Azimuthal:InvalidMap', 'Coordinate arrays must use ndgrid ordering (x fastest).');
    end
end
if ~isscalar(map.loc_x) || ~isscalar(map.loc_y) || ...
   ~isfinite(map.loc_x) || ~isfinite(map.loc_y) || ...
   abs(map.loc_x-axes_mm{1}(1))>1e-8 || abs(map.loc_y-axes_mm{2}(1))>1e-8
    error('Azimuthal:InvalidMap', 'loc_x/loc_y disagree with the coordinate origins.');
end
map.axes_mm = axes_mm;
map.length_m = (axes_mm{3}(end)-axes_mm{3}(1))/1000;
map.source_file = path;
end
