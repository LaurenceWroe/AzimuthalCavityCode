function field = convert_cst_fields(e_file, h_file, output_file)
% Convert Cartesian CST ASCII exports to the historical RF-Track schema.
% Adapted from F_CSTFieldConvert2.m; coordinates/spacing are in mm,
% E in V/m and H in A/m. Complex phase is preserved, H is converted to B.
% Two header lines followed by x y z ReX ImX ReY ImY ReZ ImZ are required.
% All grid points must be present once, in matching E/H grids.
e = dlmread(e_file, '', 2, 0);
h = dlmread(h_file, '', 2, 0);
if size(e,2) ~= 9 || size(h,2) ~= 9 || any(~isfinite(e(:))) || any(~isfinite(h(:)))
    error('Azimuthal:InvalidExport', 'Expected finite CST arrays with nine columns.');
end
ecoords = e(:,1:3); hcoords = h(:,1:3);
ecoords(abs(ecoords) < 1e-12) = 0;
hcoords(abs(hcoords) < 1e-12) = 0;
e(:,1:3) = ecoords; h(:,1:3) = hcoords;
e = sortrows(e, [3 2 1]); h = sortrows(h, [3 2 1]);
if ~isequal(size(e),size(h)) || ~isequal(e(:,1:3),h(:,1:3))
    error('Azimuthal:GridMismatch', 'E and H exports must have identical coordinates.');
end
axes_mm = {unique(e(:,1)), unique(e(:,2)), unique(e(:,3))};
shape = cellfun(@numel, axes_mm);
if any(shape < 2) || prod(shape) ~= size(e,1) || size(unique(e(:,1:3),'rows'),1) ~= size(e,1)
    error('Azimuthal:IncompleteGrid', 'Expected a complete Cartesian grid with at least two samples per axis.');
end
spacing = zeros(1,3);
for n = 1:3
    steps = diff(axes_mm{n}); spacing(n) = steps(1);
    if max(abs(steps-spacing(n))) > max(1e-10, abs(spacing(n))*1e-8)
        error('Azimuthal:UnevenGrid', 'CST export must have uniform spacing on each axis.');
    end
end
[field.a1, field.a2, field.a3] = ndgrid(axes_mm{:});
for n = 1:3
    field.(sprintf('E%d_Mat',n)) = reshape(complex(e(:,2*n+2),e(:,2*n+3)), shape);
    field.(sprintf('B%d_Mat',n)) = 4*pi*1e-7*reshape(complex(h(:,2*n+2),h(:,2*n+3)), shape);
    field.(sprintf('d%d',n)) = spacing(n);
end
field.loc_x = axes_mm{1}(1);
field.loc_y = axes_mm{2}(1); % fixes original min(temp_x) typo for asymmetric grids
if nargin >= 3 && ~isempty(output_file)
    if exist(output_file, 'file')
        error('Azimuthal:OutputExists', 'Refusing to overwrite existing map: %s', output_file);
    end
    save(output_file, '-struct', 'field', '-v7');
end
end
