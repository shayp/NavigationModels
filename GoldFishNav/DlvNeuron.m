classdef DlvNeuron
    %DLVNEURON Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Orient %% orinetation
        X      %% Fish Position X dimenstion in cm
        Y      %% Fish Position Y dimenstion in cm
        Time   %% Time stamp of X Y and Orient in seconds
        SpikeX %% Position of Spike
        SpikeY %% Position of Spike
        SpikeO %% Orientation of Spike
        SpikeTime %% TiemStamp of the spikes in seconds
        Rect   %% Aquarium position in pixels
        S      %% Spike Shapes
        Date   %% ExpDtae
        Day    %% Days from Expreiment begining
        Cluster %% Cluster Number
        
    end
    
    
    methods
        function obj = DlvNeuron(Time,X,Y,Orient,SpikeTime,Rect,S,Date,Day,Cluster) %% constructor
            [X,Y]=Pixel2Cm(X,Y,Rect);  %% convert position to cm
            [obj.SpikeX,obj.SpikeY,obj.SpikeO]=SpikeLocation(Time,X,Y,Orient,SpikeTime);  %% downsample spikes
            obj.Time = Time;
            obj.X=X;
            obj.Y=Y;
            obj.Orient=Orient;
            obj.SpikeTime=SpikeTime;
            obj.Rect=Rect;
            obj.S=S;
            obj.Date=Date;
            obj.Day=Day;
            obj.Cluster=Cluster;
        end
        
        function PositionScatter(obj,axes_h)
            axes(axes_h);
            p=plot(obj.X,obj.Y);
            p.Color(4)=1;
            drawnow;
            axis('equal');
            hold on;
            p=plot(obj.SpikeX,obj.SpikeY,'r.','MarkerSize',12);
            plot([0, 0, 140, 140, 0],[0 ,20 ,20, 0,0],'k');
            %     plot([DataP.pos_rect(1), DataP.pos_rect(1),DataP.pos_rect(1)+DataP.pos_rect(3),DataP.pos_rect(1)+DataP.pos_rect(3),DataP.pos_rect(1)],...
            %         [DataP.pos_rect(2), DataP.pos_rect(2)+DataP.pos_rect(4),DataP.pos_rect(2)+DataP.pos_rect(4),DataP.pos_rect(2),DataP.pos_rect(2)])
            hold off;
            xlabel('X dim [Cm]');
            ylabel('Y dim [Cm]');
            text(60,30,['Total spike ' num2str(length(obj.SpikeX))]);
            ylim([0 20]);
            xlim([0 140]);
            set(gca,'Ytick',[0 20]);
            
        end
        
        function Velocity_2D_Hist(obj,MaxSpeed,Bins,axes_h1,axes_h2)
            % set(gcf, 'Position', get(0, 'Screensize'));
            Edges=-MaxSpeed:Bins:MaxSpeed;
            
            temp1=diff(obj.X(1:end-1));
            temp2=diff(obj.X(2:end));
            VelocityX=(temp1+temp2)/2;
            VelocityX=[VelocityX(1) VelocityX VelocityX(end)];
            VelocityX=VelocityX/mean(diff(obj.Time));
            SpikeVX=interp1(obj.Time,VelocityX,obj.SpikeTime);
            
            temp1=diff(obj.Y(1:end-1));
            temp2=diff(obj.Y(2:end));
            VelocityY=(temp1+temp2)/2;
            VelocityY=[VelocityY(1) VelocityY VelocityY(end)];
            VelocityY=VelocityY/mean(diff(obj.Time));
            SpikeVY=interp1(obj.Time,VelocityY,obj.SpikeTime);
            
            
            axes(axes_h1);
            h=histogram2(VelocityX,VelocityY,'DisplayStyle','tile','XBinEdges',Edges,'YBinEdges',Edges);
            hold on;
            plot(SpikeVX,SpikeVY,'r.','MarkerSize',12)
            xlabel('dx/dt [Cm/s]');
            ylabel('dy/dt [Cm/s]');
            
            axes(axes_h2);
            xlabel('dx/dt [Cm/s]');
            ylabel('dy/dt [Cm/s]');
            
            N = histcounts2(SpikeVX,SpikeVY,Edges,Edges);
            N=N./(h.Values*mean(diff(obj.Time)));
            N2=N;
            
            N2(~isnan(N))=0;
            N2(isnan(N))=1;
            N(isnan(N))=0;
            N(N==inf)=0;
            imagesc([Edges(1),Edges(end)],[Edges(1),Edges(end)],log(N)');
            axis xy
            grid on
            [row,col]=find(N2~=1);
            row=Edges(row);
            col=Edges(col);
            for i=1:length(row)
                patch([row(i) row(i)+Bins row(i)+Bins row(i) row(i)],[col(i) col(i) col(i)+Bins col(i)+Bins col(i)],[1 1 1],'FaceColor','none');
            end
            
            hold on;
            [row,col]=find(N2==1);
            row=Edges(row);
            col=Edges(col);
            for i=1:length(row)
                patch([row(i) row(i)+Bins row(i)+Bins row(i) row(i)],[col(i) col(i) col(i)+Bins col(i)+Bins col(i)],[1 1 1],'EdgeColor','none');
            end
            xlim([Edges(1) Edges(end)]);
            ylim([Edges(1) Edges(end)]);
            
            %                         h=histogram2(tmp,tmp2,'DisplayStyle','tile','XBinEdges',Edges,'YBinEdges',Edges);
            
        end
        
        function Velocity_X_Hist(obj,MaxSpeed,Bins,axes_h1,axes_h2)
            Edges=-MaxSpeed:Bins:MaxSpeed;
            temp1=diff(obj.X(1:end-1));
            temp2=diff(obj.X(2:end));
            VelocityX=(temp1+temp2)/2;
            VelocityX=[VelocityX(1) VelocityX VelocityX(end)];
            VelocityX=VelocityX/mean(diff(obj.Time));
            SpikeVX=interp1(obj.Time,VelocityX,obj.SpikeTime);
            H{1}=histcounts(SpikeVX,Edges);
            H{2}=histcounts(VelocityX,Edges);
            H{2}=H{2}*mean(diff(obj.Time));
            H{3}=H{1}./H{2};
            
            axes(axes_h1);
            St(1)=stairs(Edges+1,[H{1},H{1}(end)]);
            ylabel('Spike count');
            yyaxis right
            St(2)=stairs(Edges,[H{2},H{2}(end)]);
            ylabel('Time count [Sec]');
            xlabel('dx/dt [Cm/s]');
            
            H{3}(isnan(H{3}))=0;
            H{3}(H{1}<=2)=0;
            axes(axes_h2);
            
            St(3)=stairs(Edges,[H{3},H{3}(end)]);
            set(gca,'YAxisLocation','right');
            
            ylabel('FR [Hz]');
            xlabel('dx/dt [Cm/s]');
            
            set(St,'LineWidth',2);
        end
        
        function NeuronPage(obj)
            figure
            subplot(5,2,[1 2]);
            PositionScatter(obj,gca);
            name=[obj.Date '_Day' num2str(obj.Day) '#' num2str(obj.Cluster)];
            text(-60,20,name,'Interpreter','none');
            gca1=subplot(5,2,[3 5]);
            gca2=subplot(5,2,[4 6]);
            MaxSpeed=40;
            Bins=2.5;
            Velocity_2D_Hist(obj,MaxSpeed,Bins,gca1,gca2)
            gca3=subplot(5,2,[7 9]);
            gca4=subplot(5,2,[8 10]);
            Velocity_X_Hist(obj,MaxSpeed,Bins,gca3,gca4)
            
            
        end
        
        function printNeuronPage(obj)
            NeuronPage(obj)
            FigsDir='C:\Users\pinskyeh\Dropbox\ExpData\NLoger\FiguresV2\';
            name=[obj.Date '_Day' num2str(obj.Day) '#' num2str(obj.Cluster)];
            h =gcf;
            
            set(h,'papertype','A4');
            A=h.PaperSize;
            set(h,'paperposition',[0 0 A(1) A(2)]);
            %     set(h,'units','normalized');
            %     set(h,'position',[0 0 1 1]);
            %     print(h(1),[FigsDir name ],'-dpsc');
            print([FigsDir name '.pdf'],'-dpdf');
        end
        
        
        %         function
        %             %       function STA_x(obj)
        %             %           for i=1:length(
        %             %       end
        %         end
        
    end
end

