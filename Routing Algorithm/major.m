n=100;
buffer_size=int16(10);
A=zeros(n);
b=100;
iterations =14000;
Node(n).batt=100;
total_battery=0;
Dead_node=0;
Loo = zeros(n);
Koo = zeros(n); 
counter=0;
fprintf('---------------------\n');
for i=1:n;
    Node(i).batt=rand()*109+3;
    
    total_battery=total_battery+Node(i).batt;
    Node(i).no=i;
    Node(i).buffer=zeros(buffer_size);
    Node(i).start=1;
    Node(i).endd=1;
    Node(i).sent=zeros(buffer_size);
    Node(i).dead=0;
    Node(i).buffval=0;
end

    K=randi(n,n,3);
    L=randi(n,n,3);

for i=1:n
    for j=1:3
        A(round(K(i,j)),round(L(i,j)))=rand()*10;
        A(round(L(i,j)),round(K(i,j)))=rand()*10;
    end
end

%{
A(1,2)=1;
A(2,1)=1;
A(2,5)=1;
A(5,2)=1;
A(2,4)=1;
A(4,2)=1;
A(1,3)=1;
A(3,1)=1;
A(3,5)=1;
A(5,3)=1;
A(5,7)=1;
A(7,5)=1;
A(5,8)=1;
A(8,5)=1;
A(8,9)=1;
A(9,8)=1;
A(9,10)=1;
A(10,9)=1;
A(6,8)=1;
A(8,6)=1;
A(6,9)=1;
A(9,6)=1;
A(4,6)=1;
A(6,4)=1;
%}
S=sparse(A);
packet_recieved=0;

for i=1:iterations
    disp(i);
    c=0;
    STATISTICS.Sent(i+1)=packet_recieved;
    STATISTICS.DEAD(i+1)=Dead_node;
    STATISTICS.Battery(i+1)=total_battery;
      
   
  
   source=round(rand(1)*100);
    dest=round(rand(1)*100);
  
