;CN0.1_Tm_198901_200912_daily_025x025 和 WRF_TMEAN_daily_025x025 两个文件的读取处理脚本
;将空间系数cor和置信区间prob和平均误差minus_ave 保存到 tm_or_CN051_WRF 文件中
;3.13 将mod文件从wrf改为cclm
;注意变量名wrf指模式，CN051指观测
;3.16 +处理 RegCM_TMEAN_daily_025x025
;3.17 拷贝副本修改为处理pre的形式
;3.18 +针对日降水的变异系数计算(注意处理年纪变率，可能修改分段)
;     +降水minus修改为相对误差
;     +降水wet.day
;3.19 +修改为处理CCLM的PRE数据 CCLM_PRE_daily_025x025
begin
;>>>read CN05.1 data   
  f_CN051_PRE = addfile("./practice/bc_data/CN05.1_Pre_198901_200912_daily_025x025.nc", "r")
  f_WRF_PRE   = addfile("./practice/bc_data/RegCM_PRE_daily_025x025.nc","r")
  ; f_WRF_TM  = addfile("./practice/bc_data/CCLM_TMEAN_daily_025x025.nc","r")
  ;;;;;考虑读取两年的（20000101-20011231）记录号为（4017-4747）   数据过大不能一次性读入进变量
  ;>>>>05.1观测数据集,平均气温
    ; list_filevars(f_CN051_PRE)
    list_filevars(f_WRF_PRE) 
    pre_CN051_or = f_CN051_PRE->$"pre"$;CN05.1 tm [ time | 7670 ] x [ lat | 163 ] x [ lon | 283 ]
    ; pre_CN051_time = cd_calendar(pre_CN051_or&time, 2)
    ; it_s=20000601  ;起始年月
    ; it_e=20000831  ;结束年月
    ; rec_s = ind(it_s .eq. pre_CN051_time)      ;获取开始时间的记录号 4017
    ; rec_e = ind(it_e .eq. pre_CN051_time)      ;获取结束时间的记录号 4747
    ; print(rec_s)
    ; print(rec_e)
    pre_CN051_cat = pre_CN051_or(time|4017:4747,lat|:,lon|:) ;用记录号截取
    pre_CN051_cat_JJA = pre_CN051_or(time|4169:4260,lat|:,lon|:) ;用记录号截取
;     ; tm_CN051_cat = tm_CN051_or({time|341856:359376},lat|:,lon|:) ;用具体数据范围截取
    delete(pre_CN051_or)
  ;>>>>WRF模式，平均气温
    pre_wrf_or = f_WRF_PRE->$"PRE"$;TMEAN [ time | 7670 ] x [ lat | 163 ] x [ lon | 283 ]
    pre_wrf_cat = pre_wrf_or(time|4017:4747,lat|:,lon|:) ; 整理维度
    pre_wrf_cat_JJA = pre_wrf_or(time|4169:4260,lat|:,lon|:) ; 整理维度
    delete(pre_wrf_or)
  ;>>>检查数据 CN051 unit: C wrf_cat unit K
  ;>>>降水检查数据的时候将wet.day阈值设置为0.01mm
    pre_wrf_cat = where(pre_wrf_cat.lt.0.1, 0, pre_wrf_cat)
;>>>计算空间相关系数
  cor_pre = escorc_n(pre_wrf_cat, pre_CN051_cat, 0, 0)
  copy_VarMeta(pre_wrf_cat(0,:,:),cor_pre)
  ; copy_VarMeta(pre_wrf_cat(0,:,:),prob_pre)
  ; write_matrix(prob_pre, "15F10.6", False)
;>>>计算标准差，变异系数(两年太长，不可靠，考虑年际变率再使用)(除 0 解决)
  ; cv_mod = dim_stddev_n(pre_wrf_cat_JJA,0)/dim_avg_n(pre_wrf_cat_JJA, 0)
  cv_obs = dim_stddev_n(pre_CN051_cat_JJA,0)/dim_avg_n(pre_CN051_cat_JJA, 0)
  ; copy_VarMeta(pre_wrf_cat(0,:,:),cv_mod)
  copy_VarMeta(pre_wrf_cat(0,:,:),cv_obs)
  ;---------------------------------------------------------缺失值检测(用where进行检测)
  ; obs_tm_good = where(.not.ismissing(tm_CN051_cat), 1, 0)
  ; obs_tm_good_sum = dim_sum_n(obs_tm_good, 0)
  ; printVarSummary(obs_tm_good_sum)
  ; write_matrix(obs_tm_good_sum, "15I7", False)
  ;-------------------------------------------------OBS中的缺失值都是 完全缺失；时间序列不缺失就是整齐的
;>>>计算相对误差 
  minus = abs(pre_wrf_cat - pre_CN051_cat)
  minus_ave_rel = dim_avg_n(minus, 0)/dim_avg_n(pre_CN051_cat, 0) ; 绝对误差
  minus_ave_abs = dim_avg_n(minus, 0)                             ; 相对误差
  ; printMinMax(minus_ave,1)
  copy_VarMeta(pre_wrf_cat(0,:,:), minus_ave_abs)
  copy_VarMeta(pre_wrf_cat(0,:,:), minus_ave_rel)
  ; printVarSummary(minus_ave)
; ;>>>预存作图数据 作图变量 cor_tm(WRF&cn05.1)
; 注意
; 输出直接复用tm的变量名，路径上有差异！
  path_out = "./practice/bc_data/temporary_data/bc_pre/tm_or_CN051_RegCM"+".nc"
  system("rm -f "+path_out) ;删除目录下的同名文件
  ncdf = addfile(path_out, "c") ; c表示创建netcdf文件
  ncdf->cor_tm_WRF_CN051 = cor_pre ;写入变量数值
  ncdf->minus_ave_rel = minus_ave_rel
  ncdf->minus_ave_abs = minus_ave_abs
  ncdf->cv_obs = cv_obs
  ; ncdf->cv_mod = cv_mod
  delete(ncdf)
; ;>>>绘图：画空间相关系数

end
              