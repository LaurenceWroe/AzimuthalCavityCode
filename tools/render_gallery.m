function render_gallery()
% Render computed and retained-data examples; captions document provenance.
root=fileparts(fileparts(mfilename('fullpath')));
addpath(root); setup_paths;
graphics_toolkit('gnuplot');
set(0,'defaultfigurevisible','off');
folder=fullfile(root,'docs','gallery');
if ~exist(folder,'dir'), mkdir(folder); end
names={'shapes','saved_fields','saved_distributions'};
callbacks={@demo_shapes,@demo_saved_fields,@demo_saved_distributions};
for j=1:numel(names)
    callbacks{j}(true);
    set(gcf,'paperposition',[0 0 9 6],'papersize',[9 6]);
    print(gcf,fullfile(folder,[names{j} '.png']),'-dpng','-r120');
    close(gcf);
end
end
