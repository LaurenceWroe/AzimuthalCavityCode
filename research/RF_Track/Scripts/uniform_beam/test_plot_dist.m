

LW = 1.5;
colours = jet(4);
figure(12); hold on;
##'g', 'm','r','b','g', [.7 .7 .7]
plot(bins_optim,BoxFitAll/A,'k','Linewidth',LW/2,'handlevisibility','off')
x = load('Dist/TwoPill.m','bins_optim','h');
plot(x.bins_optim,x.h./mean(x.h((end+1)/2-3:(end+1)/2+1)),'r','Linewidth',LW,'displayname','$\tilde{g}_2/\tilde{g}_4=-11e-2$')
x = load('Dist/TM4610_5_7.m','bins_optim','h');
plot(x.bins_optim,x.h./mean(x.h((end+1)/2-3:(end+1)/2+1)),'g','Linewidth',LW,'displayname','$\tilde{g}_2/\tilde{g}_4=-11e-2$')
x = load('Dist/TM4610_6_3.m','bins_optim','h');
plot(x.bins_optim,x.h./mean(x.h((end+1)/2-3:(end+1)/2+1)),'m','Linewidth',LW,'displayname','$\tilde{g}_2/\tilde{g}_4=-11e-2$')
x = load('Dist/TM4610_6_7.m','bins_optim','h');
plot(x.bins_optim,x.h./mean(x.h((end+1)/2-3:(end+1)/2+1)),'b','Linewidth',LW,'displayname','$\tilde{g}_2/\tilde{g}_4=-11e-2$')
x = load('Dist/TM4610_7_5.m','bins_optim','h');
plot(x.bins_optim,x.h./mean(x.h((end+1)/2-3:(end+1)/2+1)),'c','Linewidth',LW,'displayname','$\tilde{g}_2/\tilde{g}_4=-11e-2$')

##plot(bins_optim,h./mean(h((end+1)/2-3:(end+1)/2+1)),'color',[.7 .7 .7],'Linewidth',LW,'displayname','$0\times\tilde{g}_4$')
##plot(bins_optim,h./mean(h((end+1)/2-3:(end+1)/2+1)),'g','Linewidth',LW,'displayname','$0.5\times\tilde{g}_4$')
##plot(bins_optim,h./mean(h((end+1)/2-3:(end+1)/2+1)),'c','Linewidth',LW,'displayname','$0.75\times\tilde{g}_4$')
##plot(bins_optim,h./mean(h((end+1)/2-3:(end+1)/2+1)),'b','Linewidth',LW,'displayname','$1\times\tilde{g}_4$')
##plot(bins_optim,h./mean(h((end+1)/2-3:(end+1)/2+1)),'m','Linewidth',LW,'displayname','$1.25\times\tilde{g}_4$')
##plot(bins_optim,h./mean(h((end+1)/2-3:(end+1)/2+1)),'r','Linewidth',LW,'displayname','$1.5\times\tilde{g}_4$')
xlabel('$x$ [mm]', 'interpreter','latex')
ylabel('Relative Intensity', 'interpreter','latex');
##title(['Survived = ' num2str(B1.get_ngood/nParticles*100) '%'])
pos = get(gca, 'Position');
##set(gca, 'Position', [pos(1)-0.05 pos(2)+0.02 pos(3) pos(4)-0.02]);
##set(gca, 'Position', [pos(1) pos(2)-0.05 pos(3) pos(4)-0.12]);
##set(gca, 'Position', [pos(1)+0.05 pos(2)+0.15 pos(3) pos(4)-0.12]);
ylim([0 2])
grid; box on;
set(gca,'FontSize',24)
drawnow
