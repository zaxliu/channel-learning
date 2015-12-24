%% Hammersley set & Halton set
%2D
%Halton
halton=zeros(100,2);
hammer=zeros(100,2);
str2='';
for i=1:100
    str1=dec2base(i,3);
    l=length(str1);
    for j=1:l
        str2=[str1(j:j),str2];
    end
    halton(i,1)=base2dec(str2,3)/3^l;
    str2='';
end
hammer(:,2)=halton(:,1);

for i=1:100
    str1=dec2base(i,5);
    l=length(str1);
    for j=1:l
        str2=[str1(j:j),str2];
    end
    halton(i,2)=base2dec(str2,5)/5^l;
    str2='';
    hammer(i,1)=(i/100);
end



figure(1);
axis square;
%plot(halton(:,1),halton(:,2),'*');
plot(hammer(:,1),hammer(:,2),'*');