function showMatrix(C, Cmax)

imagesc(C, [0 Cmax]); 
axis('square'); axis('equal'); colorbar
for i = 1:size(C,1)
    for j = 1:size(C,2)
        text(i,j,num2str(round(C(i,j))), 'fontsize', 8, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
    end
end