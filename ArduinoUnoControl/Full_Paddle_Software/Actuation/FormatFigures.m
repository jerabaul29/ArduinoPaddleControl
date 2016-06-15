% script for taking care of the figures

% hx is handle to xlabel, hy to y label, ht to title, hl to legend

stringNameFont = 'times';
FtSize = 16;
LnWidth = 5;
set(gca,'fontname',stringNameFont)
set(gca,'FontSize',FtSize,'LineWidth',LnWidth);
set(hx,'fontname',stringNameFont,'FontSize',FtSize);
set(hy,'fontname',stringNameFont,'FontSize',FtSize);
set(ht,'fontname',stringNameFont,'FontSize',FtSize);
set(hl,'fontname',stringNameFont,'FontSize',FtSize);