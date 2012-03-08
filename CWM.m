function [fv,p,mx,Cx,Cy,b]=CWM(y,x,Nc,iter,optim,Sigmax)
% Fit mixture of linear regressors


Dy=size(y,1); % Dimension de y
Nf=size(x,1); % Dimension de x
Nt=size(x,2); % Cantidad de datos

f1=figure;

Lk=0;

Lopt=10^100;
for opt=1:optim
    p=ones(Nc,1)/Nc; % p(Ci)

    gx=zeros(Nt,1);
    h=zeros(Nt,Nc);
    b=zeros(Dy,Nf+1,Nc);

    sigmay=cov(y');
    sigmax=cov(x');
    max(sigmax(:))

    MAXy=max(y(1,:)); MINy=min(y(1,:));


    mc=linspace(MINy,MAXy,Nc); 
    b(1,1,:)=mc+0*(rand(size(mc))-.5)*(MAXy-MINy)/Nc/2;
    %for i=1:Nc
    %    [m,n]=min(abs(y(1,:)-mc(i)));
    %end
    k=fix(rand(1,Nc)*Nt)+1;
    %cx=mean(x,2);
    for i=1:Nc
        mx(:,i)=x(:,k(i));
        b(:,1,i)=y(:,k(i));
        Cx(:,:,i)=.5*diag(diag(sigmax))/Nc^(1/Nf)+.5*eye(Nf,Nf)*max(sigmax(:))/Nc;
        Cy(:,:,i)=1*sigmay/Nc;
    end

    % E STEP:
    ss=0;

    %%%%%% Calulo de P(Cj|y,x)  -> h
    for j=1:Nc
        % Calculo de P(x,y|Cj)=P(y|x,Cj)*P(x|Cj)
        % P(x|Cj):
        xmx=x-repmat(mx(:,j),1,Nt);
        iXa=inv(Cx(:,:,j));
        xmX=iXa'*xmx;
        dxm=sum(xmX.*xmx)';
        % P(y|x,Cj):
        ym=y-b(:,:,j)*[ones(1,Nt); xmx];
        if Dy>1
            iXa=inv(Cy(:,:,j));
            ymY=ym'*iXa;
            dym=dot(ymY',ym)';
        else
            dym=ym'.^2/Cy(:,:,j);
        end

        gxy=exp(-0.5*(dym+dxm))/sqrt(det(Cy(:,:,j)))/(2*pi)^(Dy/2)/sqrt(det(Cx(:,:,j)))/(2*pi)^(Nf/2);
        gx(:,j)=exp(-0.5*(dxm))/sqrt(det(Cx(:,:,j)))/(2*pi)^(Nf/2);
        % P(y,x):
        h(:,j)=real(p(j)*gxy);
        ss=ss+h(:,j);
    end

    % E-M algorithm
    for k=1:iter        
        % visualization
        disp(k)
        figure(f1)
        subplot(121)
        cla
        plot(x(1,:),x(2,:),'y.')
        hold on
        plot(mx(1,:),mx(2,:),'+')
        axis('square')
        axis([min(x(1,:)) max(x(1,:)) min(x(2,:)) max(x(2,:))])
        drawnow
        subplot(122)
        cla
        hold on
        my=b(:,1,:);
        plot(my(1,:),mx(1,:),'+')
        axis('square')
        title('output')
        axis([min(y(1,:)) max(y(1,:)) min(x(1,:)) max(x(1,:))])
        drawnow

        for j=1:Nc
            h(:,j)=h(:,j)./ss;
        end
        tic

        % E
        ss=0;
        SUMtot=sum(h(:));
        shj=sum(h);
        Cxm=0;
        for j=1:Nc
            sh=shj(j);
            p(j)=sh/SUMtot;
            Cxm=Cxm+Cx(:,:,j)*p(j);
        end
        for j=1:Nc
            % M-STEP
            sh=shj(j);
            p(j)=sh/SUMtot;

            hDy=repmat(h(:,j)',Dy,1);
            hNf=repmat(h(:,j)',Nf,1);
            mx(:,j)=sum(hNf.*x,2)/sh;

            my=sum(hDy.*y,2)/sh;
            xmx=x-repmat(mx(:,j),1,Nt);
            xmxp=xmx';
            X=(hNf.*xmx)*xmxp/sh;
            Cx(:,:,j)=X+Sigmax*eye(Nf,Nf)/Nc^(1/Nf)*mean(diag(sigmax));
            iXa=pinv(Cx(:,:,j));

            % Calculo de b
            Bm=zeros(Nf+1,Nf+1); Bm(1,1)=1;
            Bm(2:Nf+1,2:Nf+1)=iXa;
            yxm=(hDy.*y)*xmxp/sh;
            Am=[my yxm];
            b(:,:,j)=Am*Bm';

            %calculo de Cy
            ym=y-b(:,:,j)*[ones(1,Nt); xmx];

            if Dy>1
                Cy(:,:,j)=(hDy.*ym)*ym'/sh+0.4*diag([10000/1 100/6].^2);
            else
                Cy(:,:,j)=(hDy.*ym)*ym'/sh+.1;
            end

            % STAGE E:
            iXa=pinv(Cxm);
            xmX=iXa'*xmx;
            dxm=sum(xmX.*xmx);
            % P(y|x,Cj):
            if Dy>1
                iXa=inv(Cy(:,:,j));
                ymY=iXa'*ym;
                dym=dot(ymY,ym);
            else
                dym=ym.*ym/Cy(:,:,j);
            end
            
            %gxy=exp(-0.5*(dym+dxm))/sqrt(det(Cy(:,:,j)))/(2*pi)^(Dy/2+Nf/2)*sqrt(det(iXa))/(2*pi)^(Nf/2);
            %size(gxy)
            % gx(:,j)=exp(-0.5*(dxm'))*sqrt(det(iXa))/(2*pi)^(Nf/2);
            % P(y,x):
            h(:,j)=p(j)*(exp(-0.5*dym)/sqrt(det(Cy(:,:,j)))/(2*pi)^(Dy/2)).*exp(-0.5*(dxm))*sqrt(det(iXa))/(2*pi)^(Nf/2);
            ss=ss+h(:,j);
        end
        toc

        L=-sum(log(ss));
        Lk(k,opt)=L;
    end

    p_opt=p;
    mx_opt=mx;
    Cx_opt=Cx;
    Cy_opt=Cy;
    b_opt=b;
    Lopt=L;
end
p=p_opt;
mx=mx_opt;
Cx=Cx_opt;
Cy=Cy_opt;
b=b_opt;


fv=Lopt;

close

