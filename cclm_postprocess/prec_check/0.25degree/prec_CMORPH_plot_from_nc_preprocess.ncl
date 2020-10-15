;       10.05   在CMORPH转换二进制文件为NC文件之后，处理NC文件
;               preprocessing目的，在时间上将两个文件拆分，进行简单的计算，并合并出相应时次的文件，以便进一步的绘图操作 
;               注意降水数据的单位              
load "./quantile.ncl"
begin   

;;;>>>>>data reader
;;;>>>>>obs data
    file_path_obs = "/m2data2/yycheng/data_stage/cptp/check_data_obs/CMORPH/200807nc_cdo/"
    file_name_obs = "200807_25deg_mergetime.nc" ; 读取进行合并之后的数据
    f_obs = addfile(file_path_obs + file_name_obs, "r")
    prec_obs = f_obs->$"CMORPH"$
    ; printVarSummary(prec_ordata)
;;;>>>>>cclm data
    file_path_cclm = "/m2data2/yycheng/data_stage/cptp/cptp_backup/cptp_out_A2_10.15/cclm/"
    file_name_cclm = "out02_merge_10.15.nc" ; 读取进行合并之后的数据
    f_cclm = addfile(file_path_cclm + file_name_cclm, "r")
    prec_cclm = f_cclm->$"TOT_PREC"$
    rlat = f_cclm->$"rlat"$
    rlon = f_cclm->$"rlon"$
;>>> coordinates check
  ;;; rotatead pole就存储在rotated_pole之中
    rotated_pole = f_cclm->$"rotated_pole"$
    pole = f_cclm->rotated_pole
    pole_lon = pole@grid_north_pole_longitude
    pole_lat = pole@grid_north_pole_latitude
    lat2d  = f_cclm->$"lat"$
    lon2d  = f_cclm->$"lon"$
    nlat  = dimsizes(lat2d(:,0))
    nlon  = dimsizes(lon2d(0,:))
    prec_obs&lon = prec_obs&lon - 180. ; covert lon to -180 -- +180
;;;>>>>>time check
    time_obs  = prec_obs&time
    time_cclm = prec_cclm&time
    ; printVarSummary(time_obs)
    ; printVarSummary(time_cclm)
    time_cclm = time_to_newtime(time_cclm, time_obs@units)
    prec_cclm&time = time_cclm ;    重新赋值回
    ; printVarSummary(time_cclm)
    print("start time of cclm is : "+cd_calendar(time_cclm(0), 3)+" "+cd_calendar(time_cclm(1), 3)+ "..." +\
    " end time is: "+cd_calendar(time_cclm(dimsizes(time_cclm)-1), 3))

    print("start time of obs  is : "+cd_calendar(time_obs(0), 3)+" "+cd_calendar(time_obs(1), 3)+ "..." +\
    " end time is: "+cd_calendar(time_obs(dimsizes(time_obs)-1), 3))
;;;>>> combine time files and output obs>cclm
    ; do i = 0,dimsizes(time_cclm)-1
    ;     path_out = "/m2data2/yycheng/data_stage/cptp/postprocess_data/prec_check_temporary/"
    ;     path_out_filename = "prec_stepby"+".nc"
    ;     system("rm -f "+path_out) ;删除目录下的同名文件
    ;     ncdf = addfile(path_out, "c") ; c表示创建netcdf文件
    ;     ncdf->sum_cclm = sum_cclm
    ;     ncdf->sum_obs  = sum_obs
    ;     delete(ncdf)
    ; end do

;;;>>> data operator ,sum to 24 hr prec
    start_day  = 19
    end_day    = 24
    set_time_start = cd_inv_calendar(2008, 7, start_day, 0, 0, 0, time_obs@units, 0)     
    set_time_end   = cd_inv_calendar(2008, 7, end_day  , 0, 0, 0, time_obs@units, 0)
    ; print(set_time_start)
    sum_cclm = dim_sum_n(prec_cclm({set_time_start:set_time_end},:,:),0)
    sum_obs  = dim_sum_n(prec_obs({set_time_start:set_time_end},:,:),0)
    sum_cclm = sum_cclm/(end_day  - start_day)
    sum_obs  = sum_obs*3/(end_day - start_day) ;   mm/3hr => mm/hr (in 3 hr)
    copy_VarMeta(prec_cclm(0,:,:), sum_cclm) ; 注意拷贝原始数据
    copy_VarMeta(prec_obs(0,:,:), sum_obs)   ; metadata
    sum_obs@units = "mm"
    sum_cclm@units = "mm"
    ;;; check quantile
    ; print(percent_to_value(sum_obs,ispan(90, 100, 1)))
    ; print(percent_to_value(sum_cclm,ispan(90, 100, 1)))
;;;>>>>>saving data , 将数据暂存到 /m2data2/yycheng/data_stage/cptp/postprocess_data/prec_check_temporary/
    path_out = "/m2data2/yycheng/data_stage/cptp/postprocess_data/prec_check_temporary/"
    path_out_filename = "prec_sum_07"+start_day+"_07"+end_day+".nc"
    system("rm -f "+path_out+path_out_filename) ;删除目录下的同名文件
    ncdf = addfile(path_out+path_out_filename, "c") ; c表示创建netcdf文件
    ncdf->sum_cclm = sum_cclm
    ncdf->sum_obs  = sum_obs
    ncdf->rotated_pole  = rotated_pole
    ncdf->lat2d    = lat2d
    ncdf->lon2d    = lon2d
    delete(ncdf)

end