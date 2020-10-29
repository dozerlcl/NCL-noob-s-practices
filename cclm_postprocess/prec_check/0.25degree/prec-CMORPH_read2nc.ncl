;  2020.10.04 将CMORPH的0.25degree数据合并，并转换为NC格式
;              参考脚本有缺陷，本身只有反演的降水的数据，每日具有3小时的数据。一共0-7，共八个层次的数据
;              用途，将每日的数据处理为为3-24共8个时次的累计降水，然后逐日输出一个文件
;               关键参数：
;               netCDF 控制是否进行nc文件输出
;               ncDir  nc文件输出路径
;   备注：
;               留为注释的位置大部分是可以进行些数据测试等
;               参考脚本：https://www.ncl.ucar.edu/Applications/HiResPrc.shtml
;                         https://www.ncl.ucar.edu/Applications/Scripts/cmorph_3.ncl
;               非常好用

begin
diri   = "/m2data2/yycheng/data_stage/cptp/check_data_obs/CMORPH/200807/"
fili   = systemfunc("cd "+diri+"; ls *CMORPH*")
netCDF = True ;   switch,是否将CPC资料存放为nc格式数据

nfil   = dimsizes(fili)  ;   放置CMORPH文件夹中所有的文件名
filc   = tochar( fili ) 
if(netCDF) then
    ncDir  = "/m2data2/yycheng/data_stage/cptp/check_data_obs/CMORPH/200807nc/"     ;   创建在上一级目录中，具体自己修改
    ncFil  = fili + ".nc"
