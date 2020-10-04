;读取CN051 和 WRF 的TM数据 截取需要的时段 并输出到tm_cat_CN051_WRF文件中
;cat数据 分为19980101-20011231 1998-2000作为mod 2000-2001做订正
;给后续R处理qmap做初步cat
;原因是R读入较慢
;3.17修改为cat pre的脚本；先处理wrf
;为了省事保存变量名不做调整，只是修改文件名
;3.19 处理PRE CCLM +-文件路径，文件变量名 
begin
;>>>read CN05.1 data   
  f_CN051_TM = addfile("./practice/bc_data/CN05.1_Pre_198901_200912_daily_025x025.nc", "r")
  ; f_WRF_TM   = addfile("./practice/bc_data/WRF_TMEAN_daily_025x025.nc","r") ; WRF
  ; f_WRF_TM  = addfile("./practice/bc_data/CCLM_TMEAN_daily_025x025.nc","r") ; CCLM
  f_WRF_TM = addfile("./practice/bc_data/RegCM_PRE_daily_025x025.nc","r")
  ;;;;;考虑读取两年的（20000101-20011231）记录号为（4017-4747）   数据过大不能一次性读入进变量
  ;>>>>05.1观测数据集,平均气温
    ; list_filevars(f_CN051_TM) 
    tm_CN051_or = f_CN051_TM->$"pre"$;CN05.1 tm [ time | 7670 ] x [ lat | 163 ] x [ lon | 283 ]
    ; printVarSummary(tm_CN051&time) ; 调用变量的time坐标 19890101-20091231 逐日数据
    tm_CN051_time = cd_calendar(tm_CN051_or&time, 2)
    it_step1_s = 19970101  ;订正用 第一步起始时间
    it_step1_e = 19991231
    it_step2_s = 20000101  ;起始年月 1998(3287) 1995(2191) 1997(2922)
    it_step2_e = 20011231  ;结束年月
    rec_step1_s = ind(it_step1_s .eq. tm_CN051_time)      ;获取开始时间的记录号 4017(2000)
    rec_step1_e = ind(it_step1_e .eq. tm_CN051_time)      ;获取结束时间的记录号 4747(2001)
    rec_step2_s = ind(it_step2_s .eq. tm_CN051_time)      ;获取开始时间的记录号 4017(2000)
    rec_step2_e = ind(it_step2_e .eq. tm_CN051_time)      ;获取结束时间的记录号 4747(2001)

    tm_CN051_step1_cat = tm_CN051_or(time|rec_step1_s:rec_step1_e,lat|:,lon|:) ;用记录号截取
    tm_CN051_step2_cat = tm_CN051_or(time|rec_step2_s:rec_step2_e,lat|:,lon|:) ;用记录号截取

    delete(tm_CN051_or) ; 免除占用内存过多
  ;>>>>WRF模式，平均气温
  ; list_filevars(f_WRF_TM) 
    tm_wrf_or = f_WRF_TM->$"PRE"$;TMEAN [ time | 7670 ] x [ lat | 163 ] x [ lon | 283 ]
    tm_wrf_step1_cat = tm_wrf_or(time|rec_step1_s:rec_step1_e,lat|:,lon|:)
    tm_wrf_step2_cat = tm_wrf_or(time|rec_step2_s:rec_step2_e,lat|:,lon|:)
    ;>>>检查数据 CN051 unit: C wrf_cat unit K
    ; tm_wrf_step1_cat = tm_wrf_step1_cat -273.15
    ; tm_wrf_step2_cat = tm_wrf_step2_cat -273.15
    delete(tm_wrf_or)

;>>>预存作图数据 作图变量 cor_tm(WRF&cn05.1)
  path_out_step1 = "./practice/bc_data/temporary_data/bc_pre/ncl_to_r/tm_cat_CN051_RegCM_step1"+".nc"
  system("rm -f "+path_out_step1) ;删除目录下的同名文件
  ncdf_step1 = addfile(path_out_step1, "c") ; c表示创建netcdf文件
  ncdf_step1->tm_cn051_step1 = tm_CN051_step1_cat ;写入变量数值
  ncdf_step1->tm_wrf_step1   = tm_wrf_step1_cat
  delete(ncdf_step1)

  path_out_step2 = "./practice/bc_data/temporary_data/bc_pre/ncl_to_r/tm_cat_CN051_RegCM_step2"+".nc"
  system("rm -f "+path_out_step2) ;删除目录下的同名文件
  ncdf_step2 = addfile(path_out_step2, "c") ; c表示创建netcdf文件
  ncdf_step2->tm_cn051_step2 = tm_CN051_step2_cat ;写入变量数值
  ncdf_step2->tm_wrf_step2   = tm_wrf_step2_cat
  delete(ncdf_step2)

end