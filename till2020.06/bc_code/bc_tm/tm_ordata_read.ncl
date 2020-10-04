;CN0.1_Tm_198901_200912_daily_025x025 和 WRF_TMEAN_daily_025x025 两个文件的读取处理脚本
;将空间系数cor和置信区间prob和平均误差minus_ave 保存到 tm_or_CN051_WRF 文件中
;3.13 将mod文件从wrf改为cclm
;注意变量名wrf指模式，CN051指观测
;3.16 添加处理 RegCM_TMEAN_daily_025x025
;3.31 修改为计算RMSE的部分
begin
;>>>read CN05.1 data
modname = "WRF"   
  f_CN051_TM = addfile("./practice/bc_data/CN05.1_Tm_198901_200912_daily_025x025.nc", "r")
  f_WRF_TM   = addfile("./practice/bc_data/"+modname+"_TMEAN_daily_025x025.nc","r")
  ; f_WRF_TM  = addfile("./practice/bc_data/CCLM_TMEAN_daily_025x025.nc","r")
  ;;;;;考虑读取两年的（20000101-20011231）记录号为（4017-4747）   数据过大不能一次性读入进变量
  ;>>>>05.1观测数据集,平均气温
    ; list_filevars(f_CCLM_TM) 
    tm_CN051_or = f_CN051_TM->$"tm"$;CN05.1 tm [ time | 7670 ] x [ lat | 163 ] x [ lon | 283 ]
    ; printVarSummary(tm_CN051&time) ; 调用变量的time坐标 19890101-20091231 逐日数据
    ; tm_CN051_time = cd_calendar(tm_CN051&time, 2)
    ; it_s=20000101  ;起始年月
    ; it_e=20011231  ;结束年月
    ; rec_s = ind(it_s .eq. tm_CN051_time)      ;获取开始时间的记录号 4017
    ; rec_e = ind(it_e .eq. tm_CN051_time)      ;获取结束时间的记录号 4747
    ; print(rec_s)
    ; print(rec_e)
    tm_CN051_cat = tm_CN051_or(time|4017:4747,lat|:,lon|:) ;用记录号截取
    ; tm_CN051_cat = tm_CN051_or({time|341856:359376},lat|:,lon|:) ;用具体数据范围截取
    delete(tm_CN051_or)
  ;>>>>WRF模式，平均气温
    ; list_filevars(f_WRF_TM) 
    tm_wrf_or = f_WRF_TM->$"TMEAN"$;TMEAN [ time | 7670 ] x [ lat | 163 ] x [ lon | 283 ]
    tm_wrf_cat = tm_wrf_or(time|4017:4747,lat|:,lon|:) 
    delete(tm_wrf_or)
  ;>>>检查数据 CN051 unit: C wrf_cat unit K
  ;#################################################################################
  if(modname.eq."WRF")
    tm_wrf_cat = tm_wrf_cat -273.15
  end if
  ;#################################################################################
;>>>计算空间相关系数

  cor_tm = escorc_n(tm_wrf_cat, tm_CN051_cat, 0, 0)
  prob_tm = rtest(cor_tm, 731, 0)
  copy_VarMeta(tm_wrf_cat(0,:,:),cor_tm)
  copy_VarMeta(tm_wrf_cat(0,:,:),prob_tm)
  ; write_matrix(prob_tm, "15F10.6", False)
  ;---------------------------------------------------------缺失值检测(用where进行检测)
  ; obs_tm_good = where(.not.ismissing(tm_CN051_cat), 1, 0)
  ; obs_tm_good_sum = dim_sum_n(obs_tm_good, 0)
  ; printVarSummary(obs_tm_good_sum)
  ; write_matrix(obs_tm_good_sum, "15I7", False)
  ;-------------------------------------------------OBS中的缺失值都是 完全缺失；时间序列不缺失就是整齐的
;>>>计算离差
  minus = tm_wrf_cat - tm_CN051_cat
  ; printVarSummary(minus)
  minus = abs(minus)
    ; printMinMax(minus,1)
  minus_ave = dim_avg_n(minus, 0)
  copy_VarMeta(tm_wrf_cat(0,:,:),minus_ave)
  rmse = dim_rmsd_n(tm_wrf_cat, tm_CN051_cat, 0) ; 时间上做rmse，得空间图  
  copy_VarMeta(tm_wrf_cat(0,:,:),minus_ave)
  ; copy_VarMeta(tm_cn051_needed(0,:,:),cor_tm_bc)
  ; copy_VarMeta(tm_cn051_needed(0,:,:),prob_tm_bc)
  copy_VarMeta(tm_wrf_cat(0,:,:),rmse)
  printVarSummary(rmse)
  printMinMax(rmse, 1)
  ; printVarSummary(minus_ave)
;>>>预存作图数据 作图变量 cor_tm(WRF&cn05.1)
  path_out = "./practice/bc_data/temporary_data/bc_tm/tm_or_CN051_"+modname+"_02"+".nc"
  system("rm -f "+path_out) ;删除目录下的同名文件
  ncdf = addfile(path_out, "c") ; c表示创建netcdf文件
  ; ncdf->cor_tm_WRF_CN051 = cor_tm ;写入变量数值
  ; ncdf->prob = prob_tm
  ncdf->minus_ave_tm_WRF_CN051 = minus_ave
  ncdf->rmse = rmse
  delete(ncdf)
;>>>绘图：画空间相关系数

end
              