end if
;***************************************************************
; Read (big endian) binary file
;***************************************************************
do ind_fili = 0,nfil -1,1
    ;    setfileoption("bin","ReadByteOrder","BigEndian") ; 居然关掉就好了？10.04 读入CPC数据

    ntim  = 8
    nlat  = 480                                    ; from ctl file  
    mlon  = 1440

    ;    print(diri+fili(0)) ; check file path
    ;   当日逐三小时的资料，有0-7八个层次
    ;    comb  = fbindirread(diri+fili(21),0, (/nlat,mlon/),"float")

    cpc   = fbindirread(diri+fili(ind_fili),0, (/ntim,nlat,mlon/),"float")
    cpc_reunittime = new((/ntim, nlat, mlon/), float)
    do i = 0,ntim-1
    cpc_reunittime(i,:,:) = fbindirread(diri+fili(ind_fili),i, (/nlat,mlon/),"float")
    end do
    ; print("按照rec顺序和直接将ntim写进fbindirread的顺序读入之间的差别: "+sum(cpc_reunittime - cpc))
    ;***************************************************************
    ; Add meta data
    ;***************************************************************
    ;    comb@_FillValue = -9999.
    ;    comb@units      = "mm/hr"
    ;    comb@long_name  = "Merged microwave precip (no advection)" 

    cpc@_FillValue  = -9999.
    cpc@units       = "mm/hr"
    cpc@long_name   = "CMORPH precip"

    ;***************************************************************
    ; Change from mm/hr to mm/day
    ;***************************************************************
    ;    comb            = comb*24    
    ;    cpc             = cpc*24    
    ;    comb@units      = "mm/day"
    ;    cpc@units       = "mm/day"

    ;***************************************************************
    ; Create/Add coordinate variables. See above Grads ctl   
    ;***************************************************************
    lat       =  -59.875 + ispan(0,nlat-1,1)*0.25  
    lon       =   0.125 + ispan(0,mlon-1,1)*0.25 
                                            ;latitude
    lat!0     = "lat"
    lat&lat   =  lat
    lat@units = "degrees_north"
                                            ;longitude
    lon!0     = "lon"
    lon&lon   =  lon
    lon@units = "degrees_east"

    ;***************************************************************
    ; Associate the spatial coordinates with variables
    ;***************************************************************

    cpc!1    = "lat"                   ; 1st ... name the dimensions
    cpc!2    = "lon"
    cpc&lat  =  lat                    ; create coordinate variable
    cpc&lon  =  lon                    ; create coordinate variable

    ;    copy_VarCoords( cpc, comb)         ; same coordinates

    ;***************************************************************
    ; Simple data exploration: 
    ;    Are there missing data?
    ;    Count the number of missing values in each variable
    ;    Calculate weighted areal averages: ignore missing grid points
    ;    Calculate weighted areal averages of precip occurrence only
    ; Print results
    ;***************************************************************

    ; ;    nMsg_comb = num(ismissing(comb))
    ;    nMsg_cpc  = num(ismissing(cpc ))

    ;    rad      = 4.*atan(1.0)/180.
    ;    clat_025 = cos(lat*rad)    ; simple cosine weighting

    ; ;    combAvg_025 = wgt_areaave(comb, clat_025, 1.0, 0)
    ;    cpcAvg_025  = wgt_areaave( cpc, clat_025, 1.0, 0)

    ; ;    print(" ")
    ;    print("Number missing: Msg_cpc="+nMsg_cpc)
    ;    print(" ")
    ;    print("Original 0.25 grid: cpcAvg="+cpcAvg_025)
    ;    print(" ")


    ;************************************************
    ; Create netCDF ?
    ; Recommend to always create a 'time' dimension 
    ;************************************************
    ;       先进行读入一个文件的尝试，并转换为NC格式的文件
        ; print(filc)       ; 先输出filc，查找YYYYMMDD的位置
        yyyy     = stringtointeger( (/filc(ind_fili, 29: 32)/) ) 
        mm       = stringtointeger( (/filc(ind_fili, 33: 34)/) ) 
        dd       = stringtointeger( (/filc(ind_fili, 35: 36)/) ) 
        hh       = ispan(3,24,3)    ;   降水本身就非瞬时量，含义为该时刻前三小时的累计降水
        mn       = 0

        time      = new ( ntim, "double", "No_FillValue")
        tunits    = "hours since 1990-01-01 00:00:0.0"
        time@units= tunits
        do i=0,ntim-1,1
            time(i) = (/cd_inv_calendar(yyyy,mm,dd,hh(i),mn,0,tunits, 0)/)
        end do

        time!0   = "time"
        date      = yyyy*1000000 + mm*10000 + dd*100 + hh
        date!0    = "time"
        date@units= "yyyymmddhh"
        cpc!0     = "time"
        cpc&time  = time
        ; cpc&time@units = tunits
        ; printVarSummary(cpc&time)

    ;************************************************
    ; Create netCDF ?
    ; Recommend to always create a 'time' dimension 
    ;************************************************

    if (netCDF) then
        ;    先进行单个文件的存储，然后再批量读入文件
        nline  = inttochar(10)

        globeAtt              = 1
        globeAtt@title        = "CMORPH: 0.25 3-Hourly"    
        globeAtt@ftp          = "ftp://ftp.cpc.ncep.noaa.gov/precip/global_CMORPH/daily_025deg"
        globeAtt@acronym      = "CMORPH: CPC Morphing Technique"
        globeAtt@description  = "http://www.cpc.noaa.gov/products/janowiak/cmorph_description.html"
        globeAtt@referenceon  = nline + \
                                "Joyce, R. J., J. E. Janowiak, P. A. Arkin, and P. Xie, 2004:       "+nline+\
                                "CMORPH: A method that produces global precipitation estimates      "+nline+\
                                "        from passive microwave and infrared data at high spatial   "+nline+\
                                "        and temporal resolution. J. Hydromet., 5, 487-503.         "+nline
        
        globeAtt@creation_date= systemfunc ("date" )
        
        NCFILE = ncDir + ncFil
        ;    print(NCFILE)
        system("rm -f " +  NCFILE(ind_fili))    ; remove any pre-exist file 要先存在再进行删除否则会出现错误
            
        ncdf   = addfile(NCFILE(ind_fili),"c")     
        
        ;setfileoption(ncdf, "definemode", True)
        
        fileattdef( ncdf, globeAtt )        ; create the global [file] attributes
                                            
        dimNames = (/"time", "lat", "lon" /)  
        dimSizes = (/ ntim ,  nlat,  mlon /) 
        dimUnlim = (/ True , False, False /)   
        filedimdef(ncdf, dimNames  , dimSizes,  dimUnlim )
        
        filevardef   (ncdf, "time"  , typeof(time), getvardims(time) )
        filevarattdef(ncdf, "time", time)
        
        filevardef   (ncdf, "lat", typeof(lat), getvardims(lat))
        filevarattdef(ncdf, "lat", lat)
            
        filevardef   (ncdf, "lon", typeof(lon), getvardims(lon))
        filevarattdef(ncdf, "lon", lon)
        
        filevardef   (ncdf, "date"  , typeof(date), getvardims(date) )
        filevarattdef(ncdf, "date", date)
        
        filevardef    (ncdf, "CMORPH", typeof(cpc ) , getvardims(cpc ) )

        filevarattdef (ncdf, "CMORPH", cpc )
        
        ncdf->time   = (/ time /)
        ncdf->lat    = (/ lat /)
        ncdf->lon    = (/ lon /)
        ncdf->date   = (/ date /)

        ncdf->CMORPH = (/ cpc  /)

    end if    ; netCDF

end do

end