
function data_read=read_txt(filename,format_str,valid_cols,skip_row1)
%skip txt by sscanf %*s
%%%% read data from txt which could including data and txt together
if (nargin ==3)
    skip_row1=0;
elseif(nargin==4)

else
    error('input parameter error');
end

data_read=zeros(10,valid_cols);

fid=fopen(filename,'r');
countt=0;
idy=0;
while feof(fid)~=1
    countt=countt+1;
    str1=fgetl(fid);
    if(countt<=skip_row1)
        continue;
    end

    idy=idy+1;
    data_read(idy,:)=sscanf(str1,format_str);

end

fclose(fid);
end