%{   
   source=1;
    dest=7;
%} 
    %{ 
    source=round(K(mod(i,n)+1,round(i/n)+1));
    dest=round(L(mod(i,n)+1,round(i/n)+1));
    %}
    if source == 0
        source=source+1;
    end
    if dest == 0
       dest=dest+1;
    end
    if(Node(source).batt>1)
    Loo(dest)=Loo(dest)+1;
    dist=graphshortestpath(S,source,dest);
           
    battery=Node(source).batt;
    par=alpha(dist)+beta(battery);
    toforward=source;
    for j=1:n
        if A(source,j)>0 && Node(j).batt~=0
              l=graphshortestpath(S,j,dest);
              par1=alpha(l)+beta(Node(j).batt);
              if par1 < par
                  par=par1;
                  toforward=j;
              end
              
        end
    end
    if toforward== dest && source ~= dest
               packet_recieved=packet_recieved+1;
               Koo(dest)=Koo(dest)+1;
               c=1;
               counter=counter+1;
    end
  
    if c==0
        
        Node(source).batt=Node(source).batt-0.3;
        total_battery=total_battery-0.3;
    end
   
     if c==0
     if mod(Node(toforward).endd+1,buffer_size)==Node(toforward).start
        Node(toforward).start=mod(Node(toforward).start+1,buffer_size);
        Node(toforward).endd=mod(Node(toforward).endd+1,buffer_size);
        if Node(toforward).endd ==0
        Node(toforward).buffer(buffer_size)=dest;
        Node(toforward).sent(buffer_size)=-1;    
        else
        Node(toforward).buffer(Node(toforward).endd)=dest;
        Node(toforward).sent(Node(toforward).endd)=-1;
        end
        
    else
        Node(toforward).endd=mod(Node(toforward).endd+1,buffer_size);
        if Node(toforward).endd ==0
        Node(toforward).buffer(buffer_size)=dest;
        Node(toforward).sent(buffer_size)=-1;    
        else
        Node(toforward).buffer(Node(toforward).endd)=dest;
        Node(toforward).sent(Node(toforward).endd)=-1;
        end
        
    end          
     end 
    end
    for it=1:n
        if Node(it).dead==0 && Node(it).batt>20
        k=1;
        if(Node(it).batt<0)
       end
        while k <= buffer_size 
             if k == 0
                 k=buffer_size;
             end
             if Node(it).sent(k) == 0 && Node(it).buffer(k)~=0
                 c=0;
                source=it;
                dest=Node(it).buffer(k);
                Node(it).sent(k)=1;
                Node(it).buffval=Node(it).buffval-1;
                dist=graphshortestpath(S,source,dest);
                battery=Node(source).batt;
                par=alpha(dist)+beta(battery);
                toforward=dest;
                
                for j=1:n
                 
                    if A(source,j)>0
                      
                        l=graphshortestpath(S,j,dest);
                        
                          par1=alpha(l)+beta(Node(j).batt);
                          if par1 < par
                              par=par1;
                              toforward=j;
                          end
                          
                    end
                end
                
                if toforward==dest 
                c=1;
                %{
                fprintf('%d %da\n',dest,source);
                %}
                packet_recieved=packet_recieved+1;
                Koo(dest)=Koo(dest)+1;
                end
                if c==0
                    Node(source).batt=Node(source).batt-0.3;
                    total_battery=total_battery-0.3;
                       
                if mod(Node(toforward).endd+1,buffer_size)==Node(toforward).start
                    Node(toforward).start=mod(Node(toforward).start+1,buffer_size);
                    Node(toforward).endd=mod(Node(toforward).endd+1,buffer_size);
                    if Node(toforward).endd ==0
                    Node(toforward).buffer(buffer_size)=dest;
                    Node(toforward).sent(buffer_size)=-1;    
                    else
                    Node(toforward).buffer(Node(toforward).endd)=dest;
                    Node(toforward).sent(Node(toforward).endd)=-1;
                    end
                else
                    Node(toforward).endd=mod(Node(toforward).endd+1,buffer_size);
                    if Node(toforward).endd ==0
                    Node(toforward).buffer(buffer_size)=dest;
                    Node(toforward).sent(buffer_size)=-1;    
                    else
                    Node(toforward).buffer(Node(toforward).endd)=dest;
                    Node(toforward).sent(Node(toforward).endd)=-1;
                    end
                end
                end
    
             end
             k=(k+1);
         end
        end
    end
 if(mod(i,20)==0)
     
     for kl=1:n
     source=round(rand(1)*n);
       dest=round(rand(1)*n);
   
     if source==0
        source=source+1;
     end
     if dest==0
        dest=dest+1;
     end
     if A(source,dest)==0
         A(source,dest)=rand(1)*10;
     else
         A(source,dest)=0;
     end
     end
 end
 
 S=sparse(A);
 
 for it=1:n
     for k=1:buffer_size
       if Node(it).sent(k)==-1
           Node(it).sent(k)=0;
           Node(it).buffval=Node(it).buffval+1;
       end
     end
     if(Node(it).batt < 1)
        if Node(it).dead==0
            Dead_node=Dead_node+1;
            Node(it).dead=1;
            
        end
         for k=1:n
           A(it,k)=0;
        end
        for k=1:buffer_size
           
           Node(it).sent(k)=1;
           
       end
     end
 end
 
end
figure,plot(STATISTICS.Sent),title('Number of Packets Reached Destination'),xlabel({'time'}),ylabel({'Number of packets'});
figure,plot(STATISTICS.Battery),title('Total Battery'),xlabel({'time'}),ylabel({'Total Battery'});
figure,plot(STATISTICS.DEAD),title('Dead Nodes'),xlabel({'time'}),ylabel({'Nuumber of Dead Nodes'});