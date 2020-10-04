; 绘制BC结果和MOD结果与OBS相互比较的taylor图
; 前处理部分，先进行一些输出，stats统计函数的使用，之后再taylor中进行作图
; 3.16修改为RegCM的处理
; 3.18修改为pre的处理 WRF
; 3.19修改为处理CCLM,REGCM的脚本
;**********************************
load "./offical_sample_script/download/taylor_diagram.ncl"
load "./offical_sample_script/download/taylor_stats.ncl"
load "./offical_sample_script/download/taylor_metrics_table.ncl"
;**********************************
begin

;>>>-------------------------------------------------read CN05.1 data  

  f_tm_mod1_cat = addfile("./practice/bc_data/temporary_data/bc_pre/ncl_to_r/tm_cat_CN051_CCLM_step2"+".nc", "r")
    ; list_filevars(f_CN051_TM) 
    ; _cat为保存的作图时段(2000-2001)变量后缀
    tm_cn051_cat = f_tm_mod1_cat->$"tm_cn051_step2"$; 
    tm_wrf_cat = f_tm_mod1_cat->$"tm_wrf_step2"$
    tm_CN051_time = cd_calendar(tm_cn051_cat&time, 2)
    it_s=20000101  ;起始年月 1998(3287)
    it_e=20011231  ;结束年月
    rec_s = ind(it_s .eq. tm_CN051_time)      ;获取开始时间的记录号 4017(2000)
    rec_e = ind(it_e .eq. tm_CN051_time)      ;获取结束时间的记录号 4747(2001)
    ; 截取夏季 和 冬季 的结果


;>>>--------------------------------------------------bc的txt文件，R结果

;###################################BC文件位置的参数设置####################################
  ; bc_path = "./practice/bc_data/temporary_data/bc_tm/bc_step2_test.txt"
  bc_path = "./practice/bc_data/temporary_data/bc_pre/r_to_ncl/bc_step2_test_CCLM.txt"
;#########################################################################################

;bc_tm_r为改变维度后的bc结果
  bc_tm = asciiread(bc_path, (/731 ,163 , 283/), "float") ; 注意R的处理出来的数据，是坐标变化顺序和R是相反的
  bc_tm!0 = "time"
  bc_tm&time = tm_cn051_cat&time
  bc_tm!2 = "lon"
  bc_tm&lon = tm_cn051_cat&lon
  bc_tm!1 = "lat"
  bc_tm&lat = tm_cn051_cat&lat
  bc_tm_r = bc_tm(time|:,lat|:,lon|:)
  copy_VarAtts(tm_cn051_cat, bc_tm_r)
  bc_tm_r@_FillValue = -9999.
  
;>>>-------------------------------------------------计算BC的cor,prob,minus图

;只能对lat x lon 做检测的stats_res 选择做两年的平均?还是JJA和DJF
  tm_obs_ave = dim_avg_n(tm_cn051_cat, 0)
  bc_tm_ave = dim_avg_n(bc_tm_r, 0)
  tm_mod1_ave = dim_avg_n(tm_wrf_cat, 0)
  ; tm_mod2_ave = dim_avg_n(tm_, dims)
  stats_res_bc = taylor_stats(bc_tm_ave,tm_obs_ave,1.0,1)
  stats_res_mod1 = taylor_stats(tm_mod1_ave,tm_obs_ave,1.0,1)
  ; print(taylor_stats(bc_tm_ave,tm_obs_ave,1.0,1) - taylor_stats(tm_mod1_ave,tm_obs_ave,1.0,1))
  ; print(stats_res) ; 0-pattern_cor; 1-ratio; 2-bias (%); 3-tmean; 4-rmean; 5-tvar; 6-rvar; 7-rmse
;>>>--------------------------------------------------输出 stats结果
; 输出包含 stats_res_bc 作为mod1的统计分析结果 stats_res_mod1 作为mod的
  path_out = "./practice/bc_data/temporary_data/bc_pre/taylor/taylor_cclm_pre"+".nc"
  system("rm -f "+path_out) ;删除目录下的同名文件
  ncdf_out = addfile(path_out, "c") ; c表示创建netcdf文件
  ncdf_out->stats_bc = stats_res_bc ;写入变量数值
  ncdf_out->stats_mod = stats_res_mod1
  delete(ncdf_out)


end